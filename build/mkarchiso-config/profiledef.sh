#!/usr/bin/env bash
# shellcheck disable=SC2034
iso_name="exu-linux"
iso_label="EXU_LINUX"
iso_publisher="Exu Linux <https://github.com/EnzRides/exu-linux>"
iso_application="Exu Linux Live/Rescue DVD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=("bios.syslinux.mbr" "bios.syslinux.eltorito" "uefi-x64.systemd-boot" "uefi-x64.grub.esp" "uefi-x64.grub.eltorito")
arch="x86_64"
"""
This profile is intentionally slim and tuned for the Exu Linux ISO.
It sets branding metadata and leaves the rest to the Arch releng profile.
"""
