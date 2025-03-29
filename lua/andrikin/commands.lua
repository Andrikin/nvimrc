-- CUSTOM COMMANDS
local command = vim.api.nvim_create_user_command
local Cmus = require('andrikin.utils').Cmus
local Ouvidoria = require('andrikin.utils').Ouvidoria

command(
    'HexEditor',
    '%!xxd',
    {}
)

command(
    'CmusRemote',
    Cmus.executar,
    {
        nargs = '+',
        complete = Cmus.tab,
    }
)

command(
    'Pdflatex',
    Ouvidoria.latex.compile,
    {}
)

command(
    'Ouvidoria',
    Ouvidoria.ci.nova,
    {
        nargs = "+",
        complete = Ouvidoria.tab,
    }
)

command(
	'Reload',
    require('andrikin.utils').reload,
	{}
)

command(
	'Dicas',
	function()
		vim.cmd.edit('/home/andre/documents/misc/dicas/tips-gerais')
	end,
	{}
)

command(
	'Projetos',
	function()
		vim.cmd.Dirvish('/home/andre/documents/git/')
	end,
	{}
)

