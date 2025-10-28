// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LuckyBillionaire} from "src/LuckyBillionaire.sol";

contract LuckyBillionaireTestHelper is LuckyBillionaire {
    uint256 public constant EXPOSED_HOUSE_COMISSION = 5; // 5%
    uint256 public constant EXPOSED_MINIMUM_LUCKY_NUMBER = 1;
    uint256 public constant EXPOSED_MAXIMUM_LUCKY_NUMBER = 50;
    uint256 public constant EXPOSED_VAULT_CUT = (BET_COST * EXPOSED_HOUSE_COMISSION) / 100;

    uint256 public s_exposedVault;

    constructor(address _vrfCoordinator, bytes32 _keyHash, uint256 _subId)
        LuckyBillionaire(_vrfCoordinator, _keyHash, _subId)
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

    function exposedStartNewRoundCleanUp() external {
        startNewRoundCleanUp();
    }

    function exposedPauseLuckyBillionaire() external {
        pauseLuckyBillionaire();
    }

    function exposedResumeLuckyBillionaire() external {
        resumeLuckyBillionaire();
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

    function setVault(uint256 _amount) external {
        s_vault = _amount;
    }
}
