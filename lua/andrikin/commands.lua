-- CUSTOM COMMANDS
local fn = vim.fn
local api = vim.api
local env = vim.env
local cmd = vim.cmd

local Cmus = {}
Cmus.opts = {
	'--play', '-p',
	'--pause', '-u',
	'--stop', '-s',
	'--next', '-n',
	'--prev', '-r',
	'--repeat', '-R',
	'--clear', '-c', -- Clear playlist, library (-l) or play queue (-q).
	'--shuffle', '-S',
	'--volume', '-v',
	'--seek', '-k',
	'--playlist', '-P',
	'--file', '-f',
	'-Q', -- player status information
	'--queue', '-q',
	'--raw', '-C', -- insert command
}
Cmus.fun = function(opts)
	local acoes = { -- Ações que podem ser executadas
		play = '-p',
		pause = '-u',
		prev = '-r',
		next = '-n',
		stop = '-s',
		queue = '-q',
		redo = '-R',
		volume = '-v',
		seek = '-k',
		info = '-Q',
		command = '-C',
	}
	local comando = opts.fargs[1]
	local valido = false
	for arg, _ in pairs(acoes) do
		if comando == arg then
			valido = true
			opts.fargs[1] = acoes[comando]
			break
		end
	end
	if not valido then
		print(comando .. ': não é uma ação válida.')
		return
	end
	local prompt = {
		'cmus-remote',
	}
	for _, arg in ipairs(opts.fargs) do
		table.insert(prompt, arg)
	end
	local saida = vim.system(prompt, {text=true}):wait()
	if comando == 'info' then
		--WIP: Formatar para mostrar somente a música que está tocando
		print(saida.stdout)
	end
end
Cmus.complete = function(argumento, comando, posicao)
	local _ = posicao
	local MUSICAS = env.HOME .. [[/music/]]
	if not string.match(comando, '-') then -- nenhum comando inserido, retonar todos os comandos
		return Cmus.opts
	end
	if string.match(argumento, '^-') then -- completar o comando atual
		local prompt = {}
		for _, cmd in ipairs(Cmus.opts) do
			if string.match(cmd, argumento) then
				table.insert(prompt, cmd)
			end
		end
		return prompt
	end
	local diretorios = {}
	local ls = fn.systemlist({'ls', MUSICAS})
	if not string.match(comando, MUSICAS) then -- quando nenhum diretório foi escolhido
		if string.match(comando, '([-]?[-][qQ])') then -- checando se '--queue', '-q' ou '-Q' no comando
			table.insert(diretorios, MUSICAS)
			for _, diretorio in ipairs(ls) do -- adicionar '~/' no início de todas as opções 
				diretorio = fn.fnameescape(MUSICAS .. diretorio)
				table.insert(diretorios, diretorio)
			end
		end
	else
		for _, cmd in ipairs(ls) do -- completar diretório
			cmd = fn.fnameescape(MUSICAS .. cmd)
			if string.match(cmd, argumento) then
				table.insert(diretorios, cmd)
			end
		end
	end
	return diretorios
end

local Latex = {}
Latex.AUX_FOLDER = env.HOME .. '/git/itajai/modelos/aux' -- only for MiKTex
Latex.OUTPUT_FOLDER = env.HOME .. '/downloads'
Latex.PDF_READER = 'zathura'
Latex.ft = function()
	return vim.o.ft ~= 'tex'
end
Latex.clear = function(arquivo)
	-- deletar arquivos auxiliares da compilação, no linux
	if not fn.has('linux') then
		vim.notify('Caso esteja no sistema Windows, verifique a disponibilidade da opção de comando "-aux-directory"')
		return
	end
	local auxiliares = vim.tbl_filter(
		function(auxiliar)
			return string.match(auxiliar, 'aux$') or string.match(auxiliar, 'out$') or string.match(auxiliar, 'log$')
		end,
		fn.glob(Latex.OUTPUT_FOLDER .. '/' .. arquivo .. '.*', false, true)
	)
	if #auxiliares == 0 then
		return
	end
	for _, auxiliar in ipairs(auxiliares) do
		fn.delete(auxiliar)
	end
end
Latex.inicializar = function()
	env.TEXINPUTS='.:/home/andre/git/itajai/modelos/LaTeX/ouvidoria-latex-modelos/:'
end
Latex.compile = function(opts)
	if Latex.ft() then
		vim.notify('Comando executável somente para arquivos .tex!')
		return
	end
	if vim.o.modified then -- salvar arquivo que está modificado.
		cmd.write()
	end
	local arquivo = fn.expand('%:t')
	local cmd = {}
	if fn.has('linux') then
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
	fn.system(cmd)
	vim.notify('2º compilação!')
	fn.system(cmd)
	vim.notify('Pdf compilado!')
	arquivo = string.match(arquivo, '(.*)%..*$') -- remover extenção do arquivo
	fn.jobstart(
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
Ouvidoria.CI_FOLDER = env.HOME .. '/git/itajai/modelos/LaTeX/ouvidoria-latex-modelos'
Ouvidoria.OUTPUT_FOLDER = env.HOME .. '/downloads'
Ouvidoria.listagem = function()
	return vim.tbl_map(
		function(diretorio)
			return string.match(diretorio, "[a-zA-Z-]*.tex$")
		end,
		fn.glob(Ouvidoria.CI_FOLDER .. '/*.tex', false, true)
	)
end
Ouvidoria.nova_comunicacao = function(opts)
	local tipo = opts.fargs[1] or 'modelo-basico'
	local arquivo = opts.fargs[2] or 'ci-modelo'
	local alternativo = fn.expand('%')
	cmd.edit(Ouvidoria.CI_FOLDER .. '/' .. tipo .. Ouvidoria.TEX)
	local ok, retorno = pcall(
		cmd.saveas,
		Ouvidoria.OUTPUT_FOLDER .. '/' .. arquivo .. Ouvidoria.TEX
	)
	while not ok do
		if string.match(retorno, 'E13:') then
			arquivo = fn.input(
				'Arquivo com este nome já existe. Digite outro nome para arquivo: '
			)
			ok, retorno = pcall(
				cmd.saveas,
				Ouvidoria.OUTPUT_FOLDER .. '/' .. arquivo .. Ouvidoria.TEX
			)
		else
			vim.notify('Erro encontrado! Abortando comando.')
			return
		end
	end
	fn.setreg('#', alternativo) -- setando arquivo alternativo
	cmd.bdelete(tipo)
end
Ouvidoria.complete = function(args, cmd, pos)
	return vim.tbl_filter(
		function(ci)
			return string.match(ci, args)
		end,
		vim.tbl_map(
			function(ci)
				return string.match(ci, '(.*).tex$')
			end,
			Ouvidoria.listagem()
		)
	)
end

api.nvim_create_user_command(
	'HexEditor',
	'%!xxd',
	{}
)

-- api.nvim_create_user_command('Cmus', CMUS.fun, {
api.nvim_create_user_command(
	'Cmus',
	'silent !cmus-remote <args>',
	{
		nargs = '+',
		complete = Cmus.complete,
	}
)

api.nvim_create_user_command(
	'Pdflatex',
	Latex.compile,
	{}
)

api.nvim_create_user_command(
	'Ouvidoria',
	Ouvidoria.nova_comunicacao,
	{
		nargs = "+",
		complete = Ouvidoria.complete,
	}
)

