import React from 'react';
import { sepolia } from 'wagmi/chains';
import { useReadContract } from 'wagmi';
import { abi } from "./abi.ts";
import './index.css';

const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS as `0x${string}`;
const MIN_LUCKY_NUMBER = 1;
const MAX_LUCKY_NUMBER = 50;

// Reusable card component to display any piece of information
const InfoCard = ({ className, title, message }) => (
  <div className={`info-card ${className}`}>
    <h3>{title}</h3>
    <div className="mt-2 text-gray-600">{message}</div>
  </div>
);


// Reusable function to render winner addresses
function renderWinners(winners: readonly `0x${string}`[] | undefined) {
  if (!winners || winners.length === 0) {
    return <div>No winners this week.</div>;
  }
  return (
    <div className="winner-list">
      {winners.map((address, index) => (
        <div key={index} className="winner-address">{address}</div>
      ))}
    </div>
  );
}

function LuckyBilionaire() {
  // All data fetching logic is consolidated here, as before.
  const { data: currentRound, isLoading: isCurrentRoundLoading, isError: isCurrentRoundError } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getRound', chainId: sepolia.id,
  });
  const previousRound = currentRound ? currentRound - 1n : undefined;
  
  const { data: lastWeekLuckyNumber, isLoading: isLuckyNumberLoading, isError: isLuckyNumberError } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getLuckyNumber',
    args: previousRound !== undefined ? [previousRound] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined },
  });

  const { data: lastWeekFirstPrize, isLoading: isFirstPrizeLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getLastFirstPrize', chainId: sepolia.id,
  });

  const { data: lastWeekSecondPrize, isLoading: isSecondPrizeLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getLastSecondPrize', chainId: sepolia.id,
  });

  const { data: winnersExact, isLoading: isWinnersExactLoading, isError: isWinnersExactError } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getPlayersByNumberGuess',
    args: (previousRound && lastWeekLuckyNumber) !== undefined ? [previousRound, lastWeekLuckyNumber] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined && lastWeekLuckyNumber !== undefined },
  });

  const lastLuckyNumberNum = typeof lastWeekLuckyNumber === 'bigint' ? Number(lastWeekLuckyNumber) : undefined;
  const luckyNumberBefore = lastLuckyNumberNum !== undefined ? (lastLuckyNumberNum === MIN_LUCKY_NUMBER ? MAX_LUCKY_NUMBER : lastLuckyNumberNum - 1) : undefined;
  const luckyNumberAfter = lastLuckyNumberNum !== undefined ? (lastLuckyNumberNum === MAX_LUCKY_NUMBER ? MIN_LUCKY_NUMBER : lastLuckyNumberNum + 1) : undefined;

  const { data: winnersBefore, isLoading: isWinnersBeforeLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getPlayersByNumberGuess',
    args: (previousRound && luckyNumberBefore) !== undefined ? [previousRound, BigInt(luckyNumberBefore)] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined && luckyNumberBefore !== undefined },
  });

  const { data: winnersAfter, isLoading: isWinnersAfterLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getPlayersByNumberGuess',
    args: (previousRound && luckyNumberAfter) !== undefined ? [previousRound, BigInt(luckyNumberAfter)] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined && luckyNumberAfter !== undefined },
  });

  // Consolidated Loading and Error handling
  const isLoading = isCurrentRoundLoading || isLuckyNumberLoading || isFirstPrizeLoading || isSecondPrizeLoading || isWinnersExactLoading || isWinnersBeforeLoading || isWinnersAfterLoading;
  const isError = isCurrentRoundError || isLuckyNumberError || isWinnersExactError;

  if (isLoading) {
    return <div className="status-message">Loading prizes and winners...</div>;
  }
  
  if (isError) {
    return <div className="status-message error">Error fetching data. Check your network connection or contract address.</div>;
  }

  // Combine winners for display
  const secondPlaceWinners = winnersBefore?.concat(winnersAfter ?? []) ?? [];

  return (
    <div>
      <div className="lucky-bilionaire-container">
        <h1>
          Lucky Billionaire
        </h1>

        {/* This container sets up the two main columns */}
        <div className="results-container results-container-flex">
          
          {/* This container acts as the first column, holding the heading and the prize cards */}
          <div className="flex-column">
            <h2 className="text-3xl font-bold mb-6 text-center md:text-left">Lottery Results</h2>
            <div className="info-section">
              {/* The prize cards are now arranged using a responsive grid defined in the CSS */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                <InfoCard 
                  className="lucky-number-card" 
                  title="Last Week's Lucky Number" 
                  message={lastWeekLuckyNumber?.toString() ?? "N/A"} 
                />
                
                <InfoCard 
                  className="first-prize-card" 
                  title="First Prize Winners" 
                  message={renderWinners(winnersExact)}
                />

                <InfoCard 
                  className="first-prize-card" 
                  title="Last Week's First Prize" 
                  message={`${lastWeekFirstPrize?.toString() ?? "N/A"} ETH`}
                />
                          
                <InfoCard 
                  className="second-prize-card" 
                  title="Second Prize Winners" 
                  message={renderWinners(secondPlaceWinners)}
                />

                <InfoCard 
                  className="second-prize-card" 
                  title="Last Week's Second Prize" 
                  message={`${lastWeekSecondPrize?.toString() ?? "N/A"} ETH`}
                />
              </div>
            </div>
          </div>

          {/* This is the second column for the new features */}
          <div className="new-container flex-column info-card">
            <h3>New Lottery Features</h3>
            <p className="text-gray-700 mb-4">
              This is a new section for additional information, such as upcoming jackpot details, rules, or a ticket purchasing interface.
            </p>
            <div className="bg-gray-100 p-4 rounded-lg">
              <p className="font-semibold text-lg text-gray-800">Next Jackpot</p>
              <p className="text-2xl font-bold text-indigo-600 mt-1">250 ETH</p>
              <p className="text-sm text-gray-500 mt-2">
                Draw date: September 15th
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default LuckyBilionaire;