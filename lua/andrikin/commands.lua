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
	play = function() -- '-p',
		Cmus.comando('-p')
	end,
	pause = function() -- '-u',
		Cmus.comando('-u')
	end,
	stop = function() -- '-s',
		Cmus.comando('-s')
	end,
	next = function() -- '-n',
		Cmus.comando('-n')
	end,
	prev = function() -- '-r',
		Cmus.comando('-r')
	end,
	redo = function() -- '-R',
		Cmus.comando('-R')
	end,
	clear = function() -- '-c',  -- Clear playlist, library (-l) or play queue (-q).
		local comando = vim.fn.input('Limpar qual playlist: [l]ibrary ou [q]ueue? ', 'q')
		if not comando:match('^-') then
			comando = '-' .. comando
		end
		Cmus.comando('-c', comando)
	end,
	shuffle = function() -- '-S',
		Cmus.comando('-S')
	end,
	volume = function() -- '-v',
		Cmus.comando('-v')
	end,
	seek = function() -- '-k',
		Cmus.comando('-k')
	end,
	playlist = function() -- '-P',
		Cmus.comando('-P')
	end,
	file = function() -- '-f',
		Cmus.comando('-f')
	end,
	info = function() -- '-Q',  -- player status information
		Cmus.comando('-Q')
	end,
	queue = function(dir) -- '-q',
		Cmus.comando('-q', Cmus.diretorio_musica(dir))
		Cmus.comando('-n') -- reproduzir a primeira música da nova playlist
	end,
	raw = function() -- '-C',  -- insert command
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

