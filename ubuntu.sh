#!/usr/bin/env zsh
#install things I am using right off the bat
sudo apt install stow
sudo apt install zsh
#set default terminal to zsh
chsh -s $(which zsh)
sudo apt install curl
#install kitty terminal
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
#set up bin folder for kitty
cd
cd .local
mkdir bin
cd
#kitty setup for linux
ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
#downloading fonts
echo "[-] Download fonts [-]"
echo "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Monoki.zip"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Mononoki.zip
unzip Mononoki.zip -d ~/.local/share/fonts
fc-cache -fv
rm Mononoki.zip
#install grep for telescope nvim
sudo apt-get install ripgrep
echo "done!"
if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="nvim, kitty, awesome"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=$HOME/.dotfiles
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/install.sh

