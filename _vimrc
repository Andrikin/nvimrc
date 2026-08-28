" $MYVIMRC
" Autor: André Alexandre Aguiar
" Email: andrealexandreaguiar@gmail.com

" WARNING: Instalação -> ($VIM/_vimrc) C:\user\profile\Documents\gvim\vim\_vimrc
" INFO: MS-Windows :h initialization
" NOTE: PORTABLE-GVIM configurations locations
" https://portablegvim.sourceforge.net/configuration.html

if has('win32')
	let s:THISPC = $HOMEDRIVE .. $HOMEPATH
    let s:NVIM = glob(s:THISPC .. '/D*/nvim/*/nvim')
	" NVIMOPTS dependencies in this computer
	let s:OPTSFILE = glob(s:NVIM .. '/opt/optfile')
    if !filereadable(s:OPTSFILE)
        " in thumbdrive?
        let s:OPTSFILE = glob($VIMRUNTIME[0:1] .. '/nvim/*/nvim/opt/optfile')
        if !filereadable(s:OPTSFILE)
            " fallback to 'optfiles' in vim folder
            let s:OPTSFILE = fnamemodify($MYVIMRC, ':h') .. '/optfiles'
        endif
    endif
    " Edit 'optsfile'
    command! Optsfile execute ':e ' .. s:OPTSFILE
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
    " Update 'optfiles'
	command! UpdateOptfile call <SID>path_initialize(v:true)
	function! s:find_nvim_opt() abort
        " buscar por arquivos executáveis
        let nvimdirglob = s:NVIM .. '/opt/*/**/*.{bat,cmd,exe}'
		if !isdirectory(s:NVIM)
			silent echom "Não foi possível encontrar diretório de instalação do Neovim."
			return
		endif
		" ponto crítico, de mais demora
		let opts = glob(nvimdirglob, v:false, v:true, v:false)->map({_, dir -> fnamemodify(dir, ':h')})->uniq()
		call writefile(opts, s:OPTSFILE)
		silent echom "Arquivo OPTSFILE criado!"
	endfunction
	function! s:add_path(dir) abort
        let $PATH = $PATH .. ';' .. a:dir
	endfunction
	" inicializar PATH
    if filereadable(s:OPTSFILE)
        call s:path_initialize(v:false)
    endif
else
    " LINUX
	let s:THISPC = $HOME
endif

" Plug.vim bootstrap
if has('win32')
	let s:plugvim = fnamemodify($MYVIMRC, ':h') .. '/vimfiles/autoload/plug.vim'
else
	let s:plugvim = fnamemodify($MYVIMRC, ':h') .. '/autoload/plug.vim'
endif
if executable('curl') && !filereadable(s:plugvim)
    call system([
        \ 'curl',
        \ '-fLo',
        \ s:plugvim,
        \ '--create-dirs',
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    \ ])
	if executable('git')
		if filereadable(s:plugvim)
			execute 'source ' .. s:plugvim
		else
			silent echom "plug.vim não encontrado."
		endif
	else
		silent echom "git: instalar git ou inicializá-lo no $PATH"
	endif
endif

if has('win32')
	let s:plugged = fnamemodify($MYVIMRC, ':h') .. '/vimfiles/plugged'
else
	let s:plugged = fnamemodify($MYVIMRC, ':h') .. '/plugged'
endif
call plug#begin(s:plugged)

" colorscheme
Plug 'https://github.com/flazz/vim-colorschemes'
" Tim Pope pieces of miracle
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/tpope/vim-surround.git'
Plug 'https://github.com/tpope/vim-eunuch.git'
Plug 'https://github.com/tpope/vim-dadbod.git'
" Plug 'https://github.com/tpope/vim-commentary'
" use packadd comment - native plugin vim9.2
" My plugins
Plug 'https://github.com/Andrikin/awesome-pairing'
Plug 'https://github.com/Andrikin/awesome-substitute'
Plug 'https://github.com/Andrikin/vim-capslock'
" Utilities
Plug 'https://github.com/justinmk/vim-dirvish.git'
Plug 'https://github.com/mbbill/undotree'
Plug 'https://github.com/romainl/vim-cool.git'
Plug 'https://github.com/markonm/traces.vim'

if executable('ctags')
    Plug 'https://github.com/ludovicchabant/vim-gutentags'
endif

call plug#end()

" Install plugins, first run - plug.vim
if !isdirectory(s:plugged)
	if exists(':PlugInstall')
		PlugInstall
	endif
endif

" Add 'after/ftplugin' to runtimepath
if has('win32')
    let &g:rtp = &g:rtp .. ',' .. $VIM .. '/after'
endif

" Add optional packages.
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
	packadd! matchit
	packadd! hlyank
	packadd! comment
endif

if has("linux")
    " :Man pager
    runtime ftplugin/man.vim
endif

