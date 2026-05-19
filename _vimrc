" $MYVIMRC --- NeoVim ---
" Autor: André Alexandre Aguiar
" Email: andrealexandreaguiar@gmail.com
" Dependences: [surround, comment, capslock, eunuch, fugitive] tpope, vim-cool, vim-dirvish, undotree, vim-highlightedyank

" WARNING: diretório de instalação -> C:/Users/09153634969/Documents/gvim/Data/settings/_vimrc
source $VIMRUNTIME/defaults.vim

" Plug.vim bootstrap
let s:plugvimdir = ''
if executable('curl') && !filereadable(s:plugvimdir)
	system(['curl', '-fLo', s:plugvimdir, '--create-dirs', 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'])
	source s:plugvimdir
endif

let $MYVIMRC = "C:/Users/09153634969/Documents/gvim/Data/settings/vimrc"

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
Plug 'https://github.com/machakann/vim-highlightedyank'
Plug 'https://github.com/mbbill/undotree'
Plug 'https://github.com/romainl/vim-cool.git'
Plug 'https://github.com/flazz/vim-colorschemes'

call plug#end()

" Add optional packages.
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

silent! colorscheme molokai

" Search recursively
set path+=**

" Indicadores - números nas linhas
set rnu 
set nu

" Tamanho da indentação
set tabstop=4
set shiftwidth=4
set softtabstop=4

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
"let &g:shell='cmd.exe'
"let &g:shellpipe='2>&1 | tee'
set complete-=t
set title
set hidden
set mouse=nvi
set undodir=C:/Users/09153634969/Documents/gvim/Data/settings/undotree
set undofile
set noswapfile
" set linebreak
" set wrapmargin=5
let &g:textwidth=0
let mapleader = ' '

" Statusline
set laststatus=3
set showtabline=2 
set noshowmode 

" St tem um problema com o cursor. Ele não muda de acordo com as cores da fonte que ele está sobre. Dessa forma, com o patch de Jules Maselbas (https://git.suckless.org/st/commit/5535c1f04c665c05faff2a65d5558246b7748d49.html), é possível obter o cursor com a cor do texto (com truecolor)
set termguicolors

set guicursor=
let &g:guifont='SauceCodePro NFM:h11'
"set inccommand=
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
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" Awesome substitute config
let g:awesome_pairing_chars = "({[\'\""

" --- UndoTree ---
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_DiffpanelHeight = 5

" nvim opts dependencies
let s:OPTSFILE = ''

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
" Yank to end of sreen line. Make default in Neovim 0.6.0
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
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
" Adding jumps to jumplist - The Primeagen gold apple
nnoremap <expr> k (v:count > 1 ? 'm`' . v:count : '') . 'k'
nnoremap <expr> j (v:count > 1 ? 'm`' . v:count : '') . 'j'

" Moving lines up and down - The Primeagen knowledge word
" inoremap <c-j> <c-o>:m.+1<cr> " utilizo muito <c-j> para newlines, seria inviável trocar para essa funcionalidade
" inoremap <c-k> <c-o>:m.-2<cr>
nnoremap <leader>k <cmd>m.-2<cr>
nnoremap <leader>j <cmd>m.+1<cr>
vnoremap K :m'<-2<cr>gv
vnoremap J :m'>+1<cr>gv

" Vim-capslock in command line
cmap <silent> <expr> <c-l> <SID>capslock_redraw()

" for buffers
nnoremap <silent> ]b <cmd>bnext<cr>
nnoremap <silent> [b <cmd>bprevious<cr>
" for arglist
nnoremap <silent> ]a <cmd>next<cr>
nnoremap <silent> [a <cmd>Next<cr>

" --- Mapleader Commands ---
" Be aware that '\' is used as mapleader character, so conflits can occur in Insert Mode maps

" open $MYVIMRC
" nnoremap <silent> <leader>r <cmd>tabe $MYVIMRC<cr>
nnoremap <silent> <leader>r <cmd>Dirvish C:/Users/09153634969/Documents/gvim/Data/settings/<cr>

" :mksession
" nnoremap <silent> <leader>ss :call <SID>save_session()<cr>

" Copy and paste from clipboard (* -> selection register/+ -> primary register)
nnoremap gP "+P
nnoremap gp "+p
vnoremap gy "+y
nnoremap gY "+Y

" --- Quickfix window ---
" Toggle quickfix window
nnoremap <silent> <expr> <leader>c <SID>toggle_list('c')
nnoremap <silent> <expr> <leader>l <SID>toggle_list('l')
nnoremap <silent> <expr> <leader>q <SID>quit_list()

" Terminal
nnoremap <silent> <expr> <leader>t <SID>toggle_terminal()

" Fugitive maps
nnoremap <leader>g <cmd>Git<cr>

" Undotree plugin
nnoremap <silent> <leader>u <cmd>UndotreeToggle<cr>

" --- Command's ---

" Dirvish modes
command! -nargs=? -complete=dir Sirvish belowright split | silent Dirvish <args>
command! -nargs=? -complete=dir Virvish leftabove vsplit | silent Dirvish <args>
command! -nargs=? -complete=dir Tirvish tabedit | silent Dirvish <args>

" Command binary to hex
command! HexEditor %!xxd

" --- Functions ---
"
" HACK: Way to get :redraws after CapsLockToggle
function! s:capslock_redraw() abort
	let cmd = "\<plug>CapsLockToggle\<c-r>="
	let exec_redraw = "execute('redraws')"
	if CapsLockStatusline() is ''
		let exec_redraw = toupper(exec_redraw)
	endif
	return cmd . exec_redraw . "\<cr>"
endfunction

function! s:quit_list() abort
	let qf = s:qf_stats()
	let tf = s:t_stats()
	let cmd = ''
	if qf[0]
		let cmd = qf[1] ? ":lclose\<cr>" : ":cclose\<cr>"
	elseif tf[0]
		let cmd = join([':', tf[1], " windo normal ZQ\<cr>"], '')
	endif
	return cmd
endfunction

function! s:move_in_list(move) abort
	let qf = s:qf_stats()
	let cmd = ":" . v:count1
	let go_back_to_qf = ":call win_gotoid(" . qf[2] . ")\<cr>"
	if a:move == 'l'
		let cmd .= qf[1] ? "lnewer\<cr>" : "cnewer\<cr>"
	elseif a:move == 'h'
		let cmd .= qf[1] ? "lolder\<cr>" : "colder\<cr>"
	elseif a:move == 'j'
		let cmd .= (qf[1] ? "lnext\<bar>" : "cnext\<bar>") . go_back_to_qf
	elseif a:move == 'k'
		let cmd .= (qf[1] ? "lprevious\<bar>" : "cprevious\<bar>") . go_back_to_qf
	endif
	return cmd
endfunction

function! s:toggle_list(type) abort
	let qf = s:qf_stats()
	let cmd = ''
	if a:type == 'c'
		if qf[0]
			let cmd = qf[1] ? ":lclose\<bar>:copen\<cr>" : ":cclose\<cr>"
		else
			let cmd = ":copen\<cr>"
		endif
	elseif a:type == 'l'
		if qf[0]
			let cmd = qf[1] ? ":lclose\<cr>" : ":cclose\<bar>:lopen\<cr>"
		else
			let cmd = ":lopen\<cr>"
		endif
	endif
	return cmd
endfunction

" Toggle :terminal. Use 'i' to enter Terminal Mode. 'ctrl-\ctrl-n' to exit
function! s:toggle_terminal() abort
	let stats = s:t_stats()
	if stats[0]
		return join([':', stats[1], " windo normal ZQ\<cr>"], '')
	endif
	return ":10split +terminal\<cr>"
endfunction

function! s:t_stats() abort
	for window in gettabinfo(tabpagenr())[0].windows
		if getwininfo(window)[0].terminal
			return [1, win_id2win(window)]
		endif
	endfor
	return [0, 0]
endfunction

" INFO: It don't look for situations when there is two quickfix windows open, but I think that it handles those situations
function! s:qf_stats() abort
	for window in gettabinfo(tabpagenr())[0].windows
		if getwininfo(window)[0].quickfix
			return [1, getwininfo(window)[0].loclist, window]
		endif
	endfor
	" is_qf_on, is_qf_loc, win_id
	return [0, 0, 0]
endfunction

function! s:set_qf_win_height() abort
	let stats = s:qf_stats()
	let lnum = stats[0] ? len(stats[1] ? getloclist(0) : getqflist()) : 0
	execute "resize " min([10, max([1, lnum])])
endfunction

function! s:g_bar_search(...) abort
	return system(join([&grepprg, shellescape(expand(join(a:000, ' '))), shellescape(expand("%"))], ' '))
endfunction

" list nvim/opt and add it to $PATH
function! s:path_initialize(force) abort
	if !filereadable(s:OPTSFILE) || a:force
		s:found_nvim_opt()
	endif
	let paths = readfile(s:OPTSFILE)
	for path in paths
		s:add_path(path)
	endfor
endfunction

function! s:found_nvim_opt() abort
	let nvimdirglob = ''
	let opts = glob(nvimdirglob, v:false, v:true, v:false)->map({_, dir -> fnamemodify(dir, ':h')})->uniq()
	writefile(opts, s:OPTSFILE)
endfunction

function! s:add_path(dir) abort
	let $PATH = $PATH .. ':' .. dir
endfunction

" --- Autocommands ---
" for map's use <buffer>, for set's use setlocal

augroup goosebumps
	autocmd!
augroup END

" Atalhos para arquivos específicos
" autocmd goosebumps FileType java,c nnoremap <buffer> <m-k> <SID>run_code()<cr>

" Quickfix maps
autocmd goosebumps FileType qf nnoremap <expr> <silent> <buffer> l <SID>move_in_list('l')
autocmd goosebumps FileType qf nnoremap <expr> <silent> <buffer> h <SID>move_in_list('h')
autocmd goosebumps FileType qf nnoremap <expr> <silent> <buffer> j <SID>move_in_list('j')
autocmd goosebumps FileType qf nnoremap <expr> <silent> <buffer> k <SID>move_in_list('k')
autocmd goosebumps FileType qf nnoremap <expr> <silent> <buffer> q <SID>quit_list()

autocmd goosebumps FileType * setlocal textwidth=0

" Match pair for $MYVIMRC
autocmd goosebumps FileType html,vim setlocal mps+=<:>

" Comentary.vim
autocmd goosebumps FileType sh,bash setlocal commentstring=#\ %s
autocmd goosebumps FileType c setlocal commentstring=/*\ %s\ */
autocmd goosebumps FileType java setlocal commentstring=//\ %s
autocmd goosebumps FileType vim setlocal commentstring=\"\ %s

" When enter/exit Insert Mode, change line background color
autocmd goosebumps InsertEnter * setlocal cursorline
autocmd goosebumps InsertLeave * setlocal nocursorline

" Open quickfix window automaticaly
autocmd goosebumps QuickFixCmdPost [^l]* ++nested cwindow
autocmd goosebumps QuickFixCmdPost l* ++nested lwindow
autocmd goosebumps FileType qf call <SID>set_qf_win_height()

" Fast quit in vim help files
autocmd goosebumps FileType help nnoremap <buffer> q :helpclose<cr>

" autoresize
autocmd goosebumps VimResized * wincmd =

