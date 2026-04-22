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
    ];

    home.username = "roberte777";
    home.homeDirectory = "/Users/roberte777";
    home.stateVersion = "25.11";

    # Host-specific packages
    home.packages = with pkgs; [
      (pkgs.nerd-fonts.jetbrains-mono)
    ];
  };
}
