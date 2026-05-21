#!/bin/bash
set -e

ARCH="${1:-arm64}"

case "$ARCH" in
    arm64)  ISO_URL="https://cdimage.ubuntu.com/releases/26.04/release/ubuntu-26.04-live-server-arm64.iso" ;;
    amd64)  ISO_URL="https://releases.ubuntu.com/26.04/ubuntu-26.04-live-server-amd64.iso" ;;
    *)      echo "ERROR: unknown arch: $ARCH (use arm64 or amd64)"; exit 1 ;;
esac

GIT_TAG=$(git describe --tags --always 2>/dev/null || echo "untagged")
BASE_ISO_NAME=$(basename "$ISO_URL")
WORK_DIR="/tmp/vibeops-build-$ARCH"
SQUASHFS_DIR="/tmp/vibeops-squashfs-$ARCH"
ISO_MOUNT="/tmp/vibeops-iso-mount-$ARCH"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$REPO_ROOT/iso"
BASE_ISO="$ISO_DIR/$BASE_ISO_NAME"
ISO_OUT="$ISO_DIR/vibeopsOS-${ARCH}_v${GIT_TAG}.iso"

mkdir -p "$ISO_DIR"

echo "[*] Building viveopsOS ISO ($ARCH)"

command -v wget       >/dev/null 2>&1 || { echo "ERROR: wget required"; exit 1; }
command -v xorriso     >/dev/null 2>&1 || { echo "ERROR: xorriso required"; exit 1; }
command -v unsquashfs  >/dev/null 2>&1 || { echo "ERROR: squashfs-tools required"; exit 1; }
command -v mksquashfs  >/dev/null 2>&1 || { echo "ERROR: squashfs-tools required"; exit 1; }
command -v rsync       >/dev/null 2>&1 || { echo "ERROR: rsync required"; exit 1; }

sudo umount "$ISO_MOUNT" 2>/dev/null || true
rm -rf "$WORK_DIR" "$SQUASHFS_DIR" "$ISO_MOUNT"
mkdir -p "$WORK_DIR" "$SQUASHFS_DIR" "$ISO_MOUNT"

if [ ! -f "$BASE_ISO" ]; then
    echo "[*] Downloading base ISO..."
    wget -q --show-progress "$ISO_URL" -O "$BASE_ISO"
else
    echo "[*] Using existing base ISO: $BASE_ISO"
fi

echo "[*] Mounting ISO..."
sudo mount -o loop "$BASE_ISO" "$ISO_MOUNT"

SQUASHFS_FILE=$(ls "$ISO_MOUNT/casper/"*.squashfs 2>/dev/null | head -1 | xargs basename)
if [ -z "$SQUASHFS_FILE" ]; then
    echo "ERROR: no .squashfs found in casper/"
    sudo umount "$ISO_MOUNT"
    exit 1
fi
echo "[*] Found: casper/$SQUASHFS_FILE"

echo "[*] Copying ISO contents (excluding squashfs)..."
rsync -av --exclude="casper/$SQUASHFS_FILE" "$ISO_MOUNT/" "$WORK_DIR/" >/dev/null

echo "[*] Extracting squashfs..."
sudo unsquashfs -d "$SQUASHFS_DIR" "$ISO_MOUNT/casper/$SQUASHFS_FILE"
sudo umount "$ISO_MOUNT"
rm -rf "$ISO_MOUNT"

echo "[*] Injecting viveopsOS profile script..."
sudo cp "$REPO_ROOT/package/vibeops-init.sh" "$SQUASHFS_DIR/etc/profile.d/vibeops-init.sh"
sudo chmod +x "$SQUASHFS_DIR/etc/profile.d/vibeops-init.sh"

echo "[*] Cleaning up old systemd service (if present)..."
sudo rm -f "$SQUASHFS_DIR/etc/systemd/system/vibeops.service" \
           "$SQUASHFS_DIR/etc/systemd/system/multi-user.target.wants/vibeops.service" 2>/dev/null || true

echo "[*] Rebuilding squashfs..."
sudo mksquashfs "$SQUASHFS_DIR" "$WORK_DIR/casper/$SQUASHFS_FILE" -comp xz -noappend
sudo rm -rf "$SQUASHFS_DIR"

FILE_SIZE=$(stat -c%s "$WORK_DIR/casper/$SQUASHFS_FILE")
printf '%d' "$FILE_SIZE" | sudo tee "$WORK_DIR/casper/filesystem.size" >/dev/null

echo "[*] Regenerating md5sum.txt..."
OLDPWD="$PWD"
cd "$WORK_DIR"
find . -type f -not -path './md5sum.txt' -not -path './isolinux/*' \
    -not -path './boot/*' -exec md5sum {} \; > md5sum.txt
cd "$OLDPWD"

echo "[*] Creating ISO..."
rm -rf "$ISO_OUT"

ISO_VOLID="vibeopsOS-${ARCH}"
if [ -f "$WORK_DIR/isolinux/isolinux.bin" ]; then
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
        -J -R -V "$ISO_VOLID" \
        -o "$ISO_OUT" \
        "$WORK_DIR"
else
    echo "[*] EFI-only boot..."
    EFI_STAGING=$(mktemp -d)
    EFI_SRC=""
    [ -d "$WORK_DIR/efi" ] && EFI_SRC="$WORK_DIR/efi"
    [ -z "$EFI_SRC" ] && [ -d "$WORK_DIR/EFI" ] && EFI_SRC="$WORK_DIR/EFI"
    if [ -n "$EFI_SRC" ]; then
        mkdir -p "$EFI_STAGING/efi"
        cp -r "$EFI_SRC/"* "$EFI_STAGING/efi/"
    fi
    if [ -d "$WORK_DIR/boot/grub" ]; then
        cp -r "$WORK_DIR/boot/grub" "$EFI_STAGING/"
    fi
    EFI_SIZE=$(du -sk "$EFI_STAGING" | cut -f1)
    EFI_SIZE=$((EFI_SIZE + 10000))
    EFI_IMG="$WORK_DIR/boot/grub/efi.img"
    mkdir -p "$(dirname "$EFI_IMG")"
    dd if=/dev/zero of="$EFI_IMG" bs=1K count="$EFI_SIZE" status=none
    mkfs.vfat "$EFI_IMG" >/dev/null 2>&1
    mcopy -i "$EFI_IMG" -s "$EFI_STAGING/efi" :: >/dev/null 2>&1
    rm -rf "$EFI_STAGING"
    xorriso -as mkisofs \
        -e boot/grub/efi.img \
        -no-emul-boot \
        -J -R -V "$ISO_VOLID" \
        -o "$ISO_OUT" \
        "$WORK_DIR"
fi

rm -rf "$WORK_DIR"

echo "[*] Done: $(realpath "$ISO_OUT")"
ls -lh "$ISO_OUT"