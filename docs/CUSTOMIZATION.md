# Customizing Exu Linux

## KDE Plasma Customization

### Changing Colors

1. Open **System Settings** → **Appearance** → **Colors**
2. Select custom color scheme
3. Edit `~/.local/share/color-schemes/ExuLinux.colors`

### Changing Wallpaper

1. Right-click desktop → **Configure Desktop**
2. Select wallpaper from `/usr/share/wallpapers/`
3. Or add custom wallpaper to `~/.local/share/wallpapers/`

### Window Decorations

Edit `~/.config/kwinrc`:
```ini
[General]
Scheme=ExuLinux
```

## Terminal Customization

### Konsole Color Scheme

1. Open Konsole
2. Settings → Edit Current Profile → Appearance
3. Select "exulinux" color scheme

### Customize Scheme

Edit `~/.local/share/konsole/exulinux.colorscheme`

## System Fonts

1. Install fonts:
   ```bash
   sudo pacman -S noto-fonts noto-fonts-emoji
   ```

2. Set in System Settings → Appearance → Fonts

## Package Management

### Add/Remove Packages

```bash
# Install package
sudo pacman -S package-name

# Remove package
sudo pacman -R package-name

# Update system
sudo pacman -Syu
```

## ExuFetch Customization

Edit `/usr/local/bin/exufetch` to customize:
- Output format
- Colors
- Information displayed
- Logo

### Example modification:
```bash
# Change colors at the top of the script
PURPLE='\033[38;2;YOUR;RGB;HERE m'
```

## Bootloader Customization

### GRUB Configuration

Edit `/etc/default/grub`:
```bash
# Add Exu splash screen
GRUB_THEME="/boot/grub/themes/exulinux/theme.txt"

# Set timeout
GRUB_TIMEOUT=5
```

Then run:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Panel Customization

1. Right-click on Plasma panel
2. Select "Enter Edit Mode"
3. Add/remove widgets
4. Customize appearance
5. Click "Leave Edit Mode"

## Application Themes

### GTK Applications

Edit `~/.config/gtk-3.0/settings.ini`:
```ini
gtk-theme-name=ExuLinux
gtk-icon-theme-name=exulinux-icons
```

### Qt Applications

Edit `~/.config/kdeglobals`:
```ini
[General]
ColorScheme=ExuLinux
```

## System Optimization

### Enable Compositing

System Settings → Startup and Shutdown → Screen Lock

### Reduce Visual Effects

System Settings → Appearance → Style → Animations (set to low/off)

### Performance Tuning

```bash
# Check running services
sudo systemctl list-units --type=service --state=running

# Disable unnecessary services
sudo systemctl disable service-name
```

## Advanced: Building Custom ISO

Modify before building:

1. Edit `build/packages.txt` to add/remove packages
2. Modify `installer/calamares/settings.conf`
3. Update colors in `branding/colors/exu-colors.conf`
4. Run `sudo bash build/build.sh`

## Rollback Changes

If you break something:

```bash
# Restore original configs from backup
cp ~/.config/kdeglobals.bak ~/.config/kdeglobals

# Or reinstall Exu default settings
sudo pacman -S exu-branding
```
