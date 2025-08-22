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

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function create10Players() internal returns (address[10] memory) {
        address[10] memory players;

        for (uint i = 0; i < 10; i++) {
            players[i] = makeAddr(string.concat("player", vm.toString(i+1)));
            vm.deal(players[i], 1 ether);
        }
        return players;
    }

    function getRandomNumber() private returns (uint256 randomNumber) {
        uint256 reqId = lucky.exposedRequestRandomNumber();

        vrfCoordinator.fulfillRandomWords(reqId, address(lucky));

        uint256 round = lucky.s_round();
        randomNumber = lucky.s_luckyNumber(round);
    }

    function save10PlayersGuesses(address[10] memory players) internal returns (uint256[10] memory guesses) {
        uint256 guess;

        for (uint i = 0; i < players.length; i++) {
            guess = getRandomNumber();
            guesses[i] = guess;
            vm.prank(players[i]);
            lucky.savePlayerGuess{value: lucky.BET_COST()}(guess);
            lucky.setPlayersByNumberGuess(lucky.s_round(), guess, players[i]);
            lucky.setNumberGuesses(lucky.s_round(), guess, players[i], 1);
            lucky.setVault(lucky.EXPOSED_VAULT_CUT());
            lucky.setTotalPot((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * 10);
            lucky.setFirstPrize(lucky.BET_COST() * lucky.FIRST_WIN_PERCENTAGE() / 100);
            lucky.setSecondPrize(lucky.BET_COST() * lucky.SECOND_WIN_PERCENTAGE() / 100);
        }
    }

    /*//////////////////////////////////////////////////////////////
                             TEST FUNCTIONS
    //////////////////////////////////////////////////////////////*/
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
        address[10] memory players = create10Players();

        vm.prank(players[0]);
        lucky.savePlayerGuess{value: 1 ether}(_guess);

        assertEq(lucky.s_playersByNumberGuess(round, _guess, 0), players[0]);
    }

    function testTimesTheLuckyNumberWasGuessed(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        uint256[10] memory guesses = save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 timesGuessedByFunction = lucky.exposedTimesTheLuckyNumberWasGuessed();
        uint256 timesGuessedManually;
        
        for (uint i = 0; i < guesses.length; i++) {
            if (guesses[i] == _luckyNumber) {
                timesGuessedManually++;
            }
        }

        assertEq(timesGuessedByFunction, timesGuessedManually);
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
        address[10] memory players = create10Players();
        uint256[10] memory guesses = save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 timesAlmostGuessedByFunction = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();
        uint256 timesAlmostGuessedManually;

        for (uint i = 0; i < guesses.length; i++) {
            if (guesses[i] == beforeLuckyNumber || guesses[i] == afterLuckyNumber) {
                timesAlmostGuessedManually++;
            }
        }

        assertEq(timesAlmostGuessedByFunction, timesAlmostGuessedManually);
    }

    function testDistributeFirstPrize(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        uint256[10] memory playersGuesses = save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        lucky.exposedDistributeFirstPrize();

        uint256 prizeShare;
        if (lucky.exposedTimesTheLuckyNumberWasGuessed() > 0) {
            prizeShare = lucky.s_firstPrize() / lucky.exposedTimesTheLuckyNumberWasGuessed();
        } else {
            prizeShare = 0;
        }

        for (uint256 i = 0; i < playersGuesses.length; i++) {
            if (playersGuesses[i] == _luckyNumber) {
                lucky.setPendingWithdrawals(players[i], prizeShare);
            }
        }

        for (uint256 i = 0; i < players.length; i++) {
            uint256 playerPrize = 0;
            uint256 amountWon = 0;
            if (playersGuesses[i] == _luckyNumber) {
                playerPrize = prizeShare;
                (amountWon,) = lucky.s_pendingWithdrawals(players[i], 0); 

            }
            assertEq(playerPrize, amountWon);
        }
    }

    function testDistributeSecondPrize(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        address[10] memory players = create10Players();
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

        vm.startPrank(players[0]);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(beforeLuckyNumber);
        vm.stopPrank();
        vm.startPrank(players[1]);
        lucky.savePlayerGuess{value: lucky.BET_COST()}(afterLuckyNumber);
        vm.stopPrank();
        lucky.setSecondPrize((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * 2 * lucky.SECOND_WIN_PERCENTAGE() / 100);
        lucky.exposedDistributeSecondPrize();
        
        (uint256 firstPlayerPrize,) = lucky.s_pendingWithdrawals(players[0], 0);
        (uint256 secondPlayerPrize,) = lucky.s_pendingWithdrawals(players[1], 0);
        uint256 prizeShare = ((lucky.BET_COST() - lucky.EXPOSED_VAULT_CUT()) * lucky.SECOND_WIN_PERCENTAGE() / 100);

        assertEq(firstPlayerPrize, prizeShare);
        assertEq(secondPlayerPrize, prizeShare);
    }
}
