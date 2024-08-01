-- CUSTOM COMMANDS

local Diretorio = require('andrikin.utils').Diretorio
local musicas =  vim.fs.normalize(vim.env.HOME .. '/music/')

local Cmus = {}
Cmus.lista_diretorios_musica = function()
	return vim.fn.systemlist({'ls', musicas})
end
Cmus.diretorio_musica = function(diretorio)
    return vim.fn.fnameescape(musicas .. '/' .. diretorio)
end
Cmus.comando = function(...) -- {'silent', '!cmus-remote'} -- vim.cmd
	local arg = {...}
	local cmd = {'silent', '!cmus-remote'}
	for _, v in ipairs(arg) do
		table.insert(cmd, v)
	end
	if arg[1]:match('-[QC]') then -- mostrar resultados de '-Q', '-C'
		table.remove(cmd, 1)
	end
	local exec = table.concat(cmd, ' ')
	vim.cmd(exec)
end
Cmus.acoes = {
	play = function()
        -- -p, --play
        -- Start playing.
		Cmus.comando('-p')
	end,
	pause = function()
        -- -u, --pause
        -- Toggle pause.
		Cmus.comando('-u')
	end,
	stop = function()
        -- -s, --stop
        -- Stop playing.
		Cmus.comando('-s')
	end,
	next = function()
        -- -n, --next
        -- Skip forward in playlist.
		Cmus.comando('-n')
	end,
	prev = function()
        -- -r, --prev
        -- Skip backward in playlist.
		Cmus.comando('-r')
	end,
	redo = function()
        -- -R, --repeat
        -- Toggle repeat.
		Cmus.comando('-R')
	end,
	clear = function()
        -- -c, --clear
        -- Clear playlist, library (-l), play queue (-q) or playlist (-p).
		local comando = vim.fn.input('Limpar qual playlist: [l]ibrary/[q]ueue/[p]laylist? ', 'q')
		if not comando:match('^-') then
			comando = '-' .. comando
		end
		Cmus.comando('-c', comando)
	end,
	shuffle = function()
        -- -S, --shuffle
        -- Toggle shuffle.
		Cmus.comando('-S')
	end,
	volume = function()
        -- -v, --volume VOL
        -- Change volume. See vol command in cmus(1).
        -- cmus-remote -v <volume>
        -- cmus-remote -v +<volume>
        -- cmus-remote -v -<volume>
		Cmus.comando('-v')
	end,
	seek = function()
        -- -k, --seek SEEK
        -- Seek. See seek command in cmus(1).
        -- cmus-remote -k <tempo> (relativo a posição atual da faixa, não ao tempo total da faixa)
        -- cmus-remote -k +<tempo>
        -- cmus-remote -k -<tempo>
		-- Cmus.comando('--seek')
		Cmus.comando('-k')
	end,
	playlist = function()
        -- -P, --playlist
        -- Modify playlist (default).
        -- cmus-remote --playlist -l (exibe playlists disponíveis no cmus)
        -- cmus-remote --playlist -a <caminho/playlist(.m3u,.pls)>
        -- cmus-remote --playlista <caminho/playlist(.m3u,.pls)>
		Cmus.comando('-P')
	end,
	file = function()
        -- -f, --file FILE
        -- Play from file.
        -- Adiciona faixa ao final da lista de reprodução atual
        -- cmus-remote --file <caminho/para/arquivo>
		Cmus.comando('-f')
	end,
	info = function()
        -- -Q
        -- Get player status information. Same as -C status. Note that status is a special command only available to cmus-remote.
        -- TODO: como obter output de vim.cmd?
        -- Utilizar vim.api.nvim_exec2, [vim.split]ando o resultado por '\n'
        -- e removendo o primeiro elemento da table, junto com strings vazias
		Cmus.comando('-Q')
	end,
	queue = function(dir)
        -- -q, --queue
        -- Modify play queue instead of playlist.
		Cmus.comando('-q', Cmus.diretorio_musica(dir))
		Cmus.comando('-n') -- reproduzir a primeira música da nova playlist
	end,
	raw = function()
        -- TODO: criar completefunc para input deste comando.
        -- Seção COMANDOS, no manual do cmus
        -- -C, --raw
        -- Treat arguments (instead of stdin) as raw commands.
        -- cmus-remote -C play
        -- cmus-remote -C pause
        -- cmus-remote -C stop
        -- cmus-remote -C next
        -- cmus-remote -C prev
        -- cmus-remote -C seek <tempo>
        -- cmus-remote -C volume <número>
        -- cmus-remote -C add <caminho/para/arquivo>
        -- cmus-remote -C remove <índice>
        -- cmus-remote -C clear
        -- cmus-remote -C save <nome-da-playlist>
        -- cmus-remote -C load <nome-da-playlist>
        -- cmus-remote -C status
        -- cmus-remote -C current
        -- cmus-remote -C search <termo>
        -- cmus-remote -C queue
        -- cmus-remote -C playmode <modo>
        -- cmus-remote -C show
        -- cmus-remote -C toggle
        -- cmus-remote -C playpause
        -- cmus-remote -C repeat
        -- cmus-remote -C shuffle
		local comando = vim.fn.input('Digite comando Cmus: ')
		Cmus.comando('-C', '"' .. comando .. '"')
	end,
}
Cmus.acoes.keys = function()
    local keys = {}
    for k, _ in pairs(Cmus.acoes) do
        if k == 'keys' then
            goto continue
        end
        table.insert(keys, k)
        ::continue::
    end
    return keys
