{
  pkgs,
  pkgs-unstable,
  pkgs-master,
  inputs,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "roberte777";
      user.email = "rewilkes0041@gmail.com";
      credential.helper = "store";
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    package = pkgs-unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
  };
  programs.ripgrep.enable = true;

  home.packages = with pkgs; [
    pkgs-unstable.lazyjj
    fd
    jq
    tree
    curl
    wget
    just
    gh
    buf
    pkgs-unstable.worktrunk
    rustup
    gcc
    pkg-config
    cargo-release
    inputs.claude-code-nix.packages.${pkgs.system}.default
    sesh
    stow
    tmux
    nodePackages.typescript
    nodePackages.typescript-language-server
    lua-language-server
    stylua
    ruff
    nodePackages.prettier
    prettierd
    tree-sitter
    pkgs-unstable.opencode
    pkgs-unstable.tldr
  ];
}
