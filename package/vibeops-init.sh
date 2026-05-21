#!/bin/bash
# /etc/profile.d/vibeops-init.sh - runs once on first login

SENTINEL="$HOME/.vibeops-initialized"
[ -f "$SENTINEL" ] && return

echo ""
echo "============================================"
echo "  vibeopsOS - First Time Setup"
echo "============================================"

REPO_URL="https://github.com/vibeopsde/vibeopsOS.git"
REPO_DIR="$HOME/vibeopsOS"

echo "[*] Fetching available versions..."
TAGS=$(git ls-remote --tags "$REPO_URL" 2>/dev/null | awk -F/ '{print $NF}' | grep -v '\^{}' | sort -Vr)
if [ -z "$TAGS" ]; then
    TAG=""
else
    echo ""
    echo "  Available versions:"
    echo "  [0] latest (main branch)"
    i=1
    for t in $TAGS; do
        printf "  [%d] %s\n" "$i" "$t"
        i=$((i+1))
    done
    echo ""
    read -p "  Choose version [0]: " CHOICE
    CHOICE="${CHOICE:-0}"
    if [ "$CHOICE" != "0" ]; then
        TAG=$(echo "$TAGS" | sed -n "${CHOICE}p")
    fi
fi

echo "[*] Cloning vibeopsOS ($([ -n "$TAG" ] && echo "$TAG" || echo "latest"))..."
if [ ! -d "$REPO_DIR" ]; then
    if [ -n "$TAG" ]; then
        git clone --depth 1 --branch "$TAG" "$REPO_URL" "$REPO_DIR"
    else
        git clone --depth 1 "$REPO_URL" "$REPO_DIR"
    fi
fi

echo "[*] Running install.sh..."
bash "$REPO_DIR/install.sh"

touch "$SENTINEL"
echo "[*] Setup complete! Open a new shell or run: exec bash"