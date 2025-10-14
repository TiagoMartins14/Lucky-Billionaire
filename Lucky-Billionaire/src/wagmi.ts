import { createConfig, http } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'
import { baseAccount, injected, walletConnect } from 'wagmi/connectors'

const projectId = import.meta.env.VITE_WC_PROJECT_ID

console.log('WalletConnect project ID:', projectId)

export const config = createConfig({
  chains: [mainnet, sepolia],
  connectors: [
    injected({ shimDisconnect: true }),
    baseAccount(),
    walletConnect({ projectId }),
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
