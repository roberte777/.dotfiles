{
  pkgs,
  inputs,
  ...
}: let
  user = "ethan.wilkes";
in {
  home-manager.users.${user} = {
    imports = [
      ../../modules/home/dev.nix
      ./shell.nix
    ];

    home.username = user;
    home.homeDirectory = "/Users/${user}";
    home.stateVersion = "26.05";

    # Host-specific packages
    home.packages = with pkgs; [
      (pkgs.nerd-fonts.jetbrains-mono)
    ];
  };
}
