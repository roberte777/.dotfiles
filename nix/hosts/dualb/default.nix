{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home.nix
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.zsh.enable = true;
  programs.niri.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.roberte777 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Ethan Wilkes";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    ghostty
    kitty
    ripgrep
    curl
    stow
    fzf
    efibootmgr
    gnumake
    cmake
    gcc
    wl-clipboard

    #niri
    xwayland-satellite
    fuzzel

    alacritty

    # Qt theming
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics.enable = true;
    nvidia.modesetting.enable = true;
    nvidia.open = true;
    nvidia.nvidiaSettings = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "gtk";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia_drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    # Qt theming is handled by Home Manager's qt module
  };

  programs.xwayland.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      inter
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans"
        ];
        serif = ["Noto Serif"];
        monospace = ["JetBrainsMono Nerd Font"];
      };
    };
    fontDir.enable = true;
  };
  # noctalia settings
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
