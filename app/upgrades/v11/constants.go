package v11

import (
	store "github.com/cosmos/cosmos-sdk/store/types"

	"github.com/tessornetwork/mokita/app/upgrades"
)

// UpgradeName defines the on-chain upgrade name for the Mokita v11 upgrade.
const UpgradeName = "v11"

var Upgrade = upgrades.Upgrade{
	UpgradeName:          UpgradeName,
	CreateUpgradeHandler: CreateUpgradeHandler,
	StoreUpgrades:        store.StoreUpgrades{},
}
