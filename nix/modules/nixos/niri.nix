{pkgs, ...}: {
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Security services for polkit prompts and screen locking
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common = {
      default = "gnome";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
    };
  };

  # Required for screen sharing on Wayland
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      inter
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = ["Inter" "Noto Sans"];
        serif = ["Noto Serif"];
        monospace = ["JetBrainsMono Nerd Font"];
      };
    };
    fontDir.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Terminal emulators
    ghostty
    kitty
    alacritty

    # Niri/Wayland utilities
    xwayland-satellite
    fuzzel
    wl-clipboard

    # Qt theming support
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];
}
