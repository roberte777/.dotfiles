set guicursor =
set relativenumber
" set number, turns on line number for current row
set nu
set nohlsearch
set hidden
set noerrorbells
set expandtab
set tabstop=4 softtabstop=4
set shiftwidth=4
set smartindent
set nowrap
set noswapfile
set scrolloff=8
set signcolumn=yes
set cmdheight=1
set updatetime=50
set colorcolumn=80
" start searching while typing
set incsearch
set termguicolors

let mapleader = " "
nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>pv :Ex<CR>
call plug#begin('~/.vim/plugged')
Plug 'sainnhe/everforest'
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
" autocomplete stuffs
Plug 'hrsh7th/nvim-cmp'
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'onsails/lspkind-nvim'
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'simrat39/symbols-outline.nvim'
" tree shitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
lua require('roberte777')
set background=dark
colorscheme everforest
