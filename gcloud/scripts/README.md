# Helper scripts

In this folder we keep a set of helper script that simplify the connection to
the dataproc clusters from your own command line

## Prerequisites

The following steps only need to be setup once per system

1. Install the [Google Cloud SDK]() if is not in your system.
   You can install with brew too, `brew cask install google-cloud-sdk`


## Creating SSH tunel and running Zeppelin

If you already have a dataproc cluster provisioned you can use the following
scripts (each own its own termianl).

1. `./ssh_tunnel.sh` to create a tunnel to connect to the zeppelin interface
   from your browser.
2. `./start_proxy.sh` to open a Chrome browser with SOCKS proxy enabled.
3. `./stop_proxy.sh` to stop the SOCKS proxy after finishing.
