{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./home.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  time.timeZone = "America/Chicago";

  users.users = {
    theater = {
      isNormalUser = true;
      shell = pkgs.fish;

      extraGroups = [
        "users"
        "wheel"
        "docker"
      ];
    };
  };

  programs.fish.enable = true;

  virtualisation.docker = {
    enable = true;
  };

  # Helps with Sonarr/Radarr file watchers on big libraries
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  # If you use the NixOS firewall, open only what you need.
  networking.firewall.allowedTCPPorts = [
    7878 # radarr
    8989 # sonarr
    8787 # readarr
    9696 # prowlarr
    8080 # calibre-web (example)
    13378 # audiobookshelf (example)
    8081 # qbittorrent webui (via gluetun)
  ];

  services.openssh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    bc
    git
    git-lfs
    htop
    openssh
    pstree
    ripgrep
    rsync
    socat
    sudo-rs
    unzip
    uutils-coreutils-noprefix
    wget
    zip
  ];

  system.stateVersion = "25.11";
}
