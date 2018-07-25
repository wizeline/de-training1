# This script stops the SOCKS proxy set in start_proxy.sh
# This HARDWARE_PORT must be the same as the one defined in start_proxy.sh
HARDWARE_PORT=Wi-Fi
# Disable SOCKS
networksetup -setsocksfirewallproxystate $HARDWARE_PORT off