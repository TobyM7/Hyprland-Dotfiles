#!/bin/bash
# https://github.com/JaKooLit

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
	echo "This script should not be executed as root! Exiting......."
	exit 1
fi


# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"

#clear screen
clear

# Get the width of the terminal
TERM_WIDTH=$(tput cols)

# Calculate the padding for the message
MESSAGE="Welcome to my Arch-Hyprland Installer"
PAD_LENGTH=$(( ($TERM_WIDTH - ${#MESSAGE}) / 2 ))

# Set the color to green
GREN='\033[0;32m'
NC='\033[0m' # No Color

# Display the message with thicker width and green color
printf "${GREN}+$(printf '%*s' "$((TERM_WIDTH-1))" '' | tr ' ' -)+${NC}\n"
printf "${GREN}|%*s${MESSAGE}%*s|${NC}\n" $PAD_LENGTH "" $PAD_LENGTH ""
printf "${GREN}+$(printf '%*s' "$((TERM_WIDTH-1))" '' | tr ' ' -)+${NC}\n"

sleep 2

# Print backup warning message
printf "${ORANGE}$(tput smso)PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!$(tput rmso)\n"
printf "${YELLOW} Although I will attempt to backup your files!\n"
printf "\n"
printf "\n"
sleep 2

# Print password warning message
printf "\n${YELLOW} Some commands require you to enter your password in order to execute.\n"
printf " If you are worried about entering your password, you can cancel the script now with CTRL+C and review the contents of this script.${RESET}\n"
sleep 2
printf "\n"
printf "\n"

# Print VM warning message
printf "\n${NOTE} If you are installing on a VM (virtual box, VMWARE, QEMU-KVM), kindly ensure that 3D acceleration is enabled.\n"
printf "Hyprland's performance on a Virtual Environment is abysmal... worst at its best. and it may not start at all!! YOU HAVE BEEN WARNED .${RESET}\n"
sleep 2
printf "\n"
printf "\n"

# Print system-update warning message
printf "\n${NOTE} If you have not perform a full system update for a while, cancel the script by pressing CTRL c and perform a full system update first\n"
printf "${WARN} If there is a kernel update, reboot first your system and re-run script. Script may fail if not updated. .${RESET}\n"
sleep 2
printf "\n"
printf "\n"

# proceed
read -n1 -rep "${CAT} Shall we proceed with installation (y/n) " PROCEED
    echo
if [[ $PROCEED =~ ^[Yy]$ ]]; then
    printf "\n%s  Alright.....LETS BEGIN!.\n" "${OK}"
else
    printf "\n%s  NO changes made to your system. Goodbye.!!!\n" "${NOTE}"
    exit
fi

#clear screen
clear

# Check for AUR helper and install if not found
ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
    printf "\n%s - AUR helper was located, moving on.\n" "${OK}"
else 
    printf "\n%s - AUR helper was NOT located\n" "$WARN"

    while true; do
        read -rp "${CAT} Which AUR helper do you want to use, yay or paru? Enter 'y' or 'p': " choice 
        case "$choice" in
            y|Y)
                printf "\n%s - Installing yay from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/yay-bin.git || { printf "%s - Failed to clone yay from AUR\n" "${ERROR}"; exit 1; }
                cd yay-bin || { printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install yay from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            p|P)
                printf "\n%s - Installing paru from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/paru-bin.git || { printf "%s - Failed to clone paru from AUR\n" "${ERROR}"; exit 1; }
                cd paru-bin || { printf "%s - Failed to enter paru-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install paru from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            *)
                printf "%s - Invalid choice. Please enter 'y' or 'p'\n" "${ERROR}"
                continue
                ;;
        esac
    done
fi

#clear screen
clear

# Update system before proceeding
printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

#clear screen
clear

# Set the script to exit on error
set -e

# Function for installing packages
install_package() {
    # checking if package is already installed
    if $ISAUR -Q "$1" &>> /dev/null ; then
        echo -e "${OK} $1 is already installed. skipping..."
    else
        # package not installed
        echo -e "${NOTE} installing $1 ..."
        $ISAUR -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
        # making sure package installed
        if $ISAUR -Q "$1" &>> /dev/null ; then
            echo -e "\e[1A\e[K${OK} $1 was installed."
        else
            # something is missing, exitting to review log
            echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log . You may need to install manually! Sorry I have tried :("
            exit 1
        fi
    fi
}

# Function to print error messages
print_error() {
    printf " %s%s\n" "${ERROR}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "${OK}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

# Exit immediately if a command exits with a non-zero status.
set -e 

# Hyprland Main installation part including automatic detection of Nvidia-GPU is present in your system
if ! lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    printf "${YELLOW} No NVIDIA GPU detected in your system. Installing Hyprland without Nvidia support..."
    sleep 1
    for HYP in hyprland; do
        install_package "$HYP" 2>&1 | tee -a $LOG
    done
else
	# Prompt user for Nvidia installation
	printf "${YELLOW} NVIDIA GPU Detected. TAKE NOTE that nvidia-wayland still a hit and miss. Any hyprland issues to be reported in Hyprland-github!\n"
	sleep 1
	printf "${YELLOW} Kindly enable some Nvidia-related stuff in the ~/.config/hypr/configs/ENVariables.conf after installation. Consult Hyprland-nvidia wiki!\n"
	sleep 2
	read -n1 -rp "${CAT} Would you like to install Nvidia Hyprland? (y/n) " NVIDIA
	echo

	if [[ $NVIDIA =~ ^[Yy]$ ]]; then
    	# Install Nvidia Hyprland
    	printf "\n"
    	printf "${YELLOW}Installing Nvidia Hyprland...${RESET}\n"
    	if pacman -Qs hyprland > /dev/null; then
        	read -n1 -rp "${CAT} Hyprland detected. Would you like to remove and install hyprland-nvidia instead? (y/n) " nvidia_hypr
        	echo
        	if [[ $nvidia_hypr =~ ^[Yy]$ ]]; then
            	sudo pacman -R --noconfirm hyprland 2>/dev/null | tee -a "$LOG" || true
        	fi
    		fi
    		for hyprnvi in hyprland hyprland-nvidia hyprland-nvidia-hidpi-git; do
        	sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null | tee -a $LOG || true
    		done
    	install_package "hyprland-nvidia-git" 2>&1 | tee -a $LOG
	else
    		printf "\n"
   	 	printf "${YELLOW} Installing non-Nvidia Hyprland...\n"
    		for hyprnvi in hyprland-nvidia-git hyprland-nvidia hyprland-nvidia-hidpi-git; do
        	sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null | tee -a $LOG || true
    		done
    		for HYP2 in hyprland; do
        install_package "$HYP2" 2>&1 | tee -a $LOG
    		done
	fi

    # Install additional nvidia packages
	printf "\n"
	printf "\n"
    printf "\n${NOTE} Kindly take note nvidia-dkms support from GTX 900 series and newer. If you have nvidia drivers already installed, it maybe wise to choose n in here\n"  
	read -n1 -rp "${CAT} Would you like to install nvidia-dkms driver, nvidia-settings and nvidia-utils? and all other nvidia-stuff (y/n) " nvidia_driver
        echo
        	if [[ $nvidia_driver =~ ^[Yy]$ ]]; then
		printf "${YELLOW} Installing Nvidia packages...\n"
        		for krnl in $(cat /usr/lib/modules/*/pkgbase); do
            	for NVIDIA in "${krnl}-headers" nvidia-dkms nvidia-settings nvidia-utils libva libva-nvidia-driver-git; do
            	install_package "$NVIDIA" 2>&1 | tee -a $LOG
            	done
        	done
	else
    	printf "${NOTE} YOU choose not to install nvidia stuff!.\n"
	fi

    #check if the nvidia modules are already added in mkinitcpio.conf and add if not
    if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
	    echo "Nvidia modules already included in /etc/mkinitcpio.conf" 2>&1 | tee -a $LOG
    else
	    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf 2>&1 | tee -a $LOG
	    echo "Nvidia modules added in /etc/mkinitcpio.conf"
    fi
        sudo mkinitcpio -P 2>&1 | tee -a $LOG
    printf "\n"   
    printf "\n"
    printf "\n"

    # preparing exec.conf to enable env = WLR_NO_HARDWARE_CURSORS,1 so it will be ready once config files copied
    sed -i '14s/#//' config/hypr/configs/ENVariables.conf
    
    # Additional Nvidia steps
    NVEA="/etc/modprobe.d/nvidia.conf"
    if [ -f "$NVEA" ]; then
            printf "${OK} Seems like nvidia-drm modeset=1 is already added in your system..moving on.\n"
            printf "\n"
        else
            printf "\n"
            printf "${YELLOW} Adding options to $NVEA..."
            sudo echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf 2>&1 | tee -a $LOG
            printf "\n"  
            fi
    
    # additional for GRUB users
    # Check if /etc/default/grub exists
    if [ -f /etc/default/grub ]; then
        # Check if nvidia_drm.modeset=1 is already present
            if ! sudo grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
            # Add nvidia_drm.modeset=1 to GRUB_CMDLINE_LINUX_DEFAULT
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.modeset=1"/' /etc/default/grub
            # Regenerate GRUB configuration
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            echo "nvidia_drm.modeset=1 added to /etc/default/grub"
        else
            echo "nvidia_drm.modeset=1 is already present in /etc/default/grub"
        fi
        else
        echo "/etc/default/grub does not exist"
    fi
	
    # Blacklist nouveau
	read -n1 -rep "${CAT} Would you like to blacklist nouveau? (y/n)" response
	echo
	if [[ $response =~ ^[Yy]$ ]]; then
    	NOUVEAU="/etc/modprobe.d/nouveau.conf"
    	if [ -f "$NOUVEAU" ]; then
        	printf "${OK} Seems like nouveau is already blacklisted..moving on.\n"
    	else
        	printf "\n"
        	echo "blacklist nouveau" | sudo tee -a "$NOUVEAU" 2>&1 | tee -a $LOG 
        	printf "${NOTE} has been added to $NOUVEAU.\n"
        	printf "\n"          

        	# to completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
        	if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
            	echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a $LOG 
        	else
            	echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a $LOG 
        	fi
    	fi
	else
    	printf "${NOTE} Skipping nouveau blacklisting.\n"
	fi

fi

#clear screen
clear 



read -n1 -rep 'Would like to install  packages (y,n)' PAK
if [[ $PAK == "Y" || $PAK == "y" ]]; then
printf "\n%s - Installing other necessary packages.... \n" "${NOTE}"

for PKG1 in acpid adobe-source-code-pro-fonts asciiquarium bashtop bat bc boost brave-bin btop candy-icons-git catppuccin-cursors-frappe catppuccin-cursors-latte catppuccin-cursors-macchiato catppuccin-cursors-mocha catppuccin-cursors-mocha catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-mocha ccls checkupdates-with-aur classicube-git cpufetch dashbinsh dialog direnv dmenu dosfstools dracula-cursors-git dracula-gtk-theme dracula-icons-git dunst efibootmgr emacs etcher-bin fail2ban fd feh ffmpeg ffmpegthumbnailer ffmpegthumbs figlet file-roller fuse2 fzf gbar-git gdu git gparted gping grimblast-git gtklock gvfs hstr hyprland hyprpicker-git intel-ucode inter-font iwd jq kdialog keepassxc kitty libqalculate light lolcat lsd lxappearance lxqt-archiver ly macchanger man-db mpv muc-git neofetch neovim net-tools network-manager-applet networkmanager nordic-theme noto-fonts noto-fonts-emoji nsh-git nwg-look-bin openrgb otf-firamono-nerd otf-sora pamixer papirus-icon-theme pavucontrol playerctl plymouth plymouth-theme-dragon-git polkit-gnome ppfetch-git pulseaudio python-pipx python-requests qt5-graphicaleffects qt5-quickcontrols2 qt5ct ranger ripgrep riseup-vpn rofi sddm-git sddm-theme-corners-git socat sox swaybg swayidle swaylock-effects swww thunar thunar-archive-plugin thunar-media-tags-plugin timeshift tor transmission-gtk ttf-comfortaa ttf-fantasque-nerd ttf-font-awesome ttf-icomoon-feather ttf-iosevka-nerd ttf-jetbrains-mono-nerd ttf-material-design-icons-extended ttf-nerd-fonts-symbols-common tumbler ufw unzip waybar waybar-updates wf-recorder wget wl-clipboard wlogout xclip xorg-xkill zenity zram-generator; do
    install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
        exit 1
    fi
done


echo
print_success "All necessary packages installed successfully."
sleep 2
fi
#clear screen
clear

read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" inst4
if [[ $inst4 =~ ^[Yy]$ ]]; then
  printf "${NOTE} Installing Bluetooth Packages...\n"
  for BLUE in bluez bluez-utils blueman; do
    install_package "$BLUE" 2>&1 | tee -a "$LOG"
         if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $BLUE install had failed, please check the install.log"
        exit 1
        fi
    done

  printf " Activating Bluetooth Services...\n"
  sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$LOG"
else
  printf "${NOTE} No bluetooth packages installed..\n"
fi

#clear screen
clear

### Install software for Asus ROG laptops ###
read -n1 -rep "${CAT} (OPTIONAL - ONLY for ROG Laptops) Would you like to install Asus ROG software support? (y/n)" ROG
if [[ $ROG =~ ^[Yy]$ ]]; then
    printf " Installing ASUS ROG packages...\n"
    for ASUS in asusctl supergfxctl rog-control-center; do
        install_package  "$ASUS" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $ASUS install had failed, please check the install.log"
        exit 1
        fi
    done
    printf " Activating ROG services...\n"
    sudo systemctl enable --now supergfxd 2>&1 | tee -a "$LOG"
    sed -i '23s/#//' config/hypr/configs/Execs.conf
else
    printf "${NOTE} Asus ROG software support not installed..\n"
fi

#clear screen
clear

# XDPH
printf "${YELLOW} Kindly note XDPH only needed for screencast/screenshot. Hyprland will still work hence this is optional\n"
printf "\n"
read -n1 -rep "${CAT} Would you like to install XDG-Portal-Hyprland? (y/n)" XDPH
if [[ $XDPH =~ ^[Yy]$ ]]; then
  printf "${NOTE} Installing XDPH...\n"
  for xdph in xdg-desktop-portal-hyprland; do
    install_package "$xdph" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $xdph install had failed, please check the install.log"
        exit 1
        fi
    done
else
  printf "${NOTE} XDPH will not be installed..\n"
fi

#clear screen
clear

### Disable wifi powersave mode ###
read -n1 -rp "${CAT} Would you like to disable wifi powersave? (y/n) " WIFI
if [[ $WIFI =~ ^[Yy]$ ]]; then
    LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    if [ -f "$LOC" ]; then
        printf "${OK} seems wifi powersave already disabled.\n"
    else
        printf "\n"
        printf "${NOTE} The following has been added to $LOC.\n"
        printf "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC
        printf "\n"
        printf "${NOTE} Restarting NetworkManager service...\n"
        sudo systemctl restart NetworkManager 2>&1 | tee -a "$LOG"
        sleep 2        
    fi    
else
    printf "${NOTE} WIFI Powersave is not being disabled.\n"
fi

#clear screen
clear


### Copy Config Files ###
set -e # Exit immediately if a command exits with a non-zero status.

read -n1 -rep "${CAT} Would you like to copy files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
    printf " Copying config files...\n"
   cp -r .config/* ~/.config/ 2>&1 | tee -a $LOG
   cp -r .bashrc ~/ 2>&1 | tee -a $LOG
   cp -r Documents/bin/  ~/Documents/bin/ 2>&1 | tee -a $LOG
    
    # Set some files as exacutable 
    chmod +x ~/Documents/bin/*    
fi
fc-cache -rv  

### Enable SDDM Autologin ###
read -n1 -rep 'Would you like to enable SDDM autologin? (y,n)' SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
    LOC="/etc/sddm.conf"
    echo -e "The following has been added to $LOC.\n"
    echo -e "[Autologin]\nUser = $(whoami)\nSession=hyprland" | sudo tee -a $LOC
    echo -e "\n"
    echo -e "Enabling SDDM service...\n"
    sudo systemctl enable sddm
    sleep 3
fi

### Enable SDDM Autologin ###
read -n1 -rep 'Would you like to enable SDDM and set the theme? (y,n)' SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
    LOC="/etc/sddm.conf"
    echo -e "The following has been added to $LOC.\n"
    echo -e "[Theme]\nThemeDir=/usr/share/sddm/themes \nCurrent=corners" | sudo tee -a $LOC
    echo -e "\n"
    echo -e "Enabling SDDM service...\n"
    sudo systemctl enable sddm
    sleep 3
fi

### Enable BLE ###
read -n1 -rep 'Would you like to install ble.sh? (y,n)' BLE
if [[ $BLE == "Y" || $BLE == "y" ]]; then
    echo -e "Installing ble.sh.\n"
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
    make -C ble.sh install PREFIX=~/.local
    sleep 3
fi

read -n1 -rep 'Would like to install my emacs config (y,n)' EMACS
if [[ $EMACS == "Y" || $EMACS == "y" ]]; then
    echo -e "Installing emacs config\n"
git clone --recursive https://github.com/TobyM7/Emacs-Config.git ~/.config/emacs
fi

read -n1 -rep 'Would like to install my wallpapers (y,n)' WALL
if [[ $WALL == "Y" || $WALL == "y" ]]; then
    echo -e "Installing emacs config\n"
sudo git clone https://github.com/TobyM7/wallpapers.git /usr/share/wallpapers/
fi

#clear screen
clear

### Script is done ###
printf "\n${OK} Yey! Installation Completed.\n"
printf "\n"
printf "\n"
printf "\n${NOTE} NOTICE TO NVIDIA OWNERS! REBOOT YOUR SYSTEM!!! else you will have issues"
printf "\n"
printf "\n"
sleep 2
printf "\n${NOTE} You can start Hyprland by typing Hyprland (IF SDDM is not installed) (note the capital H!).\n"
printf "\n"
printf "\n"
printf "\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP

if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v sddm >/dev/null; then
        sudo systemctl start sddm 2>&1 | tee -a "$LOG"
    fi
    
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
        print_error "Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi


