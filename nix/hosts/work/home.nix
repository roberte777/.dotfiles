{...}: {
  imports = [
    ../../modules/home/dev.nix
    ../../modules/home/shell.nix
  ];

  home.username = "ethan.wilkes";
  home.homeDirectory = "/Users/ethan.wilkes";
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
