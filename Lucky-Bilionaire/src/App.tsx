// import React from 'react';
import { sepolia } from 'wagmi/chains';
import { useReadContract, useWriteContract } from 'wagmi';
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

  const isLoading = isCurrentRoundLoading || isLuckyNumberLoading || isFirstPrizeLoading || isSecondPrizeLoading || isWinnersExactLoading || isWinnersBeforeLoading || isWinnersAfterLoading;
  const isError = isCurrentRoundError || isLuckyNumberError || isWinnersExactError;

  if (isLoading) {
    return <div className="status-message">Loading prizes and winners...</div>;
  }
  
  if (isError) {
    return <div className="status-message error">Error fetching data. Check your network connection or contract address.</div>;
  }

  // const [betNumber, setBetNumber] = useState('');

  // function Bet({ betNumber }: { betNumber: number }) {
  //   const { writeContract } = useWriteContract();
  //   const [betMessage, setBetMessage] = useState('');

  //   const handleBet = () => {
  //     // Check if a valid number is provided
  //     if (betNumber < MIN_LUCKY_NUMBER || betNumber > MAX_LUCKY_NUMBER) {
  //       setBetMessage(`Please enter a number between ${MIN_LUCKY_NUMBER} and ${MAX_LUCKY_NUMBER}.`);
  //       return;
  //     }
      
  //     setBetMessage('Transaction initiated! Check your wallet to confirm.');

  //     writeContract({
  //       abi,
  //       address: CONTRACT_ADDRESS,
  //       functionName: 'savePlayerGuess',
  //       args: [BigInt(betNumber)],
  //       value: BigInt('1000000000000000000') // 1 ETH in Wei
  //     });
  //   }
  // };

  // Combine winners for display
  const secondPlaceWinners = winnersBefore?.concat(winnersAfter ?? []) ?? [];

  return (
    <div>
      <div className="lucky-bilionaire-container">
        <h1>
          LUCKY BILIONAIRE
        </h1>
        <div className="container-flex">
          {/* This container sets up the two main columns */}
          <div className="results-container results-container-flex">
            <div className="flex-column">
              <h2>LOTTERY RESULTS</h2>
              <div className="info-section">
                <InfoCard 
                  className="lucky-number-card" 
                  title="Lucky Number" 
                  message={lastWeekLuckyNumber?.toString() ?? "N/A"} 
                />

                <InfoCard
                  className="first-prize-card" 
                  title="First Prize" 
                  message={`${lastWeekFirstPrize?.toString() ?? "N/A"} ETH`}
                />

                <InfoCard 
                  className="first-prize-card" 
                  title="First Prize Winners" 
                  message={renderWinners(winnersExact)}
                />

                <InfoCard 
                  className="second-prize-card" 
                  title="Second Prize" 
                  message={`${lastWeekSecondPrize?.toString() ?? "N/A"} ETH`}
                />
                          
                <InfoCard 
                  className="second-prize-card" 
                  title="Second Prize Winners" 
                  message={renderWinners(secondPlaceWinners)}
                />
              </div>
            </div>
          </div>
            {/* This is the second column for the new features */}
            <div className="actions-container">
              <h2>BE THE NEXT BILIONAIRE</h2>
              <div className="current-prizes interaction-card">
                <h3>CURRENT JACKPOT</h3>
                <h3>14 ETH</h3>
              </div>
              {/* <div className="place-bet interaction-card">
                <h3>PLACE YOUR BET</h3>
                <input 
                  type="number" 
                  placeholder="1 - 50" 
                  value={betNumber}
                  onChange={(e) => setBetNumber(Number(e.target.value))}
                />
                <Bet betNumber={Number(betNumber)} />
              </div>
              <div className="withdraw-prize interaction-card">
                <h3>ARE YOU A LUCKY WINNER?</h3>
                <button className="withdraw-prize">Withdraw Prize!</button>
              </div> */}
            </div>
        </div>
      </div>
    </div>
  );
}

export default LuckyBilionaire;