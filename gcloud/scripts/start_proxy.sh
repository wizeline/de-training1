#! /bin/bash
BROWSER="Google Chrome"
# This port must be the same as in ssh_tunnel.sh
SSH_PORT=1100
# It depends on the OS and medium, for mac run  "networksetup -listallhardwareports" to check the available ports
HARDWARE_PORT=Wi-Fi

# This command will open chrome with SOCKS proxy set to the port used in ssh_tunnel.sh.
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  # MacOS
    networksetup -setsocksfirewallproxy $HARDWARE_PORT localhost $SSH_PORT
    open -na "$BROWSER" http://localhost:8080;;
  linux*)   # Linux
    curl --socks5 localhost:1100 "http://localhost:$SSH_PORT";;
  bsd*)     echo "BSD";;
  msys*)    # Windows
    netsh winhttp set proxy proxy-server="socks=localhost:1100" bypass-list="localhost" 
    start "http://localhost:1100" ;;
  *);;
esac