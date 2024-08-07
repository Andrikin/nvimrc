-- CUSTOM COMMANDS

local Diretorio = require('andrikin.utils').Diretorio
local Ouvidoria = require('andrikin.utils').Ouvidoria
local Musicas =  Diretorio.new(vim.env.HOME) / '/music/'

local Cmus = {}
Cmus.diretorios_musica = function()
    return vim.fn.systemlist({'ls', Musicas.diretorio})
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
Cmus.notificar = function()
	-- WIP: notificar o resultado de ações enviadas para o cmus-remote
	local info = vim.fn.systemlist({'cmus-remote', '-Q'})
	-- local opcoes = {
	-- 	music = function() end,
	-- 	volume = function() end,
	-- 	repeat = function() end,
	-- }
	if info then
		local musica = info[2]:match('file (.*)$')
		if musica then
			vim.notify(vim.fn.fnamemodify(musica, ':t'))
		end
	end
end
Cmus.acoes = {
	-- WIP: notificar usuário com música da vez
    play = function()
        -- -p, --play
        -- Start playing.
        Cmus.comando('-p')
		Cmus.notificar()
    end,
    pause = function()
        -- -u, --pause
        -- Toggle pause.
        Cmus.comando('-u')
		Cmus.notificar()
    end,
    stop = function()
        -- -s, --stop
        -- Stop playing.
        Cmus.comando('-s')
		Cmus.notificar()
    end,
    next = function()
        -- -n, --next
        -- Skip forward in playlist.
        Cmus.comando('-n')
		Cmus.notificar()
    end,
    prev = function()
        -- -r, --prev
        -- Skip backward in playlist.
        Cmus.comando('-r')
		Cmus.notificar()
    end,
    redo = function()
        -- -R, --repeat
        -- Toggle repeat.
        Cmus.comando('-R')
		Cmus.notificar()
    end,
    clear = function()
        -- -c, --clear
        -- Clear playlist, library (-l), play queue (-q) or playlist (-p).
        local opt = vim.fn.input('Limpar qual playlist: [l]ibrary/[q]ueue/[p]laylist: ', 'q')
        if opt == 'l' then
            local confirmar = vim.fn.input('Deseja realmente limpar a library? Você precisará reindexar todas as múscicas... [s/n]: ')
            if confirmar:match('[nN]') or confirmar:match('[nN][AaÃã][oO]') then
                do return end
            end
        end
        if not opt:match('^-') then
            opt = '-' .. opt
        end
        Cmus.opt('-c', opt)
		vim.notify(('lista "%s" esvaziada'):format(opt))
    end,
    shuffle = function()
        -- -S, --shuffle
        -- Toggle shuffle.
        Cmus.comando('-S')
		Cmus.notificar()
    end,
    volume = function(volume)
        -- -v, --volume VOL
        -- Change volume. See vol command in cmus(1).
        -- cmus-remote -v <volume>%
        -- cmus-remote -v +<volume>%
        -- cmus-remote -v -<volume>%
        if not volume:match('%%$') then
            volume = volume .. '%'
        end
        Cmus.comando('-v', volume)
    end,
    seek = function(tempo)
        -- -k, --seek SEEK
        -- Seek. See seek command in cmus(1).
        -- cmus-remote -k <tempo> (relativo a posição atual da faixa, não ao tempo total da faixa)
        -- cmus-remote -k +<tempo>
        -- cmus-remote -k -<tempo>
        Cmus.comando('-k', tempo)
    end,
    playlist = function(playlist)
		-- WIP: questionar usuário sobre operação ("-a", "-l")
        -- -P, --playlist
        -- Modify playlist (default).
        -- cmus-remote --playlist -l (exibe playlists disponíveis no cmus)
        -- cmus-remote --playlist -a <caminho/playlist(.m3u,.pls)>
        -- cmus-remote --playlist -a <caminho/playlist(.m3u,.pls)>
        local ext = playlist:match('%.(%w+)$')
        local extencoes = { -- adicionar mais extenções de arquivos válidos como playlist
            m3u = true,
            pls = true,
        }
        if not extencoes[ext] then
            vim.notify('Não foi encontrado uma playlist para tocar.')
            do return end
        end
		playlist = vim.fn.fnameescape(playlist)
        Cmus.comando('-P', '-a', playlist)
		Cmus.notificar()
    end,
    file = function(arquivo)
        -- -f, --file FILE
        -- Play from file.
        -- Adiciona faixa ao final da lista de reprodução atual
        -- cmus-remote --file <caminho/para/arquivo>
		arquivo = vim.fn.fnameescape(arquivo)
		if not vim.fn.filereadable(arquivo) == 1 then
			vim.notify('Arquivo informado não é válido.')
			do return end
		end
        Cmus.comando('-f', arquivo)
		Cmus.notificar()
    end,
    info = function()
        -- -Q
        -- Get player status information. Same as -C status. Note that status is a special command only available to cmus-remote.
        -- TODO: Utilizar vim.api.nvim_exec2, [vim.split]ando o resultado por '\n'?
        -- e removendo o primeiro elemento da table, junto com strings vazias
        Cmus.comando('-Q')
    end,
    queue = function(dir)
        -- -q, --queue
        -- Modify play queue instead of playlist.
        dir = vim.fn.fnameescape((Musicas / dir).diretorio)
        Cmus.comando('-c', '-q')
        Cmus.comando('-q', dir)
        Cmus.comando('-n') -- reproduzir a primeira música da nova playlist
		Cmus.notificar()
    end,
    raw = function(cmd)
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
        Cmus.comando('-C', ('"%s"'):format(cmd))
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
        vim.notify('Cmus: executar: não foi encontrado comando válido. Nada a fazer...')
        do return end
    end
    local opts = ''
    if #args.fargs > 1 then
        table.remove(args.fargs, 1)
        opts = table.concat(args.fargs, ' ')
    end
    exec(opts)
end
Cmus.tab = function(arg, cmd)
    local args = vim.split(cmd, ' ')
    local filtrar = function(tabela)
        return vim.tbl_filter(function(elemento)
            return elemento:match(arg)
        end, tabela)
    end
    -- WIP: CONTINUAR utilizar cmd para verificar mais opções de comando
    local completar = function()
		local localizar_arquivos_diretorios = function()
			---@type Diretorio | string
			local cd = args[3] and Diretorio.new(args[3])
			if not cd then
				return {}
			end
			local diretorios = vim.fn.glob(cd .. '*', false, true, false)
			local arquivos = vim.fn.glob(cd .. '/*.*', false, true, false)
			return vim.tbl_extend('force', diretorios, arquivos)
		end
		local cmp = ({
            play = function() end, -- são comandos diretos. Nada para retornar
            pause = function() end, -- são comandos diretos. Nada para retornar
            stop = function() end, -- são comandos diretos. Nada para retornar
            next = function() end, -- são comandos diretos. Nada para retornar
            prev = function() end, -- são comandos diretos. Nada para retornar
            redo = function() end, -- são comandos diretos. Nada para retornar
            clear = function() end, -- são comandos diretos. Nada para retornar
            shuffle = function() end, -- são comandos diretos. Nada para retornar
            volume = function() end, -- são utilizados números. Nada para retornar
            seek = function() end, -- são utilizados números. Nada para retornar
            playlist = localizar_arquivos_diretorios,
            file = localizar_arquivos_diretorios,
            info = function() end, -- nada para retornar
            queue = function() return filtrar(Cmus.diretorios_musica()) end,
            raw = function() -- TODO: retornar mais opções conforme comando
                return filtrar({
                    'play', 'pause', 'stop', 'next',
                    'prev', 'seek', 'volume', 'add',
                    'remove', 'clear', 'save', 'load',
                    'status', 'current', 'search', 'queue',
                    'playmode', 'show', 'toggle', 'playpause',
                    'repeat', 'shuffle',
                })
            end,
        })[args[2]]
        if not cmp then
            error(('Tentativa de completar um comando não existente: %s'):format(args[2]))
        end
        return cmp()
    end
    if #args == 2 then
        return filtrar(Cmus.acoes.keys())
    end
    return completar()
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
    Ouvidoria.latex.compile,
    {}
)

vim.api.nvim_create_user_command(
    'Ouvidoria',
    Ouvidoria.ci.nova,
    {
        nargs = "+",
        complete = Ouvidoria.tab,
    }
)

