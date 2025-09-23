import { WagmiProvider, createConfig, http } from "wagmi";
import { sepolia } from "wagmi/chains";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ConnectKitProvider, getDefaultConfig } from "connectkit"

const config = createConfig(
    getDefaultConfig({
        chains: [sepolia],
        transports: {
            [sepolia.id]: http(
                `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_ID}`
            ),
        },
        walletConnectProjectId: process.env.PROJECT_ID,

        appName: "Lucky Bilionaire",

        appDescription: "A Lottery Chance To Become A Bilionaire!",
        appUrl: "https://to_be_announced.co",
        appIcon: "https://to_be_decided.co"
    }),
);

const queryClient = new QueryClient();

export const Web3Provider = ({ children }) => {
    return (
        <WagmiProvider config ={config}>
            <QueryClientProvider client={queryClient}>
                <ConnectKitProvider>{children}</ConnectKitProvider>
            </QueryClientProvider>
        </WagmiProvider>
    )
}