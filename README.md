## Hello👋
Feel free to explore and incorporate what you like into your own configs (If anything). If you have any questions, comments or suggestions, open an issue or PR!
![Screenshot](https://github.com/TobyM7/Hyprland-Dotfiles/blob/main/Documents/screenshot.png)
### Staring:
- **Window Manager** • [Hyprland](https://github.com/hyprwm/Hyprland)
- **Shell** • [Bash](https://www.gnu.org/software/bash/) with
  [ble.sh](https://github.com/akinomyoga/ble.sh)
- **Terminal** • [Kitty](https://github.com/wez/wezterm)
- **Panel** • [Waybar](https://github.com/Alexays/Waybar)
- **Notify Daemon** • [Dunst](https://github.com/dunst-project/dunst)
- **Launcher** • [Rofi](https://github.com/davatorium/rofi) 
- **File Manager** • [Thunar](https://wiki.archlinux.org/title/Thunar)

## Installation
### Run this command inside the Hyprland-Dotfiles folder

To install run the install scipt that is inside the Documents folder

### Remember to BACKUP YOUR FILES

### Install git
```
sudo pacman -S git 
git clone https://github.com/TobyM7/Hyprland-Dotfiles.git
```
### Running the Script
```
cd Hyprland-Dotfiles 
chmod +x Documents/install
Documents/install
```
## Post installation
To set theme, icons etc open GTK settings using the run menu (SUPER+O)

## Key Bindings
You can press super F1 to see a list of all keybindings
But these are some of the main ones
- `SUPER+SHIFT+ENTER`: Open terminal(Kitty)
- `SUPER+1,...9,0`:   Switch workspace
- `SUPER+SHIFT+1,...9,0`: Move to workspace
- `SUPER+SHIFT+C`: Kill active Window
- `SUPER+SHIFT+Q`: Quit Hyprland
- `SUPER+SHIFT+P`: Power menu
- `SUPER+SHIFT+F`: FullScreen
- `SUPER+T`: Thunar
- `SUPER+O`: Run Menu
- `SUPER+B`: Brave
- `SUPER+W`: Changes Wallpaper (Stored in ~/.config/hypr/wallpapers/)
## Roadmap

- [ ] Make the installation script install video drivers and backup configs
- [ ] Add seprate modules to install wallpapers to speed up clone time
- [ ] Add option for gBar or waybar in install 
- [ ] Convert README to org
- [ ] Update README to show new configs

## References and Credits

- Official Hyprland GitHub: <https://github.com/hyprwm/Hyprland>
- Ble (for bash): <https://github.com/akinomyoga/ble.sh>
- adi1090x for the rofi launchers (Which I randomized, some work better than others) <https://github.com/adi1090x/rofi>
- 1amSimp1e for the waybar which I edited <https://github.com/1amSimp1e/dots/tree/balcony%F0%9F%9A%8A>
