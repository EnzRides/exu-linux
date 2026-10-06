#!/bin/bash
# Exu Linux ISO Build Script - With Calamares Graphical Installer
# This script builds the Exu Linux ISO from source

set -e

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║    Exu Linux ISO Builder v2.0 - With Calamares            ║${RESET}"
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

# Replace packages.x86_64 with Exu Linux packages
echo -e "${GREEN}[*]${RESET} Configuring Exu Linux packages..."
cat > packages.x86_64 << 'EOFPKG'
# Base system
base
linux
linux-firmware
intel-ucode
amd-ucode

# Boot & Partitioning
grub
efibootmgr
dosfstools
ntfsprogs
lvm2
btrfs-progs

# Networking
networkmanager
openssh
dhcpcd

# System utilities
sudo
which
htop
git
curl
wget
nano
vim
tree
bat
base-devel

# Display & Graphics
xorg-server
xorg-xinit
mesa
xf86-video-vesa

# KDE Plasma Desktop
plasma-desktop
plasma-nm
plasma-pa
kde-applications-meta
konsole
dolphin
kwrite
kcalc
kdeconnect
breeze
breeze-icons

# Fonts
noto-fonts
noto-fonts-emoji
ttf-liberation
terminus-font

# Audio
pipewire
pipewire-audio
pipewire-pulse
alsa-utils

# Graphical Installer - CALAMARES
calamares
ckbcomp
kconfig
kcoreaddons
kdbusaddons
kdeclarative
kdelibs4support
ki18n
kiconthemes
kio
kitemviews
kjobwidgets
knotifications
kpackage
kparts
kservice
kwidgetsaddons
kwindowsystem
kxmlgui
libxcb
qt5-base
qt5-declarative
qt5-svg
solid
yaml-cpp
EOFPKG

# Create Calamares configuration
echo -e "${GREEN}[*]${RESET} Setting up Calamares installer..."
mkdir -p airootfs/etc/calamares
mkdir -p airootfs/usr/share/calamares/branding/exu

# Main Calamares settings
cat > airootfs/etc/calamares/settings.conf << 'EOFCAL'
---
branding: exu

sequence:
  - show:
    - welcome
    - locale
    - keyboard
    - partition
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
    - networkcfg
    - grubcfg
    - bootloader
    - umount
  - show:
    - finished

users:
  - fullname: "User"
    username: "user"
    password: "user"
    autologinUser: false

branding:
  id: exu
  strings:
    productName: "Exu Linux"
    shortProductName: "Exu"
    versionShort: "1.0"
    versionLong: "Exu Linux 1.0"
    shortVersion: "1.0"
EOFCAL

# Create Calamares branding
cat > airootfs/usr/share/calamares/branding/exu/branding.desc << 'EOFBRAND'
---
componentName: exu

strings:
    productName: Exu Linux
    shortProductName: Exu
    version: "1.0"
    shortVersion: "1.0"
    versionedName: "Exu Linux 1.0"
    shortVersionedName: "Exu 1.0"
    bootloaderEntryName: "Exu Linux"
    productUrl: "https://github.com/EnzRides/exu-linux"

images:
    productLogo: "exu-logo.png"
    productIcon: "exu-icon.png"
    productWallpaper: "exu-wallpaper.png"

slideshow:
    slides: []
    interval: 5000

colors:
    primary: "#6C5CE7"
    accent: "#00B894"
    text: "#F5F6FA"
    background: "#1E1E1E"
EOFBRAND

# Create simple Exu branding images (using text-based placeholders)
mkdir -p airootfs/usr/share/calamares/branding/exu

cat > airootfs/usr/share/calamares/branding/exu/show.qml << 'EOFQML'
import QtQuick
import calamares.slideshow

Presentation {
    id: presentation

    Timer {
        id: advanceTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1E1E1E"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Welcome to Exu Linux"
                    color: "#6C5CE7"
                    font.pixelSize: 48
                    font.bold: true
                }

                Text {
                    text: "Simple. Fast. Beautiful."
                    color: "#00B894"
                    font.pixelSize: 24
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#2D3436"

            Column {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "KDE Plasma Desktop"
                    color: "#6C5CE7"
                    font.pixelSize: 36
                    font.bold: true
                }

                Text {
                    text: "A beautiful and powerful desktop environment"
                    color: "#F5F6FA"
                    font.pixelSize: 18
                }
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#1E1E1E"

            Column {
                anchors.centerIn: parent
                spacing: 15

                Text {
                    text: "Fast Installation"
                    color: "#00B894"
                    font.pixelSize: 36
                    font.bold: true
                }

                Text {
                    text: "Get up and running in minutes"
                    color: "#F5F6FA"
                    font.pixelSize: 18
                }
            }
        }
    }
}
EOFQML

# Add ExuFetch
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

# Add Exu branding
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

# KDE Plasma color scheme
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

# Custom bashrc
mkdir -p airootfs/root
cat > airootfs/root/.bashrc << 'EOFBASH'
# Exu Linux bash configuration
export PS1="\[\033[38;2;108;92;231m\]exu\[\033[0m\]@\h:\w$ "

if [ -z "$EXUFETCH_SHOWN" ]; then
    echo ""
    /usr/local/bin/exufetch 2>/dev/null || true
    echo ""
    export EXUFETCH_SHOWN=1
fi
EOFBASH

# Exu profile
mkdir -p airootfs/etc/profile.d
cat > airootfs/etc/profile.d/exu.sh << 'EOFPROFILE'
export PATH="/usr/local/bin:$PATH"
EOFPROFILE
chmod +x airootfs/etc/profile.d/exu.sh

# Build ISO
echo -e "${GREEN}[*]${RESET} Building ISO image..."
echo -e "${GREEN}[*]${RESET} This may take 20-40 minutes..."
echo ""

WORK_TMP="$BUILD_BASE/archiso-work"
mkdir -p "$WORK_TMP"
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}[*]${RESET} Using build directory: $BUILD_BASE"
echo -e "${GREEN}[*]${RESET} Using temp directory: $WORK_TMP"
echo ""

export TMPDIR="$WORK_TMP"
export TMP="$WORK_TMP"
export TEMP="$WORK_TMP"

BUILDDIR="$WORK_TMP" mkarchiso -v -w "$WORK_TMP" -o "$OUTPUT_DIR" .

echo ""
echo -e "${GREEN}[✓]${RESET} ISO build complete!"
echo -e "${GREEN}[✓]${RESET} Output: $OUTPUT_DIR/"
echo ""

ISO_FILE=$(ls -1 "$OUTPUT_DIR"/*.iso 2>/dev/null | head -n 1)

if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    echo -e "${GREEN}[✓]${RESET} ISO file: $(basename "$ISO_FILE")"
    echo -e "${GREEN}[✓]${RESET} Size: $ISO_SIZE"
    echo ""
    echo -e "${PURPLE}Next steps:${RESET}"
    echo -e "  1. Copy ISO: ${GREEN}sudo cp $ISO_FILE ~/ && sudo chown \$USER ~/$(basename $ISO_FILE)${RESET}"
    echo -e "  2. Write to USB: ${GREEN}sudo dd if=~/$(basename $ISO_FILE) of=/dev/sdX bs=4M status=progress${RESET}"
    echo -e "  3. Sync: ${GREEN}sync${RESET}"
    echo -e "  4. Boot from USB and use Calamares installer"
    echo ""
    echo -e "${GREEN}Build files in: $BUILD_BASE${RESET}"
else
    echo -e "${RED}[!]${RESET} ISO file not found in $OUTPUT_DIR"
    ls -la "$OUTPUT_DIR"
    exit 1
fi
