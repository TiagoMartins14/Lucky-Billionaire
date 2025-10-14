import { sepolia } from 'wagmi/chains';
import { useReadContract } from 'wagmi';
import { abi } from "./abi.ts";
import { useState } from "react";
import { CONTRACT_ADDRESS, MAX_LUCKY_NUMBER, MIN_LUCKY_NUMBER} from "./constants.tsx"
import { Bet } from "./components/Bet.tsx"
import { InfoCard } from './components/InfoCard.tsx';
import { WithdrawPrize } from "./components/WthdrawPrize.tsx"
import { ConnectWallet } from './components/ConnectWallet.tsx';
import { ThemeSwitch } from './components/ThemeSwitch.tsx';

import './App.css';

// Reusable function to render winner addresses
function renderWinners(winners: readonly `0x${string}`[] | undefined) {
  if (!winners || winners.length === 0) {
    return <div>No winners this week.</div>;
  }

  const numberOfWinners = winners.length;

  return (
    <div className="winner-list">
      <p>{numberOfWinners}</p>
    </div>
  );
}

function LuckyBillionaire() {
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
    args: (previousRound !== undefined && lastWeekLuckyNumber !== undefined) ? [previousRound, lastWeekLuckyNumber] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined && lastWeekLuckyNumber !== undefined },
  });

  const lastLuckyNumberNum = typeof lastWeekLuckyNumber === 'bigint' ? Number(lastWeekLuckyNumber) : undefined;
  const luckyNumberBefore = lastLuckyNumberNum !== undefined ? (lastLuckyNumberNum === MIN_LUCKY_NUMBER ? MAX_LUCKY_NUMBER : lastLuckyNumberNum - 1) : undefined;
  const luckyNumberAfter = lastLuckyNumberNum !== undefined ? (lastLuckyNumberNum === MAX_LUCKY_NUMBER ? MIN_LUCKY_NUMBER : lastLuckyNumberNum + 1) : undefined;

  const { data: winnersBefore, isLoading: isWinnersBeforeLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getPlayersByNumberGuess',
    args: (previousRound !== undefined && luckyNumberBefore !== undefined) ? [previousRound, BigInt(luckyNumberBefore)] : undefined,
    chainId: sepolia.id, query: { enabled: previousRound !== undefined && luckyNumberBefore !== undefined },
  });

  const { data: winnersAfter, isLoading: isWinnersAfterLoading } = useReadContract({
    abi, address: CONTRACT_ADDRESS, functionName: 'getPlayersByNumberGuess',
    args: (previousRound !== undefined && luckyNumberAfter !== undefined) ? [previousRound, BigInt(luckyNumberAfter)] : undefined,
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
  const firstPlaceWinners = winnersExact ?? [];
  const secondPlaceWinners = winnersBefore?.concat(winnersAfter ?? []) ?? [];

  return (
      <div className="App" data-theme={isDark ? "dark-mode" : null}>
        <ThemeSwitch isDark={isDark} setIsDark={setIsDark} />
        <div className="connect-wallet">
          <ConnectWallet />
        </div>

        {/*Seguir docs do REOWN */}
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
                  message={firstPlaceWinners ? firstPlaceWinners.length.toString() : "No winners this week"}
                />

                <InfoCard 
                  className="info-card" 
                  title="Second Prize" 
                  message={`${lastWeekSecondPrize?.toString() ?? "N/A"} ETH`}
                />
                          
                <InfoCard 
                  className="info-card" 
                  title="Second Prize Winners" 
                  message={secondPlaceWinners ? secondPlaceWinners.length.toString() : "No winners this week"}
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
              </div>
          </div>
        </div>
      </div>
  );
}

export default LuckyBillionaire;