end
Cmus.executar = function(args)
	local exec = Cmus.acoes[args.fargs[1]]
	if not exec then
		error('Cmus: executar: não foi encontrado comando válido')
	end
	local opts = ''
	if #args.fargs > 1 then
		table.remove(args.fargs, 1)
		opts = table.concat(args.fargs, ' ')
	end
    exec(opts)
end
Cmus.tab = function(arg, cmd, pos) -- completion function
    local narg = #(vim.split(cmd, ' '))
    if narg > 2 then
        return vim.tbl_filter(function(diretorio)
            return diretorio:match(arg)
        end, Cmus.lista_diretorios_musica()
        )
    end
    return vim.tbl_filter(function(acao)
        return acao:match(arg)
    end, Cmus.acoes.keys()
    )
end

local Latex = {}
Latex.AUX_FOLDER = vim.env.HOME .. '/git/ouvidoria-latex-modelos/' -- only for MiKTex
Latex.OUTPUT_FOLDER = vim.env.HOME .. '/downloads'
Latex.PDF_READER = 'zathura'
Latex.ft = function()
	return vim.o.ft ~= 'tex'
end
Latex.clear = function(arquivo)
	-- deletar arquivos auxiliares da compilação, no linux
	if not vim.fn.has('linux') then
		vim.notify('Caso esteja no sistema Windows, verifique a disponibilidade da opção de comando "-aux-directory"')
		return
	end
	local auxiliares = vim.tbl_filter(
		function(auxiliar)
			return string.match(auxiliar, 'aux$') or string.match(auxiliar, 'out$') or string.match(auxiliar, 'log$')
		end,
		vim.fn.glob(Latex.OUTPUT_FOLDER .. '/' .. arquivo .. '.*', false, true)
	)
	if #auxiliares == 0 then
		return
	end
	for _, auxiliar in ipairs(auxiliares) do
		vim.fn.delete(auxiliar)
	end
end
Latex.inicializar = function()
	vim.env.TEXINPUTS='.:/home/andre/git/ouvidoria-latex-modelos/:'
