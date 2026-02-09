{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "roberte777";
    userEmail = "rewilkes0041@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      # Editor
      core.editor = "nvim";

      # Better diffs
      diff.algorithm = "histogram";

      # Rebase config
      rebase.autoStash = true;
      rebase.autoSquash = true;

      # Merge conflict style
      merge.conflictStyle = "zdiff3";

      # Credentials (macOS keychain)
      credential.helper = "store";
    };

    # Aliases
    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      lg = "log --oneline --graph --decorate -20";
    };

    # Nice diffs with delta
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    # Global ignores
    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      ".envrc"
    ];
  };
}
