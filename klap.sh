#!/bin/bash

# Ensure running as sudo
if [ "$EUID" -ne 0 ]; then echo "Please run as root"; exit; fi

echo "Optimizing laptop for KlipperScreen..."

# 1. Disable Lid Sleep
sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
systemctl restart systemd-logind

# 2. Fix NetworkManager Polkit (Allows KlipperScreen to manage WiFi)
cat <<EOF > /etc/NetworkManager/conf.d/99-klipper-screen.conf
[main]
auth-polkit=false
EOF
systemctl restart NetworkManager

# 3. Enable Mouse Cursor in KlipperScreen
# Assuming the user installs KlipperScreen in the default home directory
if [ -f /home/$SUDO_USER/KlipperScreen/KlipperScreen.conf ]; then
    sed -i 's/show_cursor: False/show_cursor: True/' /home/$SUDO_USER/KlipperScreen/KlipperScreen.conf
    # Add if missing
    grep -q "show_cursor" /home/$SUDO_USER/KlipperScreen/KlipperScreen.conf || sed -i '/\[main\]/a show_cursor: True' /home/$SUDO_USER/KlipperScreen/KlipperScreen.conf
fi

echo "Optimization complete! Please reboot."