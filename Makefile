# Installed openzeppelin-contracts v5.4.0
# Installed chainlink-brownie-contracts v1.3.0

deploy:
	@if [ -z "$$SEPOLIA_RPC_URL" ] || [ -z "$$ACCOUNT_ADDRESS" ]; then \
		echo "Error: SEPOLIA_RPC_URL or ACCOUNT_ADDRESS is not set."; \
		exit 1; \
	fi

	forge script script/DeployLuckyBillionaire.s.sol:DeployLuckyBillionaire --rpc-url $$SEPOLIA_RPC_URL --account luckytKey --sender $$ACCOUNT_ADDRESS --broadcast -vvvv

new_round:
	forge script script/StartNewRound.s.sol --rpc-url $$SEPOLIA_RPC_URL --account luckytKey --broadcast -vvvv

withdraw_vault:
	forge script script/WithdrawAll.s.sol --rpc-url $$SEPOLIA_RPC_URL --account luckytKey --broadcast -vvvv