// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {LuckyBilionaireTestHelper} from "test/helper/LuckyBilionaireTestHelper.t.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/v0.8/vrf/test/VRFCoordinatorV2_5Mock.t.sol";

contract LuckyBilionaireTest is Test {
    VRFCoordinatorV2_5Mock private vrfCoordinator;
    LuckyBilionaireTestHelper private lucky;
    bytes32 private constant KEY_HASH = bytes32(uint256(123456));
    uint256 private subId;

    function setUp() public {
        vrfCoordinator = new VRFCoordinatorV2_5Mock(0.002 ether, 40 gwei, 0.004 ether); // Same params Chainlink uses in its tests
        subId = vrfCoordinator.createSubscription();
        lucky = new LuckyBilionaireTestHelper(address(vrfCoordinator), KEY_HASH, subId);

        vrfCoordinator.fundSubscription(subId, 10000 ether);
        vrfCoordinator.addConsumer(subId, address(lucky));
    }

    function testRequestRandomNUmber() public {
        for (uint256 i = 0; i < 1000; i++) {
            uint256 reqId = lucky.exposedRequestRandomNumber();

            vrfCoordinator.fulfillRandomWords(reqId, address(lucky));

            uint256 round = lucky.s_round();
            uint256 num = lucky.s_luckyNumber(round);

            assertGt(num, 0);
            assertLe(num, lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        }
    }

    function testSavingGuess(uint256 _guess) public {
        _guess = bound(_guess, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address player = makeAddr("player");
        vm.deal(player, 1 ether);
        vm.prank(player);
        lucky.savePlayerGuess{value: 1 ether}(_guess);

        assertEq(lucky.s_playersByNumberGuess(round, _guess, 0), player);
    }

    function testTimesTheLuckyNumberWasGuessed(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.prank(player1);
        lucky.savePlayerGuess{value: 1 ether}(_luckyNumber);
        vm.prank(player2);
        lucky.savePlayerGuess{value: 1 ether}(_luckyNumber);
        uint256 timesGuessed = lucky.exposedTimesTheLuckyNumberWasGuessed();

        assertEq(timesGuessed, 2);
    }

    function testTimesTheLuckyNumberWasAlmostGuessed(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 beforeLuckyNumber;
        uint256 afterLuckyNumber;

        if (_luckyNumber == lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()) {
            beforeLuckyNumber = lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER();
        } else {
            beforeLuckyNumber = _luckyNumber - 1;
        }

        if (_luckyNumber == lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()) {
            afterLuckyNumber = lucky.EXPOSED_MINIMUM_LUCKY_NUMBER();
        } else {
            afterLuckyNumber = _luckyNumber + 1;
        }

        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.prank(player1);
        lucky.savePlayerGuess{value: 1 ether}(beforeLuckyNumber);
        vm.prank(player2);
        lucky.savePlayerGuess{value: 1 ether}(afterLuckyNumber);
        uint256 timesAlmostGuessed = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();

        assertEq(timesAlmostGuessed, 2);
    }

    function testDistributeFirstPrize(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");

        vm.deal(player1, lucky.BET_COST());
        vm.deal(player2, lucky.BET_COST());
        vm.startPrank(player1);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(_luckyNumber);
        vm.stopPrank();
        vm.startPrank(player2);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(_luckyNumber);
        vm.stopPrank();
        lucky.setFirstPrize((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * 2 * lucky.FIRST_WIN_PERCENTAGE() / 100);
        lucky.exposedDistributeFirstPrize();

        (uint256 firstPlayerPrize,) = lucky.s_pendingWithdrawals(player1, 0);
        (uint256 secondPlayerPrize,) = lucky.s_pendingWithdrawals(player2, 0);
        uint256 prizeShare = ((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * lucky.FIRST_WIN_PERCENTAGE() / 100);

        assertEq(firstPlayerPrize, prizeShare);
        assertEq(secondPlayerPrize, prizeShare);
    }

    function testDistributeSecondPrize(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        address player1 = makeAddr("player1");
        address player2 = makeAddr("player2");
        uint256 beforeLuckyNumber;
        uint256 afterLuckyNumber;

        if (_luckyNumber == lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()) {
            beforeLuckyNumber = lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER();
        } else {
            beforeLuckyNumber = _luckyNumber - 1;
        }

        if (_luckyNumber == lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()) {
            afterLuckyNumber = lucky.EXPOSED_MINIMUM_LUCKY_NUMBER();
        } else {
            afterLuckyNumber = _luckyNumber + 1;
        }

        vm.deal(player1, lucky.BET_COST());
        vm.deal(player2, lucky.BET_COST());
        vm.startPrank(player1);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(beforeLuckyNumber);
        vm.stopPrank();
        vm.startPrank(player2);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(afterLuckyNumber);
        vm.stopPrank();
        lucky.setSecondPrize((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * 2 * lucky.SECOND_WIN_PERCENTAGE() / 100);
        lucky.exposedDistributeSecondPrize();
        
        (uint256 firstPlayerPrize,) = lucky.s_pendingWithdrawals(player1, 0);
        (uint256 secondPlayerPrize,) = lucky.s_pendingWithdrawals(player2, 0);
        uint256 prizeShare = ((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * lucky.SECOND_WIN_PERCENTAGE() / 100);

        assertEq(firstPlayerPrize, prizeShare);
        assertEq(secondPlayerPrize, prizeShare);
    }
}
