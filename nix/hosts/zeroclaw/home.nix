{pkgs,...}: {
  home-manager.users.zeroclaw = {
    imports = [
      ../../modules/home/dev.nix
      ../../modules/home/shell.nix
      ../../modules/home/desktop.nix
      ../../modules/home/theming/firefox
      ../../modules/home/spicetify.nix
      ../../modules/home/theming/noctalia.nix
      ../../modules/home/media.nix
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

    home.packages = with pkgs; [
      claude-code
    ];
    home.stateVersion = "25.11";
  };
}
