" $MYVIMRC --- NeoVim ---
" Autor: André Alexandre Aguiar
" Email: andrealexandreaguiar@gmail.com
" Dependences: [surround, comment, capslock, eunuch, fugitive] tpope,
" vim-cool, vim-dirvish, undotree,

" TODO:
" WARNING: diretório de instalação -> C:$HOME/Documents/gvim/Data/settings/_vimrc
" INFO: MS-Windows :h initialization -> $HOME/_vimrc, $HOME/vimfiles/vimrc or
" $VIM/_vimrc
" $MYVIMRC - já setado corretamente se respeitado os locais de inicialização do
" VIM - h: inicialization
" GVIM config locations
" https://portablegvim.sourceforge.net/configuration.html

" NVIM
if has('win32')
	let s:THISPC = $HOMEDRIVE .. $HOMEPATH
	if executable('fd')
		let s:NVIM = glob("`fd --type -d win-portable-neovim %HOMEPATH%`") .. 'nvim'
	else
		let s:NVIM = glob(s:THISPC .. '/D*/nvim/*/nvim')
	endif
	" NVIM OPTS dependencies
	let s:OPTSFILE = fnamemodify($MYVIMRC, ':h') .. '/optfiles'
	" list nvim/opt and add it to $PATH
	function! s:path_initialize(force) abort
		if !filereadable(s:OPTSFILE) || a:force
			call s:find_nvim_opt()
		endif
		let paths = readfile(s:OPTSFILE)
		for path in paths
			call s:add_path(path)
		endfor
	endfunction
	function! s:find_nvim_opt() abort
		let nvimdirglob = s:NVIM .. '/opt/*/**/*.exe'
		if !isdirectory(s:NVIM)
			echom "Não foi possível encontrar diretório de instalação do Neovim."
			return
		endif
		" ponto crítico, de mais demora
		let opts = glob(nvimdirglob, v:false, v:true, v:false)->map({_, dir -> fnamemodify(dir, ':h')})->uniq()
		call writefile(opts, s:OPTSFILE)
		echom "Arquivo OPTSFILE criado!"
	endfunction
	function! s:add_path(dir) abort
        let $PATH = $PATH .. ';' .. a:dir
	endfunction
	" inicializar PATH
	call s:path_initialize(v:false)
else
	let s:THISPC = $HOME
endif

" Plug.vim bootstrap
if has('win32')
	let s:plugvim = fnamemodify($MYVIMRC, ':h') .. '/vimfiles/autoload/plug.vim'
else
	let s:plugvim = fnamemodify($MYVIMRC, ':h') .. '/autoload/plug.vim'
