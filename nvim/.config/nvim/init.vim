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
set updatetime=750
set colorcolumn=80
" start searching while typing
set incsearch
" turns the background color of nvim to be whatever your terminals is
set termguicolors
" make nvim and system clipboard sync
set clipboard+=unnamedplus
set mouse+=a
set splitright

let mapleader = " "
nnoremap <Leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>pv :Ex<CR>
inoremap <C-c> <esc>
call plug#begin('~/.vim/plugged')
" dependency for a lot of stuff
Plug 'nvim-lua/plenary.nvim'
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
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'sbdchd/neoformat'
" file exploration
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'romgrk/barbar.nvim'
" comment toggling :D
Plug 'tpope/vim-commentary'
" statusline
Plug 'feline-nvim/feline.nvim'
" git stuffs
Plug 'lewis6991/gitsigns.nvim'
"telescope dependency
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-telescope/telescope.nvim'
" adds an indent line to make indents easier to see
Plug 'lukas-reineke/indent-blankline.nvim'
call plug#end()
lua require('roberte777')
lua require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}
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
    " below is something prime had, research this!
    "autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END

" source nvim settings file in plugin dir
for f in glob('~/.config/nvim/plugin/*.vim', 0, 1)
    execute 'source' f
endfor
set autochdir

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 40})
augroup END
