#!/bin/bash
set -e

ISO_OUT="vibeopsOS.iso"
WORK_DIR="/tmp/vibeops-build"
SQUASHFS_DIR="/tmp/vibeops-squashfs"
ISO_MOUNT="/tmp/vibeops-iso-mount"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "[*] Building vibeopsOS ISO"

command -v wget       >/dev/null 2>&1 || { echo "ERROR: wget required"; exit 1; }
command -v xorriso     >/dev/null 2>&1 || { echo "ERROR: xorriso required"; exit 1; }
command -v unsquashfs  >/dev/null 2>&1 || { echo "ERROR: squashfs-tools required"; exit 1; }
command -v mksquashfs  >/dev/null 2>&1 || { echo "ERROR: squashfs-tools required"; exit 1; }
command -v rsync       >/dev/null 2>&1 || { echo "ERROR: rsync required"; exit 1; }

rm -rf "$WORK_DIR" "$SQUASHFS_DIR" "$ISO_MOUNT"
mkdir -p "$WORK_DIR" "$SQUASHFS_DIR" "$ISO_MOUNT"

echo "[*] Downloading Ubuntu 24.04 base ISO..."
if [ ! -f ubuntu.iso ]; then
    wget -q --show-progress https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso -O ubuntu.iso
fi

echo "[*] Mounting ISO..."
sudo mount -o loop ubuntu.iso "$ISO_MOUNT"

echo "[*] Copying ISO contents (excluding squashfs)..."
rsync -av --exclude='casper/filesystem.squashfs' "$ISO_MOUNT/" "$WORK_DIR/" >/dev/null

echo "[*] Extracting squashfs filesystem..."
if [ ! -f "$ISO_MOUNT/casper/filesystem.squashfs" ]; then
    echo "ERROR: squashfs not found in ISO"
    sudo umount "$ISO_MOUNT"
    exit 1
fi
sudo unsquashfs -d "$SQUASHFS_DIR" "$ISO_MOUNT/casper/filesystem.squashfs"

sudo umount "$ISO_MOUNT"
rm -rf "$ISO_MOUNT"

echo "[*] Injecting vibeopsOS files into filesystem..."
sudo mkdir -p "$SQUASHFS_DIR/opt/vibeops"
sudo cp -r "$REPO_ROOT/package/templates" "$SQUASHFS_DIR/opt/vibeops/templates"
sudo cp -r "$REPO_ROOT/package/onboarding" "$SQUASHFS_DIR/opt/vibeops/onboarding"
sudo cp "$REPO_ROOT/package/vibeops-init.sh" "$SQUASHFS_DIR/opt/vibeops/vibeops-init.sh"
sudo chmod +x "$SQUASHFS_DIR/opt/vibeops/vibeops-init.sh"

echo "[*] Installing systemd service..."
sudo cp "$REPO_ROOT/package/vibeops.service" "$SQUASHFS_DIR/etc/systemd/system/vibeops.service"
sudo ln -sf /etc/systemd/system/vibeops.service \
    "$SQUASHFS_DIR/etc/systemd/system/default.target.wants/vibeops.service" 2>/dev/null || \
sudo mkdir -p "$SQUASHFS_DIR/etc/systemd/system/default.target.wants" && \
sudo ln -sf /etc/systemd/system/vibeops.service \
    "$SQUASHFS_DIR/etc/systemd/system/default.target.wants/vibeops.service"

echo "[*] Rebuilding squashfs..."
sudo mksquashfs "$SQUASHFS_DIR" "$WORK_DIR/casper/filesystem.squashfs" -comp xz -noappend

sudo rm -rf "$SQUASHFS_DIR"

echo "[*] Recalculating filesystem.size..."
FILE_SIZE=$(stat -c%s "$WORK_DIR/casper/filesystem.squashfs")
printf '%d' "$FILE_SIZE" | sudo tee "$WORK_DIR/casper/filesystem.size" >/dev/null

echo "[*] Regenerating md5sum.txt..."
OLDPWD="$PWD"
cd "$WORK_DIR"
find . -type f -not -path './md5sum.txt' -not -path './isolinux/*' \
    -not -path './boot/*' -exec md5sum {} \; > md5sum.txt
cd "$OLDPWD"

echo "[*] Creating ISO..."
xorriso -as mkisofs \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -J -R -V "vibeopsOS" \
    -o "$ISO_OUT" \
    "$WORK_DIR"

rm -rf "$WORK_DIR"

echo "[*] Done: $(realpath "$ISO_OUT")"
ls -lh "$ISO_OUT"
