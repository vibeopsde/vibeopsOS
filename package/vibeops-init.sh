#!/bin/bash
set -e

LOG="/var/log/vibeops-init.log"
echo "[*] vibeopsOS init started at $(date)" > $LOG

while [ -z "$(getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}')" ]; do
    sleep 2
done

detect_user() {
    logname 2>/dev/null ||
    who 2>/dev/null | awk '{print $1}' | head -1 ||
    getent passwd | awk -F: '$3>=1000 && $3<65534 {print $1; exit}' ||
    echo "ubuntu"
}
USERNAME=$(detect_user)
USER_HOME=$(eval echo ~$USERNAME)

echo "[*] Target user: $USERNAME ($USER_HOME)" >> $LOG

echo "[*] Setting up sudo without password for $USERNAME" >> $LOG
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vibeops
chmod 0440 /etc/sudoers.d/vibeops

echo "[*] Installing OpenCode..." >> $LOG
OPENCODE_OK=0
curl -fsSL https://opencode.ai/install | bash >> $LOG 2>&1 && OPENCODE_OK=1 || echo "[!] OpenCode install failed — will retry next boot" >> $LOG

echo "[*] Creating vibeops home structure..." >> $LOG
mkdir -p "$USER_HOME/vibeops/templates"
cp -r /opt/vibeops/templates/* "$USER_HOME/vibeops/templates/"
chown -R $USERNAME:$USERNAME "$USER_HOME/vibeops"

echo "[*] Creating OpenCode config symlink" >> $LOG
mkdir -p "$USER_HOME/.config/opencode"
ln -sf "$USER_HOME/vibeops/templates/agents.md" "$USER_HOME/.config/opencode/default-agent.md" 2>/dev/null || true
chown -R $USERNAME:$USERNAME "$USER_HOME/.config/opencode" 2>/dev/null || true

echo "[*] Adding bashrc hook for vibeops projects" >> $LOG
if ! grep -q "vibeops/templates/agents.md" "$USER_HOME/.bashrc" 2>/dev/null; then
    cat >> "$USER_HOME/.bashrc" << 'BASH_HOOK'

# vibeopsOS: auto-activate OpenCode agent config when in a project
if [ -f "$HOME/vibeops/templates/agents.md" ] && [ ! -f "$HOME/.config/opencode/default-agent.md" ]; then
    mkdir -p "$HOME/.config/opencode"
    ln -sf "$HOME/vibeops/templates/agents.md" "$HOME/.config/opencode/default-agent.md"
fi
BASH_HOOK
fi
chown $USERNAME:$USERNAME "$USER_HOME/.bashrc" 2>/dev/null || true

echo "[*] Starting onboarding wizard..." >> $LOG
sudo -u $USERNAME DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $USERNAME)/bus" \
    bash /opt/vibeops/onboarding/welcome.sh >> $LOG 2>&1 &
disown

if [ "$OPENCODE_OK" = "1" ]; then
    touch /etc/vibeops-initialized
    echo "[*] vibeopsOS init completed at $(date)" >> $LOG
else
    echo "[*] vibeopsOS init incomplete (OpenCode missing) — will retry on next boot" >> $LOG
    exit 1
fi
