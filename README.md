# vibeopsOS

**Ubuntu x OpenCode — Development Environment Out of the Box**

vibeopsOS is a customized Ubuntu 24.04 distribution with the OpenCode AI coding agent pre-installed and ready on first login.

vibeopsOS is not affiliated with, endorsed by, or connected to the OpenCode project (anomalyco) or Canonical Ltd.

## Quick Start

```bash
git clone https://github.com/vibeopsde/vibeopsOS.git
cd vibeopsOS/build
sudo ./build-iso.sh        # → vibeopsOS.iso
sudo dd if=vibeopsOS.iso of=/dev/sdX bs=4M
# Boot, install Ubuntu, login — OpenCode is ready.
```

## Features

- **OpenCode pre-installed** — auto-installs via the one-shot init service on first boot
- **Sudo without password** — configured automatically for the primary user
- **Project templates** — web (Next.js/TS), Python (Poetry/pytest), general-purpose scaffold
- **One-shot systemd service** — runs once, then removes itself (`/etc/vibeops-initialized` sentinel)
- **OpenCode agent config** — global `agents.md` symlinked into `~/.config/opencode/`

## What Gets Installed

```
~/vibeops/
└── templates/
    ├── agents.md              # Global OpenCode instructions
    ├── web/                   # Next.js + TypeScript scaffold
    ├── python/                # Poetry + pytest scaffold
    └── general/               # Minimal README scaffold
```

On first boot the welcome wizard prompts to copy a template into `~/projects/`.

## Build Requirements

- Ubuntu 24.04
- `xorriso`, `wget`, `squashfs-tools`, `rsync`
- ~6 GB disk for the Ubuntu base ISO + workspace

## Project Structure

```
build/
  build-iso.sh           # Downloads Ubuntu ISO, patches squashfs, repacks
package/
  vibeops.service        # One-shot systemd unit
  vibeops-init.sh        # First-boot init: sudo, opencode, templates, onboarding
  onboarding/
    welcome.sh           # Interactive project-type picker
  templates/
    agents.md            # Global agent config
    web/                 # Next.js template (package.json, tsconfig.json, agents.md)
    python/              # Poetry template (pyproject.toml, agents.md)
    general/             # Barebones README scaffold
```

## Customization

Edit files in `package/` before building:
- `package/vibeops-init.sh` — change what runs on first boot
- `package/templates/agents.md` — change the global OpenCode agent instructions
- `package/templates/<type>/` — add/remove project templates

## License

MIT
