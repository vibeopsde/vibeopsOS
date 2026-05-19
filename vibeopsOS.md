# vibeopsOS

**Ubuntu x OpenCode - Development Environment Out of the Box**

---

## Concept

vibeopsOS is a customized Ubuntu distribution with OpenCode pre-installed and configured for immediate productivity. Every new project starts with AI-powered development environment.

## Goals

- Ubuntu base with rock-solid stability
- OpenCode AI coding agent pre-installed
- Smart onboarding with project templates
- Developer-friendly: sudo without password
- Ready for any project type out of the box

---

## Features

### 1. OpenCode Pre-Installed
```bash
curl -fsSL https://opencode.ai/install | bash
```
OpenCode runs on first login if not installed.

### 2. Sudo Without Password
User is added to sudoers without password prompt for seamless workflow.

### 3. Project Structure
```
~/vibeops/
├── agents.md              # Global OpenCode instructions
├── projects/
│   ├── web/              # Web project template
│   ├── python/           # Python project template
│   └── general/          # General project template
├── .config/
│   └── opencode/         # OpenCode configuration
└── onboarding/           # First-run scripts
```

### 4. Project Templates
Each project type comes with `agents.md` containing:
- Preferred languages & frameworks
- Coding standards
- Testing strategies
- CI/CD templates

### 5. Onboarding Service
Systemd service runs once on first boot:
1. Create folder structure
2. Configure user environment
3. Start guided onboarding
4. Install OpenCode

---

## File Structure

```
vibeopsOS/
├── README.md
├── vibeopsOS.md
├── package/
│   ├── vibeops.service         # Systemd service
│   ├── vibeops-init.sh         # Init script
│   ├── templates/
│   │   ├── agents.md           # Global agent config
│   │   ├── web/
│   │   │   └── agents.md       # Web project template
│   │   ├── python/
│   │   │   └── agents.md       # Python project template
│   │   └── general/
│   │       └── agents.md       # General template
│   └── onboarding/
│       └── welcome.sh          # Welcome script
└── build/
    └── build-iso.sh            # ISO builder script
```

---

## Installation

### Build ISO
```bash
cd vibeopsOS/build
sudo ./build-iso.sh
```

### Use
1. Boot from ISO
2. Install Ubuntu normally
3. Login
4. OpenCode auto-installs
5. Follow onboarding

---

## Development

### Requirements
- Ubuntu 24.04 LTS base
- debootstrap
- xorriso
- chroot environment

### Build Process
1. Bootstrap Ubuntu base
2. Install additional packages
3. Copy vibeopsOS files
4. Configure services
5. Create ISO with xorriso

---

## License

MIT

## Links

- https://opencode.ai
- https://ubuntu.com