endif
if executable('curl') && !filereadable(s:plugvim)
	call system(['curl', '-fLo', s:plugvim, '--create-dirs', 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'])
	if executable('git')
		if filereadable(s:plugvim)
			execute 'source ' .. s:plugvim
		else
			echom "plug.vim não encontrado."
		endif
	else
		echom "git: instalar git ou inicializá-lo no $PATH"
	endif
endif

call plug#begin()

Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/tpope/vim-surround.git'
Plug 'https://github.com/tpope/vim-eunuch.git'
Plug 'https://github.com/tpope/vim-dadbod.git'
Plug 'https://github.com/tpope/vim-commentary'
Plug 'https://github.com/Andrikin/awesome-pairing'
Plug 'https://github.com/justinmk/vim-dirvish.git'
Plug 'https://github.com/Andrikin/awesome-substitute'
Plug 'https://github.com/Andrikin/vim-capslock'
Plug 'https://github.com/mbbill/undotree'
Plug 'https://github.com/romainl/vim-cool.git'
Plug 'https://github.com/flazz/vim-colorschemes'

call plug#end()

if has('win32')
	let plugged = fnamemodify($MYVIMRC, ':h') .. '/vimfiles/plugged'
else
	let plugged = fnamemodify($MYVIMRC, ':h') .. '/plugged'
endif
if !isdirectory(plugged)
	if exists(':PlugInstall')
		PlugInstall
	endif
endif

" Add optional packages.
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
	packadd! matchit
	packadd! hlyank
endif

silent! colorscheme molokai

" Search recursively
set path+=**

" matchit
set matchpairs+=<:>

" Indicadores - números nas linhas
set rnu 
set nu

" Tamanho da indentação
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Configurações para search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Configurações gerais
set noautochdir
set scrolloff=999
set lazyredraw
set backspace=indent,eol,start
set splitbelow
set splitright
set helpheight=15
" Problems that can occur in vim session can be avoid using this configuration
set sessionoptions-=options
set encoding=utf-8
set autoread
set tabpagemax=50
set wildmenu
set wildoptions=pum,tagfile
set complete-=t
set completeopt=menu,noinsert,noselect,popup,fuzzy
set autocomplete
set title
set hidden
set mouse=
set undofile
set noswapfile
" set linebreak
" set wrapmargin=5
let &g:textwidth=0
let &g:undodir=fnamemodify($MYVIMRC, ':h') .. '/undotree'
let mapleader = ' '
let maplocalleader = ' '

" Statusline
set laststatus=3
set showtabline=1 
set noshowmode 

" St tem um problema com o cursor. Ele não muda de acordo com as cores da
" fonte que ele está sobre. Dessa forma, com o patch de Jules Maselbas
" (https://git.suckless.org/st/commit/5535c1f04c665c05faff2a65d5558246b7748d49.html),
" é possível obter o cursor com a cor do texto (com truecolor)
set termguicolors

" gui options
set guicursor=i-n-v-c:block,n-v-c:blinkwait700-blinkoff400-blinkon250
set winaltkeys=no
let &g:guifont='SauceCodePro NFM:h11'
let &g:fillchars='vert:|,fold:*,foldclose:+,diff:-'

" Using ripgrep ([cf]open; [cf]do {cmd} | update)
if executable('rg')
	let &g:grepprg='rg --vimgrep --smart-case --follow'
else
	let &g:grepprg='grep -R'
endif

" --- Netrw ---
" Disable Netrw
let g:loaded_netrwPlugin = 1
let g:loaded_netrw = 1

" Set python
" let g:python_host_prog = '/usr/bin/python2'
" let g:python3_host_prog = '/usr/local/bin/python3'

" Awesome substitute config
let g:awesome_pairing_chars = "({[\'\""

" --- UndoTree ---
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_DiffpanelHeight = 5

" vim-surround Tim Pope
let g:surround_{char2nr('\')} = ''
let g:surround_{char2nr('l')} = ''
let g:surround_{char2nr('t')} = ''

" disable providers
let g:loaded_perl_provider = 0
let g:loaded_ruby_provider = 0

" hlyank
let g:hlyank_duration = 300

" dirvish sort
let g:dirvish_mode = ':SortingDirvish'

" --- Key maps ---

" CTRL-U in insert mode deletes a lot. Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>". -> from defaults.vim
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
nnoremap <backspace> X
nnoremap <c-h> X
nnoremap ' `
" Fix & command. Redo :substitute command
nnoremap & <cmd>&&<cr>
xnoremap & <cmd>&&<cr>
" Yank to end of sreen line.
" g$ cursor after last character, g_ cursor at last character
nnoremap Y yg_
" Disable <c-z> (:stop)
nnoremap <c-z> <nop>
" Join lines in a better way - From a video of ThePrimeagen
nnoremap J mzJ`z
" Undo better - inserting breaking points, thanks to ThePrimeagen
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ( (<c-g>u
inoremap [ [<c-g>u
inoremap { {<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Using gk and gj (screen cursor up/down)
" nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
" nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
" Adding jumps to jumplist - The Primeagen gold apple
" nnoremap <expr> k (v:count > 1 ? 'm`' . v:count : '') . 'k'
" nnoremap <expr> j (v:count > 1 ? 'm`' . v:count : '') . 'j'
function! s:vanhalen(move) abort
    let cont = v:count
    let mark = ''
    if cont > 1
        let mark = 'm`' .. cont
    endif
    if cont == 0
        return mark .. 'g' .. a:move
    endif
    return mark .. a:move
endfunction
nnoremap <expr> <silent> k <SID>vanhalen('k')
nnoremap <expr> <silent> j <SID>vanhalen('j')

" Moving lines up and down - The Primeagen knowledge word
" inoremap <c-j> <c-o>:m.+1<cr> " utilizo muito <c-j> para newlines, seria
" inviável trocar para essa funcionalidade
" inoremap <c-k> <c-o>:m.-2<cr>
nnoremap <leader>k <cmd>m.-2<cr>
nnoremap <leader>j <cmd>m.+1<cr>
vnoremap K :m'<-2<cr>gv
vnoremap J :m'>+1<cr>gv

" Vim-capslock in command line
" cmap <silent> <expr> <c-l> <SID>capslock_redraw()

" for buffers
nnoremap <silent> ]b <cmd>bnext<cr>
nnoremap <silent> [b <cmd>bprevious<cr>
" for arglist
nnoremap <silent> ]a <cmd>next<cr>
nnoremap <silent> [a <cmd>Next<cr>

" --- Mapleader Commands ---
" Insert Mode maps

" open $MYVIMRC
nnoremap <silent> <leader>r <cmd>execute 'Dirvish ' .. fnamemodify($MYVIMRC, ':h')<cr>

" Copy and paste from clipboard (* -> selection register/+ -> primary register)
nnoremap gP "+P
nnoremap gp "+p
vnoremap gy "+y
nnoremap gY "+Y

" Fix ^\
nnoremap <silent> <c-\> <c-]>

" adicionar linhas acima e abaixo
nnoremap <silent> [<space> <cmd>normal O<cr><down>
nnoremap <silent> ]<space> <cmd>normal o<cr><up>

" Terminal
nnoremap <silent> <leader>t <cmd>call <SID>toggle_terminal()<cr>

" Fugitive maps
nnoremap <leader>g <cmd>Git<cr>

" Undotree plugin
nnoremap <silent> <leader>u <cmd>UndotreeToggle<cr>

" --- Command's ---

" Neovim configuration directory
if has('win32')
	command! NvimConfig execute 'Dirvish ' .. s:NVIM .. '/config/nvim/lua/andrikin/'
	command! Downloads execute 'Dirvish ' .. s:THISPC .. '/Downloads'
	command! Documents execute 'Dirvish ' .. s:THISPC .. '/Documents'
	command! Desktop execute 'Dirvish ' .. s:THISPC .. '/Desktop'
	command! RedeLocal execute 'Dirvish T:/16-Diretoria de Ouvidoria/Andre Aguiar/' 
	command! ComunicacaoInterna execute 'Dirvish T:/1-Comunicação Interna - C.I/' .. strftime('%Y')
	" update OPTSFILE
	command! UpdateOptfile call <SID>find_nvim_opt(v:true)
else
    " Dirvish XDGlikesh
    command! Downloads execute 'Dirvish ' .. s:THISPC .. '/downloads'
    command! Documents execute 'Dirvish ' .. s:THISPC .. '/documentos'
    command! Desktop execute 'Dirvish ' .. s:THISPC .. '/desktop'
    command! Home execute 'Dirvish ' .. s:THISPC
endif

" Command binary to hex
command! HexEditor %!xxd

" Dirvish sorting
command! SortingDirvish call <SID>sortingdirvish()

" Toggle :terminal.
let g:terminal_toggle = {}
function! s:toggle_terminal() abort
    let tabnr = tabpagenr()
    if !tabnr
        echom "terminal_toggle: erro encontrado"
        return
    endif
    " terminal aberto no tab?
    if get(g:terminal_toggle, tabnr, 0)
        let buf = getbufinfo(g:terminal_toggle[tabnr])
        if !empty(buf)
            let buf = buf[0]
            if buf.hidden
                execute 'split +b\ ' .. g:terminal_toggle[tabnr]
            else
                call win_execute(win_findbuf(g:terminal_toggle[tabnr])[0], 'close', v:true)
            endif
        endif
    else
        " novo terminal no tab
        let terminals = term_list()
        if empty(terminals)
            terminal
            let g:terminal_toggle[tabnr] = term_list()[0]
        else
            if count(terminals, g:terminal_toggle[tabnr])
                " abro o buffer do terminal existente
                execute ':split +b\ ' .. g:terminal_toggle[tabnr]
            else
                " abro novo terminal e adiciono na lista
                terminal
                let tabbufs = tabpagebuflist()
                for t in terminals
                    if count(tabbufs, t)
                        let g:terminal_toggle[tabnr] = t
                        break
                    endif
                endfor
            endif
        endif
    endif
endfunction

" DIRVISH
" list files 
function! s:SortIt(a, b) abort
    if a:a.mtime > a:b.mtime
        return -1
    endif
    if a:a.mtime < a:b.mtime
        return 1
    endif
    return 0
endfunction
function! s:sortingdirvish() abort
	let plist = getline(1, line('$'))
	if len(plist) == 1 && plist[0] == ''
		let plist = []
	endif
    if has('win32')
        silent! global /[^\\]$/d
    else
        silent! global /[^/]$/d
    endif
	let dlist = getline(1, line('$'))
	if len(dlist) == 1 && dlist[0] == ''
		let dlist = []
	endif
	let fpaths = []
	for p in plist
		let path = {'path': p, 'mtime': getftime(p)}
		if getftype(p) != 'dir'
			call add(fpaths, path)
		endif
	endfor
	" ordernar arquivos
	call sort(fpaths, {a, b -> s:SortIt(a, b)})
	for path in fpaths
		call add(dlist, path.path)
	endfor
	call setline(1, dlist)
endfunction

" Open files
function! s:dirvishopen() abort
    let arquivo = getline('.')
    let ext = fnamemodify(arquivo, ':e')
    let notexecute = ext == '' || isdirectory(arquivo)
    if has('win32')
        let notexecute = notexecute || $PATHEXT->tolower()->match(ext)
    endif
    let arquivo = arquivo->trim()
    if !notexecute
        if has('win32')
            call job_start(['cmd.exe', '/c', 'start', '', arquivo->tr('/', '\')])
        else
            call job_start(['xdg-open', arquivo])
        endif
    else
        echom "dirvish: não foi encontrado arquivo para abrir"
    endif
endfunction

" --- Autocommands ---
" for map's use <buffer>, for set's use setlocal

augroup goosebumps
	autocmd!
augroup END

" Comentary.vim
autocmd goosebumps FileType sh,bash setlocal commentstring=#\ %s
autocmd goosebumps FileType c setlocal commentstring=/*\ %s\ */
autocmd goosebumps FileType java setlocal commentstring=//\ %s
autocmd goosebumps FileType vim setlocal commentstring=\"\ %s

" When enter/exit Insert Mode, change line background color
autocmd goosebumps InsertEnter * setlocal cursorline
autocmd goosebumps InsertLeave * setlocal nocursorline

" autoresize
autocmd goosebumps VimResized * wincmd =

" 'gq' to exit
autocmd goosebumps FileType help,qf nnoremap <silent> <buffer> gq <cmd>close<cr>

" Dirvish mappings
autocmd goosebumps FileType dirvish nnoremap <silent> <buffer> go <cmd>call <SID>dirvishopen()<cr>
