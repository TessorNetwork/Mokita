#!/bin/sh

CHAIN_ID=localmokita
MOKITA_HOME=$HOME/.mokitad
CONFIG_FOLDER=$MOKITA_HOME/config
MONIKER=val
STATE='false'

MNEMONIC="bottom loan skill merry east cradle onion journey palm apology verb edit desert impose absurd oil bubble sweet glove shallow size build burst effort"
POOLSMNEMONIC="traffic cool olive pottery elegant innocent aisle dial genuine install shy uncle ride federal soon shift flight program cave famous provide cute pole struggle"

while getopts s flag
do
    case "${flag}" in
        s) STATE='true';;
    esac
done

install_prerequisites () {
    apk add dasel
}

edit_genesis () {

    GENESIS=$CONFIG_FOLDER/genesis.json

    # Update staking module
    dasel put string -f $GENESIS '.app_state.staking.params.bond_denom' 'umoki'
    dasel put string -f $GENESIS '.app_state.staking.params.unbonding_time' '240s'

    # Update crisis module
    dasel put string -f $GENESIS '.app_state.crisis.constant_fee.denom' 'umoki'

    # Udpate gov module
    dasel put string -f $GENESIS '.app_state.gov.voting_params.voting_period' '60s'
    dasel put string -f $GENESIS '.app_state.gov.deposit_params.min_deposit.[0].denom' 'umoki'

    # Update epochs module
    dasel put string -f $GENESIS '.app_state.epochs.epochs.[1].duration' "60s"

    # Update poolincentives module
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[0]' "120s"
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[1]' "180s"
    dasel put string -f $GENESIS '.app_state.poolincentives.lockable_durations.[2]' "240s"
    dasel put string -f $GENESIS '.app_state.poolincentives.params.minted_denom' "umoki"

    # Update incentives module
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[0]' "1s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[1]' "120s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[2]' "180s"
    dasel put string -f $GENESIS '.app_state.incentives.lockable_durations.[3]' "240s"
    dasel put string -f $GENESIS '.app_state.incentives.params.distr_epoch_identifier' "day"

    # Update mint module
    dasel put string -f $GENESIS '.app_state.mint.params.mint_denom' "umoki"
    dasel put string -f $GENESIS '.app_state.mint.params.epoch_identifier' "day"

    # Update gamm module
    dasel put string -f $GENESIS '.app_state.gamm.params.pool_creation_fee.[0].denom' "umoki"

    # Update txfee basedenom
    dasel put string -f $GENESIS '.app_state.txfees.basedenom' "umoki"

    # Update wasm permission (Nobody or Everybody)
    dasel put string -f $GENESIS '.app_state.wasm.params.code_upload_access.permission' "Everybody"
}

add_genesis_accounts () {

    mokitad add-genesis-account moki12smx2wdlyttvyzvzg54y2vnqwq2qjateuf7thj 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1cyyzpxplxdzkeea7kwsydadg87357qnahakaks 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki18s5lynnmx37hq4wlrw9gdn68sg2uxp5rgk26vv 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1qwexv7c6sm95lwhzn9027vyu2ccneaqad4w8ka 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki14hcxlnwlqtq75ttaxf674vk6mafspg8xwgnn53 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki12rr534cer5c0vj53eq4y32lcwguyy7nndt0u2t 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1nt33cjd5auzh36syym6azgc8tve0jlvklnq7jq 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki10qfrpash5g2vk3hppvu45x0g860czur8ff5yx0 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1f4tvsdukfwh6s9swrc24gkuz23tp8pd3e9r5fa 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1myv43sqgnj5sm4zl98ftl45af9cfzk7nhjxjqh 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki14gs9zqh8m49yy9kscjqu9h72exyf295afg6kgk 100000000000umoki,100000000000uion,100000000000stake --home $MOKITA_HOME
    mokitad add-genesis-account moki1jllfytsz4dryxhz5tl7u73v29exsf80vz52ucc 1000000000000umoki,1000000000000uion,1000000000000stake --home $MOKITA_HOME

    echo $MNEMONIC | mokitad keys add $MONIKER --recover --keyring-backend=test --home $MOKITA_HOME
    echo $POOLSMNEMONIC | mokitad keys add pools --recover --keyring-backend=test --home $MOKITA_HOME
    mokitad gentx $MONIKER 500000000umoki --keyring-backend=test --chain-id=$CHAIN_ID --home $MOKITA_HOME

    mokitad collect-gentxs --home $MOKITA_HOME
}

edit_config () {
    # Remove seeds
    dasel put string -f $CONFIG_FOLDER/config.toml '.p2p.seeds' ''

    # Expose the rpc
    dasel put string -f $CONFIG_FOLDER/config.toml '.rpc.laddr' "tcp://0.0.0.0:26657"
}

create_two_asset_pool () {
    # Create default pool
    substring='code: 0'
    COUNTER=0
    while [ $COUNTER -lt 15 ]; do
        string=$(mokitad tx gamm create-pool --pool-file=$1 --from pools --chain-id=$CHAIN_ID --home $MOKITA_HOME --keyring-backend=test -b block --yes  2>&1)
        if [ "$string" != "${string%"$substring"*}" ]; then
            echo "create two asset pool: successful"
            break
        else
            let COUNTER=COUNTER+1
            sleep 0.5
        fi
    done
}

create_three_asset_pool () {
    # Create three asset pool
    substring='code: 0'
    COUNTER=0
    while [ $COUNTER -lt 15 ]; do
        string=$(mokitad tx gamm create-pool --pool-file=nativeDenomThreeAssetPool.json --from pools --chain-id=$CHAIN_ID --home $MOKITA_HOME --keyring-backend=test -b block --yes 2>&1)
        if [ "$string" != "${string%"$substring"*}" ]; then
            echo "create three asset pool: successful"
            break
        else
            let COUNTER=COUNTER+1
            sleep 0.5
        fi
    done
}

if [[ ! -d $CONFIG_FOLDER ]]
then
    echo $MNEMONIC | mokitad init -o --chain-id=$CHAIN_ID --home $MOKITA_HOME --recover $MONIKER
    install_prerequisites
    edit_genesis
    add_genesis_accounts
    edit_config
fi

mokitad start --home $MOKITA_HOME &

if [[ $STATE == 'true' ]]
then
    create_two_asset_pool "nativeDenomPoolA.json"
    create_two_asset_pool "nativeDenomPoolB.json"
    create_three_asset_pool
fi
wait
