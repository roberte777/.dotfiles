augroup fmt
    autocmd!
    au BufWritePre * try | undojoin | Neoformat | catch /E790/ | Neoformat | endtry
augroup end
