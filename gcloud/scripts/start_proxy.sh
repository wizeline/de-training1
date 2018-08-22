#! /bin/bash
# This port must be the same as in ssh_tunnel.sh
echo "Type the port used in the ssh tunel, recommended port was 1100."
echo
read SSH_PORT
# It depends on the OS and medium, for mac run  "networksetup -listallhardwareports" to check the available ports


# This command will open chrome with SOCKS proxy set to the port used in ssh_tunnel.sh.
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  # MacOS
    echo
    echo "Type the hardware to be used, for example in mac type in a terminal 'networksetup -listallhardwareports', for wifi is 'Wi-Fi'."
    echo
    read HARDWARE_PORT
    networksetup -setsocksfirewallproxy $HARDWARE_PORT localhost $SSH_PORT
    open http://localhost:8080;;
  linux*)   # Linux
    gsettings set org.gnome.system.proxy.socks host 'localhost'
    gsettings set org.gnome.system.proxy.socks port $SSH_PORT
    gsettings set org.gnome.system.proxy.mode 'manual'
    xdg-open http://localhost:8080 ;;
  bsd*)     echo "BSD";;
  msys*)    # Windows
    netsh winhttp set proxy localhost:$SSH_PORT
    start "http://localhost:8080" ;;
  *);;
esac
