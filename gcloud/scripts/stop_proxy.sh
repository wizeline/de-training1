# This script stops the SOCKS proxy set in start_proxy.sh

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
    netsh winhttp reset proxy ;;
  *);;
esac