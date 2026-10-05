#!/bin/bash
# Install ExuFetch command

echo "[*] Installing ExuFetch..."

# Copy script to /usr/local/bin
sudo cp exufetch/exufetch.sh /usr/local/bin/exufetch
sudo chmod +x /usr/local/bin/exufetch

echo "[✓] ExuFetch installed successfully!"
echo "[*] Run 'exufetch' to display system information"
