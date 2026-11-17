{pkgs, ...}: let
  user = "ethan.wilkes";
in {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  imports = [
    ./home.nix
  ];

  nix.settings.trusted-users = [user];

  # User account nix-darwin is aware of
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  security.pam.services.sudo_local.enable = false;

  # Packages available system-wide
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
  ];

  # macOS system defaults
  system.defaults = {
    dock.autohide = false;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
    CustomSystemPreferences = {
      ".GlobalPreferences" = {
        "com.apple.mouse.linear" = true;
      };
    };
  };

  # Homebrew (optional, for casks/App Store apps nix can't provide)
  homebrew = {
    enable = true;
    casks = [
      "raycast"
      "ghostty"
      "obsidian"
    ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  system.primaryUser = user;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # SSH. Turns on macOS's built-in sshd (System Settings > Sharing > Remote
  # Login) rather than building one; the NixOS hosts get this from
  # modules/nixos/common.nix.
  services.openssh.enable = true;

  # Automatic Nix garbage collection. theater/dualb already do this; without it
  # the store here grew to 335G, 300G of which was unreachable.
  # nix-darwin uses `interval` (a launchd calendar spec) — `dates` is removed.
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  # Hardlink identical files between store paths; was never enabled here.
  nix.optimise = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 4;
      Minute = 0;
    };
  };
}
