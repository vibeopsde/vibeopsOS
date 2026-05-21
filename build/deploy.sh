#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$REPO_ROOT/iso"
DEST_DIR="/var/www/html/ISO"

if [ ! -d "$ISO_DIR" ]; then
    echo "ERROR: ISO dir not found: $ISO_DIR"
    exit 1
fi

echo "[*] Deploying ISOs to $DEST_DIR..."
sudo mkdir -p "$DEST_DIR"
sudo cp -av "$ISO_DIR/"* "$DEST_DIR/"
echo "[*] Done."