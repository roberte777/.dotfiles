{
  pkgs,
  pkgs-unstable,
  pkgs-master,
  inputs,
  ...
}: {
  imports = [
    ./mcap.nix
    ./worktrunk-sync.nix
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "roberte777";
      user.email = "rewilkes0041@gmail.com";
      credential.helper = "store";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.neovim = {
    package = pkgs-unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    # home-manager 26.05 started writing its generated init.lua (just the
    # ruby/python3/node provider paths) to $XDG_CONFIG_HOME/nvim/init.lua,
    # which is the stow symlink to our own handwritten config. Sideload it
    # through wrapper args instead so the providers still get set and the
    # file stays ours.
    sideloadInitLua = true;
    # No plugins use the ruby/python3 remote-plugin hosts; opt into the
    # 26.05 default instead of the legacy one stateVersion would pin.
    withRuby = false;
    withPython3 = false;
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
    inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    sesh
    stow
    tmux
    typescript
    typescript-language-server
    lua-language-server
    stylua
    # Python: uv owns interpreters and project envs; ruff lints/formats and
    # pyright type-checks (both are wired up in the neovim LSP config).
    pkgs-unstable.uv
    ruff
    pyright
    prettier
    prettierd
    tree-sitter
    pkgs-unstable.opencode
    pkgs-unstable.tldr
    awscli2
  ];
}
