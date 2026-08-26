{pkgs, ...}: {
  imports = [
    ./home.nix
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

  # User account nix-darwin is aware of
  users.users.roberte777 = {
    name = "roberte777";
    home = "/Users/roberte777";
  };

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
      "firefox"
      "raycast"
      "discord"
      "google-chrome"
      "ghostty"
      "obsidian"
      "docker-desktop"
      "tailscale-app"
      "bitwarden"
    ];
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  system.primaryUser = "roberte777";
  nix.settings.experimental-features = ["nix-command" "flakes"];

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
