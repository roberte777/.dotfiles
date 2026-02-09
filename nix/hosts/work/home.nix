{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ethan.wilkes";
  home.homeDirectory = "/Users/ethan.wilkes";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship.enable = true;
  programs.direnv.enable = true;
  programs.zoxide.enable = true;
  programs.zellij.enable = true;
  programs.jujutsu.enable = true;
  programs.ripgrep.enable = true;
  programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  home.packages = with pkgs; [
    lazyjj
          fd
      jq
      tree
      curl
      wget
      just
      gh
  ];
}
