{
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.roberte777 = {
    imports = [
      ../../modules/home/dev.nix
      ../../modules/home/shell.nix
      ../../modules/home/zen-browser.nix
      ../../modules/home/claude.nix
    ];

    home.username = "roberte777";
    home.homeDirectory = "/Users/roberte777";
    home.stateVersion = "26.05";

    # Host-specific packages
    home.packages = with pkgs; [
      (pkgs.nerd-fonts.jetbrains-mono)
    ];
  };
}
