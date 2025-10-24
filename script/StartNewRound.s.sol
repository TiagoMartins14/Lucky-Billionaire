// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";

interface ILuckyBillionaire {
    function StartNewRound() external;
    function owner() external view returns (address);
    function getRound() external view returns (uint256);
}

contract StartNewRoundScript is Script {
    function run() external {
        // Load your private key from environment
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(pk);
        vm.startBroadcast(pk);

        // 🪙 Replace this with your actual deployed contract address
        ILuckyBillionaire lucky = ILuckyBillionaire(vm.envAddress("CONTRACT_ADDRESS"));

        console.log("Contract owner:", lucky.owner());
        console.log("Calling from:", caller);

        require(lucky.owner() == caller, "You are not the owner!");

        uint256 roundBefore = lucky.getRound();
        console.log("Round before:", roundBefore);

        // 🧩 Call onlyOwner function
        lucky.StartNewRound();

        uint256 roundAfter = lucky.getRound();
        console.log("Round after:", roundAfter);

        vm.stopBroadcast();
    }
}
