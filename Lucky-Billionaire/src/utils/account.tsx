import { useAccount, useDisconnect, useEnsAvatar, useEnsName } from 'wagmi'

export function Account() {
  const { address } = useAccount()
  const { disconnect } = useDisconnect()
  const { data: ensName } = useEnsName({ address })
  const { data: ensAvatar } = useEnsAvatar({ name: ensName! })

  return (
    <div>
      {ensAvatar && <img alt="ENS Avatar" src={ensAvatar} />}
      {/* {address && <div>{ensName ? `${ensName} (${address})` : address}</div>} */}
      {/* <button id="connect-wallet-button" onClick={() => disconnect()}>Disconnect</button> */}
      <p id="connect-wallet-button">{address}</p>
    </div>
  )
}