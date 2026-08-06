-- OPTIONS

vim.g.mapleader = ' '
vim.g.localmapleader = ' '

-- terminal toggler
vim.g.ttoggler = {}

vim.o.mouse = ''

-- Search recursively
vim.opt.path:append('**')

-- Indicadores - números nas linhas
vim.o.rnu = true
vim.o.nu = true

-- Tamanho da indentação
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- Configurações para search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true

-- Configurações gerais
vim.o.autochdir = false
vim.o.scrolloff = 999
vim.o.lazyredraw = true
vim.o.backspace = 'indent,eol,start'
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.helpheight = 15
-- Problems that can occur in vim session can be avoid using this configuration
vim.opt.sessionoptions:remove('options')
vim.o.encoding = 'utf-8'
vim.o.autoread = true
vim.o.tabpagemax = 50
vim.o.wildmenu = true
vim.o.completeopt = 'menu,noinsert,noselect,popup,fuzzy'
vim.o.autocomplete = false
if vim.fn.has('win32') then
	vim.g.shell = vim.env.COMSPEC
else
	vim.g.shell = vim.env.TERM
end
--let &g:shellpipe = '2>&1 | tee'
vim.opt.complete:remove('t')
vim.o.title = true
vim.o.hidden = true
vim.o.mouse = ''
if vim.fn.has('persistent_undo') == 1 then
	local path = vim.fs.joinpath(
		---@diagnostic disable-next-line: param-type-mismatch
		vim.fn.stdpath('config'),
		'undotree'
	)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, 'p', '0755')
	end
	vim.o.undodir = path
	vim.o.undofile = true
end
vim.o.swapfile = false
vim.g.textwidth = 0

-- Statusline
vim.o.laststatus = 3
vim.o.showtabline = 1
vim.o.showmode = false

-- NeoVim configurations
vim.o.guicursor = 'i-n-v-c:block'
vim.o.guifont = 'SauceCodePro NFM:h11'
vim.o.inccommand = ''
vim.o.winborder = 'rounded'
vim.o.fillchars = 'vert:|,fold:*,foldclose:+,diff:-'

-- Python 
-- vim.g.python_host_prog = '/usr/bin/python2'
-- vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.python3_host_prog = vim.fn.systemlist('which python3')[1]

-- Using ripgrep ([cf]open; [cf]do {cmd} | update)
if vim.fn.executable('rg') then
	vim.g.grepprg = 'rg --vimgrep --smart-case --follow'
else
	vim.g.grepprg = 'grep -R'
end

-- --- Emmet ---
vim.g.user_emmet_install_global = 0
-- vim.g.user_emmet_leader_key = '<m-space>'

-- spellfile.nvim -- Lua port of spellfile.vim
vim.o.spelllang = 'pt_br'

-- --- Netrw ---
-- Disable Netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Dirvish
vim.g.dirvish_mode = ':SortingDirvish'

-- Removendo providers: Perl e Ruby
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Andrikin/awesome-pairing
vim.g.awesome_pairing_chars = [[({['"]]

-- Vim-Surround (Tim Pope)
-- Latex
vim.g['surround_' .. vim.fn.char2nr('\\')] = ''
vim.g['surround_' .. vim.fn.char2nr('l')] = ''
-- Html
vim.g['surround_' .. vim.fn.char2nr('t')] = ''

-- neovide cofigurations
if vim.g.neovide then
	vim.g.neovide_position_animation_length = 0
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_short_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_scroll_animation_length = 0
	vim.g.neovide_scroll_animation_far_lines = 0
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_cursor_antialiasing = false
	vim.g.neovide_cursor_animate_in_insert_mode = false
	vim.g.neovide_cursor_animate_command_line = false
	vim.g.neovide_cursor_vfx_mode = ''
	vim.g.neovide_detach_on_quit = 'always_detach'
	vim.g.neovide_fullscreen = false
	vim.g.neovide_cursor_hack = false
end

