#!/usr/bin/env bash
set -euo pipefail

PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [[ ${EUID} -ne 0 ]]; then
  echo -e "${RED}[!]${RESET} This script must be run as root."
  echo -e "${GREEN}[*]${RESET} Try: sudo bash build/build.sh"
  exit 1
fi

echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}║    Exu Linux ISO Builder - Fully Branded Installer        ║${RESET}"
echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

for dep in arch-install-scripts archiso pacman-contrib; do
  if ! pacman -Q "$dep" >/dev/null 2>&1; then
    echo -e "${RED}[!]${RESET} Missing dependency: $dep"
    echo -e "${GREEN}[*]${RESET} Install with: sudo pacman -S $dep"
    exit 1
  fi
done

echo -e "${GREEN}[*]${RESET} Checking dependencies..."
echo -e "${GREEN}[✓]${RESET} All dependencies found"
echo ""

echo -e "${GREEN}[*]${RESET} Cleaning temporary files..."
rm -rf /tmp/* 2>/dev/null || true

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/." && pwd)"
BUILD_BASE="${HOME}/exu-iso-build-work"
WORK_DIR="${BUILD_BASE}/exu-iso-build"
OUTPUT_DIR="${BUILD_BASE}/exu-output"
WORK_TMP="${BUILD_BASE}/archiso-work"

echo -e "${GREEN}[*]${RESET} Cleaning old build directories..."
rm -rf "${BUILD_BASE}"
mkdir -p "${WORK_DIR}" "${OUTPUT_DIR}" "${WORK_TMP}"

echo -e "${GREEN}[*]${RESET} Creating work directory at ${WORK_DIR}..."
cd "${WORK_DIR}"

echo -e "${GREEN}[*]${RESET} Setting up archiso base from /usr/share/archiso/configs/releng..."
cp -r /usr/share/archiso/configs/releng exu-build
cd exu-build

echo -e "${GREEN}[*]${RESET} Configuring Exu Linux packages..."
cat > packages.x86_64 <<'EOF_PACKAGES'
base
linux
linux-firmware
intel-ucode
amd-ucode
grub
efibootmgr
dosfstools
ntfsprogs
lvm2
btrfs-progs
syslinux
memtest86+
memtest86+-efi
edk2-shell
networkmanager
openssh
dhcpcd
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
xorg-server
xorg-xinit
mesa
xf86-video-vesa
plasma-desktop
plasma-nm
plasma-pa
plasma-workspace
kde-applications-meta
konsole
dolphin
kwrite
kcalc
kdeconnect
plasma-firewall
plasma-systemmonitor
pipewire
pipewire-audio
pipewire-pulse
alsa-utils
noto-fonts
noto-fonts-emoji
ttf-liberation
terminus-font
calamares
kde-gtk-config
breeze
breeze-icons
qt5-base
qt5-declarative
qt5-svg
kconfig
kcoreaddons
kdbusaddons
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
solid
EOF_PACKAGES

echo -e "${GREEN}[*]${RESET} Setting up Calamares installer..."
mkdir -p airootfs/etc/calamares \
         airootfs/usr/share/calamares/branding/exu \
         airootfs/usr/share/calamares/branding/exu/images \
         airootfs/usr/share/backgrounds \
         airootfs/usr/share/pixmaps \
         airootfs/etc/profile.d \
         airootfs/etc/skel/.local/share/color-schemes \
         airootfs/etc/skel/.local/share/plasma/desktoptheme \
         airootfs/usr/local/bin

echo -e "${GREEN}[*]${RESET} Installing Calamares configuration..."
if [[ -f "${REPO_ROOT}/installer/calamares/settings.conf" ]]; then
  cp "${REPO_ROOT}/installer/calamares/settings.conf" airootfs/etc/calamares/settings.conf
else
  cat > airootfs/etc/calamares/settings.conf <<'EOF_CALAMARES_SETTINGS'
branding: exu
entropy: 160
pythonjobs: 1

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
    - hwclock
    - grubcfg
    - bootloader
    - umount
  - show:
    - finished
EOF_CALAMARES_SETTINGS
fi

echo -e "${GREEN}[*]${RESET} Installing Calamares branding descriptor..."
if [[ -f "${REPO_ROOT}/installer/calamares/branding/exu/branding.desc" ]]; then
  cp "${REPO_ROOT}/installer/calamares/branding/exu/branding.desc" airootfs/usr/share/calamares/branding/exu/branding.desc
else
  cat > airootfs/usr/share/calamares/branding/exu/branding.desc <<'EOF_BRANDING_DESC'
---
branding:
  distribution: Exu Linux
  logo: logo.png
  logo_text: Exu Linux
  icon: exulinux
  primary_color: "#6C5CE7"
  secondary_color: "#A29BFE"
  accent_color: "#00B894"
  text_dark: "#2D3436"
  text_light: "#F5F6FA"

slideshow:
  images_dir: images
  interval: 5000

sidebar:
  background_color: "#2D3436"
  text_color: "#F5F6FA"
EOF_BRANDING_DESC
fi

echo -e "${GREEN}[*]${RESET} Installing Exu branding assets..."
if [[ -f "${REPO_ROOT}/branding/logo/exu-logo.svg" ]]; then
  cp "${REPO_ROOT}/branding/logo/exu-logo.svg" airootfs/usr/share/pixmaps/exu-logo.svg
  ln -sf exu-logo.svg airootfs/usr/share/pixmaps/exulinux-logo.svg
else
  echo -e "${RED}[!]${RESET} Warning: exu-logo.svg not found"
fi

if [[ -f "${REPO_ROOT}/branding/wallpapers/exu-wallpaper.svg" ]]; then
  cp "${REPO_ROOT}/branding/wallpapers/exu-wallpaper.svg" airootfs/usr/share/backgrounds/exu-wallpaper.svg
  cp "${REPO_ROOT}/branding/wallpapers/exu-wallpaper.svg" airootfs/usr/share/calamares/branding/exu/images/exu-wallpaper.svg
else
  echo -e "${RED}[!]${RESET} Warning: exu-wallpaper.svg not found"
fi

# Create minimal PNG for Calamares branding fallback
echo -e "${GREEN}[*]${RESET} Creating Calamares branding PNG..."
python3 - <<'PY' 2>/dev/null || true
from pathlib import Path
import base64
# Minimal 1x1 transparent PNG
png_b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
Path('airootfs/usr/share/calamares/branding/exu/logo.png').write_bytes(base64.b64decode(png_b64))
PY

echo -e "${GREEN}[*]${RESET} Configuring Exu Linux environment profile..."
cat > airootfs/etc/profile.d/exu.sh <<'EOF_PROFILE'
export PATH="/usr/local/bin:$PATH"
export XDG_CURRENT_DESKTOP=KDE
export QT_QPA_PLATFORMTHEME=kde
EOF_PROFILE
chmod +x airootfs/etc/profile.d/exu.sh

echo -e "${GREEN}[*]${RESET} Adding ExuFetch system information tool..."
cat > airootfs/usr/local/bin/exufetch <<'EOF_EXUFETCH'
#!/usr/bin/env bash
PURPLE='\033[38;2;108;92;231m'
GREEN='\033[38;2;0;184;148m'
LIGHT='\033[38;2;245;246;250m'
RESET='\033[0m'
BOLD='\033[1m'

printf '%b' "${PURPLE}"
printf '\n'
printf '    ╔═══════════════════════════════════╗\n'
printf '    ║       EXU LINUX v1.0              ║\n'
printf '    ║   Simple. Fast. Beautiful.        ║\n'
printf '    ╚═══════════════════════════════════╝\n'
printf '%b' "${RESET}"
printf '\n'
printf '%b' "${BOLD}${PURPLE}System Information${RESET}\n"
printf '%b' "${PURPLE}───────────────────────────────────${RESET}\n"
printf '%b' "${GREEN}OS${RESET}           ${LIGHT}Exu Linux${RESET}\n"
printf '%b' "${GREEN}Kernel${RESET}       ${LIGHT}$(uname -r)${RESET}\n"
printf '%b' "${GREEN}Uptime${RESET}       ${LIGHT}$(uptime -p 2>/dev/null || echo 'N/A')${RESET}\n"
printf '%b' "${GREEN}Desktop${RESET}      ${LIGHT}KDE Plasma${RESET}\n"
printf '%b' "${GREEN}Shell${RESET}        ${LIGHT}$(basename "$SHELL")${RESET}\n"
printf '%b' "${GREEN}Packages${RESET}     ${LIGHT}$(pacman -Q 2>/dev/null | wc -l)${RESET}\n"
printf '\n'
printf '%b' "${BOLD}${PURPLE}Hardware${RESET}\n"
printf '%b' "${PURPLE}───────────────────────────────────${RESET}\n"
printf '%b' "${GREEN}CPU${RESET}         ${LIGHT}$(lscpu 2>/dev/null | grep 'Model name' | cut -d':' -f2 | xargs || echo 'Unknown')${RESET}\n"
printf '%b' "${GREEN}Memory${RESET}      ${LIGHT}$(free -h 2>/dev/null | awk '/^Mem/ {print $3 " / " $2}' || echo 'N/A')${RESET}\n"
printf '%b' "${GREEN}Disk${RESET}        ${LIGHT}$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2}' || echo 'N/A')${RESET}\n"
printf '\n'
printf '%b' "${LIGHT}Simple. Fast. Beautiful.${RESET}\n"
EOF_EXUFETCH
chmod +x airootfs/usr/local/bin/exufetch

echo -e "${GREEN}[*]${RESET} Configuring custom bashrc..."
cat > airootfs/root/.bashrc <<'EOF_BASHRC'
export PS1='\[\033[38;2;108;92;231m\]exu\[\033[0m\]@\h:\w$ '
if [ -z "${EXUFETCH_SHOWN:-}" ]; then
  /usr/local/bin/exufetch 2>/dev/null || true
  export EXUFETCH_SHOWN=1
fi
EOF_BASHRC

echo -e "${GREEN}[*]${RESET} Setting Exu Linux hostname..."
cat > airootfs/etc/hostname <<'EOF_HOSTNAME'
exu-linux
EOF_HOSTNAME

echo -e "${GREEN}[*]${RESET} Installing KDE color scheme..."
cat > airootfs/etc/skel/.local/share/color-schemes/ExuLinux.colors <<'EOF_COLORSCHEME'
[ColorScheme]
Name=Exu Linux

[General]
ForegroundNormal=30,30,30
BackgroundNormal=245,246,250

[Button]
BackgroundNormal=240,241,245
ForegroundNormal=30,30,30
BackgroundPressed=108,92,231
ForegroundPressed=245,246,250

[Selection]
BackgroundNormal=108,92,231
ForegroundNormal=245,246,250

[View]
BackgroundNormal=245,246,250
ForegroundNormal=30,30,30

[Window]
BackgroundNormal=240,241,245
ForegroundNormal=30,30,30
Decoration=108,92,231
EOF_COLORSCHEME

echo -e "${GREEN}[*]${RESET} Setting up live desktop wallpaper..."
cat > airootfs/etc/skel/.config/plasmarc <<'EOF_PLASMARC'
[General]
plasmaTheme=breeze-dark
desktopTheme=breeze-dark
widgetStyle=breeze

[ScreenConnectors]
DP-1=

[PlasmaViews]
Panel 0/floating=false
Panel 0/height=37
Panel 0/length=100

EOF_PLASMARC

echo -e "${GREEN}[*]${RESET} Configuring KDE desktop defaults..."
mkdir -p airootfs/etc/skel/.config
cat > airootfs/etc/skel/.config/kscreenlocker_greetdrc <<'EOF_LOCKSCREEN'
[General]
ShowFacesIdentifier=true
EOF_LOCKSCREEN

echo -e "${GREEN}[*]${RESET} Building ISO image..."
echo -e "${GREEN}[*]${RESET} This may take 20-40 minutes..."
echo ""

echo -e "${GREEN}[*]${RESET} Using build directory: ${BUILD_BASE}"
echo -e "${GREEN}[*]${RESET} Using temp directory: ${WORK_TMP}"
echo ""

export TMPDIR="${WORK_TMP}"
export TMP="${WORK_TMP}"
export TEMP="${WORK_TMP}"

BUILDDIR="${WORK_TMP}" mkarchiso -v -w "${WORK_TMP}" -o "${OUTPUT_DIR}" .

echo ""
echo -e "${GREEN}[✓]${RESET} ISO build complete!"
echo -e "${GREEN}[✓]${RESET} Output: ${OUTPUT_DIR}/"
echo ""

ISO_FILE="$(find "${OUTPUT_DIR}" -maxdepth 1 -type f -name '*.iso' 2>/dev/null | head -n 1)"
if [[ -z "${ISO_FILE}" ]]; then
  echo -e "${RED}[!]${RESET} ISO file not found in ${OUTPUT_DIR}"
  ls -la "${OUTPUT_DIR}"
  exit 1
fi

ISO_SIZE=$(du -h "${ISO_FILE}" | cut -f1)
ISO_NAME=$(basename "${ISO_FILE}")

echo -e "${GREEN}[✓]${RESET} ISO file: ${ISO_NAME}"
echo -e "${GREEN}[✓]${RESET} Size: ${ISO_SIZE}"
echo ""
echo -e "${PURPLE}Next steps:${RESET}"
echo -e "  1. Copy ISO: ${GREEN}sudo cp ${ISO_FILE} ~/ && sudo chown \$USER ~/${ISO_NAME}${RESET}"
echo -e "  2. Write to USB: ${GREEN}sudo dd if=~/${ISO_NAME} of=/dev/sdX bs=4M status=progress${RESET}"
echo -e "  3. Replace sdX with your USB device (use 'lsblk' to identify)"
echo -e "  4. Sync: ${GREEN}sync${RESET}"
echo -e "  5. Boot from USB and use Calamares graphical installer"
echo ""
echo -e "${GREEN}Build files in: ${BUILD_BASE}${RESET}"
echo -e "${GREEN}Branded ISO ready with KDE Plasma and Calamares installer!${RESET}"
echo ""
