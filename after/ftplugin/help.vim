if winwidth('%') > winheight('%')
    " move janela para o lado
    wincmd L
endif

nnoremap <silent> gq <cmd>close<cr>
