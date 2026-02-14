{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/nvidia.nix
    inputs.noctalia.nixosModules.default
  ];

  # Bootloader - host-specific (dual-boot with GRUB)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dualb";
  networking.networkmanager.enable = true;

  # User account
  programs.zsh.enable = true;
  users.users.roberte777 = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Ethan Wilkes";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Host-specific hardware
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Host-specific packages (build tools)
  environment.systemPackages = with pkgs; [
    stow
    fzf
    efibootmgr
    gnumake
    cmake
    gcc
    whitesur-cursors
  ];

  # Noctalia services
  services.noctalia-shell.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.variables = {
    XCURSOR_THEME = "WhiteSur-cursors";
    XCURSOR_SIZE = "28";
  };
  services.upower.enable = true;

  system.stateVersion = "25.11";
}
