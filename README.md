# Exu Linux

**Exu Linux** is a fast, lightweight, and beautifully designed Arch Linux-based distribution featuring KDE Plasma desktop environment with custom branding, optimization, and a graphical installer.

## Features

- 🚀 **Fast & Optimized** - Performance-tuned for speed and efficiency
- 🎨 **KDE Plasma** - Modern, customizable desktop environment with Exu branding
- 📦 **Graphical Installer** - Calamares-based installer with Exu theming
- 🔧 **ExuFetch** - Custom system information tool (replaces fastfetch)
- 🎯 **Complete Branding** - Every element branded as Exu Linux
- 💻 **Arch Linux Base** - Rolling release, cutting-edge packages

## Project Structure

```
exu-linux/
├── branding/                    # Distro branding assets
│   ├── logo/
│   ├── wallpapers/
│   ├── colors/
│   └── fonts/
├── kde-plasma-theme/            # KDE Plasma theme & configs
│   ├── color-scheme/
│   ├── plasma-theme/
│   ├── konsole-theme/
│   └── kvantum-theme/
├── installer/                   # Calamares installer config
│   ├── calamares-config/
│   ├── branding/
│   └── modules/
├── exufetch/                    # ExuFetch replacement tool
│   ├── src/
│   └── config/
├── build/                       # ISO build scripts
│   ├── mkarchiso-config/
│   ├── build.sh
│   └── packages.txt
├── docs/                        # Documentation
│   ├── BUILD.md
│   ├── BRANDING.md
│   ├── CUSTOMIZATION.md
│   └── CONTRIBUTING.md
└── scripts/                     # Helper scripts
    ├── setup-dev.sh
    └── install-exufetch.sh
```

## Quick Start

### Build Exu Linux ISO

```bash
git clone https://github.com/EnzRides/exu-linux.git
cd exu-linux
./build/build.sh
```

### Install ExuFetch

```bash
bash scripts/install-exufetch.sh
exufetch
```

### Customize KDE Plasma

See `kde-plasma-theme/README.md` for theme customization options.

## System Requirements

- **Minimum**: 2GB RAM, 10GB disk space, 64-bit CPU
- **Recommended**: 4GB+ RAM, 20GB+ disk space

## Building from Source

For detailed build instructions, see [BUILD.md](docs/BUILD.md)

## Branding Guidelines

All Exu Linux branding follows our design guidelines. See [BRANDING.md](docs/BRANDING.md)

## Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/CONTRIBUTING.md)

## License

Exu Linux is provided under the GPL v3 License.

## Contact & Support

- 🌐 Website: [exulinux.com](https://exulinux.com) *(placeholder)*
- 📧 Email: support@exulinux.com *(placeholder)*
- 💬 Community: [Discord](https://discord.gg/exulinux) *(placeholder)*

---

**Exu Linux - Simple. Fast. Beautiful.**
