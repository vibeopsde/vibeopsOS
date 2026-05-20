#!/bin/bash
# /etc/profile.d/vibeops-init.sh - runs once on first login

SENTINEL="$HOME/.vibeops-initialized"
[ -f "$SENTINEL" ] && return

echo ""
echo "============================================"
echo "  vibeopsOS - First Time Setup"
echo "============================================"

sudo -k
sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vibeops && chmod 0440 /etc/sudoers.d/vibeops"
echo "[*] Passwordless sudo enabled"

REPO_DIR="$HOME/vibeopsOS"
if [ ! -d "$REPO_DIR" ]; then
    git clone https://github.com/vibeopsde/vibeopsOS.git "$REPO_DIR"
fi

echo "[*] Running install.sh..."
bash "$REPO_DIR/install.sh"

touch "$SENTINEL"
echo "[*] Setup complete! Open a new shell or run: exec bash"