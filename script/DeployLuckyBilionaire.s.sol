// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {LuckyBilionaire} from "src/LuckyBilionaire.sol";

contract DeployLuckyBilionaire is Script {
	function run() external {
		address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
		bytes32 keyHash = vm.envBytes32("KEY_HASH");
		uint256 subId = vm.envUint("SUBSCRIPTION_ID");

		vm.startBroadcast();
		new LuckyBilionaire(vrfCoordinator, keyHash, subId);
		vm.stopBroadcast();
	}
}