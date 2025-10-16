// wallet-options.tsx

import * as React from 'react'
import { useConnect } from 'wagmi'

export function WalletOptions() {
  const { connectors, connect } = useConnect()

  const injectedConnector = connectors.find(
    (connector) => connector.id === 'injected',
  )

  const hasBrowserWallet = !!injectedConnector

  const handleConnectClick = () => {
    if (injectedConnector) {
      connect({ connector: injectedConnector })
    }
  }

  return (
    <div >
      <button id="connect-wallet-button"
        disabled={!hasBrowserWallet}
        onClick={handleConnectClick}
      >
        Connect Wallet
      </button>

      {!hasBrowserWallet && (
        <p>
          No browser wallet detected. Please install a wallet extension like MetaMask.
        </p>
      )}
    </div>
  )
}