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
      PNPM_HOME = "/home/roberte777/.local/share/pnpm";
      BUN_INSTALL = "$HOME/.bun";
    };

    shellAliases = {
      sl = "sesh-sessions";
      openfortivpn = "sudo systemctl start systemd-resolved.service && sudo openfortivpn --set-dns=0 --pppd-use-peerdns=1";
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
      path+="$PNPM_HOME"
      path+="$BUN_INSTALL/bin"
      export PATH

      # History search
      bindkey '^R' history-incremental-search-backward

      # NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Bun completions
      [ -s "/home/roberte777/.bun/_bun" ] && source "/home/roberte777/.bun/_bun"

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
