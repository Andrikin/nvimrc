" Awesome-surround: study case of Tim Pope's plugin Surround.vim
" Autor: André Alexandre Aguiar

if exists("g:awesome_surround")
  finish
endif
let g:awesome_surround = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:get_char() abort
	let c = nr2char(getchar())
	if c =~ "\<esc>" || c =~ "\<c-c>" || c =~ "\<cr>"
		return ''
	endif
	return c
endfunction

" Search for delimiters
" Get position of cursor and look for string under delimiters
" Get string and switch to new delimiter
function! s:surround_it() abort
	" let [_, cur_line, cur_col, _, _] = getcurpos()
	" Delimiters: ", ', {, [, (
	" From cursor position, look for the first delimiter to right
	" If found one, look to the left for the pair
	let user_delimiter = s:get_char()
	if empty(user_delimiter)
		return ''
	endif
	" let cur_line = getline('.')
	execute "normal! /\\v[^\\\\]\\zs([\"')\\]}]){1}\\ze\<cr>"
	let delimiter = cur_line[col('.') - 1]
	execute "normal! r" . user_delimiter
	execute "normal! ?\\v[^\\\\]\\zs(\\" . delimiter . "){1}\\ze\<cr>"
	execute "normal! r" . user_delimiter
	return ''
endfunction

nnoremap <expr> <plug>(Awesome_Surround) <SID>surround_it()

if hasmapto("\<plug>(Awesome_Surround)")
	nmap cs <plug>(Awesome_Surround)
endif

let &cpo = s:cpo_save