end
Latex.compile = function(opts)
	if Latex.ft() then
		vim.notify('Comando executável somente para arquivos .tex!')
		return
	end
	if vim.o.modified then -- salvar arquivo que está modificado.
		vim.cmd.write()
	end
	local arquivo = vim.fn.expand('%:t')
	local cmd = {}
	if vim.fn.has('linux') then
		cmd = {
			'pdflatex',
			'-file-line-error',
			'-interaction=nonstopmode',
			'-output-directory=' .. Latex.OUTPUT_FOLDER,
			arquivo
		}
	else -- para sistemas que não são linux, verificar a opção '-aux-directory'
		cmd = {
			'pdflatex',
			'-file-line-error',
			'-interaction=nonstopmode',
			'-aux-directory=' .. Latex.AUX_FOLDER,
			'-output-directory=' .. Latex.OUTPUT_FOLDER,
			arquivo
		}
	end
	vim.notify('1º compilação!')
	vim.fn.system(cmd)
	vim.notify('2º compilação!')
	vim.fn.system(cmd)
	vim.notify('Pdf compilado!')
	arquivo = string.match(arquivo, '(.*)%..*$') -- remover extenção do arquivo
	vim.fn.jobstart(
		{
			Latex.PDF_READER,
			Latex.OUTPUT_FOLDER .. '/' .. arquivo .. '.pdf'
		}
	)
	Latex.clear(arquivo)
end
Latex.inicializar()

local Ouvidoria = {}
Ouvidoria.TEX = '.tex'
Ouvidoria.CI_FOLDER = vim.env.HOME .. '/git/ouvidoria-latex-modelos'
Ouvidoria.OUTPUT_FOLDER = vim.env.HOME .. '/downloads'
Ouvidoria.listagem = function()
	return vim.tbl_map(
		function(diretorio)
			return string.match(diretorio, "[a-zA-Z-]*.tex$")
		end,
		vim.fn.glob(Ouvidoria.CI_FOLDER .. '/*.tex', false, true)
	)
end
Ouvidoria.nova_comunicacao = function(opts)
	local tipo = opts.fargs[1] or 'modelo-basico'
	local arquivo = opts.fargs[2] or 'ci-modelo'
	local alternativo = vim.fn.expand('%')
	vim.cmd.edit(Ouvidoria.CI_FOLDER .. '/' .. tipo .. Ouvidoria.TEX)
	local ok, retorno = pcall(
		vim.cmd.saveas,
		Ouvidoria.OUTPUT_FOLDER .. '/' .. arquivo .. Ouvidoria.TEX
	)
	while not ok do
		if string.match(retorno, 'E13:') then
			arquivo = vim.fn.input(
				'Arquivo com este nome já existe. Digite outro nome para arquivo: '
			)
			ok, retorno = pcall(
				vim.cmd.saveas,
				Ouvidoria.OUTPUT_FOLDER .. '/' .. arquivo .. Ouvidoria.TEX
			)
		else
			vim.notify('Erro encontrado! Abortando comando.')
			return
		end
	end
	vim.fn.setreg('#', alternativo) -- setando arquivo alternativo
	vim.cmd.bdelete(tipo)
end
Ouvidoria.complete = function(args, cmd, pos)
	return vim.tbl_filter(
		function(ci)
			return string.match(ci, args:gsub('-', '.'))
		end,
		vim.tbl_map(
			function(ci)
				return string.match(ci, '(.*).tex$')
			end,
			Ouvidoria.listagem()
		)
	)
end

vim.api.nvim_create_user_command(
	'HexEditor',
	'%!xxd',
	{}
)

vim.api.nvim_create_user_command(
    'Cmus',
    Cmus.executar,
    {
		nargs = '+',
		complete = Cmus.tab,
	}
)

vim.api.nvim_create_user_command(
	'Pdflatex',
	Latex.compile,
	{}
)

vim.api.nvim_create_user_command(
	'Ouvidoria',
	Ouvidoria.nova_comunicacao,
	{
		nargs = "+",
		complete = Ouvidoria.complete,
	}
)

