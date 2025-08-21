// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {LuckyBilionaireTestHelper} from "test/helper/LuckyBilionaireTestHelper.t.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/v0.8/vrf/test/VRFCoordinatorV2_5Mock.t.sol";

contract LuckyBilionaireTest is Test {
    VRFCoordinatorV2_5Mock private vrfCoordinator;
    LuckyBilionaireTestHelper private luckyBilionaire;
    bytes32 private constant KEY_HASH = bytes32(uint256(123456));
    uint256 private subId;

    function setUp() public {
        vrfCoordinator = new VRFCoordinatorV2_5Mock(0.002 ether, 40 gwei, 0.004 ether);// Same params Chainlink uses in its tests
        subId = vrfCoordinator.createSubscription();
        luckyBilionaire = new LuckyBilionaireTestHelper(address(vrfCoordinator), KEY_HASH, subId);

        vrfCoordinator.fundSubscription(subId, 10000 ether);
        vrfCoordinator.addConsumer(subId, address(luckyBilionaire));
    }

    function testRequestRandomNUmber() public {
        for (uint256 i = 0; i < 1000; i++) {
            uint256 reqId = luckyBilionaire.exposedRequestRandomNumber();

            vrfCoordinator.fulfillRandomWords(reqId, address(luckyBilionaire));

            uint256 round = luckyBilionaire.s_round();
            uint256 num = luckyBilionaire.s_luckyNumber(round);

            assertGt(num, 0);
            assertLe(num, luckyBilionaire.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        }
    }

    function testSavingGuess(uint256 guess) public {
        guess = bound(guess, luckyBilionaire.EXPOSED_MINIMUM_LUCKY_NUMBER(), luckyBilionaire.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = luckyBilionaire.s_round();
        address player = makeAddr("player");
        vm.deal(player, 1 ether);
        vm.prank(player);
        luckyBilionaire.savePlayerGuess{value: 1 ether}(guess);

        assertEq(luckyBilionaire.s_playersByNumberGuess(round, guess, 0), player);
    }
}


