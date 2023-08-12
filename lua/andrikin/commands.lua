-- CUSTOM COMMANDS
local fn = vim.fn
local api = vim.api
-- WIP
-- Verificando dependência -- fd
if fn.executable('fd') ~= 1 then
	-- Criar uma função para enviar erros
	print('Não foi encontrado programa "fd". Realize a instalação do programa!')
end
local escapespace = function(s)
	return fn.substitute(s, [[\s]], [[\\ ]], 'g')
end
api.nvim_create_user_command('HexEditor', '%!xxd', {})
api.nvim_create_user_command('Cmus', 'silent !cmus-remote <args>', {
	nargs = '+',
	complete = function(lead, cmd, pos)
		local DIR_MUSICAS = vim.env.HOME .. [[/music/]]
		local cmus_options = {
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
		local sub_prefix = '<barra_espaco>' -- Removendo '\ '
		cmd = fn.substitute(cmd, [[\\\s]], sub_prefix, 'g')
		local args = fn.split(cmd, [[\s]])
		for i, arg in ipairs(args) do -- Recolocando '\ '
			args[i] = fn.substitute(arg, sub_prefix, [[\\ ]], 'g')
		end
		local n = table.getn(args)
		if lead == '' then -- Quando estiver dando entrada em novo argumento
			-- Verificar se existe a opção de 'queue'
			if args[n] == '--queue' or args[n] == '-q' then
				local dirs = {}
				local ls = fn.systemlist({'ls', DIR_MUSICAS})
				table.insert(dirs, DIR_MUSICAS)
				for _, diretorio in ipairs(ls) do -- adicionar '~/' no início de todas as opções 
					table.insert(dirs, DIR_MUSICAS .. diretorio)
				end
				return dirs
			end
			return cmus_options
		end
		if args[n - 1] == '--queue' or args[n - 1] == '-q' then -- Entrada parcial para '--queue'
			local dirs = {}
			local ls = fn.systemlist({'fd', '--glob', '--full-path', '--type', 'directory', args[n] .. '*', DIR_MUSICAS})
			for _, diretorio in ipairs(ls) do -- adicionar '~/'
				table.insert(dirs, escapespace(diretorio))
			end
			return dirs
		end
		if fn.match(lead, '^-') >= 0 then -- Entrada de novo comando
			local prompt = {}
			for _, argumento in ipairs(cmus_options) do
				if fn.match(argumento, lead) >= 0 then
					table.insert(prompt, argumento)
				end
			end
			return prompt
		end
		-- TODO: Melhorar lógica para sugestões
		return cmus_options -- padrão
	end
})
