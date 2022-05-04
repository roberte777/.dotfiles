set path+=**
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
" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
" autocomplete stuffs
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'
Plug 'L3MON4D3/LuaSnip'
" tree shitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'morhetz/gruvbox'
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
call plug#end()
lua require('roberte777')
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*
augroup THE_PRIMEAGEN
    autocmd!
    " autocmd BufWritePre *.lua Neoformat
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END

for f in glob('~/.config/nvim/plugin/*.vim', 0, 1)
    execute 'source' f
endfor
set autochdir

"enable different settings for different languages (in ftplugins folder)
filetype plugin on
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
"autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync

