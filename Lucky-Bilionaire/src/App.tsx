import {sepolia} from 'wagmi/chains'
import {useAccount, useConnect, useDisconnect} from 'wagmi'
import {useReadContract} from 'wagmi'
import {abi} from "./abi.ts"

// function App() {
//   const account = useAccount()
//   const { connectors, connect, status, error } = useConnect()
//   const { disconnect } = useDisconnect()

//   return (
//     <>
//       <div>
//         <h2>Account</h2>

//         <div>
//           status: {account.status}
//           <br />
//           addresses: {JSON.stringify(account.addresses)}
//           <br />
//           chainId: {account.chainId}
//         </div>

//         {account.status === 'connected' && (
//           <button type="button" onClick={() => disconnect()}>
//             Disconnect
//           </button>
//         )}
//       </div>

//       <div>
//         <h2>Connect</h2>
//         {connectors.map((connector) => (
//           <button
//             key={connector.uid}
//             onClick={() => connect({ connector })}
//             type="button"
//           >
//             {connector.name}
//           </button>
//         ))}
//         <div>{status}</div>
//         <div>{error?.message}</div>
//       </div>
//     </>
//   )
// }

// export default App
// type Address = `0x${string}`;

// ... (other parts of the component)

function DisplayLastWeekLuckyNumber() {
  const contractAddress = "0x73fBB342911550742382F76643796AA7D3Db34b6";

  const { data: previousLuckyNumber, isLoading: previousLuckyNumberIsLoading, isError, error } = useReadContract({
    abi,
    address: contractAddress,
    functionName: 'getLastLuckyNumber',
    chainId: sepolia.id,
  });

  if (previousLuckyNumberIsLoading) {
    return <div>Loading last week's lucky number...</div>;
  }

  if (isError) {
    return <div>Error fetching lucky number: {error.message}</div>;
  }

  const lastWeeksLuckyNumber = "Last week's lucky number: " + previousLuckyNumber;

  return (
    <>
      <div className="show-prizes">
        <h3>{lastWeeksLuckyNumber}</h3>
      </div>
    </>
  );
}

function WithdrawPrizes() {}

function EnterLottery() {}

function LuckyBilionaire() {
  return (
    <>
        <DisplayLastWeekLuckyNumber /> 
    </>)
}

export default LuckyBilionaire
