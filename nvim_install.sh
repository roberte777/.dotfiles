#!/usr/bin/env zsh
# sudo apt-get install cmake
# sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
# cd $HOME
# mkdir install_repos
# cd install_repos
# git clone https://github.com/neovim/neovim
# cd neovim
# git checkout v0.8.0
# make CMAKE_BUILD_TYPE=Release
# sudo make install
# sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
#        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
#
#        install with release binary instead of making from source
sudo apt-get -y install cmake stow tmux fzf
cd $(mktemp -d) \
    && curl -L https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.deb -O \
    && sudo apt install ./nvim-linux64.deb \
    && git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
