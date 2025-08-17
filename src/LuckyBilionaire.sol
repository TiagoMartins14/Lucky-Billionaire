
// Order of Layout
// Contract elements should be laid out in the following order:

// Pragma statements
// Import statements
// Events
// Errors
// Interfaces
// Libraries
// Contracts

// Inside each contract, library or interface, use the following order:

// Type declarations
// State variables
// Events
// Errors
// Modifiers
// Functions

// Order of Functions

// Constructor
// Receive function (if exists)
// Falback function (if exists)
// External
// Public
// Internal
// Private
// view & pure functions


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2_5} from "@chainlink/v0.8/vrf/dev/VRFCoordinatorV2_5.sol";
import {VRFV2PlusClient} from "@chainlink/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

contract LuckyBilionaire is VRFConsumerBaseV2Plus {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
	error LuckyBilionaire__GuessOutOfRange();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
	// uint8 private constant HOUSE_EARNINGS_PERCENTAGE = 5; // 5%
	uint8 private constant FIRST_WIN_PERCENTAGE = 80; // 80%
	uint8 private constant SECOND_WIN_PERCENTAGE = 15; // 15%
	uint8 private MINIMUM_LUCKY_NUMBER = 1;
	uint8 private MAXIMUM_LUCKY_NUMBER = 50;
	uint256 private constant BET_COST = 1 ether;
	uint16 private constant REQUEST_CONFIRMATIONS = 100;
	uint32 private constant CALLBACK_GAS_LIMIT = 150000;
	uint32 private constant NUM_WORDS = 1;

	mapping(uint256 number => address[] player) public s_playersByNumberGuess;
	mapping(uint256 number => mapping(address player => uint256 timesGuessed)) public s_numberGuesses;
	uint256 private s_vault;
	uint256 public s_totalPot;
	uint256 public s_firstPrize;
	uint256 public s_secondPrize;
	uint256 public s_lastLuckyNumber;
	uint256 private s_luckyNumber;
	bytes32 private immutable s_keyHash;
	uint256 private immutable s_subId;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
	constructor (address vrfCoordinator, bytes32 keyHash, uint256 subId) VRFConsumerBaseV2Plus(vrfCoordinator) {
		s_vrfCoordinator = VRFCoordinatorV2_5(vrfCoordinator);
		s_keyHash = keyHash;
		s_subId = subId;
	}

	function updateFirstPrize () private {
		s_firstPrize += ((BET_COST * FIRST_WIN_PERCENTAGE) / 100);
	}

	function updateSecondPrize () private {
		s_secondPrize += ((BET_COST * SECOND_WIN_PERCENTAGE) / 100);
	}

	function savePlayerGuess(uint256 _guess) public {
		if (_guess < MINIMUM_LUCKY_NUMBER || _guess > MAXIMUM_LUCKY_NUMBER) {
			revert LuckyBilionaire__GuessOutOfRange();
		}

		s_totalPot += 1 ether;

		if (s_numberGuesses[_guess][msg.sender] == 0) {
			s_playersByNumberGuess[_guess].push(msg.sender);
		}

		s_numberGuesses[_guess][msg.sender] += 1;		
	}

	/**
	 * @notice Requests a new set of random numbers from Chainlink VRF v2.5.
	 * @dev The returned request ID can be used to track the fulfillment via 'fulfillRandomWords'.
	 * @dev Payment is done in LINK, not native token.
	 * @return _requestId The unique identifier for this VRF request.
	 */
	function requestRandomNumber() internal returns (uint256 _requestId) {
		VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
			keyHash: s_keyHash,
			subId: s_subId,
			requestConfirmations: REQUEST_CONFIRMATIONS,
			callbackGasLimit: CALLBACK_GAS_LIMIT,
			numWords: NUM_WORDS,
			extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({
				nativePayment: false
			}))		
		});
		
		_requestId = s_vrfCoordinator.requestRandomWords(req);
	}

	/**
	 * @notice Callback function called by the Chainlink VRF Coordinator after the random number request is fulfilled.
	 * @dev This function overrides 'VRFConsumerBaseV2Plus.fulfillRandomWords'. It receives the random words array,
	 *      takes the first element, and maps it into a number between 1 and 50 (inclusive) for 's_luckyNumber'.
	 *      The '_requestId' parameter is unused but required to match the VRF callback signature.
	 * @param _randomWords The array of random numbers returned by the VRF Coordinator.
	 */
	function fulfillRandomWords(uint256 /*_requestId*/, uint256[] calldata _randomWords) internal override {
		uint256 rawRandom = _randomWords[0];
		s_luckyNumber = (rawRandom % MAXIMUM_LUCKY_NUMBER) + 1;
	}

	/**
	 * @notice Calculates the amount of times the lucky number was guessed
	 */
	function calculateSizeOfFirstPrizeWinners() private view returns (uint256 numberOfFirstPrizeWinners) {
		numberOfFirstPrizeWinners = 0;
		address[] memory firstPrizeWinners = s_playersByNumberGuess[s_luckyNumber];
		
		for (uint8 i = 0; i < firstPrizeWinners.length; i++) {
			numberOfFirstPrizeWinners += s_numberGuesses[s_luckyNumber][firstPrizeWinners[i]];
		}
	}
	
	/**
	 * @notice Calculates the amount of times either the number right before or after the lucky number was guessed
	 * @dev If the lucky number is on the lower or upper limit, the second prize loops around.
	 * @dev Example: Lucky number = 50; Second prize numbers = 49 and 1.
	 */
	function calculateSizeOfSecondPrizeWinners() private view returns (uint256 numberOfSecondPrizeWinners) {
		numberOfSecondPrizeWinners = 0;
		uint256 beforeLuckyNumber;
		uint256 afterLuckyNumber;

		if (s_luckyNumber == MINIMUM_LUCKY_NUMBER) {
			beforeLuckyNumber = MAXIMUM_LUCKY_NUMBER;
		} else {
			beforeLuckyNumber = s_luckyNumber - 1;
		}

		if (s_luckyNumber == MAXIMUM_LUCKY_NUMBER) {
			afterLuckyNumber = MINIMUM_LUCKY_NUMBER;
		} else {
			afterLuckyNumber = s_luckyNumber + 1;
		}

		address[] memory secondPrizeWinnersBeforeNumber = s_playersByNumberGuess[beforeLuckyNumber];
		address[] memory secondPrizeWinnersAfterNumber = s_playersByNumberGuess[afterLuckyNumber];

		for (uint8 i = 0; i < secondPrizeWinnersBeforeNumber.length; i++) {
			numberOfSecondPrizeWinners += s_numberGuesses[beforeLuckyNumber][secondPrizeWinnersBeforeNumber[i]];
		}

		for (uint8 i = 0; i < secondPrizeWinnersAfterNumber.length; i++) {
			numberOfSecondPrizeWinners += s_numberGuesses[afterLuckyNumber][secondPrizeWinnersAfterNumber[i]];
		}
	}

	/**
	 * @notice Calculates the first prize amount based on the total pot and the number of winners.
	 * @dev The first prize is 80% of the total pot.
	 * @return _firstPrize The calculated first prize amount.
	 */
	function calcuteFirstPrize() private view returns (uint256 _firstPrize) {
		_firstPrize = (s_totalPot * 80) / 100;
	}

	/**
	 * @notice Calculates the second prize amount based on the total pot.
	 * @dev The second prize is 15% of the total pot.
	 * @return _secondPrize The calculated second prize amount.
	 */
	function calculateSecondPrize() private view returns (uint256 _secondPrize) {
		_secondPrize = (s_totalPot * 15) / 100;
	}

	/**
	 * @notice 
	 */
	function distributeFirstPrize() private {
		uint256 firstPrizeParcel = calculateSizeOfFirstPrizeWinners();
		require(firstPrizeParcel > 0, "No first prize winners");
		uint256 firstPrizePot = calcuteFirstPrize();
		uint256 numberOfFirstPrizeWinners = 0;
		address[] memory firstPrizeWinners = s_playersByNumberGuess[s_luckyNumber];

		for (uint8 i = 0; i < firstPrizeWinners.length; i++) {
			numberOfFirstPrizeWinners += s_numberGuesses[s_luckyNumber][firstPrizeWinners[i]];
		}
	}

	function distributeSecondPrize() private {}

	function acumulatePotsPrize() private {}

	function startNewRound() private {}

	function distributePrizesAndStartNewRound() external {}


}