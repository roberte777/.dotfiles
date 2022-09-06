#!/usr/bin/env zsh
if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim, zsh, kitty, awesome, rofi, picom, tmux, ssh"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME/.dotfiles
fi
STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES

# I am using zsh instead of bash.  I was having some troubles using bash with
# arrays.  Didn't want to investigate, so I just did zsh
pushd $DOTFILES
for folder in $(echo $STOW_FOLDERS | sed "s/,/ /g")
do
    stow -D $folder
    stow $folder
done
popd
