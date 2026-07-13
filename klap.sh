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

# 2. Fix NetworkManager Polkit (Allows Wi-Fi management in KlipperScreen)
echo "Configuring NetworkManager..."
cat <<EOF > /etc/NetworkManager/conf.d/99-klipper-screen.conf
[main]
auth-polkit=false
EOF
systemctl restart NetworkManager

# 3. Enable Mouse Cursor
# Target the user who invoked sudo to ensure we edit the correct home folder
USER_HOME=$(eval echo "~$SUDO_USER")

if [ -f "$USER_HOME/KlipperScreen/KlipperScreen.conf" ]; then
    echo "Enabling mouse cursor..."
    # If the file exists, update or add the setting
    if grep -q "show_cursor" "$USER_HOME/KlipperScreen/KlipperScreen.conf"; then
        sed -i 's/show_cursor:.*/show_cursor: True/' "$USER_HOME/KlipperScreen/KlipperScreen.conf"
    else
        sed -i '/\[main\]/a show_cursor: True' "$USER_HOME/KlipperScreen/KlipperScreen.conf"
    fi
else
    echo "KlipperScreen.conf not found. Skipping cursor config."
fi

echo "--- Optimization complete! Please reboot. ---"