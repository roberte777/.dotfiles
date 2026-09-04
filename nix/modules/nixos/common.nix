{pkgs, ...}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Timezone and locale
  time.timeZone = "America/Chicago";

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

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    ripgrep
    curl
    # btop
  ];

  # uv downloads prebuilt CPython builds that expect an FHS dynamic loader,
  # which NixOS does not have. nix-ld supplies one so `uv python install` and
  # native wheels work. Add to programs.nix-ld.libraries if a wheel reports a
  # missing shared object.
  programs.nix-ld.enable = true;

  # SSH
  services.openssh.enable = true;
}
