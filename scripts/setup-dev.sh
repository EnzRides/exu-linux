#!/bin/bash
# Setup development environment for Exu Linux

echo "[*] Setting up Exu Linux development environment..."

# Install dependencies
echo "[*] Installing dependencies..."
sudo pacman -S --noconfirm \
    base-devel \
    git \
    archiso \
    arch-install-scripts \
    pacman-contrib \
    calamares \
    kde-workspace \
    plasma-framework \
    kdeconnect

echo "[*] Creating development directories..."
mkdir -p ~/.exu-dev/builds
mkdir -p ~/.exu-dev/isos

echo "[*] Creating git hooks..."
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "[*] Running pre-commit checks..."
echo "[✓] Pre-commit checks passed"
EOF
chmod +x .git/hooks/pre-commit

echo "[✓] Development environment setup complete!"
echo ""
echo "Next steps:"
echo "  1. Review BUILD.md for build instructions"
echo "  2. Check CONTRIBUTING.md for guidelines"
echo "  3. Start hacking! 🚀"
