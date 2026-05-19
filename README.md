# vibeopsOS

**Ubuntu x OpenCode - Development Environment Out of the Box**

vibeopsOS is a customized Ubuntu distribution with OpenCode AI coding agent pre-installed and ready to go.

## Why vibeopsOS?

- **Out of the Box** - OpenCode is pre-configured, no manual setup needed
- **Smart Onboarding** - Project templates guide you through creating your first project
- **Developer Ready** - User has sudo without password, perfect for local development
- **AI-Powered** - Every project starts with AI assistance via OpenCode

## Quick Start

1. Download the ISO
2. Boot from USB/CD
3. Install Ubuntu as usual
4. Login
5. OpenCode auto-installs on first login
6. Follow the welcome wizard to create your first project

## Features

### Pre-Installed OpenCode
OpenCode AI coding agent is ready immediately. Run `opencode .` in any project directory.

### Project Templates
Choose from pre-configured project templates:
- **Web** - Node.js, TypeScript, Next.js/Express
- **Python** - Python 3.12+, Poetry, pytest
- **General** - For any other project type

### Auto-Configuration
- User sudo without password
- sensible defaults
- Clean project structure

## Installation

### Build from Source

Requirements:
- Ubuntu 24.04
- `xorriso`
- `wget`
- Internet connection

```bash
git clone https://github.com/vibeopsde/vibeopsOS.git
cd vibeopsOS/build
sudo ./build-iso.sh
```

The resulting ISO will be `vibeopsOS.iso` in the current directory.

### Using the ISO

1. Flash to USB: `sudo dd if=vibeopsOS.iso of=/dev/sdX bs=4M`
2. Boot from USB
3. Install Ubuntu
4. Done

## Project Structure

After installation, your home directory contains:

```
~/vibeops/
├── agents.md              # Global OpenCode instructions
├── projects/
│   ├── web/              # Web project template
│   ├── python/           # Python project template
│   └── general/          # General project template
└── onboarding/
    └── welcome.sh        # First-run wizard
```

## Customization

### Adding Custom agents.md

Edit `~/vibeops/agents.md` to customize OpenCode behavior for all projects.

To customize per project type, edit the respective `agents.md` in `~/vibeops/projects/<type>/`.

### Modifying the Build

Edit files in `package/` before running `build-iso.sh`:

- `vibeops.service` - Systemd service
- `vibeops-init.sh` - Initialization script
- `templates/` - Project templates and agents

## Tech Stack

- **Base**: Ubuntu 24.04 LTS
- **AI**: OpenCode (opencode.ai)
- **Install**: Standard Ubuntu installer

## License

MIT

## Links

- [OpenCode](https://opencode.ai)
- [Ubuntu](https://ubuntu.com)
- [GitHub](https://github.com/vibeopsde/vibeopsOS)