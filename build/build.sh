#!/bin/bash
# Exu Linux ISO Build Script
# This script builds the Exu Linux ISO from source

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Color output
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║       Exu Linux ISO Builder v1.0       ║${RESET}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!]${RESET} This script must be run as root"
    echo -e "${GREEN}[*]${RESET} Try: sudo bash build/build.sh"
    exit 1
fi

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

# Create work directory
WORK_DIR="/tmp/exu-iso-build"
echo -e "${GREEN}[*]${RESET} Creating work directory at $WORK_DIR..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Copy archiso baseline
echo -e "${GREEN}[*]${RESET} Setting up archiso base..."
cp -r /usr/share/archiso/configs/releng exu-build
cd exu-build

# Customize packages
echo -e "${GREEN}[*]${RESET} Adding Exu Linux packages..."
cat >> packages.x86_64 << 'EOF'

# KDE Plasma Desktop
plasma-desktop
plasma-wayland-session
plasma-nm
plasma-pa
plasma-workspace
kde-applications
konsole
dolphin
kwrite
kcalc

# System utilities
neofetch
htop
git
curl
wget
nano
vim

# Fonts
noto-fonts
noto-fonts-emoji

# Other essentials
networkmanager
sudo
EOF

# Copy Calamares config
echo -e "${GREEN}[*]${RESET} Configuring Calamares installer..."
mkdir -p "airootfs/etc/calamares"
cp "$REPO_ROOT/installer/calamares/settings.conf" "airootfs/etc/calamares/" 2>/dev/null || echo -e "${PURPLE}[~]${RESET} Calamares settings not found (optional)"

mkdir -p "airootfs/usr/share/calamares/branding/exu"
cp -r "$REPO_ROOT/installer/calamares/branding/exu/"* "airootfs/usr/share/calamares/branding/exu/" 2>/dev/null || echo -e "${PURPLE}[~]${RESET} Calamares branding not found (optional)"

# Add KDE Plasma theme
echo -e "${GREEN}[*]${RESET} Adding KDE Plasma theme..."
mkdir -p "airootfs/etc/skel/.local/share/color-schemes"
cp "$REPO_ROOT/kde-plasma-theme/color-scheme/"*.colors "airootfs/etc/skel/.local/share/color-schemes/" 2>/dev/null || echo -e "${PURPLE}[~]${RESET} Color schemes not found (optional)"

# Add ExuFetch
echo -e "${GREEN}[*]${RESET} Adding ExuFetch tool..."
mkdir -p "airootfs/usr/local/bin"
cp "$REPO_ROOT/exufetch/exufetch.sh" "airootfs/usr/local/bin/exufetch"
chmod +x "airootfs/usr/local/bin/exufetch"

# Add branding
echo -e "${GREEN}[*]${RESET} Adding Exu Linux branding..."
mkdir -p "airootfs/etc/exu"
cp "$REPO_ROOT/branding/colors/exu-colors.conf" "airootfs/etc/exu/" 2>/dev/null || echo -e "${PURPLE}[~]${RESET} Branding colors not found (optional)"

# Create rootfs hooks for branding
mkdir -p "airootfs/root"
cat > "airootfs/root/.bashrc" << 'EOF'
# Exu Linux bashrc
export PS1="\[\033[38;2;108;92;231m\]exu\[\033[0m\]@\h:\w$ "
EOF

# Build ISO
echo -e "${GREEN}[*]${RESET} Building ISO image..."
echo -e "${GREEN}[*]${RESET} This may take 10-30 minutes..."
echo ""

OUTPUT_DIR="/tmp/exu-output"
mkdir -p "$OUTPUT_DIR"

# Run mkarchiso
sudo mkarchiso -v -w /tmp/archiso-tmp -o "$OUTPUT_DIR" .

echo ""
echo -e "${GREEN}[✓]${RESET} ISO build complete!"
echo -e "${GREEN}[✓]${RESET} Output: $OUTPUT_DIR/"
echo ""

# Find the ISO file
ISO_FILE=$(ls -1 "$OUTPUT_DIR"/*.iso 2>/dev/null | head -n 1)

if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo -e "${GREEN}[✓]${RESET} ISO file: $(basename "$ISO_FILE")"
    echo -e "${GREEN}[✓]${RESET} Size: $ISO_SIZE"
    echo ""
    echo -e "${PURPLE}Next steps:${RESET}"
    echo -e "  1. Write to USB: ${GREEN}sudo dd if=$ISO_FILE of=/dev/sdX bs=4M status=progress${RESET}"
    echo -e "  2. Replace sdX with your USB device (use 'lsblk' to find it)"
    echo -e "  3. Boot from USB and run the Calamares installer"
    echo ""
else
    echo -e "${RED}[!]${RESET} ISO file not found in $OUTPUT_DIR"
    exit 1
fi
