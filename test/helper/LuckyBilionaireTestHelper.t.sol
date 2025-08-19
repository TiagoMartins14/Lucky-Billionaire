// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LuckyBilionaire} from "src/LuckyBilionaire.sol";

contract LuckyBilionaireTestHelper is LuckyBilionaire {
    uint8 public constant EXPOSED_HOUSE_COMISSION = 5; // 5%
    uint8 public EXPOSED_MINIMUM_LUCKY_NUMBER = 1;
    uint8 public EXPOSED_MAXIMUM_LUCKY_NUMBER = 50;

    constructor(address _vrfCoordinator, bytes32 _keyHash, uint256 _subId)
        LuckyBilionaire(_vrfCoordinator, _keyHash, _subId)
    {}

    function exposedRequestRandomNumber() external returns (uint256 _requestId) {
        return requestRandomNumber();
    }

    function exposedFulfillRandomWords(uint256 /*_requestId*/, uint256[] calldata _randomWords) external {
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

    function exposedAnnounceLuckyNumber() external {
        announceLuckyNumber();
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
}

