#!/bin/bash
# Exu Linux ISO Build Script - Fixed with proper temp handling
# This script builds the Exu Linux ISO from source

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║       Exu Linux ISO Builder v1.0                          ║${RESET}"
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

# Clean /tmp first
echo -e "${GREEN}[*]${RESET} Cleaning /tmp..."
rm -rf /tmp/* 2>/dev/null || true

# Use home directory for build (not /tmp which is small)
BUILD_BASE="$HOME/exu-iso-build-work"
WORK_DIR="$BUILD_BASE/exu-iso-build"
OUTPUT_DIR="$BUILD_BASE/exu-output"

echo -e "${GREEN}[*]${RESET} Cleaning old build directories..."
rm -rf "$BUILD_BASE"

echo -e "${GREEN}[*]${RESET} Creating work directory at $WORK_DIR..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Copy archiso baseline
echo -e "${GREEN}[*]${RESET} Setting up archiso base..."
cp -r /usr/share/archiso/configs/releng exu-build
cd exu-build

# Add Exu Linux packages to packages.x86_64
echo -e "${GREEN}[*]${RESET} Adding Exu Linux packages..."
cat >> packages.x86_64 << 'EOFPKG'

# KDE Plasma Desktop Environment
plasma-desktop
plasma-nm
plasma-pa
kde-applications-meta
konsole
dolphin
kwrite
kcalc
kdeconnect

# System Utilities  
htop
git
curl
wget
nano
vim
tree
bat

# Display & Graphics
xorg-server
xorg-xinit
mesa
xf86-video-vesa

# Fonts
noto-fonts
noto-fonts-emoji
ttf-liberation

# Audio
pipewire
pipewire-audio

# Networking
networkmanager
openssh

# Other essentials
sudo
which
EOFPKG

# Create basic Calamares config inline
echo -e "${GREEN}[*]${RESET} Configuring installer..."
mkdir -p airootfs/etc/calamares
cat > airootfs/etc/calamares/settings.conf << 'EOFCAL'
branding: exu

instances:
  - id: root
    weight: 80
    critical: true

sequence:
  - show:
    - welcome
    - locale
    - keyboard
    - partition
    - users
    - summary
  - exec:
    - partition
    - mount
    - unpackfs
    - machineid
    - fstab
    - locale
    - keyboard
    - localtime
    - users
    - displaymanager
    - networkcfg
    - grubcfg
    - bootloader
    - umount
  - show:
    - finished
EOFCAL

# Add ExuFetch inline
echo -e "${GREEN}[*]${RESET} Adding ExuFetch system information tool..."
mkdir -p airootfs/usr/local/bin
cat > airootfs/usr/local/bin/exufetch << 'EOFETCH'
#!/bin/bash
# ExuFetch - System Information for Exu Linux

PURPLE='\033[38;2;108;92;231m'
GREEN='\033[38;2;0;184;148m'
LIGHT='\033[38;2;245;246;250m'
RESET='\033[0m'
BOLD='\033[1m'

print_logo() {
    echo -e "${PURPLE}"
    echo "    ╔═══════════════════════════════════╗"
    echo "    ║       EXU LINUX v1.0              ║"
    echo "    ║   Simple. Fast. Beautiful.        ║"
    echo "    ╚═══════════════════════════════════╝"
    echo -e "${RESET}"
}

print_info() {
    echo -e "${BOLD}${PURPLE}System Information${RESET}"
    echo -e "${PURPLE}───────────────────────────────────${RESET}"
    echo -e "${GREEN}OS${RESET}           ${LIGHT}Exu Linux${RESET}"
    echo -e "${GREEN}Kernel${RESET}       ${LIGHT}$(uname -r)${RESET}"
    echo -e "${GREEN}Uptime${RESET}       ${LIGHT}$(uptime -p 2>/dev/null || echo 'N/A')${RESET}"
    echo -e "${GREEN}Desktop${RESET}      ${LIGHT}KDE Plasma${RESET}"
    echo -e "${GREEN}Shell${RESET}        ${LIGHT}$(basename $SHELL)${RESET}"
    echo -e "${GREEN}Packages${RESET}     ${LIGHT}$(pacman -Q 2>/dev/null | wc -l)${RESET}"
    echo -e ""
    echo -e "${BOLD}${PURPLE}Hardware${RESET}"
    echo -e "${PURPLE}───────────────────────────────────${RESET}"
    echo -e "${GREEN}CPU${RESET}         ${LIGHT}$(lscpu 2>/dev/null | grep 'Model name' | cut -d':' -f2 | xargs || echo 'Unknown')${RESET}"
    echo -e "${GREEN}Memory${RESET}      ${LIGHT}$(free -h 2>/dev/null | awk '/^Mem/ {print $3 " / " $2}' || echo 'N/A')${RESET}"
    echo -e "${GREEN}Disk${RESET}        ${LIGHT}$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}' || echo 'N/A')${RESET}"
    echo -e ""
    echo -e "${LIGHT}Simple. Fast. Beautiful.${RESET}"
}

print_logo
print_info
EOFETCH

chmod +x airootfs/usr/local/bin/exufetch

# Add Exu branding colors
echo -e "${GREEN}[*]${RESET} Adding Exu Linux branding..."
mkdir -p airootfs/etc/exu
cat > airootfs/etc/exu/colors.conf << 'EOFCOL'
EXU_PRIMARY=#6C5CE7
EXU_PRIMARY_LIGHT=#A29BFE
EXU_ACCENT=#00B894
EXU_DARK=#2D3436
EXU_LIGHT=#F5F6FA
EXU_TEXT_DARK=#1E1E1E
EXU_TEXT_LIGHT=#FFFFFF
EOFCOL

# Create KDE Plasma color scheme inline
mkdir -p airootfs/etc/skel/.local/share/color-schemes
cat > airootfs/etc/skel/.local/share/color-schemes/ExuLinux.colors << 'EOFCOLORS'
[ColorScheme]
Name=Exu Linux

[General]
ForegroundNormal=30,30,30
BackgroundNormal=245,246,250

[Button]
BackgroundNormal=240,241,245
ForegroundNormal=30,30,30

[Selection]
BackgroundNormal=108,92,231
ForegroundNormal=245,246,250

[View]
BackgroundNormal=245,246,250
ForegroundNormal=30,30,30

[Window]
BackgroundNormal=240,241,245
ForegroundNormal=30,30,30
EOFCOLORS

# Create custom bashrc for Exu branding
mkdir -p airootfs/root
cat > airootfs/root/.bashrc << 'EOFBASH'
# Exu Linux bash configuration
export PS1="\[\033[38;2;108;92;231m\]exu\[\033[0m\]@\h:\w$ "

# Welcome message
if [ -z "$EXUFETCH_SHOWN" ]; then
    echo ""
    /usr/local/bin/exufetch 2>/dev/null || true
    echo ""
    export EXUFETCH_SHOWN=1
fi
EOFBASH

# Create custom profile for Exu
echo -e "${GREEN}[*]${RESET} Creating Exu Linux profile..."
mkdir -p airootfs/etc/profile.d
cat > airootfs/etc/profile.d/exu.sh << 'EOFPROFILE'
# Exu Linux environment
export PATH="/usr/local/bin:$PATH"
EOFPROFILE

chmod +x airootfs/etc/profile.d/exu.sh

# Build ISO
echo -e "${GREEN}[*]${RESET} Building ISO image..."
echo -e "${GREEN}[*]${RESET} This may take 15-40 minutes..."
echo ""

# Set work directory for archiso
WORK_TMP="$BUILD_BASE/archiso-work"
mkdir -p "$WORK_TMP"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[*]${RESET} Using build directory: $BUILD_BASE"
echo -e "${GREEN}[*]${RESET} Using temp directory: $WORK_TMP"
echo ""

# Set environment variables to avoid /tmp
export TMPDIR="$WORK_TMP"
export TMP="$WORK_TMP"
export TEMP="$WORK_TMP"

# Run mkarchiso with explicit temp directory
# Use BUILDDIR to ensure archiso uses our temp dir
BUILDDIR="$WORK_TMP" mkarchiso -v -w "$WORK_TMP" -o "$OUTPUT_DIR" .

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
    echo -e "  3. Sync: ${GREEN}sync${RESET}"
    echo -e "  4. Boot from USB and follow the installer"
    echo ""
    echo -e "${GREEN}Build files in: $BUILD_BASE${RESET}"
else
    echo -e "${RED}[!]${RESET} ISO file not found in $OUTPUT_DIR"
    ls -la "$OUTPUT_DIR"
    exit 1
fi
