package main

import (
	"os"

	svrcmd "github.com/cosmos/cosmos-sdk/server/cmd"

	mokita "github.com/tessornetwork/mokita/app"
	"github.com/tessornetwork/mokita/app/params"
	"github.com/tessornetwork/mokita/cmd/mokitad/cmd"
)

func main() {
	params.SetAddressPrefixes()
	rootCmd, _ := cmd.NewRootCmd()
	if err := svrcmd.Execute(rootCmd, mokita.DefaultNodeHome); err != nil {
		os.Exit(1)
	}
}
