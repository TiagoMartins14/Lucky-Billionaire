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
import {ConfirmedOwner} from "@chainlink/v0.8/shared/access/ConfirmedOwner.sol";
import {ReentrancyGuard} from "@openzeppelin/security/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/security/Pausable.sol";

contract LuckyBilionaire is VRFConsumerBaseV2Plus, ReentrancyGuard, Pausable {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint8 private constant HOUSE_COMISSION = 5; // 5%
    uint8 public constant FIRST_WIN_PERCENTAGE = 80; // 80%
    uint8 public constant SECOND_WIN_PERCENTAGE = 20; // 15%
    uint256 public constant BET_COST = 1 ether;
    uint8 private MINIMUM_LUCKY_NUMBER = 1;
    uint8 private MAXIMUM_LUCKY_NUMBER = 50;
    uint16 private constant REQUEST_CONFIRMATIONS = 100;
    uint32 private constant CALLBACK_GAS_LIMIT = 150000;
    uint32 private constant NUM_WORDS = 1;

    struct prize {
        uint256 amountWon;
        uint256 dateWon;
    }

    mapping(uint256 round => mapping(uint256 number => address[] player)) public s_playersByNumberGuess;
    mapping(uint256 round => mapping(uint256 number => mapping(address player => uint256 timesGuessed))) public
        s_numberGuesses;
    mapping(uint256 round => uint256 number) public s_luckyNumber;
    mapping(address player => prize[] prizes) public s_pendingWithdrawals;
    uint256 public s_round;
    uint256 public s_totalPot;
    uint256 public s_firstPrize; // s_totalPot * FIRST_WIN_PERCENTAGE / 100
    uint256 public s_secondPrize; // s_totalPot * SECOND_WIN_PERCENTAGE / 100
    uint256 public s_lastLuckyNumber;
    uint256 public s_lastFirstPrize;
    uint256 public s_lastSecondPrize;
    uint256 private s_vault;
    bytes32 private immutable s_keyHash;
    uint256 private immutable s_subId;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error LuckyBilionaire__GuessOutOfRange();
    error LuckyBilionaire__NoFundsToWithdraw();
    error LuckyBilionaire_TransferFailed();
    error LuckyBilionaire__IncorrectPaymentValue();
    error LuckyBilionaire__NeedsToBeMoreThanZero();

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(address vrfCoordinator, bytes32 keyHash, uint256 subId) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_vrfCoordinator = VRFCoordinatorV2_5(vrfCoordinator);
        s_keyHash = keyHash;
        s_subId = subId;
        s_round = 0;
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Saves the player's guess and updates the total prize pot.
     * @notice Each bet costs BET_COST.
     * @param _guess The player's guess. A number within MINIMUM_LUCKY_NUMBER and MAXIMUM_LUCKY_NUMBER.
     */
    function savePlayerGuess(uint256 _guess) external payable whenNotPaused {
        if (msg.value != 1 ether) {
            revert LuckyBilionaire__IncorrectPaymentValue();
        }

        if (_guess < MINIMUM_LUCKY_NUMBER || _guess > MAXIMUM_LUCKY_NUMBER) {
            revert LuckyBilionaire__GuessOutOfRange();
        }

        s_vault += (BET_COST * HOUSE_COMISSION) / 100;
        s_totalPot += BET_COST - s_vault;

        if (s_numberGuesses[s_round][_guess][msg.sender] == 0) {
            s_playersByNumberGuess[s_round][_guess].push(msg.sender);
        }

        s_numberGuesses[s_round][_guess][msg.sender] += 1;
    }

    /**
     * @notice Announces a Lucky Number, distributes prizes and starts a new round.
     * @notice Lucky Billionaire is paused between the announcement and the start of a new round.
     */
    function StartNewRound() external onlyOwner {
        pauseLuckyBilionaire();
        announceLuckyNumber();
        startNewRoundCleanUp();
        resumeLuckyBilionaire();
    }

    /**
     * @notice Allows players to claim any prizes they've won within the last 28 days.
     * @notice After 28 days the prize is redeemed as uncollected and reverts as house earnings.
     */
    function claimPrize() external nonReentrant {
        uint256 amount = 0;
        prize[] storage playerPrizes = s_pendingWithdrawals[msg.sender];

        for (uint256 i = 0; i < playerPrizes.length; i++) {
            if (block.timestamp - playerPrizes[i].dateWon <= 28 days) {
                amount += playerPrizes[i].amountWon;
                playerPrizes[i] = playerPrizes[playerPrizes.length - 1];
                playerPrizes.pop();
            }
        }
        if (amount == 0) {
            revert LuckyBilionaire__NoFundsToWithdraw();
        }

        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) {
            revert LuckyBilionaire_TransferFailed();
        }
    }

    /**
     * @notice Withdraw funds from the contract.
     */
    function withdraw(uint256 _amount) external onlyOwner {
        if (_amount <= 0) {
            revert LuckyBilionaire__NeedsToBeMoreThanZero();
        }

        if (_amount > s_vault) {
            revert LuckyBilionaire__NoFundsToWithdraw();
        }

        (bool success,) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert LuckyBilionaire_TransferFailed();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/
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
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
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
        s_luckyNumber[s_round] = (rawRandom % MAXIMUM_LUCKY_NUMBER) + 1;
    }

    /**
     * @notice Calculates the amount of times the lucky number was guessed
     */
    function timesTheLuckyNumberWasGuessed() internal view returns (uint256 numberOfFirstPrizeWinners) {
        numberOfFirstPrizeWinners = 0;
        address[] memory firstPrizeWinners = s_playersByNumberGuess[s_round][s_luckyNumber[s_round]];

        for (uint8 i = 0; i < firstPrizeWinners.length; i++) {
            numberOfFirstPrizeWinners += s_numberGuesses[s_round][s_luckyNumber[s_round]][firstPrizeWinners[i]];
        }
    }

    /**
     * @notice Calculates the amount of times either the number right before or after the lucky number was guessed
     * @dev If the lucky number is on the lower or upper limit, the second prize loops around.
     * @dev Example: Lucky number = 50; Second prize numbers = 49 and 1.
     */
    function timesTheLuckyNumberWasAlmostGuessed() internal view returns (uint256 numberOfSecondPrizeWinners) {
        numberOfSecondPrizeWinners = 0;
        uint256 beforeLuckyNumber;
        uint256 afterLuckyNumber;

        if (s_luckyNumber[s_round] == MINIMUM_LUCKY_NUMBER) {
            beforeLuckyNumber = MAXIMUM_LUCKY_NUMBER;
        } else {
            beforeLuckyNumber = s_luckyNumber[s_round] - 1;
        }

        if (s_luckyNumber[s_round] == MAXIMUM_LUCKY_NUMBER) {
            afterLuckyNumber = MINIMUM_LUCKY_NUMBER;
        } else {
            afterLuckyNumber = s_luckyNumber[s_round] + 1;
        }

        address[] memory secondPrizeWinnersBeforeNumber = s_playersByNumberGuess[s_round][beforeLuckyNumber];
        address[] memory secondPrizeWinnersAfterNumber = s_playersByNumberGuess[s_round][afterLuckyNumber];

        for (uint8 i = 0; i < secondPrizeWinnersBeforeNumber.length; i++) {
            numberOfSecondPrizeWinners += s_numberGuesses[s_round][beforeLuckyNumber][secondPrizeWinnersBeforeNumber[i]];
        }

        for (uint8 i = 0; i < secondPrizeWinnersAfterNumber.length; i++) {
            numberOfSecondPrizeWinners += s_numberGuesses[s_round][afterLuckyNumber][secondPrizeWinnersAfterNumber[i]];
        }
    }

    /**
     * @notice Distributes the prizes to the winners so they're available for withdrawall.
     */
    function distributeFirstPrize() internal {
        uint256 overallCorrectLuckyNumberGuesses = timesTheLuckyNumberWasGuessed();
        require(overallCorrectLuckyNumberGuesses > 0, "No first prize winners");
        uint256 individualPrizeParcel = s_firstPrize / overallCorrectLuckyNumberGuesses;
        address[] memory firstPrizeWinners = s_playersByNumberGuess[s_round][s_luckyNumber[s_round]];

        for (uint8 i = 0; i < firstPrizeWinners.length; i++) {
            uint256 timesGuessed = s_numberGuesses[s_round][s_luckyNumber[s_round]][firstPrizeWinners[i]];
            prize memory winnerPrize;
            winnerPrize.amountWon = individualPrizeParcel * timesGuessed;
            winnerPrize.dateWon = block.timestamp;
            s_pendingWithdrawals[firstPrizeWinners[i]].push(winnerPrize);
        }
    }

    /**
     * @notice Distributes the prizes to the second winners so they're available for withdrawall.
     */
    function distributeSecondPrize() internal {
        uint256 overallAlmosLuckyNumberGuesses = timesTheLuckyNumberWasAlmostGuessed();
        require(overallAlmosLuckyNumberGuesses > 0, "No second prize winners");
        uint256 individualPrizeParcel = s_secondPrize / overallAlmosLuckyNumberGuesses;
        address[] memory secondPrizeWinners = s_playersByNumberGuess[s_round][s_luckyNumber[s_round]];

        for (uint8 i = 0; i < secondPrizeWinners.length; i++) {
            uint256 timesGuessed = s_numberGuesses[s_round][s_luckyNumber[s_round]][secondPrizeWinners[i]];
            prize memory winnerPrize;
            winnerPrize.amountWon = individualPrizeParcel * timesGuessed;
            winnerPrize.dateWon = block.timestamp;
            s_pendingWithdrawals[secondPrizeWinners[i]].push(winnerPrize);
        }
    }

    /**
     * @notice Calculates new round's initial pot depending on last week's winners.
     * @notice In case of no winner and/or no second winner, the correspondent prize rolls to the new round.
     */
    function calculateNewRoundInitialPot() internal {
        uint256 winnersShare = s_totalPot * FIRST_WIN_PERCENTAGE / 100;
        uint256 secondWinnersShare = s_totalPot * SECOND_WIN_PERCENTAGE / 100;
        uint256 beforeLuckyNumber;
        uint256 afterLuckyNumber;

        if (s_luckyNumber[s_round] == MINIMUM_LUCKY_NUMBER) {
            beforeLuckyNumber = MAXIMUM_LUCKY_NUMBER;
        } else {
            beforeLuckyNumber = s_luckyNumber[s_round] - 1;
        }

        if (s_luckyNumber[s_round] == MAXIMUM_LUCKY_NUMBER) {
            afterLuckyNumber = MINIMUM_LUCKY_NUMBER;
        } else {
            afterLuckyNumber = s_luckyNumber[s_round] + 1;
        }

        if (
            s_playersByNumberGuess[s_round][s_luckyNumber[s_round]].length > 0
                && (
                    s_playersByNumberGuess[s_round][beforeLuckyNumber].length > 0
                        || s_playersByNumberGuess[s_round][afterLuckyNumber].length > 0
                )
        ) {
            s_totalPot = 0;
        } else if (
            s_playersByNumberGuess[s_round][s_luckyNumber[s_round]].length > 0
                && s_playersByNumberGuess[s_round][beforeLuckyNumber].length == 0
                && s_playersByNumberGuess[s_round][afterLuckyNumber].length == 0
        ) {
            s_totalPot = secondWinnersShare;
        } else if (
            s_playersByNumberGuess[s_round][s_luckyNumber[s_round]].length == 0
                && (
                    s_playersByNumberGuess[s_round][beforeLuckyNumber].length > 0
                        || s_playersByNumberGuess[s_round][afterLuckyNumber].length > 0
                )
        ) {
            s_totalPot = winnersShare;
        }
    }

    /**
     * @notice Retreives unclaimed prizes.
     * @dev Prizes are deemed unclaimed if not withdrawn within 28 days.
     */
    function retreiveUnclaimedPrizes() internal {
        if (s_round > 4) {
            for (uint8 i = 4; i > 0; i--) {
                uint256 round = s_round - i;
                uint256 luckyNumber = s_luckyNumber[round];
                for (uint256 j = 0; j < s_playersByNumberGuess[round][luckyNumber].length; j++) {
                    prize[] storage playerPrizes = s_pendingWithdrawals[s_playersByNumberGuess[round][luckyNumber][j]];
                    if (block.timestamp - playerPrizes[i].dateWon > 28 days) {
                        s_vault += playerPrizes[i].amountWon;
                        playerPrizes[i] = playerPrizes[playerPrizes.length - 1];
                        playerPrizes.pop();
                    }
                }
            }
        }
    }

    /**
     * @notice Updates states variables for new round.
     */
    function updateStateVariablesFornewRound() internal {
        s_round++;
        s_lastFirstPrize = s_firstPrize;
        s_lastSecondPrize = s_secondPrize;
        s_firstPrize = s_totalPot * FIRST_WIN_PERCENTAGE / 100;
        s_secondPrize = s_totalPot * SECOND_WIN_PERCENTAGE / 100;
    }

    /**
     * @notice Requests a random number from VRF Chainlink and then distributes prizes accordingly.
     */
    function announceLuckyNumber() internal {
        requestRandomNumber();
        distributeFirstPrize();
        distributeSecondPrize();
    }

    /**
     * @notice Retreives any unclaimed prizes within the last 28 days.
     * @notice Calculates new round's initial pot depending on last round's result.
     * @notice Updates the relevant state variables for new round.
     */
    function startNewRoundCleanUp() internal {
        retreiveUnclaimedPrizes();
        calculateNewRoundInitialPot();
        updateStateVariablesFornewRound();
    }

    /**
     * @notice Sets the status of pause to true.
     */
    function pauseLuckyBilionaire() internal {
        _pause();
    }

    /**
     * @notice Sets the status of pause to false.
     */
    function resumeLuckyBilionaire() internal {
        _unpause();
    }
}
