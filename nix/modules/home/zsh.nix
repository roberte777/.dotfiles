{...}: {
  programs.zsh = {
    enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
    };

    # Vi mode
    defaultKeymap = "viins";

    sessionVariables = {
      EDITOR = "nvim";
      FLYCTL_INSTALL = "/home/roberte777/.fly";
      NVM_DIR = "$HOME/.nvm";
      # PNPM_HOME = "/home/roberte777/.local/share/pnpm";
      # BUN_INSTALL = "$HOME/.bun";
    };

    shellAliases = {
      sl = "sesh-sessions";
      openfortivpn = "sudo systemctl start systemd-resolved.service && sudo openfortivpn --set-dns=0 --pppd-use-peerdns=1";

      # Git. Names follow the oh-my-zsh `git` plugin so muscle memory carries
      # over. The ones using $(git_main_branch)/$(git_current_branch) rely on
      # the helper functions defined in initContent below.
      g = "git";
      lg = "lazygit";

      # Status / staging
      gst = "git status";
      gss = "git status --short --branch";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      grs = "git restore";
      grst = "git restore --staged";

      # Commit
      gc = "git commit --verbose";
      gca = "git commit --verbose --all";
      gcmsg = "git commit --message";
      gcam = "git commit --all --message";
      gam = "git commit --verbose --amend";
      gan = "git commit --amend --no-edit";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";

      # Diff / show / blame
      gd = "git diff";
      gdca = "git diff --cached";
      gdw = "git diff --word-diff";
      gdst = "git diff --stat";
      gsh = "git show";
      gbl = "git blame -w";

      # Branches
      gb = "git branch";
      gba = "git branch --all";
      gbd = "git branch --delete";
      gbD = "git branch --delete --force";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcm = "git checkout $(git_main_branch)";
      gsw = "git switch";
      gswc = "git switch --create";
      gswm = "git switch $(git_main_branch)";

      # Remotes / syncing
      gf = "git fetch";
      gfa = "git fetch --all --prune";
      gl = "git pull";
      glr = "git pull --rebase";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpsup = "git push --set-upstream origin $(git_current_branch)";
      gr = "git remote";
      grv = "git remote --verbose";
      grpo = "git remote prune origin";

      # Log
      glog = "git log --oneline --decorate --graph";
      gloga = "git log --oneline --decorate --graph --all";
      glg = "git log --stat";
      glp = "git log --patch";

      # Rebase / merge / reset
      grb = "git rebase";
      grbi = "git rebase --interactive";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      grbm = "git rebase $(git_main_branch)";
      gm = "git merge";
      gma = "git merge --abort";
      grh = "git reset";
      grhh = "git reset --hard";
      grho = "git reset --hard origin/$(git_current_branch)";

      # Stash
      gsta = "git stash push";
      gstp = "git stash pop";
      gstl = "git stash list";
      gsts = "git stash show --text";
      gstd = "git stash drop";

      # Worktrees
      gwt = "git worktree";
      gwta = "git worktree add";
      gwtl = "git worktree list";
      gwtrm = "git worktree remove";

      gclean = "git clean --interactive -d";
    };

    initContent = ''
      # Disable PROMPT_SP (the % shown for partial lines)
      unsetopt PROMPT_SP

      # Additional path entries
      path+="/usr/local/go/bin"
      path+="$HOME/go/bin"
      path+="$HOME/.cargo/bin"
      path+="$HOME/.local/bin"
      path+="/usr/local/cuda/bin"
      path+="$HOME/.config/emacs/bin"
      path+="/home/roberte777/.fly/bin"
      # path+="$PNPM_HOME"
      # path+="$BUN_INSTALL/bin"
      export PATH

      # Source secrets from ~/.secrets (not version controlled)
      [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

      # NVM
      # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Bun completions
      [ -s "/home/roberte777/.bun/_bun" ] && source "/home/roberte777/.bun/_bun"

      # zsh.nix - put this at the very end of initExtra
      eval "$(direnv hook zsh)"

      # Worktrunk shell integration: provides the `wt` wrapper function so
      # `wt switch` etc. can change the current shell's directory. Runs after
      # compinit (see enableCompletion) so `compdef` is available for
      # completions. Declarative equivalent of `wt config shell install`.
      if command -v wt >/dev/null 2>&1; then
        eval "$(wt config shell init zsh)"
      fi

      # Helpers for the git shellAliases (oh-my-zsh equivalents). These are
      # evaluated when the alias runs, not when the shell starts.
      function git_current_branch() {
        git symbolic-ref --quiet --short HEAD 2>/dev/null
      }

      function git_main_branch() {
        git rev-parse --git-dir >/dev/null 2>&1 || return
        local ref
        for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,master}; do
          if git show-ref --quiet --verify "$ref"; then
            echo "''${ref##*/}"
            return
          fi
        done
        echo main
      }

      # Tmux sesh function
      function sesh-sessions() {
        {
          exec </dev/tty
          exec <&1
          local session
          session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
          zle reset-prompt > /dev/null 2>&1 || true
          [[ -z "$session" ]] && return
          sesh connect $session
        }
      }

      zle     -N             sesh-sessions
      bindkey -M emacs '\es' sesh-sessions
      bindkey -M vicmd '\es' sesh-sessions
      bindkey -M viins '\es' sesh-sessions
    '';
  };
}
