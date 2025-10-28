// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

interface ILuckyBillionaire {
    function withdrawAll() external;
    function owner() external view returns (address);
    function getRound() external view returns (uint256);
}

contract WithdrawAllScript is Script {
    function run() external {
        vm.startBroadcast();

        ILuckyBillionaire lucky = ILuckyBillionaire(vm.envAddress("CONTRACT_ADDRESS"));

        lucky.withdrawAll();

        vm.stopBroadcast();
    }
}
