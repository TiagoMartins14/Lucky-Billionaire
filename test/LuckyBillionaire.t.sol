// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {LuckyBillionaireTestHelper} from "test/helper/LuckyBillionaireTestHelper.t.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/v0.8/vrf/test/VRFCoordinatorV2_5Mock.t.sol";

contract LuckyBillionaireTest is Test {
    VRFCoordinatorV2_5Mock private vrfCoordinator;
    LuckyBillionaireTestHelper private lucky;
    bytes32 private constant KEY_HASH = bytes32(uint256(123456));
    uint256 private subId;

    function setUp() public {
        vrfCoordinator = new VRFCoordinatorV2_5Mock(0.002 ether, 40 gwei, 0.004 ether); // Same params Chainlink uses in its tests
        subId = vrfCoordinator.createSubscription();
        lucky = new LuckyBillionaireTestHelper(address(vrfCoordinator), KEY_HASH, subId);

        vrfCoordinator.fundSubscription(subId, 10000 ether);
        vrfCoordinator.addConsumer(subId, address(lucky));
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error LuckyBillionaire__GuessOutOfRange();
    error LuckyBillionaire__NoFundsToWithdraw();
    error LuckyBillionaire__TransferFailed();
    error LuckyBillionaire__IncorrectPaymentValue();
    error LuckyBillionaire__NeedsToBeMoreThanZero();

    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function create10Players() internal returns (address[10] memory) {
        address[10] memory players;

        for (uint256 i = 0; i < 10; i++) {
            players[i] = makeAddr(string.concat("player", vm.toString(i + 1)));
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

        for (uint256 i = 0; i < players.length; i++) {
            guess = getRandomNumber();
            guesses[i] = guess;
            vm.startPrank(players[i]);
            lucky.savePlayerGuess{value: lucky.BET_COST()}(guess);
            vm.stopPrank();
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

    function testSavingGuessRevertWhenOutOfRange(uint256 _guess) public {
        vm.assume(_guess < lucky.EXPOSED_MINIMUM_LUCKY_NUMBER() || _guess > lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        address player = makeAddr("player");
        vm.deal(player, 1 ether);
        vm.startPrank(player);
        vm.expectRevert(LuckyBillionaire__GuessOutOfRange.selector);
        lucky.savePlayerGuess{value: 1 ether}(_guess);
        vm.stopPrank();
    }

    function testSavingGuessRevertWhenIncorrectPaymentValue(uint256 _guess, uint256 _value) public {
        _guess = bound(_guess, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        _value = bound(_value, 0, 100 ether);
        address player = makeAddr("player");
        if (_value != lucky.BET_COST()) {
            vm.deal(player, 100 ether);
            vm.startPrank(player);
            vm.expectRevert(LuckyBillionaire__IncorrectPaymentValue.selector);
            lucky.savePlayerGuess{value: _value}(_guess);
            vm.stopPrank();
        }
    }

    function testTimesTheLuckyNumberWasGuessed(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        uint256[10] memory guesses = save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 timesGuessedByFunction = lucky.exposedTimesTheLuckyNumberWasGuessed();
        uint256 timesGuessedManually = 0;

        for (uint256 i = 0; i < guesses.length; i++) {
            if (guesses[i] == _luckyNumber) {
                timesGuessedManually++;
            }
        }

        assertEq(timesGuessedByFunction, timesGuessedManually);
    }

    function testTimesTheLuckyNumberWasAlmostGuessed(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 beforeLuckyNumber = _luckyNumber == lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            : _luckyNumber - 1;
        uint256 afterLuckyNumber = _luckyNumber == lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            : _luckyNumber + 1;

        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        uint256[10] memory guesses = save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 timesAlmostGuessedByFunction = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();
        uint256 timesAlmostGuessedManually;

        for (uint256 i = 0; i < guesses.length; i++) {
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
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        lucky.exposedDistributeFirstPrize();

        uint256 timesGuessedCorrectly = lucky.exposedTimesTheLuckyNumberWasGuessed();
        uint256 prizeShare = 0;
        if (timesGuessedCorrectly > 0) {
            prizeShare = lucky.s_firstPrize() / timesGuessedCorrectly;
        }

        for (uint256 i = 0; i < players.length; i++) {
            uint256 expectedPlayerPrize = 0;
            uint256 amountWon = 0;
            uint256 timesPlayerGuessed = lucky.s_numberGuesses(round, _luckyNumber, players[i]);

            if (timesPlayerGuessed > 0) {
                expectedPlayerPrize = prizeShare * timesPlayerGuessed;
                (amountWon,) = lucky.s_pendingWithdrawals(players[i], 0);
            }

            assertEq(expectedPlayerPrize, amountWon);
        }
    }

    function testDistributeSecondPrize(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        lucky.exposedDistributeSecondPrize();

        uint256 beforeLuckyNumber = _luckyNumber == lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            : _luckyNumber - 1;
        uint256 afterLuckyNumber = _luckyNumber == lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            : _luckyNumber + 1;

        uint256 timesGuessedAlmost = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();
        uint256 prizeShare = 0;
        if (timesGuessedAlmost > 0) {
            prizeShare = lucky.s_secondPrize() / timesGuessedAlmost;
        }

        for (uint256 i = 0; i < players.length; i++) {
            uint256 expectedPlayerPrize = 0;
            uint256 amountWon = 0;

            uint256 timesGuessedBefore = lucky.s_numberGuesses(round, beforeLuckyNumber, players[i]);
            uint256 timesGuessedAfter = lucky.s_numberGuesses(round, afterLuckyNumber, players[i]);
            uint256 totalAlmostGuesses = timesGuessedBefore + timesGuessedAfter;

            if (totalAlmostGuesses > 0) {
                expectedPlayerPrize = prizeShare * totalAlmostGuesses;
                (amountWon,) = lucky.s_pendingWithdrawals(players[i], 0);
            }

            assertEq(expectedPlayerPrize, amountWon);
        }
    }

    function testNewRoundInitialPot(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);

        uint256 oldRoundPot = lucky.s_totalPot();
        lucky.exposedCalculateNewRoundInitialPot();
        uint256 newRoundPot = lucky.s_totalPot();

        if (
            lucky.exposedTimesTheLuckyNumberWasGuessed() == 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() == 0
        ) {
            assertEq(oldRoundPot, newRoundPot);
        } else if (
            lucky.exposedTimesTheLuckyNumberWasGuessed() > 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() == 0
        ) {
            assertEq(newRoundPot, oldRoundPot - lucky.s_firstPrize());
        } else if (
            lucky.exposedTimesTheLuckyNumberWasGuessed() == 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() > 0
        ) {
            assertEq(newRoundPot, oldRoundPot - lucky.s_secondPrize());
        } else {
            assertEq(newRoundPot, oldRoundPot - lucky.s_firstPrize() - lucky.s_secondPrize());
        }
    }

    function testRetreivalOfUnclaimedPrizes(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        lucky.exposedDistributeFirstPrize();
        lucky.exposedDistributeSecondPrize();

        uint256 vaultBefore = lucky.getVault();
        uint256 expectedUnclaimedValue;

        if (lucky.exposedTimesTheLuckyNumberWasGuessed() > 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() > 0)
        {
            expectedUnclaimedValue = lucky.s_firstPrize() + lucky.s_secondPrize();
        } else if (
            lucky.exposedTimesTheLuckyNumberWasGuessed() > 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() == 0
        ) {
            expectedUnclaimedValue = lucky.s_firstPrize();
        } else if (
            lucky.exposedTimesTheLuckyNumberWasGuessed() == 0 && lucky.exposedTimesTheLuckyNumberWasAlmostGuessed() > 0
        ) {
            expectedUnclaimedValue = lucky.s_secondPrize();
        } else {
            expectedUnclaimedValue = 0;
        }

        vm.warp(block.timestamp + 30 days);

        lucky.setLuckyNumber(1, 10);
        lucky.setLuckyNumber(2, 20);
        lucky.setLuckyNumber(3, 30);

        lucky.setRound(4);

        lucky.exposedRetreiveUnclaimedPrizes();

        uint256 vaultAfter = lucky.getVault();
        assertEq(vaultAfter, vaultBefore + expectedUnclaimedValue);
    }

    function testCheckStateVariablesAreUpdatedforNewround(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 timesLuckyNUmberWasGuessed = lucky.exposedTimesTheLuckyNumberWasGuessed();
        uint256 timesLuckyNumberWasAlmostGuessed = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();
        lucky.exposedDistributeFirstPrize();
        lucky.exposedDistributeSecondPrize();
        uint256 previousRound = lucky.s_round();
        uint256 previousFirstPrize = lucky.s_firstPrize();
        uint256 previousSecondPrize = lucky.s_secondPrize();
        lucky.exposedCalculateNewRoundInitialPot();

        lucky.exposedUpdateStateVariablesFornewRound();

        if (timesLuckyNUmberWasGuessed == 0 && timesLuckyNumberWasAlmostGuessed == 0) {
            assertEq(lucky.s_firstPrize(), previousFirstPrize);
            assertEq(lucky.s_secondPrize(), previousSecondPrize);
        } else if (timesLuckyNUmberWasGuessed > 0 && timesLuckyNumberWasAlmostGuessed == 0) {
            assertEq(lucky.s_firstPrize(), previousSecondPrize * lucky.FIRST_WIN_PERCENTAGE() / 100);
            assertEq(lucky.s_secondPrize(), previousSecondPrize * lucky.SECOND_WIN_PERCENTAGE() / 100);
        } else if (timesLuckyNUmberWasGuessed == 0 && timesLuckyNumberWasAlmostGuessed > 0) {
            assertEq(lucky.s_firstPrize(), previousFirstPrize * lucky.FIRST_WIN_PERCENTAGE() / 100);
            assertEq(lucky.s_secondPrize(), previousFirstPrize * lucky.SECOND_WIN_PERCENTAGE() / 100);
        } else {
            assertEq(lucky.s_firstPrize(), 0);
            assertEq(lucky.s_secondPrize(), 0);
        }
        assertEq(lucky.s_round(), previousRound + 1);
        assertEq(lucky.s_luckyNumber(lucky.s_round()), 0);
    }

    function testPlayersCanWithdrawTheirFunds(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        address[10] memory players = create10Players();
        uint256[10] memory guesses = save10PlayersGuesses(players);
        uint256 round = lucky.s_round();
        lucky.setLuckyNumber(round, _luckyNumber);
        uint256 beforeLuckyNumber = _luckyNumber == lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            : _luckyNumber - 1;
        uint256 afterLuckyNumber = _luckyNumber == lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER()
            ? lucky.EXPOSED_MINIMUM_LUCKY_NUMBER()
            : _luckyNumber + 1;

        lucky.exposedDistributeFirstPrize();
        lucky.exposedDistributeSecondPrize();

        for (uint256 i = 0; i < players.length; i++) {
            address currentPlayer = players[i];
            uint256 amountWon = 0;
            if (guesses[i] == _luckyNumber || guesses[i] == beforeLuckyNumber || guesses[i] == afterLuckyNumber) {
                (amountWon,) = lucky.s_pendingWithdrawals(currentPlayer, 0);
            }

            uint256 playerBalanceBefore = currentPlayer.balance;

            vm.startPrank(currentPlayer);
            if (amountWon > 0) {
                lucky.claimPrize();
                uint256 playerBalanceAfter = currentPlayer.balance;
                assertEq(playerBalanceAfter, playerBalanceBefore + amountWon);
            } else {
                vm.expectRevert(LuckyBillionaire__NoFundsToWithdraw.selector);
                lucky.claimPrize();
            }
            vm.stopPrank();
        }
    }

    function testLuckyNumberAnnouncementAndNewRoundCleanup(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        uint256 round = lucky.s_round();
        address[10] memory players = create10Players();
        save10PlayersGuesses(players);
        lucky.setLuckyNumber(round, _luckyNumber);

        uint256 timesLuckyNUmberWasGuessed = lucky.exposedTimesTheLuckyNumberWasGuessed();
        uint256 timesLuckyNumberWasAlmostGuessed = lucky.exposedTimesTheLuckyNumberWasAlmostGuessed();
        uint256 previousRound = lucky.s_round();
        uint256 previousFirstPrize = lucky.s_firstPrize();
        uint256 previousSecondPrize = lucky.s_secondPrize();

        lucky.exposedDistributePrizes();
        lucky.exposedStartNewRoundCleanUp();

        if (timesLuckyNUmberWasGuessed == 0 && timesLuckyNumberWasAlmostGuessed == 0) {
            assertEq(lucky.s_firstPrize(), previousFirstPrize);
            assertEq(lucky.s_secondPrize(), previousSecondPrize);
        } else if (timesLuckyNUmberWasGuessed > 0 && timesLuckyNumberWasAlmostGuessed == 0) {
            assertEq(lucky.s_firstPrize(), previousSecondPrize * lucky.FIRST_WIN_PERCENTAGE() / 100);
            assertEq(lucky.s_secondPrize(), previousSecondPrize * lucky.SECOND_WIN_PERCENTAGE() / 100);
        } else if (timesLuckyNUmberWasGuessed == 0 && timesLuckyNumberWasAlmostGuessed > 0) {
            assertEq(lucky.s_firstPrize(), previousFirstPrize * lucky.FIRST_WIN_PERCENTAGE() / 100);
            assertEq(lucky.s_secondPrize(), previousFirstPrize * lucky.SECOND_WIN_PERCENTAGE() / 100);
        } else {
            assertEq(lucky.s_firstPrize(), 0);
            assertEq(lucky.s_secondPrize(), 0);
        }
        assertEq(lucky.s_round(), previousRound + 1);
        assertEq(lucky.s_luckyNumber(lucky.s_round()), 0);
    }

    function testPausedAndUnpausedState(uint256 _luckyNumber) public {
        _luckyNumber = bound(_luckyNumber, lucky.EXPOSED_MINIMUM_LUCKY_NUMBER(), lucky.EXPOSED_MAXIMUM_LUCKY_NUMBER());
        address player = makeAddr("player");
        uint256 betCost = lucky.BET_COST();
        vm.deal(player, 1 ether);
        lucky.exposedPauseLuckyBillionaire();
        vm.prank(player);
        vm.expectRevert("Pausable: paused");
        lucky.savePlayerGuess{value: betCost}(_luckyNumber);
        lucky.exposedResumeLuckyBillionaire();
        vm.prank(player);
        lucky.savePlayerGuess{value: betCost}(_luckyNumber);
    }

    function testOwnerCanWithdrawMoney(uint256 _amount) public {
        vm.deal(address(lucky), 100 ether);
        _amount = bound(_amount, 1, address(lucky).balance);
        lucky.setVault(address(lucky).balance);
        uint256 ownerBalanceBefore = address(this).balance;
        uint256 contractBalanceBefore = address(lucky).balance;

        lucky.withdraw(_amount);

        uint256 ownerBalanceAfter = address(this).balance;
        uint256 contractBalanceAfter = address(lucky).balance;

        assertEq(ownerBalanceAfter, ownerBalanceBefore + _amount);
        assertEq(contractBalanceAfter, contractBalanceBefore - _amount);
    }

    function testCannotWithdrawZeroAmount() public {
        vm.expectRevert(LuckyBillionaire__NeedsToBeMoreThanZero.selector);
        lucky.withdraw(0);
    }

    function testWithdrawRevertWhenNoFundsToWithdraw(uint256 _amount) public {
        vm.assume(_amount > 0);
        lucky.setVault(0);
        vm.expectRevert(LuckyBillionaire__NoFundsToWithdraw.selector);
        lucky.withdraw(1 ether);
    }
}
