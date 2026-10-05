# Contributing to Exu Linux

We welcome contributions from the community!

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/exu-linux.git
   cd exu-linux
   ```

3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Code of Conduct

- Be respectful and inclusive
- No harassment or discrimination
- Constructive criticism only
- Help others learn and grow

## Contribution Types

### Bug Reports

1. Check if issue already exists
2. Include system info: `exufetch`
3. Steps to reproduce
4. Expected vs actual behavior
5. Error logs or screenshots

### Feature Requests

1. Describe the feature clearly
2. Explain the use case
3. Provide examples or mockups
4. Consider performance impact

### Code Contributions

1. Follow existing code style
2. Test your changes thoroughly
3. Document new features
4. Write clear commit messages
5. Reference issues in PR description

### Documentation

- Fix typos and grammar
- Clarify unclear sections
- Add examples
- Update outdated info

### Theme/Design

- Submit design mockups
- Suggest color/layout improvements
- Create new wallpapers
- Design icons and graphics

## Commit Guidelines

```bash
# Good commit message
git commit -m "Add KDE Plasma optimization"

# Reference issues
git commit -m "Fix installer boot timeout - fixes #42"

# Format: type(scope): description
# Types: feat, fix, docs, style, refactor, test, chore
```

## Pull Request Process

1. Update documentation
2. Add/update tests if applicable
3. Push to your fork
4. Create pull request
5. Describe changes clearly
6. Wait for review
7. Address feedback
8. Merge!

## Development Setup

```bash
# Install dev dependencies
sudo pacman -S base-devel git

# Setup repository
git clone https://github.com/EnzRides/exu-linux.git
cd exu-linux
bash scripts/setup-dev.sh
```

## Testing

### Build ISO
```bash
sudo bash build/build.sh
```

### Test in VM
```bash
qemu-system-x86_64 -cdrom /tmp/exu-output/exu-linux-1.0-x86_64.iso -m 2G
```

### Theme Testing
```bash
# Install theme
cd kde-plasma-theme
bash install-theme.sh

# Log out and log in to apply
```

## Coding Standards

- **Bash**: Use shellcheck
  ```bash
  shellcheck build/build.sh
  ```

- **Python**: Follow PEP 8
  ```bash
  pip install pylint flake8
  ```

- **Documentation**: Clear and concise

## Getting Help

- 💬 Join our Discord
- 📧 Email: support@exulinux.com
- 📖 Check existing docs
- 🐛 Search closed issues

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Mentioned on our website
- Featured in community updates

Thank you for contributing to Exu Linux! 🎉
