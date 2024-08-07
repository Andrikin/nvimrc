-- CUSTOM COMMANDS

local Diretorio = require('andrikin.utils').Diretorio
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

local Latex = {}
Latex.__index = Latex
Latex.new = function()
    local latex = setmetatable({
        reader = 'zathura',
        diretorios = {
            modelos = Diretorio.new(vim.env.HOME) / 'git' / 'ouvidoria-latex-modelos',
            destino = Diretorio.new(vim.env.HOME) / 'downloads',
        }
    }, Latex)
    latex:init()
    return latex
end
Latex.ft_tex = function()
    return vim.o.ft == 'tex'
end
Latex.clear_files = function()
    -- deletar arquivos auxiliares da compilação, no linux
    if not vim.fn.has('linux') then
        vim.notify('Caso esteja no sistema Windows, verifique a disponibilidade da opção de comando "-aux-directory"')
        do return end
    end
    local auxiliares = vim.fn.glob((Latex.diretorios.destino / '*.{aux,out,log}').diretorio, false, true)
    if #auxiliares == 0 then
        do return end
    end
    for _, auxiliar in ipairs(auxiliares) do
        vim.fn.delete(vim.fn.fnameescape(auxiliar))
    end
end
Latex.init = function(self)
    vim.env.TEXINPUTS = '.:' .. self.diretorios.modelos.diretorio .. ':'
end
Latex.compile = function()
    local arquivo = vim.fn.expand('%')
    if not Latex.ft_tex() or not arquivo:match('%.tex$') then
        vim.notify('Comando executável somente para arquivos .tex!')
        do return end
    end
    if not arquivo:match(Latex.diretorios.destino.diretorio) then
        vim.notify('Não foi possível compilar arquivo .tex! Necessário que arquivo esteja no diretório "$HOME/downloads."')
        do return end
    end
    if vim.o.modified then -- salvar arquivo que está modificado.
        vim.cmd.write()
        vim.cmd.redraw({bang = true})
    end
    local cmd = {}
    cmd = {
        'pdflatex',
        '-file-line-error',
        '-interaction=nonstopmode',
        '-output-directory=' .. Latex.diretorios.destino.diretorio,
        arquivo
    }
    vim.notify('Compilando arquivo!')
    vim.fn.systemlist(cmd)
    ---@type string | table | nil
    local out = vim.fn.systemlist(cmd) -- necessário segunda compilação
    if vim.v.shell_error > 0 then
        if type(out) == 'table' then
            out = table.concat(out, ' ')
        end
        vim.notify('Não foi possível compilar arquivo.\n' .. out)
        Latex.clear_files()
        do return end
    else
        Latex.clear_files()
    end
    vim.notify('Pdf compilado!')
    Latex.open(arquivo)
end
Latex.open = function(arquivo)
    arquivo = arquivo:gsub('tex$', 'pdf')
    local existe = vim.fn.filereadable(arquivo) ~= 0
    if not existe then
        error('Ouvidoria: pdf.abrir: não foi possível encontrar arquivo "pdf"')
    end
    vim.notify(string.format('Abrindo arquivo %s', vim.fn.fnamemodify(arquivo, ':t')))
    vim.fn.jobstart({
        Latex.reader,
        arquivo
    })
end

local Ouvidoria = {}
Ouvidoria.__index = Ouvidoria
Ouvidoria.new = function()
    local ouvidoria = setmetatable({
        tex = '.tex',
        latex = Latex.new(),
    }, Ouvidoria)
    return ouvidoria
end
Ouvidoria.ci = {
    nova = function(opts)
        local tipo = opts.fargs[1] or 'modelo-basico'
        local modelo = table.concat(
            vim.tbl_filter(
                function(ci)
                    return ci:match(tipo:gsub('-', '.'))
                end,
                Ouvidoria.ci.modelos()
            )
        )
        if not modelo then
            vim.notify('Não foi encontrado o arquivo modelo para criar nova comunicação.')
            do return end
        end
        local num_ci = vim.fn.input('Digite o número da C.I.: ')
        local setor = vim.fn.input('Digite o setor destinatário: ')
        local ocorrencia = ''
        if not modelo:match('modelo.basico') then
            ocorrencia = vim.fn.input('Digite o número da ocorrência: ')
        end
        if num_ci == '' or ocorrencia == '' or setor == '' then -- obrigatório informar os dados
            error('Não foram informados os dados ou algum deles [C.I., ocorrência, setor].')
        end
        local titulo = ocorrencia .. '-' .. setor
        if tipo:match('sipe.lai') then
            titulo = 'LAI-' .. titulo .. Ouvidoria.tex
        elseif tipo:match('carga.gabinete') then
            titulo = 'GAB-PREF-LAI-' .. titulo .. Ouvidoria.tex
        else
            titulo = 'OUV-' .. titulo .. Ouvidoria.tex
        end
        titulo = string.format('C.I. N° %s.%s - ', num_ci, os.date('%Y')) .. titulo
        local ci = (Ouvidoria.latex.diretorios.destino / titulo).diretorio
        vim.fn.writefile(vim.fn.readfile(modelo), ci) -- Sobreescreve arquivo, se existir
        vim.cmd.edit(ci)
        vim.cmd.redraw({bang = true})
        local range = {1, vim.fn.line('$')}
        -- preencher dados de C.I., ocorrência e setor no arquivo tex
        if modelo:match('modelo.basico') then
            vim.cmd.substitute({string.format("/Cabecalho{}{[A-Z-]\\{-}}/Cabecalho{%s}{%s}/I", num_ci, setor), range = range})
        elseif modelo:match('alerta.gabinete') or modelo:match('carga.gabinete') then
            vim.cmd.substitute({string.format("/Ocorrencia{}/Ocorrencia{%s}/I", ocorrencia), range = range})
            vim.cmd.substitute({string.format("/Secretaria{}/Secretaria{%s}/I", setor), range = range})
            vim.cmd.substitute({string.format("/Cabecalho{}/Cabecalho{%s}/I", num_ci), range = range})
        else
            vim.cmd.substitute({string.format("/Ocorrencia{}/Ocorrencia{%s}/I", ocorrencia), range = range})
            vim.cmd.substitute({string.format("/Cabecalho{}{[A-Z-]\\{-}}/Cabecalho{%s}{%s}/I", num_ci, setor), range = range})
        end
    end,
    modelos = function()
        return vim.fs.find(
            function(name, path)
                return name:match('.*%.tex$') and path:match('[/\\]ouvidoria.latex.modelos')
            end,
            {
                path = tostring(Ouvidoria.ci.diretorios.modelos),
                limit = math.huge,
                type = 'file'
            }
        )
    end,
}
Ouvidoria.tab = function(args)
    return vim.tbl_filter(
        function(ci)
            return ci:match(args:gsub('-', '.'))
        end,
        vim.tbl_map(
            function(modelo)
                return vim.fn.fnamemodify(modelo, ':t'):match('(.*).tex$')
            end,
            Ouvidoria.ci.modelos()
        )
    )
end
local ouvidoria = Ouvidoria.new()

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
    ouvidoria.latex.compile,
    {}
)

vim.api.nvim_create_user_command(
    'Ouvidoria',
    ouvidoria.ci.nova,
    {
        nargs = "+",
        complete = ouvidoria.tab,
    }
)

