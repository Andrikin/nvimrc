vim.g.mapleader = ' '

-- Search recursively
vim.opt.path:append('**')

-- Indicadores - números nas linhas
vim.opt.rnu=true
vim.opt.nu=true

-- Tamanho da indentação
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.softtabstop=4

-- Configurações para search
vim.opt.incsearch=true
vim.opt.ignorecase=true
vim.opt.smartcase=true
vim.opt.hlsearch=true

-- Configurações gerais
vim.opt.autochdir=false
vim.opt.scrolloff=999
vim.opt.lazyredraw=true
vim.opt.backspace='indent,eol,start'
vim.opt.splitbelow=true
vim.opt.splitright=true
vim.opt.helpheight=15
-- Problems that can occur in vim session can be avoid using this configuration
vim.opt.sessionoptions:remove('options')
vim.opt.encoding='utf-8'
vim.opt.autoread=true
vim.opt.tabpagemax=50
vim.opt.wildmenu=true
vim.opt.completeopt='menu,menuone,noselect'
if vim.fn.has('win32') then
	vim.g.shell=vim.env.COMSPEC
else
	vim.g.shell=vim.env.TERM
end
--let &g:shellpipe='2>&1 | tee'
vim.opt.complete:remove('t')
vim.opt.title=true
vim.opt.hidden=true
vim.opt.mouse='nvi'
vim.g.undodir=vim.fn.stdpath('data') .. [[\undotree]]
vim.opt.undofile=true
vim.opt.swapfile=false
vim.g.textwidth=0

-- Statusline
vim.opt.laststatus=3
vim.opt.showtabline=1
vim.opt.showmode=false

-- st (simple terminal - suckless) tem um problema com o cursor. Ele não muda de acordo com as cores da fonte que ele está sobre. Dessa forma, com o patch de Jules Maselbas (https://git.suckless.org/st/commit/5535c1f04c665c05faff2a65d5558246b7748d49.html), é possível obter o cursor com a cor do texto (truecolor)
vim.opt.termguicolors=true

-- NeoVim configurations
vim.opt.guicursor='i-n-v-c:block'
vim.opt.guifont=[[SauceCodePro NFM]]
vim.opt.inccommand=''
vim.opt.fillchars={
	vert = '|',
	fold = '*',
	foldclose = '+',
	diff = '-',
}

-- Python 
vim.g.python_host_prog = '/usr/bin/python2'
vim.g.python3_host_prog = '/usr/bin/python3.10'

-- Using ripgrep ([cf]open; [cf]do {cmd} | update)
if vim.fn.executable('rg') then
	vim.g.grepprg=[[rg --vimgrep --smart-case --follow]]
else
	vim.g.grepprg=[[grep -R]]
end

-- --- Emmet ---
vim.g.user_emmet_install_global=0
-- vim.g.user_emmet_leader_key = '<m-space>'

-- --- Traces ---
vim.g.traces_num_range_preview=0

-- --- UndoTree ---
vim.g.undotree_WindowLayout=2
vim.g.undotree_ShortIndicators=1
vim.g.undotree_SetFocusWhenToggle=1
vim.g.undotree_DiffpanelHeight=5

-- --- Netrw ---
-- Disable Netrw
vim.g.loaded_netrwPlugin=1
