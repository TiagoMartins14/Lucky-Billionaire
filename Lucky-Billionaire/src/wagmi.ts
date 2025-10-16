import { createConfig, http } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'
import { injected, walletConnect, coinbaseWallet } from 'wagmi/connectors'

const projectId = import.meta.env.VITE_WC_PROJECT_ID

console.log('WalletConnect project ID:', projectId)

export const config = createConfig({
  chains: [mainnet, sepolia],
  connectors: [
    injected({ shimDisconnect: true }), // MetaMask, Brave, etc.
    walletConnect({ projectId }),        // WalletConnect
    coinbaseWallet({ appName: 'Lucky Billionaire' }), // Optional Coinbase Wallet
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
})

declare module 'wagmi' {
  interface Register {
    config: typeof config
  }
}
