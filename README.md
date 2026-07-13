# Klap: Laptop Klipper Optimizer

A lightweight, no-nonsense utility to optimize x86 laptops for Klipper / KlipperScreen duty. 

### Why Klap?
When running Klipper on repurposed "e-waste" hardware, you shouldn't have to fight the OS to keep the printer alive. This script automates the standard "Maker Terminal" tweaks so you can focus on printing, not troubleshooting.

### What it does:
*   **Lid Switch:** Disables system suspend when closing the lid, keeping your print running even if the laptop is tucked away.
*   **NetworkManager:** Adjusts polkit authentication to ensure your screen connects without credential prompts.
*   **KlipperScreen Cursor:** Automatically forces the mouse cursor to appear so you can navigate the UI with a trackpad or mouse.

### Installation & Usage

1.  **SSH into your host** and run the following commands:

```bash
# Download the script
curl -s [https://raw.githubusercontent.com/Kanrog/klap/main/klap.sh](https://raw.githubusercontent.com/Kanrog/klap/main/klap.sh) > klap.sh

# Make it executable
chmod +x klap.sh

# Run with root privileges
sudo ./klap.sh
```

2.  **Follow the on-screen prompts** and reboot when finished to apply all settings.

### Troubleshooting
*   **"Command not found":** Ensure you are in the folder where you downloaded `klap.sh` and that you used `chmod +x`.
*   **Missing Cursor:** Ensure your `KlipperScreen.conf` is located at `~/printer_data/config/KlipperScreen.conf`. The script will automatically detect and configure this for you.