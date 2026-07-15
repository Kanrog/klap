#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./klap.sh)"
  exit 1
fi

echo "--- Klap: Laptop Klipper Optimizer ---"
read -p "This script will modify system settings for KlipperScreen. Proceed? [y/N] " confirm
if [[ $confirm != [yY] ]]; then
  echo "Aborting."
  exit 1
fi

# 1. Disable Lid Sleep
echo "Disabling lid suspend..."
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
systemctl restart systemd-logind

# 2. Fix NetworkManager Polkit
echo "Configuring NetworkManager Permissions..."
cat <<EOF > /etc/NetworkManager/conf.d/99-klipper-screen.conf
[main]
auth-polkit=false
EOF

# 3. Fix "Not Managed" Wi-Fi Error (Debian Netinst conflict)
echo "Transferring network management to NetworkManager..."
cat <<EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
EOF

# Restart NetworkManager to apply both fixes above
systemctl restart NetworkManager

# 4. Enable Mouse Cursor
CONFIG_PATH="/home/klap/printer_data/config/KlipperScreen.conf"

echo "Configuring KlipperScreen..."

# Create directory and file if they don't exist
mkdir -p "$(dirname "$CONFIG_PATH")"
if [ ! -f "$CONFIG_PATH" ]; then
    touch "$CONFIG_PATH"
fi

# Cleanly rebuild the configuration file
TMP_CONFIG=$(mktemp)
# Filter out existing [main] and show_cursor settings to avoid duplicates
grep -v "\[main\]" "$CONFIG_PATH" | grep -v "show_cursor" > "$TMP_CONFIG"

# Write the fresh [main] block and append the rest of the existing config
{
    echo "[main]"
    echo "show_cursor: True"
    cat "$TMP_CONFIG"
} > "$CONFIG_PATH"

rm "$TMP_CONFIG"

echo "--- Optimization complete! ---"
read -p "Would you like to reboot now to apply changes? [y/N] " reboot_confirm
if [[ $reboot_confirm == [yY] ]]; then
  echo "Rebooting..."
  sudo reboot
else
  echo "Please remember to type 'sudo reboot' later to finish the setup."
fi