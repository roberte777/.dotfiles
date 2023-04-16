#!/usr/bin/env zsh
sudo apt-get install ninja-build gettext cmake unzip curl make g++ curl stow tmux fzf
cd $HOME
mkdir install_repos
cd install_repos
git clone https://github.com/neovim/neovim
cd neovim
git checkout v0.9.0
make CMAKE_BUILD_TYPE=Release
sudo make install
