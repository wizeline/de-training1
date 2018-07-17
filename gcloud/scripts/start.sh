#! /bin/bash
# This command will open chrome with SOCKS proxy set to the port used in the previous command.
open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --proxy-server="socks5://localhost:1100"--host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost"