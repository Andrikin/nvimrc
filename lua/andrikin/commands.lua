-- CUSTOM COMMANDS
local fn = vim.fn
local api = vim.api

-- TODO: Criar plugin?
local FILLME = function(argumento, comando, posicao)
	local MUSICAS = vim.env.HOME .. [[/music/]]
	local opts = {
		'--play', '-p',
		'--pause', '-u',
		'--stop', '-s',
		'--next', '-n',
		'--prev', '-r',
		'--repeat', '-R',
		'--clear', '-c', -- Clear playlist, library (-l) or play queue (-q).
		'--shuffle', '-S',
		'--file', '-f',
		'-Q', -- player status information
		'--queue', '-q',
		'--raw', '-C', -- insert command
	}
	if not string.match(comando, '-') then -- nenhum comando inserido, retonar todos os comandos
		return opts
	end
	if string.match(argumento, '^-') then -- completar o comando atual
		local prompt = {}
		for _, cmd in ipairs(opts) do
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

api.nvim_create_user_command('HexEditor', '%!xxd', {})
api.nvim_create_user_command('Cmus', 'silent !cmus-remote <args>', {
	nargs = '+',
	complete = FILLME
})

