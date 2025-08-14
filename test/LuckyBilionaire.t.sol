// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LuckyBilionaire} from "src/LuckyBilionaire.sol";
import {Test} from "forge-std/Test.sol";
import {VRFCoordinatorV2_5MockTest} from "@chainlink/v0.8/vrf/test/VRFCoordinatorV2_5Mock.t.sol";

contract LuckyBilionaireTest is Test {
    LuckyBilionaire private luckyBilionaire;
    VRFCoordinatorV2_5MockTest private vrfCoordinator;

    bytes32 private keyHash;
    uint256 private subId;

    function setUp() public {
        vrfCoordinator = new VRFCoordinatorV2_5MockTest();
        keyHash = bytes32(vm.envUint("KEY_HASH"));
        subId = vm.envUint("SUB_ID");

        luckyBilionaire = new LuckyBilionaire(address(vrfCoordinator), keyHash, subId);
    }
}
