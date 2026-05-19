#!/bin/bash
set -e

ISO_OUT="vibeopsOS.iso"
WORK_DIR="/tmp/vibeops-build"

echo "[*] Building vibeopsOS ISO"

mkdir -p $WORK_DIR

echo "[*] Downloading Ubuntu base ISO..."
if [ ! -f ubuntu.iso ]; then
    wget -q https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso -O ubuntu.iso
fi

echo "[*] Extracting ISO..."
mkdir -p /tmp/vibeops-iso
sudo mount -o loop ubuntu.iso /tmp/vibeops-iso
cp -r /tmp/vibeops-iso/* $WORK_DIR/
sudo umount /tmp/vibeops-iso

echo "[*] Adding vibeopsOS packages..."
sudo cp -r package/* $WORK_DIR/
sudo chmod +x $WORK_DIR/vibeops-init.sh

echo "[*] Creating ISO..."
xorriso -as mkisofs \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -J -R -V "vibeopsOS" \
    -o $ISO_OUT \
    $WORK_DIR

echo "[*] ISO created: $ISO_OUT"
ls -lh $ISO_OUT