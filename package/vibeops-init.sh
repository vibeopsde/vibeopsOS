#!/bin/bash
set -e

LOG="/var/log/vibeops-init.log"
echo "[*] vibeopsOS init started at $(date)" >> $LOG

USERNAME=$(logname 2>/dev/null || echo "ubuntu")
USER_HOME=$(getent passwd $USERNAME | cut -d: -f6)

echo "[*] Setting up sudo without password for $USERNAME" >> $LOG
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vibeops
chmod 0440 /etc/sudoers.d/vibeops

echo "[*] Copying vibeopsOS files to $USER_HOME" >> $LOG
cp -r /opt/vibeops/templates "$USER_HOME/vibeops"
chown -R $USERNAME:$USERNAME "$USER_HOME/vibeops"

echo "[*] Creating OpenCode config symlink" >> $LOG
mkdir -p "$USER_HOME/.config/opencode"
ln -sf "$USER_HOME/vibeops/agents.md" "$USER_HOME/.config/opencode/default-agent.md" 2>/dev/null || true

echo "[*] Starting onboarding" >> $LOG
sudo -u $USERNAME bash /opt/vibeops/onboarding/welcome.sh &
disown

touch /etc/vibeops-initialized
echo "[*] vibeopsOS init completed at $(date)" >> $LOG