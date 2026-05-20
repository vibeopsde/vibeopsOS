#!/bin/bash
set -e

LOG="/var/log/vibeops-init.log"
REPO_URL="https://github.com/vibeopsde/vibeopsOS.git"
export HOME="/root"

echo "[*] vibeopsOS init started at $(date)" > $LOG

while [ -z "$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')" ]; do
    sleep 2
done

USERNAME=$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')
USER_HOME=$(eval echo ~$USERNAME)

echo "[*] Target user: $USERNAME ($USER_HOME)" >> $LOG

echo "[*] Setting up sudo without password for $USERNAME" >> $LOG
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vibeops
chmod 0440 /etc/sudoers.d/vibeops

echo "[*] Installing OpenCode..." >> $LOG
OPENCODE_OK=0
export HOME="/root"
curl -fsSL https://opencode.ai/install | bash >> $LOG 2>&1 && OPENCODE_OK=1 || echo "[!] OpenCode install failed — will retry next boot" >> $LOG

echo "[*] Cloning vibeopsOS repo..." >> $LOG
REPO_DIR="$USER_HOME/vibeopsOS"
rm -rf "$REPO_DIR" 2>/dev/null || true
git clone "$REPO_URL" "$REPO_DIR" >> $LOG 2>&1 || {
    echo "[!] Repo clone failed — will retry next boot" >> $LOG
    exit 1
}

echo "[*] Running install.sh..." >> $LOG
sudo -u "$USERNAME" bash "$REPO_DIR/install.sh" >> $LOG 2>&1

if [ "$OPENCODE_OK" = "1" ]; then
    touch /etc/vibeops-initialized
    echo "[*] vibeopsOS init completed at $(date)" >> $LOG
else
    echo "[*] vibeopsOS init incomplete (OpenCode missing) — will retry next boot" >> $LOG
    exit 1
fi