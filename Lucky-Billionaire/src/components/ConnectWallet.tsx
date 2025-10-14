import { useAccount, useConnect, useDisconnect, useChainId } from 'wagmi'


export function ConnectWallet() {
  const { address, isConnected } = useAccount()
  const { connect, connectors, isPending, error } = useConnect()
  const { disconnect } = useDisconnect()
  const chainId = useChainId()

  console.log('Connected chain:', chainId)

  if (isConnected) {
    return (
      <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
        <span>
          Connected: {address?.slice(0, 6)}...{address?.slice(-4)}
        </span>
        <button
          onClick={() => disconnect()}
          style={{
            backgroundColor: '#ef4444',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            padding: '8px 16px',
            cursor: 'pointer',
          }}
        >
          Disconnect
        </button>
      </div>
    )
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
      {connectors.map((connector) => (
        <button
          key={connector.uid}
          onClick={() => connect({ connector })}
          disabled={!connector.ready}
          style={{
            backgroundColor: '#2563eb',
            color: 'white',
            border: 'none',
            borderRadius: '8px',
            padding: '8px 16px',
            cursor: 'pointer',
            opacity: connector.ready ? 1 : 0.5,
          }}
        >
          Connect with {connector.name}
          {isPending && ' (connecting...)'}
        </button>
      ))}
      {error && <p style={{ color: 'red' }}>{error.message}</p>}
    </div>
  )
}
