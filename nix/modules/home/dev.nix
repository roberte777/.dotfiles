{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "roberte777";
      user.email = "rewilkes0041@gmail.com";
      credential.helper = "store";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.jujutsu.enable = true;
  programs.ripgrep.enable = true;

  home.packages = with pkgs; [
    lazyjj
    fd
    jq
    tree
    curl
    wget
    just
    gh
    buf
  ];
}
