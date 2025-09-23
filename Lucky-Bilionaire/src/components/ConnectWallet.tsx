import { Web3Provider } from './Web3Provider.tsx';
import { ConnectKitButton } from 'connectkit';

export const ConnectWallet = () => {
    return (
        <Web3Provider>
            <ConnectKitButton />
        </Web3Provider>
    );
};