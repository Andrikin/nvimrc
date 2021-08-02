" Autor: André Alexandre Aguiar
" Dependences: xtitle, xkey, bspc, xdo
" TODO: Clear code

let s:cpo_save = &cpo
set cpo&vim

" Full path of file
let s:file = ''

" ':' == 0x003a
let s:cmd = ['xdo activate ', 
			\'xkev -s -e 0x003a',
			\]

function! swapfile#handle_swapfile(file) abort
	let s:file = a:file
	if getftime(v:swapname) < getftime(s:file)
		let v:swapchoice = 'e'
	else
		call s:detect_window_in_other_node()
		let v:swapchoice = 'q'
		echomsg 'Buffer already open!'
	endif
endfunction

" Get Hex value
function! s:get_hex_char(char) abort
	let number = char2nr(a:char)
	return s:get_hex_number(number)
endfunction

function! s:get_hex_number(number) abort
	let hex = ''
	let num = a:number
	let to_convert = []
	let q = 1
	while q
		let q = num / 16
		let r = num % 16
		let num = q
		" Insert before the first item
		call insert(to_convert, r)
	endwhile
	for decimal in to_convert
		if decimal =~ '^\d$'
			let hex_num = string(decimal)
		elseif decimal == 10
			let hex_num = 'A'
		elseif decimal == 11
			let hex_num = 'B'
		elseif decimal == 12
			let hex_num = 'C'
		elseif decimal == 13
			let hex_num = 'D'
		elseif decimal == 14
			let hex_num = 'E'
		elseif decimal == 15
			let hex_num = 'F'
		else
			return ''
		endif
		let hex .= hex_num
	endfor
	return hex
endfunction

" Get command from string
function! s:get_cmd_from_string(string) abort
	let cmd_list = []
	for c in split(a:string, '\zs')
		if c =~ '[^#_/]'
			call add(cmd_list, 'xkev -e 0x00' . s:get_hex_char(c))
		elseif c =~ '[#_]'
			call add(cmd_list, 'xkev -s -e 0x00' . s:get_hex_char(c))
		else
			call add(cmd_list, 'xkev -A -e 0x00' . s:get_hex_char(c))
		endif
	endfor
	return cmd_list
endfunction

" Get all win_id of current node
" INFO: nvim_list_wins() do the same
function! s:get_all_windows() abort
	let windows = []
	for tab in range(1, tabpagenr('$'))
		for win_id in gettabinfo(tab)[0].windows
			call add(windows, win_id)
		endfor
	endfor
	return windows
endfunction

" Get the other win_id, because there is just one other window
function! s:get_other_window(file) abort
	for id in s:get_all_windows()
		let file_name = bufname(winbufnr(id))
		if strlen(matchstr(a:file, file_name))
			return id
		endif
	endfor
	return 0
endfunction

" Get all nodes_id
function! s:get_all_nodes() abort
	let nodes = split(system("bspc query -N | tr '\n' ' '"))
	return nodes
endfunction

" Get the other node, because can exist more than one *VIM node
function! s:get_vim_nodes() abort
	let other_node = []
	let nodes = s:get_all_nodes()
	for node in nodes
		if node != '0x0' . s:get_hex_number($WINDOWID) && system('xtitle ' . node) =~ '\v.*VIM\n$\C'
			call add(other_node, node)
		endif
	endfor
	return other_node
endfunction

" Function to search for window in injection
function! swapfile#look_for(file) abort
	call win_gotoid(s:get_other_window(a:file))
endfunction

" Look for the window in others nodes
" FIXME: If there is more than two nodes, the loop will not stop if it find the right window
function! s:detect_window_in_other_node() abort
	let others_vim = s:get_vim_nodes()
	if empty(others_vim)
		return ''
	endif
	for node in others_vim
		let s:cmd[0] .= node
		let s:cmd += s:get_cmd_from_string('call swapfile#look_for(' . "'" . s:file . "'" . ')')
		" Return, enter
		call add(s:cmd, 'xkev -e 0xff0a')
		call system(join(s:cmd, ';'))
	endfor
	return ''
endfunction

let &cpo = s:cpo_save
