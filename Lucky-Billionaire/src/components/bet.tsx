import { useWriteContract } from 'wagmi';
import { abi } from "../abi.ts";
import { CONTRACT_ADDRESS, MAX_LUCKY_NUMBER, MIN_LUCKY_NUMBER, BET_COST} from "../constants.tsx"
import { useEffect, useState } from 'react'
import { parseEther } from 'viem';

export function Bet () {
	const { writeContract, isPending, isSuccess, isError, error } = useWriteContract()
	const [bet, setBet] = useState<number>(0);

	const handleBet = () => {
		if (bet < MIN_LUCKY_NUMBER || bet > MAX_LUCKY_NUMBER || isNaN(bet)) {
			alert(`Please enter a number between ${MIN_LUCKY_NUMBER} and ${MAX_LUCKY_NUMBER}.`)
			return;
		}

		writeContract({
			abi,
			address: CONTRACT_ADDRESS,
			functionName: 'savePlayerGuess',
			args: [BigInt(bet)],
			value: parseEther(BET_COST),
			gas: 300000n,
		});
	};

	useEffect(() => {
		if (isSuccess) {
			alert(`Transaction sucessfull! Your bet has been placed.`)
		}

		if (isError) {
			alert(`Error: ${error?.message}`)
		}
	}, [isSuccess, isError, error]);
	

	return (
		<div className="action-card">
			<h3>PLACE YOUR BET!</h3>
			<input
				type="number" 
				min={MIN_LUCKY_NUMBER} 
				max={MAX_LUCKY_NUMBER} 
				placeholder={` ${MIN_LUCKY_NUMBER} - ${MAX_LUCKY_NUMBER} `} 
				value={bet}
				onChange={(e) => setBet(Number(e.target.value))}
			/>
			<button
				className="bet-button"
				onClick={handleBet}
				disabled={isPending}
			>
				{isPending ? 'Confirming...' : 'BET'}
			</button>
		</div>
	)
}