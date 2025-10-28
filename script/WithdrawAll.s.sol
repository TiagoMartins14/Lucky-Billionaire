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
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(pk);
        vm.startBroadcast(pk);

        ILuckyBillionaire lucky = ILuckyBillionaire(vm.envAddress("CONTRACT_ADDRESS"));

        console.log("Contract owner:", lucky.owner());
        console.log("Calling from:", caller);

        require(lucky.owner() == caller, "You are not the owner!");

        lucky.withdrawAll();

        vm.stopBroadcast();
    }
}
