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
echo "Configuring NetworkManager..."
cat <<EOF > /etc/NetworkManager/conf.d/99-klipper-screen.conf
[main]
auth-polkit=false
EOF
systemctl restart NetworkManager

# 3. Enable Mouse Cursor
CONFIG_PATH="/home/klap/printer_data/config/KlipperScreen.conf"

echo "Configuring KlipperScreen..."

# Create file if it doesn't exist
if [ ! -f "$CONFIG_PATH" ]; then
    touch "$CONFIG_PATH"
fi

# Use a clean approach: extract everything NOT related to [main] 
# and rebuild the config file with the correct [main] block.
TMP_CONFIG=$(mktemp)
grep -v "\[main\]" "$CONFIG_PATH" | grep -v "show_cursor" > "$TMP_CONFIG"

{
    echo "[main]"
    echo "show_cursor: True"
    cat "$TMP_CONFIG"
} > "$CONFIG_PATH"

rm "$TMP_CONFIG"

echo "Restarting KlipperScreen..."
systemctl restart KlipperScreen

# Give the user time to read the final message before the UI takes over
echo "--- Optimization complete! Please type 'sudo reboot' to finish. ---"
sleep 5