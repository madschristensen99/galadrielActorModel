// constants.js

// Contract ABI (replace with your actual ABI)
const CONTRACT_ABI = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "initialOracleAddress",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "chatId",
				"type": "uint256"
			}
		],
		"name": "ChatCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOracleAddress",
				"type": "address"
			}
		],
		"name": "OracleAddressUpdated",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "ACTOR_LIMIT",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "MESSAGE_LIMIT",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "actorCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "actors",
		"outputs": [
			{
				"internalType": "string",
				"name": "system",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "context",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "agentLimit",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "messageLimit",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "message",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "runId",
				"type": "uint256"
			}
		],
		"name": "addMessage",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "chatRuns",
		"outputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "messagesCount",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "system",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "initialContext",
				"type": "string"
			}
		],
		"name": "createActor",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "getActorIdFromRunId",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "actorId",
				"type": "uint256"
			}
		],
		"name": "getActorInfo",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "system",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "context",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "agentLimit",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "messageLimit",
						"type": "uint256"
					},
					{
						"internalType": "uint256[]",
						"name": "chatIds",
						"type": "uint256[]"
					}
				],
				"internalType": "struct AnthropicChatGpt.Actor",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllActorInfo",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "system",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "context",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "agentLimit",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "messageLimit",
						"type": "uint256"
					},
					{
						"internalType": "uint256[]",
						"name": "chatIds",
						"type": "uint256[]"
					}
				],
				"internalType": "struct AnthropicChatGpt.Actor[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "chatId",
				"type": "uint256"
			}
		],
		"name": "getMessageHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "role",
						"type": "string"
					},
					{
						"components": [
							{
								"internalType": "string",
								"name": "contentType",
								"type": "string"
							},
							{
								"internalType": "string",
								"name": "value",
								"type": "string"
							}
						],
						"internalType": "struct IOracle.Content[]",
						"name": "content",
						"type": "tuple[]"
					}
				],
				"internalType": "struct IOracle.Message[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "initialization",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "knowledgeBase",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "actorId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "message",
				"type": "string"
			}
		],
		"name": "messageAgent",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "runId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "response",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "errorMessage",
				"type": "string"
			}
		],
		"name": "onOracleFunctionResponse",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "runId",
				"type": "uint256"
			},
			{
				"internalType": "string[]",
				"name": "documents",
				"type": "string[]"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"name": "onOracleKnowledgeBaseQueryResponse",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "runId",
				"type": "uint256"
			},
			{
				"components": [
					{
						"internalType": "string",
						"name": "id",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "content",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "functionName",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "functionArguments",
						"type": "string"
					},
					{
						"internalType": "uint64",
						"name": "created",
						"type": "uint64"
					},
					{
						"internalType": "string",
						"name": "model",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "systemFingerprint",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "object",
						"type": "string"
					},
					{
						"internalType": "uint32",
						"name": "completionTokens",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "promptTokens",
						"type": "uint32"
					},
					{
						"internalType": "uint32",
						"name": "totalTokens",
						"type": "uint32"
					}
				],
				"internalType": "struct IOracle.LlmResponse",
				"name": "response",
				"type": "tuple"
			},
			{
				"internalType": "string",
				"name": "errorMessage",
				"type": "string"
			}
		],
		"name": "onOracleLlmResponse",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "oracleAddress",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOracleAddress",
				"type": "address"
			}
		],
		"name": "setOracleAddress",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "message",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "delimiter",
				"type": "string"
			}
		],
		"name": "splitMessage",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "message",
				"type": "string"
			}
		],
		"name": "startChat",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "s",
				"type": "string"
			}
		],
		"name": "stringToUint",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "toolRunning",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_i",
				"type": "uint256"
			}
		],
		"name": "uintToString",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
];

// Contract address (replace with your actual deployed contract address)
const CONTRACT_ADDRESS = "0xB03b0e572239424eA6e91F8eAb85C15f216597ED";
