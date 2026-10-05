#!/bin/bash
# Exu Linux ISO Build Script
# This script builds the Exu Linux ISO from source

set -e

# Color output
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${PURPLE}╔════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║       Exu Linux ISO Builder v1.0       ║${RESET}"
echo -e "${PURPLE}╚════════════════════════════════════════╝${RESET}"
echo ""

# Check dependencies
echo -e "${GREEN}[*]${RESET} Checking dependencies..."
DEPS=(arch-install-scripts archiso pacman-contrib)
for dep in "${DEPS[@]}"; do
    if ! pacman -Q "$dep" &> /dev/null; then
        echo -e "${RED}[!]${RESET} Missing dependency: $dep"
        echo -e "${GREEN}[*]${RESET} Install with: sudo pacman -S $dep"
        exit 1
    fi
done
echo -e "${GREEN}[✓]${RESET} All dependencies found"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!]${RESET} This script must be run as root"
    exit 1
fi

# Create work directory
WORK_DIR="/tmp/exu-iso-build"
echo -e "${GREEN}[*]${RESET} Creating work directory at $WORK_DIR..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Copy archiso baseline
echo -e "${GREEN}[*]${RESET} Setting up archiso base..."
cp -r /usr/share/archiso/configs/releng exu-build
cd exu-build

# Customize packages
echo -e "${GREEN}[*]${RESET} Adding Exu Linux packages..."
cat >> packages.x86_64 << 'EOF'
# KDE Plasma
plasma-desktop
plasma-wayland-session
plasma-nm
plasma-pa
kde-applications
konsole
dolphin

# Utilities
neofetch
htop
git
curl

# Exu branding
exu-branding
exufetch
EOF

# Copy Calamares config
echo -e "${GREEN}[*]${RESET} Configuring Calamares installer..."
mkdir -p airootfs/etc/calamares
cp ../../installer/calamares/settings.conf airootfs/etc/calamares/
mkdir -p airootfs/usr/share/calamares/branding/exu
cp -r ../../installer/calamares/branding/exu/* airootfs/usr/share/calamares/branding/exu/

# Add KDE Plasma theme
echo -e "${GREEN}[*]${RESET} Adding KDE Plasma theme..."
mkdir -p airootfs/etc/skel/.local/share/color-schemes
cp ../../kde-plasma-theme/color-scheme/*.colors airootfs/etc/skel/.local/share/color-schemes/

# Add ExuFetch
echo -e "${GREEN}[*]${RESET} Adding ExuFetch tool..."
mkdir -p airootfs/usr/local/bin
cp ../../exufetch/exufetch.sh airootfs/usr/local/bin/exufetch
chmod +x airootfs/usr/local/bin/exufetch

# Add branding
echo -e "${GREEN}[*]${RESET} Adding Exu Linux branding..."
mkdir -p airootfs/etc/exu
cp ../../branding/colors/exu-colors.conf airootfs/etc/exu/

# Build ISO
echo -e "${GREEN}[*]${RESET} Building ISO image..."
echo -e "${GREEN}[*]${RESET} This may take several minutes..."
echo ""

./mkarchiso -v -w /tmp/archiso-tmp -o /tmp/exu-output exu-build

echo ""
echo -e "${GREEN}[✓]${RESET} ISO build complete!"
echo -e "${GREEN}[✓]${RESET} Output: /tmp/exu-output/"
echo ""
echo -e "${PURPLE}Next steps:${RESET}"
echo -e "  1. Verify the ISO: ${GREEN}ls -lh /tmp/exu-output/*.iso${RESET}"
echo -e "  2. Write to USB: ${GREEN}sudo dd if=/tmp/exu-output/exu-linux.iso of=/dev/sdX bs=4M${RESET}"
echo -e "  3. Boot from USB and run the Calamares installer"
echo ""
