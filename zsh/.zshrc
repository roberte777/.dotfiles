eval "$(starship init zsh)"
plugins=(git)
eval "$(zoxide init zsh)"
unsetopt PROMPT_SP

export EDITOR="nvim"

path+="/usr/local/go/bin"
path+="$HOME/go/bin"
path+="$HOME/.cargo/bin"
path+="$HOME/.local/bin"
path+="/usr/local/cuda/bin"
path+="$HOME/.config/emacs/bin"
export FLYCTL_INSTALL="/home/roberte777/.fly"
path+="/home/roberte777/.fly/bin"
export PATH

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
bindkey -v
bindkey '^R' history-incremental-search-backward

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/roberte777/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/home/roberte777/.bun/_bun" ] && source "/home/roberte777/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# tmux sesh
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

alias sl="sesh-sessions"
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

alias openfortivpn="sudo systemctl start systemd-resolved.service && sudo openfortivpn --set-dns=0 --pppd-use-peerdns=1"

# java
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#
# . "$HOME/.local/share/../bin/env"

# source /home/roberte777/.config/broot/launcher/bash/br
