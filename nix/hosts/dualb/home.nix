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
      # ../../modules/home/theming/everforest.nix
      ../../modules/home/theming/firefox
      ../../modules/home/desktop.nix
      ../../modules/home/media.nix
      ../../modules/home/spicetify.nix
      ../../modules/home/cava.nix
    ];

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        size = 24;
      };
    };

    programs.firefox-themed = {
      enable = true;
      theme = "dracula";
    };

    home.stateVersion = "25.11";

    # Host-specific packages
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
