import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider, useAccount } from 'wagmi'
import { config } from '../config'
import { Account } from '../utils/account'
import { WalletOptions } from '../utils/wallet-options'

const queryClient = new QueryClient()

function ConnectWallet() {
  const { isConnected } = useAccount()
  if (isConnected) return <Account />
  return <WalletOptions />
}

export function ConnectWalletButton () {
	return (
		// <div id="wallet-address">
			<WagmiProvider config={config}>
				<QueryClientProvider client={queryClient}>
						<ConnectWallet />
				</QueryClientProvider> 
			</WagmiProvider>
		// </div>
	)
}