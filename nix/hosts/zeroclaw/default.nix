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
    inputs.noctalia.nixosModules.default
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "zeroclaw";
  networking.networkmanager.enable = true;

  # User account
  programs.zsh.enable = true;
  users.users.zeroclaw = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["users" "wheel" "docker" "networkmanager"];
  };

  # Docker for media services
  virtualisation.docker.enable = true;

  # Auto-start media stack on boot
  systemd.services.media-stack = {
    description = "Media Stack (Docker Compose)";
    after = ["docker.service" "network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/zeroclaw/.dotfiles/nix/hosts/zeroclaw";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };
  };

  # Auto-login on TTY1
  services.getty.autologinUser = "zeroclaw";

  # Kernel tuning for Sonarr/Radarr file watchers on big libraries
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  # Firewall for media services
  networking.firewall.allowedTCPPorts = [
    7878 # radarr
    8989 # sonarr
    9696 # prowlarr
    8080 # calibre-web
    13378 # audiobookshelf
    8081 # qbittorrent webui
    8096 # jellyfin
    5055 # seerr
    6767 # bazarr
    6868 # profilarr
    7575 # homarr
  ];

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    bc
    git-lfs
    htop
    btop
    pstree
    rsync
    socat
    sudo-rs
    unzip
    uutils-coreutils-noprefix
    zip
    stow
    fzf
    gnumake
    cmake
    gcc
    openssl
  ];

  services.noctalia-shell.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
