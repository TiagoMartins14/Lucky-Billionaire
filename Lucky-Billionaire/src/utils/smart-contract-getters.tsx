import { sepolia } from 'wagmi/chains';
import { useReadContract } from 'wagmi';
import { abi } from "../abi.ts";
import { CONTRACT_ADDRESS, MAX_LUCKY_NUMBER, MIN_LUCKY_NUMBER } from "../constants.tsx";
import { formatEther } from "viem";

export function useLuckyContractData() {
  const { data: currentRound, isLoading: isCurrentRoundLoading, isError: isCurrentRoundError } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getRound',
    chainId: sepolia.id,
  });

  const previousRound = currentRound ? currentRound - 1n : undefined;

  const { data: lastWeekLuckyNumber, isLoading: isLuckyNumberLoading, isError: isLuckyNumberError } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getLuckyNumber',
    args: previousRound !== undefined ? [previousRound] : undefined,
    chainId: sepolia.id,
    query: { enabled: previousRound !== undefined },
  });

  const { data: firstPrize, isLoading: isFirstPrizeLoading } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getFirstPrize',
    chainId: sepolia.id,
  });

  const firstPrizeInEther = firstPrize ? formatEther(BigInt(firstPrize)) : "0";

  const { data: lastWeekFirstPrize, isLoading: isLastWeekFirstPrizeLoading } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getLastFirstPrize',
    chainId: sepolia.id,
  });

  const { data: lastWeekSecondPrize, isLoading: isSecondPrizeLoading } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getLastSecondPrize',
    chainId: sepolia.id,
  });

  const { data: winnersExact, isLoading: isWinnersExactLoading, isError: isWinnersExactError } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getPlayersByNumberGuess',
    args:
      previousRound !== undefined && lastWeekLuckyNumber !== undefined
        ? [previousRound, lastWeekLuckyNumber]
        : undefined,
    chainId: sepolia.id,
    query: { enabled: previousRound !== undefined && lastWeekLuckyNumber !== undefined },
  });

  const lastLuckyNumberNum =
    typeof lastWeekLuckyNumber === 'bigint' ? Number(lastWeekLuckyNumber) : undefined;

  const luckyNumberBefore =
    lastLuckyNumberNum !== undefined
      ? lastLuckyNumberNum === MIN_LUCKY_NUMBER
        ? MAX_LUCKY_NUMBER
        : lastLuckyNumberNum - 1
      : undefined;

  const luckyNumberAfter =
    lastLuckyNumberNum !== undefined
      ? lastLuckyNumberNum === MAX_LUCKY_NUMBER
        ? MIN_LUCKY_NUMBER
        : lastLuckyNumberNum + 1
      : undefined;

  const { data: winnersBefore, isLoading: isWinnersBeforeLoading } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getPlayersByNumberGuess',
    args:
      previousRound !== undefined && luckyNumberBefore !== undefined
        ? [previousRound, BigInt(luckyNumberBefore)]
        : undefined,
    chainId: sepolia.id,
    query: { enabled: previousRound !== undefined && luckyNumberBefore !== undefined },
  });

  const { data: winnersAfter, isLoading: isWinnersAfterLoading } = useReadContract({
    abi,
    address: CONTRACT_ADDRESS,
    functionName: 'getPlayersByNumberGuess',
    args:
      previousRound !== undefined && luckyNumberAfter !== undefined
        ? [previousRound, BigInt(luckyNumberAfter)]
        : undefined,
    chainId: sepolia.id,
    query: { enabled: previousRound !== undefined && luckyNumberAfter !== undefined },
  });

  const isLoading =
    isCurrentRoundLoading ||
    isLuckyNumberLoading ||
    isFirstPrizeLoading ||
    isLastWeekFirstPrizeLoading ||
    isSecondPrizeLoading ||
    isWinnersExactLoading ||
    isWinnersBeforeLoading ||
    isWinnersAfterLoading;

  const isError = isCurrentRoundError || isLuckyNumberError || isWinnersExactError;

  return {
    currentRound,
    previousRound,
    lastWeekLuckyNumber,
    firstPrizeInEther,
    lastWeekFirstPrize,
    lastWeekSecondPrize,
    winnersExact,
    winnersBefore,
    winnersAfter,
    isLoading,
    isError,
  };
}
