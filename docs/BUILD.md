# Building Exu Linux ISO

This guide covers how to build the Exu Linux ISO from source.

## Prerequisites

### System Requirements
- Arch Linux host system
- 20GB+ free disk space
- 4GB+ RAM
- Internet connection

### Required Packages

```bash
sudo pacman -S archiso arch-install-scripts pacman-contrib
```

## Build Steps

### Option 1: Automated Build (Recommended)

```bash
cd exu-linux
sudo bash build/build.sh
```

The script will:
1. Validate dependencies
2. Copy archiso base configuration
3. Add Exu packages and customizations
4. Configure Calamares installer
5. Apply KDE Plasma theme
6. Build the ISO

### Option 2: Manual Build

```bash
# Copy archiso baseline
cp -r /usr/share/archiso/configs/releng exu-build
cd exu-build

# Add Exu packages to packages.x86_64
echo "exufetch" >> packages.x86_64

# Run mkarchiso
sudo mkarchiso -v -w /tmp/archiso-tmp -o /tmp/exu-output .
```

## Output

After successful build, the ISO will be located at:
```
/tmp/exu-output/exu-linux-1.0-x86_64.iso
```

## Verification

Verify the ISO checksum:
```bash
sha256sum /tmp/exu-output/exu-linux-1.0-x86_64.iso
```

## Writing to USB

### Linux
```bash
# Find your USB device
lsblk

# Write ISO (replace sdX with your device)
sudo dd if=/tmp/exu-output/exu-linux-1.0-x86_64.iso of=/dev/sdX bs=4M status=progress
sync
```

### macOS
```bash
# Find device
diskutil list

# Unmount
diskutil unmountDisk /dev/diskX

# Write
sudo dd if=/tmp/exu-output/exu-linux-1.0-x86_64.iso of=/dev/rdiskX bs=4m
```

### Windows
Use:
- **Etcher** (https://www.balena.io/etcher/)
- **Rufus** (https://rufus.ie/)
- **Ventoy** (https://www.ventoy.net/)

## Installation

1. Boot from USB
2. Select "Install Exu Linux"
3. Follow the Calamares installer
4. Reboot and enjoy!

## Troubleshooting

### ISO won't boot
- Ensure UEFI/BIOS settings allow USB boot
- Try writing with Etcher or Rufus
- Check USB drive is not corrupted

### Build fails
- Ensure you have 20GB+ free space
- Run `sudo pacman -Syu` to update packages
- Check internet connection
- Review build script output for errors

## Customization

Before building, customize:
- `build/packages.txt` - Add/remove packages
- `kde-plasma-theme/` - Modify appearance
- `installer/calamares/` - Installer options
- `branding/` - Colors and logos

## Building on Non-Arch Systems

You can build Exu Linux on other distros using Docker:

```bash
docker run -it --privileged -v $(pwd):/build archlinux:latest bash
cd /build
sudo pacman -S archiso arch-install-scripts
sudo bash build/build.sh
```
