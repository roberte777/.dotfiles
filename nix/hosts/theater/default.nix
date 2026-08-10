{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/cloudflared.nix
    inputs.noctalia.nixosModules.default
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "theater";
  networking.networkmanager.enable = true;

  # Storage mounts
  fileSystems."/mnt/bay1" = {
    device = "/dev/disk/by-uuid/af74c964-f88c-48b0-a56b-97f67036d8b5";
    fsType = "ext4";
  };

  # MergerFS pool combining all bay drives
  fileSystems."/mnt/storage" = {
    device = "/mnt/bay*";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs" # most free space for new files
      "moveonenospc=true" # move files if drive fills up
      "fsname=mergerfs:storage"
    ];
  };

  # User account
  programs.zsh.enable = true;
  users.users.theater = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["users" "wheel" "docker" "networkmanager" "video" "render"];
  };

  # Docker for media services
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["-a" "--volumes"];
    };
  };

  # Auto-start media stack on boot
  systemd.services.media-stack = {
    description = "Media Stack (Docker Compose)";
    after = ["docker.service" "network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/theater/.dotfiles/nix/hosts/theater";
      ExecStart = "${config.virtualisation.docker.package}/bin/docker compose up -d";
      ExecStop = "${config.virtualisation.docker.package}/bin/docker compose down";
    };
  };

  # Silent-failure checks for the media stack -- the states where every
  # container reports healthy but the stack is broken (no forwarded port, MAM
  # session rejected, VPN leak, unmounted bay). Pushes to ntfy on failure.
  #
  # Runs as root, unlike the stack itself: smartctl needs raw device access and
  # the mountpoint checks read /mnt directly.
  systemd.services.stack-healthcheck = {
    description = "Media stack silent-failure checks";
    after = ["docker.service" "network-online.target"];
    wants = ["network-online.target"];
    path = with pkgs; [
      docker_29
      curl
      gnused
      gawk
      gnugrep
      smartmontools
      util-linux # mountpoint
      coreutils
      bash
    ];
    serviceConfig = {
      Type = "oneshot";
      # A failing check exits 1 by design, which would otherwise mark the unit
      # failed and, worse, make `systemctl status` misleading during a real
      # outage. The notification is the output that matters.
      SuccessExitStatus = "0 1";
      ExecStart = "/home/theater/.dotfiles/nix/hosts/theater/scripts/stack-healthcheck.sh";
    };
  };

  systemd.timers.stack-healthcheck = {
    description = "Run media stack checks every 15 minutes";
    wantedBy = ["timers.target"];
    timerConfig = {
      # First run 5 min after boot so the stack has time to come up; a check at
      # T+0 would alert on containers that are merely still starting.
      OnBootSec = "5min";
      OnUnitActiveSec = "15min";
      # Spread the run so it does not collide with watchtower's 04:00 cycle.
      RandomizedDelaySec = "60";
      Unit = "stack-healthcheck.service";
    };
  };

  # Automatic Nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Auto-login on TTY1
  services.getty.autologinUser = "theater";

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
    8082 # shelfarr
    8096 # jellyfin
    32400 # plex
    5055 # seerr
    6767 # bazarr
    6868 # profilarr
    7575 # homarr
    3000 # omnibus
    443 # kasm browser sessions
    3001 # kasm https
    3002 # kasm http
    3003 # uptime kuma
    8085 # ntfy
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
    libva-utils
    intel-gpu-tools
    ncdu # disk usage analyzer
    mergerfs # filesystem for pooling drives
    smartmontools # SMART drive health, read by stack-healthcheck.sh
  ];

  # Intel Quick Sync (Alder Lake-N) hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD driver for QSV
      intel-compute-runtime # OpenCL for HDR tone-mapping
      vpl-gpu-rt # Intel Video Processing Library
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  services.noctalia-shell.enable = true;
  services.power-profiles-daemon.enable = true;
  services.tailscale.enable = true;

  system.stateVersion = "25.11";
}
