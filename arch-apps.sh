#!/bin/bash

install_section() {
	SECTION_NAME="$1"
	shift
	PACKAGES=("$@")

	echo -e "\n==> Installing $SECTION_NAME packages..."
	paru -S --needed --noconfirm "${PACKAGES[@]}"
}

HYPRLAND_REQUIRED=(
    hyprland
    dolphin
    kitty
    wofi
    xdg-desktop-portal-hyprland
    hyprpolkitagent
    qt5-wayland
    qt6-wayland
    grim
    slurp
)

ESSENTIAL_TOOLS=(
    git
    neovim
    cmake
    grep
    ripgrep
    nwg-displays
    rofi-wayland
    hyprpaper
    pavucontrol
    starship
    libnotify
    systemd
    hyprlock
    firefox
    ghostty
    ags-hyprpanel-git
    zsh
    oh-my-zsh-git
    zoxide
    tmux
    swww
    sesh-bin
    pandoc
    texlive
)

WORK_APPS=(
    openfortivpn
)

PLUGIN_REQUIREMENTS=(
    cmake
    meson
    cpio
)


setup_hyprland_plugins() {
    echo -e "\n==> Installing reuqired packages..."
    paru -S --needed --noconfirm "${PLUGIN_REQUIREMENTS[@]}"
    # hyprland plugin
    hyprpm add https://github.com/Duckonaut/split-monitor-workspaces # Add the plugin repository
    hyprpm enable split-monitor-workspaces # Enable the plugin
    hyprpm reload # Reload the plugins
    hyprpm update

}


read -p "Install hyprland required packages? (y/n): " ans
[[ "$ans" == [Yy]* ]] && install_section "Hyprland Required" "${HYPRLAND_REQUIRED[@]}"
read -p "Install essential tools? (y/n): " ans
[[ "$ans" == [Yy]* ]] && install_section "Essential Tools" "${ESSENTIAL_TOOLS[@]}"
read -p "Install work stuff? (y/n): " ans
[[ "$ans" == [Yy]* ]] && install_section "Work Stuff" "${WORK_APPS[@]}"
read -p "Install hyprland plugins? (y/n): " ans
[[ "$ans" == [Yy]* ]] && setup_hyprland_plugins

