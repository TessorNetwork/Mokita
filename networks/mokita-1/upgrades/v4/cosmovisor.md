# Install and setup Cmokivisor

We highly recommend validators use cmokivisor to run their nodes. This
will make low-downtime upgrades smoother, as validators don't have to
manually upgrade binaries during the upgrade, and instead can preinstall
new binaries, and cmokivisor will automatically update them based on
on-chain SoftwareUpgrade proposals.

You should review the docs for cmokivisor located here:
<https://docs.cosmos.network/master/run-node/cmokivisor.html>

If you choose to use cmokivisor, please continue with these
instructions:

To install Cmokivisor:

    git clone https://github.com/cosmos/cosmos-sdk
    cd cosmos-sdk
    git checkout v0.42.9
    make cmokivisor
    cp cmokivisor/cmokivisor $GOPATH/bin/cmokivisor
    cd $HOME

After this, you must make the necessary folders for cosmosvisor in your
daemon home directory (\~/.mokitad).

``` {.sh}
mkdir -p ~/.mokitad
mkdir -p ~/.mokitad/cmokivisor
mkdir -p ~/.mokitad/cmokivisor/genesis
mkdir -p ~/.mokitad/cmokivisor/genesis/bin
mkdir -p ~/.mokitad/cmokivisor/upgrades
```

Cmokivisor requires some ENVIRONMENT VARIABLES be set in order to
function properly. We recommend setting these in your `.profile` so it
is automatically set in every session.

For validators we recommmend setting

- `DAEMON_ALLOW_DOWNLOAD_BINARIES=false` for security reasons
- `DAEMON_LOG_BUFFER_SIZE=512` to avoid a bug with extra long log
    lines crashing the server.
- `DAEMON_RESTART_AFTER_UPGRADE=true` for unattended upgrades

```{=html}
<!-- -->
```

    echo "# Setup Cmokivisor" >> ~/.profile
    echo "export DAEMON_NAME=mokitad" >> ~/.profile
    echo "export DAEMON_HOME=$HOME/.mokitad" >> ~/.profile
    echo "export DAEMON_ALLOW_DOWNLOAD_BINARIES=false" >> ~/.profile
    echo "export DAEMON_LOG_BUFFER_SIZE=512" >> ~/.profile
    echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> ~/.profile
    source ~/.profile

Finally, you should copy the current mokitad binary into the
cmokivisor/genesis folder.

    cp $GOPATH/bin/mokitad ~/.mokitad/cmokivisor/genesis/bin

Prepare for upgrade (v4)
------------------------

To prepare for the upgrade, you need to create some folders, and build
and install the new binary.

    mkdir -p ~/.mokitad/cmokivisor/upgrades/v4/bin
    git clone https://github.com/tessornetwork/mokita
    cd mokita
    git checkout v4.0.0
    make build
    cp build/mokitad ~/.mokitad/cmokivisor/upgrades/v4/bin

Now cmokivisor will run with the current binary, and will automatically
upgrade to this new binary at the appropriate height if run with:

    cmokivisor start

Please note, this does not automatically update your
`$GOPATH/bin/mokitad` binary, to do that after the upgrade, please run
`make install` in the mokita source folder.
