" $MYVIMRC --- NeoVim ---
" Autor: André Alexandre Aguiar
" Email: andrealexandreaguiar@gmail.com
" Dependences: ripgrep, traces.vim, [surround, comment, capslock, eunuch, fugitive] tpope, emmet-vim, vim-cool, vim-dirvish, undotree, vim-highlightedyank, vim-sxhkdrc, telescope.nvim [popup.nvim, plenary.nvim], nvim-treesitter [playground], nvim-colorizer, nvim-lspconfig
" TODO: Learn how to use vimdiff/diffing a file, learn :args and how to modify :args list, learn how to use :ls and :buffer, configure telescope!, learn lua!

" plugin -> verify $RUNTIMEPATH/ftplugin for files
" indent -> verify $RUNTIMEPATH/indent for files
filetype indent plugin on
syntax enable
" colorscheme molokai
colorscheme dracula

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
let &g:shell='/bin/bash'
let &g:shellpipe='2>&1 | tee'
set complete-=t
set title
set hidden
set mouse=nvi
set undodir=~/.config/nvim/undodir
set undofile
set noswapfile
" set linebreak
" set wrapmargin=5
let &g:textwidth=0
let mapleader = ' '

" Statusline
set laststatus=2 
set showtabline=2 
set noshowmode 

" St tem um problema com o cursor. Ele não muda de acordo com as cores da fonte que ele está sobre. Dessa forma, com o patch de Jules Maselbas (https://git.suckless.org/st/commit/5535c1f04c665c05faff2a65d5558246b7748d49.html), é possível obter o cursor com a cor do texto (com truecolor)
set termguicolors

" NeoVim
set guicursor=
set inccommand=
let &g:fillchars='vert: '

" Using ripgrep ([cf]open; [cf]do {cmd} | update)
if executable('rg')
	let &g:grepprg='rg --vimgrep --smart-case --follow'
else
	let &g:grepprg='grep -R'
endif

" --- lightline ---
" Only possible with SauceCodePro Nerd Font
let g:lightline = {
			\ 'colorscheme': 'darcula',
			\ 'separator': { 'left': '', 'right': '' },
			\ 'subseparator': { 'left': '', 'right': '' },
			\ 'tabline': {
			\	'left': [['tabs']],
			\ },
			\ 'active': {
			\	'left': [
			\		['mode', 'paste'],
			\		['readonly', 'filename'],
			\		['gitbranch'],
			\		],
			\	},
			\ 'component': {
			\	'close': '',
			\	'lineinfo': '%l/%L%<',
			\	},
			\ 'component_function': {
			\	'mode': 'LightlineMode',
			\	'readonly': 'LightlineReadonly',
			\	'filename': 'LightlineFilename',
			\	'gitbranch': 'LightlineStatusline',
			\	},
			\ 'tab': {
			\	'active': ['filename', 'modified'],
			\	'inactive': ['filename', 'modified'],
			\	},
			\ }

" --- Hexokinase ---
" let g:Hexokinase_highlighters = ['backgroundfull']

" --- Emmet ---
let g:user_emmet_install_global = 0
let g:user_emmet_leader_key = '<m-space>'

" --- Traces ---
let g:traces_num_range_preview = 1

" --- UndoTree ---
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_DiffpanelHeight = 5

" --- Netrw ---
" Disable Netrw
let g:loaded_netrwPlugin = 1

" Set python
let g:python_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" " --- Gutentags ---
" let g:gutentags_add_default_project_roots = 0
" let g:gutentags_project_root = ['package.json', '.git']
" let g:gutentags_cache_dir = expand('~/.cache/nvim/ctags/')
" let g:gutentags_generate_on_new = 1
" let g:gutentags_generate_on_missing = 1
" let g:gutentags_generate_on_write = 1
" let g:gutentags_generate_on_empty_buffer = 0

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
" Yank to end of sreen line
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

" Move to first/last character in screen line - Evita casos em que existem espaços no final da linha
nnoremap H g^
vnoremap H g^
nnoremap L g$
vnoremap L g$

" Vim-capslock in command line
cmap <silent> <expr> <c-l> <SID>capslock_redraw()

" --- Mapleader Commands ---
" Be aware that '\' is used as mapleader character, so conflits can occur in Insert Mode maps

" open $MYVIMRC
nnoremap <silent> <leader>r <cmd>tabe $MYVIMRC<cr>

" :mksession
" nnoremap <silent> <leader>ss :call <SID>save_session()<cr>

" Copy and paste from clipboard (* -> selection register/+ -> primary register)
nnoremap <leader>p "+P
vnoremap <leader>y "+y
nnoremap <leader>y "+y

" --- Quickfix window ---
" NeoVim excells about terminal jobs
nnoremap <silent> <leader>m <cmd>make %:S<cr>
" Toggle quickfix window
nnoremap <silent> <expr> <leader>c <SID>toggle_list('c')
nnoremap <silent> <expr> <leader>l <SID>toggle_list('l')
nnoremap <silent> <expr> <leader>q <SID>quit_list()

" Undotree plugin
nnoremap <silent> <leader>u <cmd>UndotreeToggle<cr>

" Terminal
nnoremap <silent> <expr> <leader>t <SID>toggle_terminal()

" Fugitive maps
nnoremap <leader>g <cmd>Git<cr>

" --- Telescope ---
nnoremap <silent> <leader>b <cmd>Telescope buffers<cr>
nnoremap <silent> <leader>o <cmd>Telescope find_files<cr>

