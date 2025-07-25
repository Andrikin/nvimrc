-- CUSTOM COMMANDS
local command = vim.api.nvim_create_user_command
local Cmus = require('andrikin.utils').Cmus
local Ouvidoria = require('andrikin.utils').Ouvidoria
local Copyq = require('andrikin.utils').Copyq

command(
	'Clipboard',
    function(opts)
        Copyq.clipboard(opts)
    end,
	{
		nargs = "?",
	}
)

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
	function()
		Ouvidoria.latex:compile()
	end,
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
	'ListaMusicas',
	function()
		vim.cmd.edit('/home/andre/.config/dmenu_player/lista_de_musicas_completa.dmenu')
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

