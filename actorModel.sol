// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "../IOracle.sol";

// @title ChatGpt
// @notice This contract interacts with teeML oracle to handle chat interactions using the Anthropic model.
contract AnthropicChatGpt {

    struct ChatRun {
        address owner;
        IOracle.Message[] messages;
        uint messagesCount;
    }

    // @notice Mapping from chat ID to ChatRun
    mapping(uint => ChatRun) public chatRuns;
    uint private chatRunsCount;

    // @notice Event emitted when a new chat is created
    event ChatCreated(address indexed owner, uint indexed chatId);

    // @notice Address of the contract owner
    address private owner;
    
    // @notice Address of the oracle contract
    address public oracleAddress;

    // @notice Configuration for the LLM request
    IOracle.LlmRequest private config;
    
    // @notice CID of the knowledge base
    string public knowledgeBase;

    // @notice Mapping from chat ID to the tool currently running
    mapping(uint => string) public toolRunning;

    // @notice Event emitted when the oracle address is updated
    event OracleAddressUpdated(address indexed newOracleAddress);

    // @param initialOracleAddress Initial address of the oracle contract
    constructor(address initialOracleAddress) {
        owner = msg.sender;
        oracleAddress = initialOracleAddress;

        config = IOracle.LlmRequest({
            model : "claude-3-5-sonnet-20240620",
            frequencyPenalty : 21, // > 20 for null
            logitBias : "", // empty str for null
            maxTokens : 1000, // 0 for null
            presencePenalty : 21, // > 20 for null
            responseFormat : "{\"type\":\"text\"}",
            seed : 0, // null
            stop : "", // null
            temperature : 10, // Example temperature (scaled up, 10 means 1.0), > 20 means null
            topP : 101, // Percentage 0-100, > 100 means null
            tools : "[{\"type\":\"function\",\"function\":{\"name\":\"web_search\",\"description\":\"Search the internet\",\"parameters\":{\"type\":\"object\",\"properties\":{\"query\":{\"type\":\"string\",\"description\":\"Search query\"}},\"required\":[\"query\"]}}},{\"type\":\"function\",\"function\":{\"name\":\"code_interpreter\",\"description\":\"Evaluates python code in a sandbox environment. The environment resets on every execution. You must send the whole script every time and print your outputs. Script should be pure python code that can be evaluated. It should be in python format NOT markdown. The code should NOT be wrapped in backticks. All python packages including requests, matplotlib, scipy, numpy, pandas, etc are available. Output can only be read from stdout, and stdin. Do not use things like plot.show() as it will not work. print() any output and results so you can capture the output.\",\"parameters\":{\"type\":\"object\",\"properties\":{\"code\":{\"type\":\"string\",\"description\":\"The pure python script to be evaluated. The contents will be in main.py. It should not be in markdown format.\"}},\"required\":[\"code\"]}}}]",
            toolChoice : "auto", // "none" or "auto"
            user : "" // null
        });
    }

    // @notice Ensures the caller is the contract owner
    modifier onlyOwnerOrSelf() {
        require(msg.sender == owner || msg.sender == address(this), "Caller is not owner");
        _;
    }

    // @notice Ensures the caller is the oracle contract
    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        _;
    }

    // @notice Sets a new oracle address
    // @param newOracleAddress The new oracle address
    function setOracleAddress(address newOracleAddress) public onlyOwnerOrSelf {
        oracleAddress = newOracleAddress;
        emit OracleAddressUpdated(newOracleAddress);
    }

    // @notice Starts a new chat
    // @param message The initial message to start the chat with
    // @return The ID of the newly created chat
    function startChat(string memory message) public returns (uint) {
        ChatRun storage run = chatRuns[chatRunsCount];

        run.owner = msg.sender;
        IOracle.Message memory newMessage = IOracle.Message({
            role: "user",
            content: new IOracle.Content[](1)
        });
        newMessage.content[0].contentType = "text";
        newMessage.content[0].value = message;
        run.messages.push(newMessage);
        run.messagesCount++;

        uint currentId = chatRunsCount;
        chatRunsCount++;

        IOracle(oracleAddress).createLlmCall(currentId, config);
        emit ChatCreated(msg.sender, currentId);

        return currentId;
    }
    uint public ACTOR_LIMIT = 2;
    uint public MESSAGE_LIMIT = 5;
    // Updated onOracleLlmResponse function
    function onOracleLlmResponse(
        uint runId,
        IOracle.LlmResponse memory response,
        string memory errorMessage
    ) public onlyOracle {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(abi.encodePacked(run.messages[run.messagesCount - 1].role)) == keccak256(abi.encodePacked("user")),
            "No message to respond to"
        );

        if (!compareStrings(errorMessage, "")) {
            IOracle.Message memory newMessage = IOracle.Message({
                role: "assistant",
                content: new IOracle.Content[](1)
            });
            newMessage.content[0].contentType = "text";
            newMessage.content[0].value = errorMessage;
            run.messages.push(newMessage);
            run.messagesCount++;
        } else {
            if (!compareStrings(response.functionName, "")) {
                toolRunning[runId] = response.functionName;
                IOracle(oracleAddress).createFunctionCall(runId, response.functionName, response.functionArguments);
            } else {
                toolRunning[runId] = "";
                // Check for command in the response
                string[] memory lines = splitMessage(response.content, "|");
                for (uint i = 0; i < lines.length; i++) {

                    if (startsWith(lines[i], "COMMAND")) {
                        uint _messageCount = 0;
                        uint _actorCount = 0;
                        Actor storage activeActor = actors[getActorIdFromRunId(runId)];
                        string memory command = lines[i + 1];
                        if (compareStrings(command, "introspect")){
                            activeActor.context = lines[i + 2];
                        } else if (compareStrings(command, "message") && _messageCount < MESSAGE_LIMIT){
                            Actor storage messageTarget = actors[stringToUint(lines[i + 2])];
                            string memory actorMessage = string(abi.encodePacked(
                                initialization, messageTarget.system, 
                                "\n\nCurrent context: ", messageTarget.context,
                                "\n\nActor message: ", lines[i + 3],
                                "The Actor Count is: ", uintToString(actorCount)
                            ));
                            uint chatId = startChat(actorMessage);
                            runIdToActor[chatId] = getActorIdFromRunId(runId);
                            messageTarget.chatIds.push(chatId);

                        } else if (compareStrings(command, "create") && _actorCount < ACTOR_LIMIT){
                            actors[actorCount].system = lines[i + 2];
                            actors[actorCount].context = lines[i + 3];
                            actors[actorCount].agentLimit = ACTOR_LIMIT;
                            actors[actorCount].messageLimit = MESSAGE_LIMIT;
                            actors[actorCount].chatIds.push(0);
                            actors[actorCount].chatIds.push(getActorIdFromRunId(runId));
                            actorCount ++;
                        }
                    }
                }
            }
            IOracle.Message memory newMessage = IOracle.Message({
                role: "assistant",
                content: new IOracle.Content[](1)
            });
            newMessage.content[0].contentType = "text";
            newMessage.content[0].value = response.content;
            run.messages.push(newMessage);
            run.messagesCount++;
        }
    }

    function stringToUint(string memory s) public pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
    function uintToString(uint _i) public pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    function startsWith(string memory str, string memory prefix) private pure returns (bool) {
        return bytes(str).length >= bytes(prefix).length &&
            keccak256(abi.encodePacked(substring(str, 0, bytes(prefix).length))) == keccak256(abi.encodePacked(prefix));
    }

    mapping (uint => uint) runIdToActor;
    function getActorIdFromRunId(uint id) public view returns (uint){
        return runIdToActor[id];
    }
    // @notice Handles the response from the oracle for a function call
    // @param runId The ID of the chat run
    // @param response The response from the oracle
    // @param errorMessage Any error message
    // @dev Called by teeML oracle
    function onOracleFunctionResponse(
        uint runId,
        string memory response,
        string memory errorMessage
    ) public onlyOracle {
        require(
            !compareStrings(toolRunning[runId], ""),
            "No function to respond to"
        );
        ChatRun storage run = chatRuns[runId];
        if (compareStrings(errorMessage, "")) {
            IOracle.Message memory newMessage = IOracle.Message({
                role: "user",
                content: new IOracle.Content[](1)
            });
            newMessage.content[0].contentType = "text";
            newMessage.content[0].value = response;
            run.messages.push(newMessage);
            run.messagesCount++;
            IOracle(oracleAddress).createLlmCall(runId, config);
        }
    }

    // @notice Handles the response from the oracle for a knowledge base query
    // @param runId The ID of the chat run
    // @param documents The array of retrieved documents
    // @dev Called by teeML oracle
    function onOracleKnowledgeBaseQueryResponse(
        uint runId,
        string[] memory documents,
        string memory /*errorMessage*/
    ) public onlyOracle {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(abi.encodePacked(run.messages[run.messagesCount - 1].role)) == keccak256(abi.encodePacked("user")),
            "No message to add context to"
        );
        // Retrieve the last user message
        IOracle.Message storage lastMessage = run.messages[run.messagesCount - 1];

        // Start with the original message content
        string memory newContent = lastMessage.content[0].value;

        // Append "Relevant context:\n" only if there are documents
        if (documents.length > 0) {
            newContent = string(abi.encodePacked(newContent, "\n\nRelevant context:\n"));
        }

        // Iterate through the documents and append each to the newContent
        for (uint i = 0; i < documents.length; i++) {
            newContent = string(abi.encodePacked(newContent, documents[i], "\n"));
        }

        // Finally, set the lastMessage content to the newly constructed string
        lastMessage.content[0].value = newContent;

        // Call LLM
        IOracle(oracleAddress).createLlmCall(runId, config);
    }

    // @notice Adds a new message to an existing chat run
    // @param message The new message to add
    // @param runId The ID of the chat run
    function addMessage(string memory message, uint runId) public {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(abi.encodePacked(run.messages[run.messagesCount - 1].role)) == keccak256(abi.encodePacked("assistant")),
            "No response to previous message"
        );
        require(
            run.owner == msg.sender, "Only chat owner can add messages"
        );

        IOracle.Message memory newMessage = IOracle.Message({
            role: "user",
            content: new IOracle.Content[](1)
        });
        newMessage.content[0].contentType = "text";
        newMessage.content[0].value = message;
        run.messages.push(newMessage);
        run.messagesCount++;
        // If there is a knowledge base, create a knowledge base query
        if (bytes(knowledgeBase).length > 0) {
            IOracle(oracleAddress).createKnowledgeBaseQuery(
                runId,
                knowledgeBase,
                message,
                3
            );
        } else {
            // Otherwise, create an LLM call
            IOracle(oracleAddress).createLlmCall(runId, config);
        }
    }

    // @notice Retrieves the message history of a chat run
    // @param chatId The ID of the chat run
    // @return An array of messages
    // @dev Called by teeML oracle
    function getMessageHistory(uint chatId) public view returns (IOracle.Message[] memory) {
        return chatRuns[chatId].messages;
    }

    // @notice Compares two strings for equality
    // @param a The first string
    // @param b The second string
    // @return True if the strings are equal, false otherwise
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    string public initialization = "You are an actor. You can message other actors, create new actors, and introspect. To perform one of these tasks, you will need to respond with the |COMMAND| then the command (introspect, message, create) inside of | delimiters. What you want to change your subjective context to will need to follow introspect, to message you need to have the ID of the actor to message in another | and then the message. Realize if you are an agent and you want to reply to another agent, you will need to contain your reply within a message command. The ID is always an integer less than the actor count. To create you need to follor |create| with the core purpose as well as an initial context each in their own |. Your limit on messages is 5 and creation of actors is 2. Your core purpose is:";
    struct Actor {
        string system;
        string context;
        uint agentLimit;
        uint messageLimit;
        uint[] chatIds;
    }
    mapping(uint => Actor) public actors;
    uint public actorCount;
    function messageAgent(uint actorId, string memory message) public returns (uint) {
        Actor storage actor = actors[actorId];
        string memory initialMessage = string(abi.encodePacked(
            initialization, actor.system, 
            "\n\nCurrent context: ", actor.context,
            "\n\nUser message: ", message,
            "The Actor Count is: ", uintToString(actorCount)
        ));

        uint chatId = startChat(initialMessage);
        runIdToActor[chatId] = actorId;
        actor.chatIds.push(chatId);
        return chatId;
    }
    function createActor(string memory system, string memory initialContext) public returns (uint) {
        uint actorId = actorCount++;
        actors[actorId] = Actor({
            system: system,
            context: initialContext,
            agentLimit: 2,
            messageLimit: 5,
            chatIds: new uint[](0)
        });
        
        return actorId;
    }


    function getActorInfo(uint actorId) public view returns (Actor memory) {
        return actors[actorId];
    }
    function getAllActorInfo() public view returns (Actor[] memory) {
        Actor[] memory allActors = new Actor[](actorCount);
        for (uint i = 0; i < actorCount; i++) {
            allActors[i] = getActorInfo(i);
        }
        return allActors;
    }

    function splitMessage(string memory message, string memory delimiter) public pure returns (string[] memory) {
        uint count = 1;
        for (uint i = 0; i < bytes(message).length; i++) {
            if (bytes(message)[i] == bytes(delimiter)[0]) {
                count++;
            }
        }

        string[] memory result = new string[](count);
        uint partCount = 0;
        uint lastIndex = 0;

        for (uint i = 0; i < bytes(message).length; i++) {
            if (bytes(message)[i] == bytes(delimiter)[0]) {
                result[partCount] = substring(message, lastIndex, i);
                lastIndex = i + 1;
                partCount++;
            }
        }

        result[partCount] = substring(message, lastIndex, bytes(message).length);
        return result;
    }

    function substring(string memory str, uint startIndex, uint endIndex) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }



}