{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    ../../modules/nixos/common.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "theater";

  # User account
  programs.fish.enable = true;
  users.users.theater = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["users" "wheel" "docker"];
  };

  # Docker for media services
  virtualisation.docker.enable = true;

  # Kernel tuning for Sonarr/Radarr file watchers on big libraries
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  # Firewall for media services
  networking.firewall.allowedTCPPorts = [
    7878 # radarr
    8989 # sonarr
    8787 # readarr
    9696 # prowlarr
    8080 # calibre-web
    13378 # audiobookshelf
    8081 # qbittorrent webui
  ];

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    bc
    git-lfs
    htop
    pstree
    rsync
    socat
    sudo-rs
    unzip
    uutils-coreutils-noprefix
    zip
  ];

  system.stateVersion = "25.11";
}