" --- Builtin LSP commands ---
" Only available in git projects (git init)
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap <silent> <ctrl-k> <cmd>lua vim.lsp.buf.signature_help()<cr>
" Lida com erros LSP
nnoremap <silent> ]d <cmd>lua vim.lsp.diagnostic.goto_next()<cr>
nnoremap <silent> [d <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>
nnoremap <leader>e <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>
" Renomeia variável pelo projeto inteiro
nnoremap <leader>s <cmd>lua vim.lsp.buf.rename()<cr>

" --- Command's ---

" Dirvish modes
command! -nargs=? -complete=dir Sirvish belowright split | silent Dirvish <args>
command! -nargs=? -complete=dir Virvish leftabove vsplit | silent Dirvish <args>
command! -nargs=? -complete=dir Tirvish tabedit | silent Dirvish <args>

" Command binary to hex
command! HexEditor %!xxd

" --- Abbreviations ---

" --- Plug's ---

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

" Run C, Java code
" TODO: Make it better
function! s:run_code() abort
	let file = shellescape(expand("%:e"))
	if file ==? "java"
		execute join(['!java ', shellescape(expand("%:t:r"))])
	elseif file ==? "c"
		execute join(['!tcc -run ', shellescape(expand("%:t"))])
	endif
endfunction

 " --- Lightline Funcions --- 
 function! LightlineMode() abort
 	return lightline#mode() . ' ' . CapsLockStatusline()
 endfunction

function! LightlineReadonly() abort
	return &readonly ? '' : ''
endfunction

function! LightlineFilename() abort
	let filename = expand("%:t") !=# '' ? expand("%:t") : '[No Name]'
	let modified = &modified ? ' +' : ''
	return filename . modified 
endfunction

function! LightlineStatusline() abort
	let branch = FugitiveHead()
	if branch != ''
		return ' [' . FugitiveHead() . ']'
	else
		return ''
	endif
endfunction

" function! LightlineGutentag() abort
" 	return gutentags#statusline('[', ']')
" endfunction

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
" TEST: Highligh the 80th column only on INSERT MODE
" autocmd goosebumps InsertEnter * setlocal colorcolumn=80 
" autocmd goosebumps InsertEnter * hi ColorColumn ctermbg=NONE guibg=NONE
" autocmd goosebumps InsertLeave * setlocal colorcolumn& 
" autocmd goosebumps InsertLeave * hi ColorColumn ctermbg=1 guibg=#232526

" Enable Emmet plugin just for html, css files
autocmd goosebumps FileType html,css EmmetInstall

" Setlocal :compiler to use with :make and quickfix commands
autocmd goosebumps FileType python compiler python3
autocmd goosebumps FileType java compiler java
autocmd goosebumps FileType css compiler csslint

" Open quickfix window automaticaly
autocmd goosebumps QuickFixCmdPost [^l]* ++nested cwindow
autocmd goosebumps QuickFixCmdPost l* ++nested lwindow
autocmd goosebumps FileType qf call <SID>set_qf_win_height()

" Remove map 'K' from :Man plugin
autocmd goosebumps FileType man nnoremap <buffer> K <c-u>

" Fast quit in vim help files
autocmd goosebumps FileType help nnoremap <buffer> q ZQ

" Highlight yanked text - NeoVim 0.5.0 nightly
autocmd goosebumps TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=300}

" --- Lua Configurations ---
" Python Lsp
lua require('lspconfig').pyright.setup{}

" VimScript Lsp
lua require('lspconfig').vimls.setup{}

" Javascript/Typescript Lsp
lua require('lspconfig').denols.setup{}

" Rust Lsp
lua require('lspconfig').rust_analyzer.setup{}

" Lua Lsp
lua << EOF
local sumneko_root_path = '/home/andre/documents/LSP Servers/sumneko/lua-language-server'
local sumneko_binary = sumneko_root_path.."/bin/Linux/lua-language-server"

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require('lspconfig').sumneko_lua.setup{
	cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
	settings = {
		Lua = {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				-- Setup your lua path
				path = runtime_path,
				},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = {'vim'},
				},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
			enable = false,
			},
		},
	},
}
EOF

" Colorizer
lua require('colorizer').setup(nil, { css = true; })

" Configuração Treesitter para highligth, configuração retirada diretamente do site
lua require('nvim-treesitter.configs').setup{highlight = {enable = true, additional_vim_regex_highlighting = true}}

" Telescope configuration
lua << EOF
local actions = require('telescope.actions')
require('telescope').setup{
	-- Playground configuration, extracted from github https://github.com/nvim-treesitter/playground
	playground = {
		enable = true,
		disable = {},
		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = false, -- Whether the query persists across vim sessions
		keybindings = {
			toggle_query_editor = 'o',
			toggle_hl_groups = 'i',
			toggle_injected_languages = 't',
			toggle_anonymous_nodes = 'a',
			toggle_language_display = 'I',
			focus_language = 'f',
			unfocus_language = 'F',
			update = 'R',
			goto_node = '<cr>',
			show_help = '?',
		},
	},
	pickers = {
		buffers = {
			previewer = false,
			mappings = {
				i = {
					["<c-d>"] = actions.delete_buffer,
				},
				n = {
					["<c-d>"] = actions.delete_buffer,
				},
			},
		},
		find_files = {
			previewer = false,
		},
		file_browser = {
			previewer = false,
		},
	},
	defaults = {
		layout_config = { 
			width = 0.5, 
			height = 0.70,
		},
		path_display = { 
			tail = true,
		},
		mappings = {
			i = {
				["<NL>"] = actions.select_default + actions.center,
				["<esc>"] = actions.close,
				["<c-u>"] = {"<c-u>", type = "command"},
			},
			n = {
				["<NL>"] = actions.select_default + actions.center,
			},
		},
	}
}
EOF
