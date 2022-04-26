setlocal tabstop=2
setlocal shiftwidth=2
augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END
