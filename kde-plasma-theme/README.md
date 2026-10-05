# Exu Linux KDE Plasma Theme

Complete KDE Plasma customization for Exu Linux with color scheme, window decorations, and plasma theme.

## Installation

### Automatic Installation

```bash
cd kde-plasma-theme
bash install-theme.sh
```

### Manual Installation

1. Copy color scheme:
   ```bash
   cp color-scheme/ExuLinux.colors ~/.local/share/color-schemes/
   ```

2. Copy plasma theme:
   ```bash
   cp plasma-theme/exulinux ~/.local/share/plasma/desktoptheme/
   ```

3. Copy Konsole theme:
   ```bash
   cp konsole-theme/exulinux.colorscheme ~/.local/share/konsole/
   ```

4. Copy Kvantum theme:
   ```bash
   cp kvantum-theme/ExuLinux ~/.local/share/Kvantum/
   ```

## Apply Theme

1. Open **System Settings** (Systemeinstellungen)
2. Go to **Appearance** → **Global Style**
3. Select **Exu Linux**
4. Go to **Colors** and select **Exu Linux**
5. Apply and restart Plasma

## Configuration Files

- `color-scheme/` - Color schemes for KDE
- `plasma-theme/` - Plasma desktop theme
- `konsole-theme/` - Terminal emulator theme
- `kvantum-theme/` - Qt application theme
- `kwinsettings/` - Window manager settings

## Customization

Edit the `.colors` and `.conf` files to customize colors, fonts, and appearance.
