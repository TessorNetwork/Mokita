# Download a genesis.json for testing. The node that you this on will be your "validator"
# It should be on version v4.x

mokitad init --chain-id=testing testing --home=$HOME/.mokitad
mokitad keys add validator --keyring-backend=test --home=$HOME/.mokitad
mokitad add-genesis-account $(mokitad keys show validator -a --keyring-backend=test --home=$HOME/.mokitad) 1000000000umoki,1000000000valtoken --home=$HOME/.mokitad
sed -i -e "s/stake/umoki/g" $HOME/.mokitad/config/genesis.json
mokitad gentx validator 500000000umoki --commission-rate="0.0" --keyring-backend=test --home=$HOME/.mokitad --chain-id=testing
mokitad collect-gentxs --home=$HOME/.mokitad

cat $HOME/.mokitad/config/genesis.json | jq '.initial_height="711800"' > $HOME/.mokitad/config/tmp_genesis.json && mv $HOME/.mokitad/config/tmp_genesis.json $HOME/.mokitad/config/genesis.json
cat $HOME/.mokitad/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"]["denom"]="valtoken"' > $HOME/.mokitad/config/tmp_genesis.json && mv $HOME/.mokitad/config/tmp_genesis.json $HOME/.mokitad/config/genesis.json
cat $HOME/.mokitad/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"]["amount"]="100"' > $HOME/.mokitad/config/tmp_genesis.json && mv $HOME/.mokitad/config/tmp_genesis.json $HOME/.mokitad/config/genesis.json
cat $HOME/.mokitad/config/genesis.json | jq '.app_state["gov"]["voting_params"]["voting_period"]="120s"' > $HOME/.mokitad/config/tmp_genesis.json && mv $HOME/.mokitad/config/tmp_genesis.json $HOME/.mokitad/config/genesis.json
cat $HOME/.mokitad/config/genesis.json | jq '.app_state["staking"]["params"]["min_commission_rate"]="0.050000000000000000"' > $HOME/.mokitad/config/tmp_genesis.json && mv $HOME/.mokitad/config/tmp_genesis.json $HOME/.mokitad/config/genesis.json

# Now setup a second full node, and peer it with this v3.0.0-rc0 node.

# start the chain on both machines
mokitad start
# Create proposals

mokitad tx gov submit-proposal --title="existing passing prop" --description="passing prop"  --from=validator --deposit=1000valtoken --chain-id=testing --keyring-backend=test --broadcast-mode=block  --type="Text"
mokitad tx gov vote 1 yes --from=validator --keyring-backend=test --chain-id=testing --yes
mokitad tx gov submit-proposal --title="prop with enough moki deposit" --description="prop w/ enough deposit"  --from=validator --deposit=500000000umoki --chain-id=testing --keyring-backend=test --broadcast-mode=block  --type="Text"
# Check that we have proposal 1 passed, and proposal 2 in deposit period
mokitad q gov proposals
# CHeck that validator commission is under min_commission_rate
mokitad q staking validators
# Wait for upgrade block.
# Upgrade happened
# your full node should have crashed with consensus failure

# Now we test post-upgrade behavior is as intended

# Everything in deposit stayed in deposit
mokitad q gov proposals
# Check that commissions was bumped to min_commission_rate
mokitad q staking validators
# pushes 2 into voting period
mokitad tx gov deposit 2 1valtoken --from=validator --keyring-backend=test --chain-id=testing --yes