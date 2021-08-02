" Vim global plugin for automating response to swapfiles 
" based on Damian Conway autoswap_mac_linux.vim plugin (https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/autoswap_mac_linux.vim)
" Autor:   André Alexandre Aguiar
" Version:      0.1

" If already loaded, we're done...
if exists("g:loaded_autoswap")
    finish
endif
let g:loaded_autoswap = 1

" Preserve external compatibility options, then enable full vim compatibility...
let s:cpo_save = &cpo
set cpo&vim

" Invoke the behaviour whenever a swapfile is detected...
augroup awesomeswap
    autocmd!
    autocmd SwapExists * call swapfile#handle_swapfile(expand('<afile>:p'))
augroup END

" Restore previous external compatibility options
let &cpo = s:cpo_save
