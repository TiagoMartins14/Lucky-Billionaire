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

        vrfCoordinator.fundSubscription(subId, 2 ether);
        vrfCoordinator.addConsumer(subId, address(luckyBilionaire));
    }

    function test_RequestAndFulfill() public {
        // Call the exposed internal that requests randomness
        uint256 reqId = luckyBilionaire.exposedRequestRandomNumber();

        // Let the mock coordinator call back into your contract
        vrfCoordinator.fulfillRandomWords(reqId, address(luckyBilionaire));

        uint256 round = luckyBilionaire.s_round();
        uint256 num = luckyBilionaire.s_luckyNumber(round);
        assertGt(num, 0);
        assertLe(num, luckyBilionaire.EXPOSED_MAXIMUM_LUCKY_NUMBER());
    }

    function testRequestRandomNUmber() public {
        luckyBilionaire.exposedRequestRandomNumber();
        assertGt(luckyBilionaire.s_luckyNumber[luckyBilionaire.s_round], 0, "Lucky number should be greater than zero");
        assertLt(luckyBilionaire.s_luckyNumber[luckyBilionaire.s_round], 51, "Lucky number should be lower than 51");
    }
}


