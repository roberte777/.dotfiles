#!/usr/bin/env zsh
echo "[-] Download fonts [-]"
echo "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Monoki.zip"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Mononoki.zip
unzip Mononoki.zip -d ~/.local/share/fonts
fc-cache -fv
echo "done!"
if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim, kitty, awesome"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME/.dotfiles
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/install.sh