" configurações próprias do tema, no caso 'molokai'
silent! colorscheme monokain
highlight clear Visual
highlight Visual guibg=#293739 gui=italic

" Search recursively in directories
setglobal path+=**
setglobal path+=.

" matchit configurations
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
set nomore
set shortmess=aoOt
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
set completeopt=menu,noinsert,noselect,popup,fuzzy
" autocomplete pode causar muito lag ao digitar. Deixar para autocomplete
" buscar no próprio buffer pelas palavras
set complete=.
set autocomplete
" set autocompletedelay=250
" set autocompletetimeout=80
set title
set hidden
set mouse=
if has('win32')
    let &g:viminfo=&g:viminfo .. ',n' .. $VIM .. '\_viminfo'
endif
set undofile
set noswapfile
" set linebreak
" set wrapmargin=5
let &g:textwidth=0
let &g:undodir=fnamemodify($MYVIMRC, ':h') .. '/undotree'
if !isdirectory(&g:undodir)
    call mkdir(&g:undodir, 'p', 0o755)
endif
let mapleader = ' '
let maplocalleader = ' '

" Statusline
set laststatus=2
set showtabline=1 
set noshowmode 

" Spell
" WARNING: para realizar o download, netrw precisa estar carregado
" TODO: encontrar um modo de realizar o download automaticamente...
set spelllang=pt_br

" St tem um problema com o cursor. Ele não muda de acordo com as cores da
" fonte que ele está sobre. Dessa forma, com o patch de Jules Maselbas
" (https://git.suckless.org/st/commit/5535c1f04c665c05faff2a65d5558246b7748d49.html),
" é possível obter o cursor com a cor do texto (com truecolor)
set termguicolors

" -- GUI --
set guicursor=i-n-v-c:block,n-v-c:blinkwait700-blinkoff400-blinkon250
" ! -> no external cmd window prompt output
" d -> dark mode (Windows version)
set guioptions=!d
if has('win32')
    let &g:guifont='SauceCodePro NFM:h12'
else
    let &g:guifont='SauceCodePro Nerd Font Mono 11'
endif
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

" Set python3.+
let python2 = exepath('python')
let python3 = exepath('python3.14')
if python2 != ''
    let g:python_host_prog = python2
endif
if python3 != ''
    let g:python3_host_prog = python3
endif

" Awesome substitute config
let g:awesome_pairing_chars = "({[\'\""

" --- UndoTree ---
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_DiffpanelHeight = 5

" --- Gutentags ---
if executable('ctags')
    if has('win32')
        let g:gutentags_cache_dir = fnamemodify($MYVIMRC, ':h') .. '/vimfiles/cache/ctags'
    else
        let g:gutentags_cache_dir = $MYVIMDIR .. 'cache/ctags'
    endif
    if !isdirectory(g:gutentags_cache_dir)
        call mkdir(g:gutentags_cache_dir, 'p', 0o755)
    endif
    let g:gutentags_add_default_project_roots = 0
    let g:gutentags_project_root = ['package.json', '.git']
    let g:gutentags_generate_on_new = 1
    let g:gutentags_generate_on_missing = 1
    let g:gutentags_generate_on_write = 1
    let g:gutentags_generate_on_empty_buffer = 0
else
    silent echom 'Ctags: executável não encontrado. Realizar instalação!'
endif

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

" vim.traces configuration
" Window used to show off-screen matches.
let g:traces_preview_window = "winwidth('%') > 160 ? 'bot vnew' : 'bot 10new'"

" --- Key maps ---

" FROM: defaults.vim
" Don't use Q for Ex mode, use it for formatting.  Except for Select mode.
" Revert with ":unmap Q".
map Q gq
sunmap Q

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

" ctrl-v clipboard
inoremap <c-v> <c-r>+
cnoremap <c-v> <c-r>+

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
function! s:arglistthings(comando) abort
    let n = argc() - 1
    if n <= 0
        silent echom "arglist: nenhum arquivo listado."
        return
    endif
    try
        execute a:comando
    catch /^Vim\%((\S\+)\)\=:E165:/
        execute ':' .. n .. 'previous'
    catch /^Vim\%((\S\+)\)\=:E164:/
        execute ':' .. n .. 'next'
    endtry
endfunction
nnoremap <silent> ]a <cmd>call <SID>arglistthings('next')<cr>
nnoremap <silent> [a <cmd>call <SID>arglistthings('previous')<cr>

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
if has('win32')
    " fix keyboard weird interation
    nnoremap <silent> <c-\> <c-]>
else
    " Terminal map
    tnoremap <silent> <c-]> <c-\>
