
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes

test   :; forge test -vvv

deploy-cbETH :;  forge script scripts/DeploycbETHAdapter.s.sol:DeploycbETH --rpc-url mainnet --broadcast --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify -vvvv
deploy-rETH :;  forge script scripts/DeployrETHAdapter.s.sol:DeploycbETH --rpc-url mainnet --broadcast --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify -vvvv

deploy-wstETH-arbitrum :;  forge script scripts/DeployWstETH.s.sol:DeployWstETHArbitrum --rpc-url arbitrum --broadcast --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify -vvvv

deploy-LDOETH :; forge script scripts/DeployLDOAdapter.s.sol:DeployLDOMainnet --rpc-url mainnet --broadcast --private-key ${PRIVATE_KEY} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

deploy-wstETH-polygon :; forge script scripts/DeployWstETHAdapterPolygon.s.sol:DeployWstETHPolygon --rpc-url polygon --broadcast --private-key ${PRIVATE_KEY} --verify --etherscan-api-key ${ETHERSCAN_API_KEY_POLYGON} -vvvv

deploy-maticx-polygon :; forge script scripts/DeployMaticAdapterPolygon.s.sol:DeployMaticXAdapterPolygon --rpc-url polygon --broadcast --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify -vvvv
deploy-stmatic-polygon :; forge script scripts/DeployMaticAdapterPolygon.s.sol:DeployStMaticAdapterPolygon --rpc-url polygon --broadcast --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify -vvvv

deploy-wstETH-gnosis :; forge script scripts/DeployWstETHAdapterGnosis.s.sol:DeployWstETHGnosis --rpc-url gnosis --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY_GNOSIS} -vvvv

deploy-sDai-gnosis :; forge script scripts/DeploysDaiAdapterGnosis.s.sol:DeploysDAIGnosis --rpc-url gnosis --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY_GNOSIS} -vvvv