-- OPTIONS

local function add_path(path)
	vim.env.PATH = vim.fn.join({vim.env.PATH, path}, ":")
end

vim.g.mapleader = ' '
vim.g.maplocalleader = vim.g.mapleader

-- terminal toggler
vim.g.ttoggler = {}

-- Search locally and recursively
vim.go.path = '.,**'

-- Indicadores - números nas linhas
vim.o.rnu = true
vim.o.nu = true
vim.o.signcolumn = 'number'

-- Tamanho da indentação
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
-- ThePrimeagen way
vim.o.expandtab = true

-- Configurações para search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = true

-- Configurações gerais
vim.o.scrolloff = 999
vim.o.lazyredraw = true
vim.o.splitbelow = true
vim.o.splitright = true
-- Problems that can occur in vim session can be avoid using this configuration
vim.opt.sessionoptions:remove('options')
vim.o.encoding = 'utf-8'
vim.o.autoread = true
vim.o.tabpagemax = 50
vim.o.completeopt = 'menu,noinsert,noselect,popup,fuzzy'
if vim.fn.has('win32') then
	vim.g.shell = vim.env.COMSPEC
else
	vim.g.shell = vim.env.TERM
end
vim.o.wildmode = 'noselect:longest:lastused,full'
vim.o.wildoptions = {'pum', 'fuzzy'}
vim.o.findfunc = function (cmdargs, cmdcomplete)
    cmdargs = vim.fs.normalize(cmdargs)
    local arquivo = vim.uv.fs_stat(cmdargs)
    if arquivo and arquivo.type == 'file' then
        return {cmdargs}
    end
    local query = '%:h'
    if vim.o.filetype == 'dirvish' then
        query = '%'
    end
    local cwd = vim.fs.normalize(vim.fn.expand(query))
    if not cmdargs:match(cwd) then
        query = vim.fs.joinpath(cwd, '**', cmdargs)
    end
    local type_search = 'f'
    if cmdcomplete then
        local ftype = vim.uv.fs_stat(cmdargs)
        if ftype and ftype.type == 'directory' then
            query = vim.fs.joinpath(cmdargs, '*')
        end
        type_search = 'd'
    end
    local cmd = {
        'fdfind',
        '-uu',
        '-E', '.git',
        '-E', 'ctags',
        '-E', 'undotree',
        '-a', '-p', '-c', 'never',
        '--path-separator', '/',
        '--base-directory', cwd,
        '-t', type_search,
        cmdargs
    }
    local files = {}
    if vim.fn.executable('fdfind') == 1 then
        files = vim.split(
            vim.system(cmd):wait().stdout,
        '\n', {trimempty = true})
    else
        vim.print('findfunc: "fdfind" executável não encontrado.')
    end
    -- fallback
    if vim.v.shell_error > 0 or vim.tbl_isempty(files) then
        vim.print('findfunc: glob fallback')
        files = vim.npcall(function ()
            return vim.fn.glob(query, false, true)
        end)
        if files and #files == 0 then
            files = vim.fn.glob(query .. '*', false, true)
        end
    end
    return vim.fn.matchfuzzy(files, cmdargs)
end
--let &g:shellpipe = '2>&1 | tee'
vim.opt.complete:remove('u')
vim.o.hidden = true
vim.o.mouse = ''
if vim.fn.has('persistent_undo') == 1 then
	local path = vim.fs.joinpath(
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
vim.o.inccommand = 'split'
vim.o.winborder = 'single'
vim.o.fillchars = 'vert:|,fold:*,foldclose:+,diff:-'

-- Python 
-- vim.g.python_host_prog = '/usr/bin/python2'
-- vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.python3_host_prog = vim.fn.systemlist('which python3')[1]

-- Using ripgrep ([cf]open; [cf]do {cmd} | update)
if not vim.fn.executable('rg') == 1 then
	vim.g.grepprg = "grep -HIn $* /dev/null"
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

-- initialize PATH variables
local serversdir = vim.fs.joinpath(vim.env.HOME, '.config', 'nvim', 'servers')
local optsdir = vim.fs.joinpath(vim.env.HOME, '.config', 'nvim', 'opts')
for program, path in pairs({
	['jdtls'] = vim.fs.joinpath(serversdir, 'jdtls', 'bin'),
	['luals'] = vim.fs.joinpath(serversdir, 'luals', 'bin'),
	['texlab'] = vim.fs.joinpath(serversdir, 'texlab'),
	['tectonic'] = vim.fs.joinpath(optsdir, 'tectonic'),
	['zig'] = vim.fs.joinpath(vim.env.HOME, '.local', 'zig')
}) do
	if not vim.env.PATH:match(program) then
		add_path(path)
	end
end