endif

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
else
    " Dirvish XDGlikesh
    if exists('$XDG_DOWNLOAD_DIR') && exists('$XDG_DOCUMENTS_DIR') && exists('$XDG_DESKTOP_DIR')
        command! Downloads execute 'Dirvish ' .. $XDG_DOWNLOAD_DIR
        command! Documents execute 'Dirvish ' .. $XDG_DOCUMENTS_DIR
        command! Desktop execute 'Dirvish ' .. $XDG_DESKTOP_DIR
    else
        command! Downloads execute 'Dirvish ~/downloads'
        command! Documents execute 'Dirvish ~/documentos'
        command! Desktop execute 'Dirvish ~/desktop'
    endif
    command! Home execute 'Dirvish ' .. s:THISPC
endif

" Command binary to hex
command! HexEditor %!xxd

" Dirvish sorting
command! SortingDirvish call <SID>sortingdirvish()

" Toggle :terminal. Use 'i' to enter Terminal Mode. 'ctrl-\ctrl-n' to exit
" when <c-\> mapped to <c-]>
let g:ttoggler = {}
function! s:toggle_terminal() abort
    let tnumber = tabpagenr()
    if !tnumber
        silent echom "terminal: sem número de tabpage"
        return 
    endif
    " terminal buffer existe?
    if get(g:ttoggler, tnumber, 0) && len(getbufinfo(get(g:ttoggler, tnumber, 0)))
        let binfo = getbufinfo(g:ttoggler[tnumber])[0]
        " está aberto?
        if !binfo.hidden
            call win_execute(binfo.windows[0], 'close', v:true)
        else
            execute 'split +b' .. g:ttoggler[tnumber]
        endif
    else
        " abrir
        terminal
        " registrar
        let b = bufnr(0)
        let info = win_findbuf(b)[0]->getwininfo()[0]
        if info.terminal
            let g:ttoggler[tnumber] = b
        else
            for wbuf in term_list()
                let winfo = win_findbuf(wbuf)[0]->win_id2tabwin()
                let wtab = winfo[0]
                if wtab == tnumber
                    let g:ttoggler[tnumber] = wbuf
                    break
                endif
            endfor
        endif
    endif
endfunction

" DIRVISH
" list files 
function! s:SortIt(a, b) abort
    if a:a.mtime > a:b.mtime
        return -1
    elseif a:a.mtime < a:b.mtime
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
" WARNING: adicionar a pasta after/ftplugin no 'runtimepath'
function! DirvishOpen() abort
    let arquivo = getline('.')
    let ext = fnamemodify(arquivo, ':e')
    let noexecute = ext == '' || isdirectory(arquivo)
    if has('win32')
        let noexecute = noexecute || $PATHEXT->tolower()->match(ext) < 0 ? 0 : 1
    endif
    " let arquivo = arquivo->shellescape()->trim()
    if !noexecute
        if has('win32')
            call dist#vim9#Open(arquivo) | nohlsearch
            " call job_start(['cmd.exe', '/c', 'start', '', arquivo])
        else
            " call dist#vim9#Open(arquivo)
            let arquivo = arquivo->trim()
            call job_start(['xdg-open', arquivo])
        endif
    else
        silent echom "dirvish: não foi encontrado arquivo para abrir"
    endif
endfunction

" --- Autocommands ---
" for map's use <buffer>, for set's use setlocal

augroup goosebumps
	autocmd!
augroup END

" linux GVim maximized window
function! s:resizeit() abort
    if executable('wmctrl')
        let winid = split(system('wmctrl -pl | grep ' .. shellescape(getpid())))
        try
            let winid = winid[0]
        catch /^Vim\%((\S\+)\)\=:E684:/
            echo 'Não foi possível redimensionar Gvim'
        endtry
        if winid
            call system('wmctrl -i -b add,maximized_vert,maximized_horz -r ' .. winid)
        endif
    endif
endfunction
" Open in fullscreen
if has('win32')
    autocmd goosebumps GUIEnter * simalt ~<space>x
else
    autocmd goosebumps VimEnter * call <SID>resizeit()
endif
set winaltkeys=no

" set environment variables for 'uv'
if has('python') && has('uv')
    let UVDIR = fnamemodify(exepath('uv'), ':h')
    $UV_PYTHON_INSTALL_DIR = UVDIR
    $UV_TOOL_BIN_DIR = UVDIR
    $UV_TOOL_DIR = UVDIR
    $UV_CACHE_DIR = UVDIR .. '\cache'
endif

" Force 'path' setting
autocmd goosebumps FileType * let &g:path=&g:path

" When enter/exit Insert Mode, change line background color
autocmd goosebumps InsertEnter * setlocal cursorline
autocmd goosebumps InsertLeave * setlocal nocursorline

" Configuração para arquivos temporários copyq
autocmd goosebumps BufRead CopyQ.*.txt setlocal textwidth=78 spell noeol nofixeol ff=dos

" autoresize
autocmd goosebumps VimResized * wincmd =

if has('win32')
    let $HOME = $VIM
endif

if has('win32')
    cd $USERPROFILE\Desktop
else
    cd desktop
endif 

