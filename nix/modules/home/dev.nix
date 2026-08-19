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

  programs.gh = {
    enable = true;
    extensions = [pkgs-unstable.gh-stack];
    # Keep the global `credential.helper = "store"` above in charge of
    # github.com rather than letting gh inject a per-host helper.
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  home.packages = with pkgs; [
    pkgs-unstable.lazyjj
    pkgs-unstable.lazygit
    fzf
    fd
    jq
    tree
    curl
    wget
    just
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
    awscli2
  ];
}
