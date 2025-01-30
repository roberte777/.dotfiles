yay -S nwg-displays rofi-wayland hyprpaper \
    waybar pavucontrol starship plasma-polkit-agent \
    swaync libnotify systemd openfortivpn hyprlock \
    ags-hyprpanel-git

# hyprland plugin
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces # Add the plugin repository
hyprpm enable split-monitor-workspaces # Enable the plugin
hyprpm reload # Reload the plugins
hyprpm update
