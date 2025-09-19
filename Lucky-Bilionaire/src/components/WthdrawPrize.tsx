import { useWriteContract } from 'wagmi';
import { abi } from "../abi.ts";
import { CONTRACT_ADDRESS} from "../constants.tsx"

export function WithdrawPrize () {
	const { writeContract, isPending, isSuccess, isError, error } = useWriteContract()

	const handleWithdraw = () => {
		writeContract({
			abi,
			address: CONTRACT_ADDRESS,
			functionName: 'claimPrize',
			args: [],
		});
	};

	const renderFeedback = () => {
		if (isPending) return <p>Confirming your transaction</p>
		if (isSuccess) return <p>Prize claimed successfully!</p>
		if (isError) return <p>Error: {error?.message}</p>
		return null;
	}

	return (
		<div className="action-card withdraw">
			<h3>ARE YOU A LUCKY WINNER?</h3>
			<button
				onClick={handleWithdraw}
				disabled={isPending}
			>
				WITHDRAW YOUR PRIZE!
			</button>
			{renderFeedback()}
        </div>
	)

}