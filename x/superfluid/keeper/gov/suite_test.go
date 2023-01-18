package gov_test

import (
	"testing"

	"github.com/stretchr/testify/suite"

	"github.com/tessornetwork/mokita/app/apptesting"
	"github.com/tessornetwork/mokita/x/superfluid/keeper"
	"github.com/tessornetwork/mokita/x/superfluid/types"
)

type KeeperTestSuite struct {
	apptesting.KeeperTestHelper

	querier types.QueryServer
}

func (suite *KeeperTestSuite) SetupTest() {
	suite.Setup()
	suite.querier = keeper.NewQuerier(*suite.App.SuperfluidKeeper)
}

func TestKeeperTestSuite(t *testing.T) {
	suite.Run(t, new(KeeperTestSuite))
}
