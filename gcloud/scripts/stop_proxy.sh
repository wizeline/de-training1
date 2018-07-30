# This script stops the SOCKS proxy set in start_proxy.sh
# This HARDWARE_PORT must be the same as the one defined in start_proxy.sh

HARDWARE_PORT=Wi-Fi

# This command will open chrome with SOCKS proxy set to the port used in ssh_tunnel.sh.
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  # MacOS
    echo
    echo "Type the hardware to be used to start the proxy, 'Wi-Fi' was the example."
    echo
    read HARDWARE_PORT
    # Disable SOCKS
    networksetup -setsocksfirewallproxystate $HARDWARE_PORT off ;;
  linux*)   # Linux
    gsettings set org.gnome.system.proxy.mode 'disabled' ;;
  bsd*)     echo "BSD";;
  msys*)    # Windows
    netsh winhttp set proxy proxy-server="socks=localhost:$SSH_PORT" bypass-list="localhost" 
    start "http://localhost:8080" ;;
  *);;
esac


gsettings set org.gnome.system.proxy.socks host 'localhost'
    gsettings set org.gnome.system.proxy.socks port $SSH_PORT
    gsettings set org.gnome.system.proxy.mode 'manual'  
    xdg-open http://localhost:8080 ;;