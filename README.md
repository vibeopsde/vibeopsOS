# vibeopsOS

**Ubuntu x OpenCode — Development Environment Out of the Box**

vibeopsOS is a customized Ubuntu 26.04 distribution with the OpenCode AI coding agent pre-installed via an interactive first-login onboarding.

vibeopsOS is not affiliated with, endorsed by, or connected to the OpenCode project (anomalyco) or Canonical Ltd.

## Quick Start

```bash
git clone https://github.com/vibeopsde/vibeopsOS.git
cd vibeopsOS/build

# Build for your architecture:
sudo ./build-arm64.sh     # → iso/vibeopsOS-arm64_vYYMMDDHH.iso
sudo ./build-x64.sh       # → iso/vibeopsOS-amd64_vYYMMDDHH.iso

# Flash and boot:
sudo dd if=iso/vibeopsOS-*.iso of=/dev/sdX bs=4M status=progress
```

After installing Ubuntu and logging in, the vibeopsOS onboarding starts automatically.

## Onboarding (First Login)

```
  vibeopsOS — First Time Setup
  ──────────────────────────────
  Choose version:
    [0] latest (main branch)
    [1] v2605.0

  → Welcome to VibeOps — Onboarding
  ─────────────────────────────────
  [1/6] Enable passwordless sudo      (one-time password prompt)
  [2/6] Install OpenCode              (via https://opencode.ai/install)
  [3/6] Choose project name           (default: my-project)
  [4/6] Warning: agent has full sudo
  [5/6] Select agent mode:
          [1] Safe  — asks before every sudo command
          [2] Trust — works autonomously with full sudo
  [6/6] AGENTS.md copied to project. Ready.
```

The setup runs once via `/etc/profile.d/vibeops-init.sh`. On first login you can pick a specific git tag or the latest main branch. The repo is cloned to `~/vibeopsOS/` and `install.sh` is executed. A sentinel file `~/.vibeops-initialized` prevents re-runs.

## Features

- **OpenCode installed on first login** — no manual setup required
- **Passwordless sudo** — configured automatically (one-time sudo prompt)
- **Safe / Trust agent modes** — choose whether the agent asks before sudo or works autonomously
- **Version pinning** — pick a specific git tag or always get the latest main
- **Clean onboarding** — interactive setup with project creation

## Build Requirements

- Ubuntu 24.04+ / Debian
- `xorriso`, `wget`, `squashfs-tools`, `rsync`, `mtools`
- ~8 GB disk for the Ubuntu base ISO + workspace

## Project Structure

```
.
├── build/
│   ├── build-iso.sh              # Core ISO builder (accepts arch as argument)
│   ├── build-arm64.sh            # ARM64 thin wrapper
│   └── build-x64.sh              # AMD64 thin wrapper
├── package/
│   ├── vibeops-init.sh           # /etc/profile.d/ first-login script
│   ├── vibeops.service           # (deprecated) legacy systemd unit
│   └── templates/
│       ├── agents-safe.md        # Agent config: ask before every sudo
│       ├── agents-trust.md       # Agent config: autonomous with full sudo
│       └── ...                   # Additional template scaffolds
├── install.sh                    # Onboarding script (sudoers, OpenCode, project, AGENTS.md)
├── iso/                          # Base ISOs and build output (*.iso — gitignored)
├── .gitignore
└── LICENSE
```

## Customization

- `install.sh` — the main onboarding flow (sudoers, OpenCode, project setup, agent mode)
- `package/vibeops-init.sh` — first-login entry point (clone repo, run install.sh)
- `package/templates/agents-safe.md` — agent instructions for Safe mode
- `package/templates/agents-trust.md` — agent instructions for Trust mode
- `build/build-iso.sh` — ISO build logic (arch detection, squashfs patching, repack)

## License

MIT