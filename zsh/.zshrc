eval "$(starship init zsh)"
plugins=(git)

alias exa="exa --all --icons"
alias exal="exa --all --icons --long"
alias exat="exa --tree --level=2"
path+="/usr/local/go/bin"
path+="$HOME/go/bin"
path+="$HOME/.local/bin"
path+="/usr/local/cuda/bin"
export PATH

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PIPENV_VENV_IN_PROJECT=1
export POETRY_VIRTUALENVS_IN_PROJECT=1

eval "$(zoxide init zsh)"

rbonsai -p -m "Happy Coding!"

unsetopt PROMPT_SP

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
