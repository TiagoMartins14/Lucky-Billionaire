import { useState } from "react";
import { Bet } from "./components/bet.tsx"
import { InfoCard } from './components/info-card.tsx';
import { WithdrawPrize } from "./components/wthdraw-prize.tsx"
import { ThemeSwitch } from './components/theme-switch.tsx';
import { ConnectWalletButton } from './components/connect-wallet.tsx'
import { useLuckyContractData } from './utils/smart-contract-getters.tsx'
import './app.css';

function LuckyBillionaire() {
  const [isDark, setIsDark] = useState(false);

  const {
    lastWeekLuckyNumber,
    firstPrizeInEther,
    lastWeekFirstPrizeInEther,
    lastWeekSecondPrizeInEther,
    winnersExact,
    winnersBefore,
    winnersAfter,
    isLoading,
    isError,
  } = useLuckyContractData();

  if (isLoading) {
    return <div className="status-message">Loading prizes and winners...</div>;
  }

  if (isError) {
    return (
      <div className="status-message error">
        Error fetching data. Check your network connection or contract address.
      </div>
    );
  }

  const firstPlaceWinners = winnersExact ?? [];
  const secondPlaceWinners = winnersBefore?.concat(winnersAfter ?? []) ?? [];

  return (
    <div className="App" data-theme={isDark ? "dark-mode" : null}>
      <ThemeSwitch isDark={isDark} setIsDark={setIsDark} />
      <ConnectWalletButton />
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
                message={`${Number(lastWeekFirstPrizeInEther).toFixed(4)} Seploia ETH`}
              />

              <InfoCard 
                className="info-card" 
                title="First Prize Winners" 
                message={firstPlaceWinners ? firstPlaceWinners.length.toString() : "No winners this week"}
              />

              <InfoCard 
                className="info-card" 
                title="Second Prize" 
                message={`${Number(lastWeekSecondPrizeInEther).toFixed(4)} Sepolia ETH`}
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
                  <p className="highlighted-text">{Number(firstPrizeInEther).toFixed(4)} SepoliaETH</p>
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