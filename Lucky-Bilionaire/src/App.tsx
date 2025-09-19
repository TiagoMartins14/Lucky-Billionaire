import { sepolia } from 'wagmi/chains';
import { useReadContract, useWriteContract } from 'wagmi';
import { abi } from "./abi.ts";
import React, { useState } from "react";
import { CONTRACT_ADDRESS, MAX_LUCKY_NUMBER, MIN_LUCKY_NUMBER} from "./constants.tsx"
import { Bet } from "./components/BetButton.tsx"
import { WithdrawPrize } from "./components/WthdrawPrize.tsx"

import './App.css';

// Reusable card component to display any piece of information
const InfoCard = ({ className, title, message }) => (
  <div className={`info-card ${className}`}>
    <h3>{title}</h3>
    <div>{message}</div>
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

  const [isDark, setIsDark] = useState(false);

  const handleThemeSwitch = () => {
    isDark === true ? setIsDark(false) : setIsDark(true);
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
      <div className="App" data-theme={isDark ? "dark-mode" : null}>
        <button id="theme-switch" title="Switch theme" onClick={handleThemeSwitch}>
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M480-120q-150 0-255-105T120-480q0-150 105-255t255-105q14 0 27.5 1t26.5 3q-41 29-65.5 75.5T444-660q0 90 63 153t153 63q55 0 101-24.5t75-65.5q2 13 3 26.5t1 27.5q0 150-105 255T480-120Zm0-80q88 0 158-48.5T740-375q-20 5-40 8t-40 3q-123 0-209.5-86.5T364-660q0-20 3-40t8-40q-78 32-126.5 102T200-480q0 116 82 198t198 82Zm-10-270Z"/></svg>
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="#e3e3e3"><path d="M480-360q50 0 85-35t35-85q0-50-35-85t-85-35q-50 0-85 35t-35 85q0 50 35 85t85 35Zm0 80q-83 0-141.5-58.5T280-480q0-83 58.5-141.5T480-680q83 0 141.5 58.5T680-480q0 83-58.5 141.5T480-280ZM200-440H40v-80h160v80Zm720 0H760v-80h160v80ZM440-760v-160h80v160h-80Zm0 720v-160h80v160h-80ZM256-650l-101-97 57-59 96 100-52 56Zm492 496-97-101 53-55 101 97-57 59Zm-98-550 97-101 59 57-100 96-56-52ZM154-212l101-97 55 53-97 101-59-57Zm326-268Z"/></svg>
        </button>
        <div className="lucky-bilionaire-container">
          <h1>
            LUCKY BILIONAIRE
          </h1>
          <div className="container-flex">
            <div className="main-flex-column">
              <h2>LOTTERY RESULTS</h2>
              <div className="info-section">
                <InfoCard 
                  className="info-card" 
                  title="Lucky Number" 
                  message={lastWeekLuckyNumber?.toString() ?? "N/A"} 
                />

                <InfoCard
                  className="info-card" 
                  title="First Prize" 
                  message={`${lastWeekFirstPrize?.toString() ?? "N/A"} ETH`}
                />

                <InfoCard 
                  className="info-card" 
                  title="First Prize Winners" 
                  message={renderWinners(winnersExact)}
                />

                <InfoCard 
                  className="info-card" 
                  title="Second Prize" 
                  message={`${lastWeekSecondPrize?.toString() ?? "N/A"} ETH`}
                />
                          
                <InfoCard 
                  className="info-card" 
                  title="Second Prize Winners" 
                  message={renderWinners(secondPlaceWinners)}
                />
              </div>
            </div>
              <div className="main-flex-column">
                  <h2>BE THE NEXT BILIONAIRE</h2>
                <div className="info-section">
                  <div className="info-card">
                    <h3>CURRENT JACKPOT</h3>
                    <p className="highlighted-text">14 ETH</p>
                  </div>
                </div>
                <div className="action-section">
                  <Bet/>
                  <WithdrawPrize/>
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