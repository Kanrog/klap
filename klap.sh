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

if [ -f "$CONFIG_PATH" ]; then
    echo "Enabling mouse cursor..."
    # Remove any existing show_cursor lines to avoid duplicates
    sed -i '/show_cursor/d' "$CONFIG_PATH"
    # Ensure [main] section exists before appending
    if ! grep -q "\[main\]" "$CONFIG_PATH"; then
        echo -e "\n[main]" >> "$CONFIG_PATH"
    fi
    # Add the setting under [main]
    sed -i '/\[main\]/a show_cursor: True' "$CONFIG_PATH"
    
    echo "Restarting KlipperScreen to apply changes..."
    systemctl restart KlipperScreen
else
    echo "KlipperScreen.conf not found at $CONFIG_PATH. Skipping cursor config."
fi

echo "--- Optimization complete! Please type 'sudo reboot' to finish. ---"