vim.cmd[[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]] -- accept the copilot suggestion
vim.cmd[[let g:copilot_no_tab_map = v:true]] -- disable tab mapping
