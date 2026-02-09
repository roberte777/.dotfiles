{
  config,
  pkgs,
  ...
}: {
  home-manager.users.theater = {
    config,
    pkgs,
    ...
  }: {
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.11";

    programs.git = {
      enable = true;
      userName = "roberte777";
      userEmail = "rewilkes0041@gmail.com";
    };
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
  };
}
