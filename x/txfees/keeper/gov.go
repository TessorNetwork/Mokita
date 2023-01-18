package keeper

import (
	sdk "github.com/cosmos/cosmos-sdk/types"

	"github.com/tessornetwork/mokita/x/txfees/types"
)

func (k Keeper) HandleUpdateFeeTokenProposal(ctx sdk.Context, p *types.UpdateFeeTokenProposal) error {
	// setFeeToken internally calls ValidateFeeToken
	return k.setFeeToken(ctx, p.Feetoken)
}
