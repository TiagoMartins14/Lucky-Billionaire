// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

interface ILuckyBillionaire {
    function startNewRound() external;
    function owner() external view returns (address);
    function getRound() external view returns (uint256);
}

contract StartNewRoundScript is Script {
    function run() external {
        vm.startBroadcast();

        ILuckyBillionaire lucky = ILuckyBillionaire(vm.envAddress("CONTRACT_ADDRESS"));

        uint256 roundBefore = lucky.getRound();
        console.log("Round before:", roundBefore);

        lucky.startNewRound();

        uint256 roundAfter = lucky.getRound();
        console.log("Round after:", roundAfter);

        vm.stopBroadcast();
    }
}
