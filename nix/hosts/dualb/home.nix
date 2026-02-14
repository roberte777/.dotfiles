{
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.roberte777 = {
    imports = [
      ../../modules/home/dev.nix
      ../../modules/home/shell.nix
      ../../modules/home/theming/noctalia.nix
      ../../modules/home/theming/everforest.nix
      ../../modules/home/theming/firefox.nix
      ../../modules/home/desktop.nix
      ../../modules/home/spicetify.nix
    ];

    home.stateVersion = "25.11";

    # Host-specific packages
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
