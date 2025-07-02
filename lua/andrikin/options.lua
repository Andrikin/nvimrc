vim.g.mapleader = ' '

vim.opt.mouse = ''

vim.env.WAYLAND_DISPLAY = 'wayland-1' -- Configuração para wl-clipboard

-- Search recursively
vim.opt.path:append('**')

-- Indicadores - números nas linhas
vim.opt.rnu = true
vim.opt.nu = true

-- Tamanho da indentação
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Configurações para search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Configurações gerais
vim.opt.autochdir = false
vim.opt.scrolloff = 999
vim.opt.lazyredraw = true
vim.opt.backspace = 'indent,eol,start'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.helpheight = 15
-- Problems that can occur in vim session can be avoid using this configuration
vim.opt.sessionoptions:remove('options')
vim.opt.encoding = 'utf-8'
vim.opt.autoread = true
vim.opt.tabpagemax = 50
vim.opt.wildmenu = true
vim.opt.completeopt = 'menu,noinsert,noselect,popup,fuzzy'
if vim.fn.has('win32') then
	vim.g.shell = vim.env.COMSPEC
else
	vim.g.shell = vim.env.TERM
end
--let &g:shellpipe = '2>&1 | tee'
vim.opt.complete:remove('t')
vim.opt.title = true
vim.opt.hidden = true
vim.opt.mouse = nil
if vim.fn.has('persistent_undo') == 1 then
	local path = vim.fs.joinpath(
		---@diagnostic disable-next-line: param-type-mismatch
		vim.fn.stdpath('config'),
		'undotree'
	)
	if vim.fn.isdirectory(path) == 0 then
		vim.fn.mkdir(path, 'p', '0755')
	end
	vim.opt.undodir = path
	vim.opt.undofile = true
end
vim.opt.swapfile = false
vim.g.textwidth = 0

-- Statusline
vim.opt.laststatus = 3
vim.opt.showtabline = 1
vim.opt.showmode = false

-- NeoVim configurations
vim.opt.guicursor = 'i-n-v-c:block'
vim.opt.guifont =  'SauceCodePro NFM:h11'
vim.opt.inccommand = ''
vim.opt.winborder = 'none'
vim.opt.fillchars = {
	vert = '|',
	fold = '*',
	foldclose = '+',
	diff = '-',
}

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

-- --- Traces ---
vim.g.traces_num_range_preview = 0

-- --- UndoTree ---
vim.g.undotree_WindowLayout = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_DiffAutoOpen = 0
-- vim.g.undotree_DiffpanelHeight = 10
-- vim.g.undotree_DiffAutoOpen = 1

-- --- Netrw ---
-- Disable Netrw
vim.g.loaded_netrwPlugin = 1

-- Dirvish
vim.g.dirvish_mode = '%sort /.*\\/\\|.*[^\\/]/' -- diretórios primeiro, depois arquivos

-- Removendo providers: Perl e Ruby
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
