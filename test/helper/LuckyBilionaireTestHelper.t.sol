// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LuckyBilionaire} from "src/LuckyBilionaire.sol";

contract LuckyBilionaireTestHelper is LuckyBilionaire {
    uint256 public constant EXPOSED_HOUSE_COMISSION = 5; // 5%
    uint256 public constant EXPOSED_MINIMUM_LUCKY_NUMBER = 1;
    uint256 public constant EXPOSED_MAXIMUM_LUCKY_NUMBER = 50;
    uint256 public constant EXPOSED_VAULT_CUT = (BET_COST * EXPOSED_HOUSE_COMISSION) / 100;

    uint256 public s_exposedVault;

    constructor(address _vrfCoordinator, bytes32 _keyHash, uint256 _subId)
        LuckyBilionaire(_vrfCoordinator, _keyHash, _subId)
    {}

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/
    function getVault() external view returns (uint256) {
        return s_vault;
    }

    /*//////////////////////////////////////////////////////////////
                           EXPOSED FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function exposedRequestRandomNumber() external returns (uint256 _requestId) {
        return requestRandomNumber();
    }

    function exposedFulfillRandomWords(uint256, /*_requestId*/ uint256[] calldata _randomWords) external {
        fulfillRandomWords(0, _randomWords);
    }

    function exposedTimesTheLuckyNumberWasGuessed() external view returns (uint256 numberOfFirstPrizeWinners) {
        return timesTheLuckyNumberWasGuessed();
    }

    function exposedTimesTheLuckyNumberWasAlmostGuessed() external view returns (uint256 numberOfSecondPrizeWinners) {
        return timesTheLuckyNumberWasAlmostGuessed();
    }

    function exposedDistributeFirstPrize() external {
        distributeFirstPrize();
    }

    function exposedDistributeSecondPrize() external {
        distributeSecondPrize();
    }

    function exposedCalculateNewRoundInitialPot() external {
        calculateNewRoundInitialPot();
    }

    function exposedRetreiveUnclaimedPrizes() external {
        retreiveUnclaimedPrizes();
    }

    function exposedUpdateStateVariablesFornewRound() external {
        updateStateVariablesFornewRound();
    }

    function exposedAdistributePrizes() external {
        distributePrizes();
    }

    function exposedStartNewRoundCleanUp() external {
        startNewRoundCleanUp();
    }

    function exposedPauseLuckyBilionaire() external {
        pauseLuckyBilionaire();
    }

    function exposedResumeLuckyBilionaire() external {
        resumeLuckyBilionaire();
    }

    /*//////////////////////////////////////////////////////////////
                                SETTERS
    //////////////////////////////////////////////////////////////*/
    function setRound(uint256 _round) external {
        s_round = _round;
    }

    function setLuckyNumber(uint256 _round, uint256 _luckyNumber) external {
        s_luckyNumber[_round] = _luckyNumber;
    }
}
