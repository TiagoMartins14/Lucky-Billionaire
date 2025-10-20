export const abi = [
		{
			"type": "constructor",
			"inputs": [
				{
					"name": "vrfCoordinator",
					"type": "address",
					"internalType": "address"
				},
				{
					"name": "keyHash",
					"type": "bytes32",
					"internalType": "bytes32"
				},
				{
					"name": "subId",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "BET_COST",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "FIRST_WIN_PERCENTAGE",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "SECOND_WIN_PERCENTAGE",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "StartNewRound",
			"inputs": [],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "acceptOwnership",
			"inputs": [],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "claimPrize",
			"inputs": [],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "getFirstPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getLastFirstPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getLastSecondPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getLuckyNumber",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getNumberGuesses",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "number",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "player",
					"type": "address",
					"internalType": "address"
				}
			],
			"outputs": [
				{
					"name": "timesGuessed",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getPendingWithdrawals",
			"inputs": [
				{
					"name": "player",
					"type": "address",
					"internalType": "address"
				}
			],
			"outputs": [
				{
					"name": "prizes",
					"type": "tuple[]",
					"internalType": "struct LuckyBillionaire.prize[]",
					"components": [
						{
							"name": "amountWon",
							"type": "uint256",
							"internalType": "uint256"
						},
						{
							"name": "dateWon",
							"type": "uint256",
							"internalType": "uint256"
						}
					]
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getPlayersByNumberGuess",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "number",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [
				{
					"name": "players",
					"type": "address[]",
					"internalType": "address[]"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getRound",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getSecondPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "getTotalPot",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "owner",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "address",
					"internalType": "address"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "paused",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "bool",
					"internalType": "bool"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "rawFulfillRandomWords",
			"inputs": [
				{
					"name": "requestId",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "randomWords",
					"type": "uint256[]",
					"internalType": "uint256[]"
				}
			],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "s_firstPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_lastFirstPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_lastSecondPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_luckyNumber",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [
				{
					"name": "number",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_numberGuesses",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "number",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "player",
					"type": "address",
					"internalType": "address"
				}
			],
			"outputs": [
				{
					"name": "timesGuessed",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_pendingWithdrawals",
			"inputs": [
				{
					"name": "player",
					"type": "address",
					"internalType": "address"
				},
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [
				{
					"name": "amountWon",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "dateWon",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_playersByNumberGuess",
			"inputs": [
				{
					"name": "round",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "number",
					"type": "uint256",
					"internalType": "uint256"
				},
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [
				{
					"name": "player",
					"type": "address",
					"internalType": "address"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_round",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_secondPrize",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_totalPot",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "s_vrfCoordinator",
			"inputs": [],
			"outputs": [
				{
					"name": "",
					"type": "address",
					"internalType": "contract IVRFCoordinatorV2Plus"
				}
			],
			"stateMutability": "view"
		},
		{
			"type": "function",
			"name": "savePlayerGuess",
			"inputs": [
				{
					"name": "_guess",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [],
			"stateMutability": "payable"
		},
		{
			"type": "function",
			"name": "setCoordinator",
			"inputs": [
				{
					"name": "_vrfCoordinator",
					"type": "address",
					"internalType": "address"
				}
			],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "transferOwnership",
			"inputs": [
				{
					"name": "to",
					"type": "address",
					"internalType": "address"
				}
			],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "function",
			"name": "withdraw",
			"inputs": [
				{
					"name": "_amount",
					"type": "uint256",
					"internalType": "uint256"
				}
			],
			"outputs": [],
			"stateMutability": "nonpayable"
		},
		{
			"type": "event",
			"name": "AnnounceLuckyNumber",
			"inputs": [
				{
					"name": "luckyNumber",
					"type": "uint256",
					"indexed": true,
					"internalType": "uint256"
				},
				{
					"name": "round",
					"type": "uint256",
					"indexed": true,
					"internalType": "uint256"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "CoordinatorSet",
			"inputs": [
				{
					"name": "vrfCoordinator",
					"type": "address",
					"indexed": false,
					"internalType": "address"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "MoneyWithdrawn",
			"inputs": [
				{
					"name": "owner",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				},
				{
					"name": "amount",
					"type": "uint256",
					"indexed": false,
					"internalType": "uint256"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "OwnershipTransferRequested",
			"inputs": [
				{
					"name": "from",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				},
				{
					"name": "to",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "OwnershipTransferred",
			"inputs": [
				{
					"name": "from",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				},
				{
					"name": "to",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "Paused",
			"inputs": [
				{
					"name": "account",
					"type": "address",
					"indexed": false,
					"internalType": "address"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "PlayerGuessed",
			"inputs": [
				{
					"name": "player",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				},
				{
					"name": "guess",
					"type": "uint256",
					"indexed": true,
					"internalType": "uint256"
				},
				{
					"name": "round",
					"type": "uint256",
					"indexed": true,
					"internalType": "uint256"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "PrizeClaimed",
			"inputs": [
				{
					"name": "player",
					"type": "address",
					"indexed": true,
					"internalType": "address"
				},
				{
					"name": "amount",
					"type": "uint256",
					"indexed": false,
					"internalType": "uint256"
				}
			],
			"anonymous": false
		},
		{
			"type": "event",
			"name": "Unpaused",
			"inputs": [
				{
					"name": "account",
					"type": "address",
					"indexed": false,
					"internalType": "address"
				}
			],
			"anonymous": false
		},
		{
			"type": "error",
			"name": "LuckyBillionaire__GuessOutOfRange",
			"inputs": []
		},
		{
			"type": "error",
			"name": "LuckyBillionaire__IncorrectPaymentValue",
			"inputs": []
		},
		{
			"type": "error",
			"name": "LuckyBillionaire__NeedsToBeMoreThanZero",
			"inputs": []
		},
		{
			"type": "error",
			"name": "LuckyBillionaire__NoFundsToWithdraw",
			"inputs": []
		},
		{
			"type": "error",
			"name": "LuckyBillionaire__TransferFailed",
			"inputs": []
		},
		{
			"type": "error",
			"name": "OnlyCoordinatorCanFulfill",
			"inputs": [
				{
					"name": "have",
					"type": "address",
					"internalType": "address"
				},
				{
					"name": "want",
					"type": "address",
					"internalType": "address"
				}
			]
		},
		{
			"type": "error",
			"name": "OnlyOwnerOrCoordinator",
			"inputs": [
				{
					"name": "have",
					"type": "address",
					"internalType": "address"
				},
				{
					"name": "owner",
					"type": "address",
					"internalType": "address"
				},
				{
					"name": "coordinator",
					"type": "address",
					"internalType": "address"
				}
			]
		},
		{
			"type": "error",
			"name": "ZeroAddress",
			"inputs": []
		}
	] as const