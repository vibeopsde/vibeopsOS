# vibeopsOS

**Ubuntu x OpenCode — Development Environment Out of the Box**

vibeopsOS is a customized Ubuntu 26.04 distribution with the OpenCode AI coding agent pre-installed and ready on first login.

vibeopsOS is not affiliated with, endorsed by, or connected to the OpenCode project (anomalyco) or Canonical Ltd.

## Quick Start

```bash
git clone https://github.com/vibeopsde/vibeopsOS.git
cd vibeopsOS/build
sudo ./build-iso.sh        # → vibeopsOS_vYYMMDDHH.iso
sudo dd if=vibeopsOS_v*.iso of=/dev/sdX bs=4M
# Boot, install Ubuntu, login — setup runs automatically.
```

## Features

- **OpenCode pre-installed** — auto-installs on first login via `/etc/profile.d/`
- **Sudo without password** — configured automatically for the primary user (one-time sudo prompt)
- **Project templates** — web (Next.js/TS), Python (Poetry/pytest), general-purpose scaffold
- **First-login setup** — runs once, then creates `~/.vibeops-initialized` sentinel
- **Incremental builds** — skips re-downloading `ubuntu.iso` if already present

## What Happens on First Login

```
~/
└── vibeopsOS/              # Cloned from GitHub
    ├── install.sh           # Custom setup script
    └── package/
        └── templates/
            ├── agents.md
            ├── web/
            ├── python/
            └── general/
```

## Build Requirements

- Ubuntu 24.04+ / Debian
- `xorriso`, `wget`, `squashfs-tools`, `rsync`, `mtools`
- ~6 GB disk for the Ubuntu base ISO + workspace

## Project Structure

```
.
├── build/
│   └── build-iso.sh           # Downloads Ubuntu ISO, patches squashfs, repacks
├── package/
│   ├── vibeops-init.sh        # Profile.d first-login script
│   ├── vibeops.service        # (deprecated) legacy systemd unit
│   ├── onboarding/
│   │   └── welcome.sh         # Interactive project-type picker
│   └── templates/
│       ├── agents.md          # Global agent config
│       ├── web/               # Next.js + TypeScript scaffold
│       ├── python/            # Poetry + pytest scaffold
│       └── general/           # Barebones README scaffold
├── install.sh                 # Post-clone setup (runs in user context)
└── .gitignore
```

## Customization

Edit files in `package/` before building:
- `package/vibeops-init.sh` — change what runs on first login
- `package/templates/agents.md` — change the global OpenCode agent instructions
- `package/templates/<type>/` — add/remove project templates
- `install.sh` — post-clone setup tasks

## License

MIT