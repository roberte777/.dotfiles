{...}: {
  imports = [
    ./zsh.nix
  ];
  programs.starship.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true; # adds the hook for zsh
    nix-direnv.enable = true;
  };
  programs.zoxide.enable = true;
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.fastfetch.enable = true;
  programs.btop = {
    enable = true;
    settings = {
      # color_theme = "everforest-dark-hard";
      color_theme = "catppuccin_mocha";
    };
  };
}
