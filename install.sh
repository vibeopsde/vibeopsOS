#!/bin/bash
set -e

echo ""
echo "============================================"
echo "  Welcome to VibeOps — Onboarding"
echo "============================================"
echo ""

echo "[1/5] Installing OpenCode..."
curl -fsSL https://opencode.ai/install | bash
echo ""

echo "[2/5] Project setup"
read -p "  Project name (default: my-project): " PROJECT
PROJECT="${PROJECT:-my-project}"
PROJECT_DIR="$HOME/$PROJECT"
mkdir -p "$PROJECT_DIR"
echo "  Created: $PROJECT_DIR"
echo ""

echo "[3/5] Warning"
echo "  The vibeopsOS agent has sudo without password enabled."
echo "  It can install packages, modify system config, and run"
echo "  administrative commands on this machine."
echo ""

echo "[4/5] Choose agent mode:"
echo "  [1] Safe   — asks before every sudo command"
echo "  [2] Trust  — works autonomously with full sudo"
read -p "  Choice [1]: " MODE
MODE="${MODE:-1}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$MODE" = "2" ]; then
    cp "$SCRIPT_DIR/package/templates/agents-trust.md" "$PROJECT_DIR/AGENTS.md"
    echo "  Active: Trust mode"
else
    cp "$SCRIPT_DIR/package/templates/agents-safe.md" "$PROJECT_DIR/AGENTS.md"
    echo "  Active: Safe mode"
fi
echo ""

echo "[5/5] Done."
cd "$PROJECT_DIR"
echo ""
echo "  Project ready: $PROJECT_DIR"
echo "  To start: opencode"