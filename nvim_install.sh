#!/usr/bin/env zsh
sudo apt-get install cmake
sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
cd $HOME
mkdir install_repos
cd install_repos
git clone https://github.com/neovim/neovim
cd neovim
git checkout v0.8.0
make CMAKE_BUILD_TYPE=Release
sudo make install
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
