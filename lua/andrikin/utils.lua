---@class Utils
---@field Diretorio Diretorio
---@field win7 string | nil
local Utils = {}

---@class Diretorio
---@field diretorio string Caminho completo do diretório
---@field add function
local Diretorio = {}

Diretorio.__index = Diretorio

---@param caminho string | table
---@return Diretorio
Diretorio.new = function(caminho)
    caminho = caminho or ''
    vim.validate({caminho = {caminho, {'table', 'string'}}})
    if type(caminho) == 'table' then
        for _, valor in ipairs(caminho) do
            if type(valor) ~= 'string' then
                error('Diretorio: new: Elemento de lista diferente de "string"!')
            end
        end
        caminho = table.concat(caminho, '/'):gsub('//+', '/')
    end
    local diretorio = setmetatable({
        diretorio = Diretorio._sanitize(caminho),
    }, Diretorio)
    return diretorio
end

---@private
---@param str string
---@return string
Diretorio._sanitize = function(str)
    vim.validate({ str = {str, 'string'} })
    return vim.fs.normalize(str)
end

---@return boolean
---@param dir Diretorio | string
Diretorio.validate = function(dir)
    local isdirectory = function(d)
        return vim.fn.isdirectory(d) == 1
    end
    local valido = false
    if type(dir) == 'Diretorio' then
        valido = isdirectory(dir.diretorio)
    elseif type(dir) == 'string' then
        valido = isdirectory((Diretorio.new(dir)).diretorio)
    else
        error('Diretorio: validate: variável não é do tipo "Diretorio" ou "string"')
    end
    return valido
end

---@private
---@return Diretorio
--- Realiza busca nas duas direções pelo 
Diretorio.buscar = function(dir, start)
    vim.validate({ dir = {dir,{'table', 'string'}} })
    vim.validate({ start = {start, 'string'} })
    if type(dir) == 'table' then
        dir = vim.fs.normalize(table.concat(dir, '/'))
    else
        dir = vim.fs.normalize(dir)
    end
    if dir:match('^' .. vim.env.HOMEDRIVE) then
        error('Diretorio: buscar: argumento deve ser um trecho de diretório, não deve conter "C:/" no seu início.')
    end
    start = start and Diretorio._sanitize(start) or Diretorio._sanitize(vim.env.HOMEPATH)
    local diretorio = ''
    local diretorios = vim.fs.dir(start, {depth = math.huge})
    for d, t in diretorios do
        if not t == 'directory' then
            goto continue
        end
        if d:match('.*' .. dir:gsub('-', '.')) then
            diretorio = d
            break
        end
        ::continue::
    end
    if diretorio == '' then
        error('Diretorio: buscar: não foi encontrado o caminho do diretório informado.')
    end
    diretorio = vim.fs.normalize(start .. '/' .. diretorio):gsub('//+', '/')
    return Diretorio.new(diretorio)-- valores de vim.fs.dir já são normalizados
end

---@private
---@param str string
---@return string
Diretorio._suffix = function(str)
    vim.validate({ str = {str, 'string'} })
    return (str:match('^[/\\]') or str == '') and str or vim.fs.normalize('/' .. str)
end

---@param caminho string | table
Diretorio.add = function(self, caminho)
    if type(caminho) == 'table' then
        local concatenar = ''
        for _, c in ipairs(caminho) do
            concatenar = concatenar .. Diretorio._suffix(c)
        end
        caminho = concatenar
    end
    self.diretorio = self.diretorio .. Diretorio._suffix(caminho)
end

---@param other Diretorio | string
---@return Diretorio
Diretorio.__div = function(self, other)
    local nome = self.diretorio
    if getmetatable(other) == Diretorio then
        other = other.diretorio
    elseif type(other) ~= 'string' then
        error('Diretorio: __div: Elementos precisam ser do tipo "string".')
    end
    return Diretorio.new(Diretorio._sanitize(nome .. Diretorio._suffix(other)))
end

---@param str string
---@return string
Diretorio.__concat = function(self, str)
    if getmetatable(self) ~= Diretorio then
        error('Diretorio: __concat: Objeto não é do tipo Diretorio.')
    end
    if type(str) ~= 'string' then
        error('Diretorio: __concat: Argumento precisa ser do tipo "string".')
    end
    return Diretorio._sanitize(self.diretorio .. str)
end

---@return string
Diretorio.__tostring = function(self)
    return self.diretorio
end

Utils.Diretorio = Diretorio

---@class Latex
---@field reader string
local Latex = {}

Latex.__index = Latex

Latex.new = function()
    local latex = setmetatable({
        reader = 'zathura',
        diretorios = {
            modelos = Diretorio.new(vim.env.HOME) / 'documents' / 'git' / 'ouvidoria-latex-modelos',
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

---@class Ouvidoria
---@field tex string
---@field latex Latex
---@field ci table
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

Utils.Ouvidoria = Ouvidoria.new()

---@class Cmus
---@field diretorios_musica function
---@field comando function
---@field notificar function
---@field acoes table
---@field executar function
---@field tab function
---@field Musicas Diretorio
local Cmus = {}

Cmus.__index = Cmus

Cmus.Musicas = Diretorio.new(vim.env.HOME) / '/music/'

---@return Cmus
Cmus.new = function()
	local cmus = setmetatable({}, Cmus)
	cmus:init()
	return cmus
end

Cmus.init = function(self)
	-- verificar se cmus-remote está funcionando
    local cmus = vim.fn.executable('cmus-remote') == 1
    if not cmus then
        vim.notify('Não foi encontrado o comando "cmus-remote".')
        self.diretorios_musica = nil
        self.comando = nil
        self.notificar = nil
        self.acoes = nil
        self.executar = function()
            vim.notify('Desabilitado comando. instalar "cmus-remote"')
        end
        self.tab = function()
            vim.notify('Desabilitado comando. instalar "cmus-remote"')
        end
    end
end

Cmus.diretorios_musica = function()
    return vim.fn.systemlist({'ls', Cmus.Musicas.diretorio})
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

Cmus.notificar = function(opt)
	local info = vim.fn.systemlist({'cmus-remote', '-Q'})
	if not info then
		vim.notify('Comando "cmus-remote -Q" não retornou informação.')
		do return end
	end
	local opcoes = {
		music = function()
			local musica = info[2]:match('file (.*)$')
			if musica then
				vim.notify(vim.fn.fnamemodify(musica, ':t'))
			end
		end,
		volume = function()
			local vol_left = info[16]:match('(%d+)$')
			local vol_right = info[17]:match('(%d+)$')
			vim.notify(('Volume esquerdo: %s\nVolume direito: %s'):format(vol_left, vol_right))
		end,
		redo = function()
			local r = info[12]:match('(%a+)$')
			local rc = info[13]:match('(%a+)$')
			vim.notify(('Repeat: %s\nRepeat current: %s'):format(r, rc))
		end,
		shuffle = function()
			local enabled = info[14]:match('(%a+)$')
			vim.notify(('Shuffle: %s'):format(enabled))
		end,
		continue = function()
			local enabled = info[6]:match('(%a+)$')
			vim.notify(('Continue: %s'):format(enabled))
		end,
		seek = function()
			local tempo = function(t)
				local formatado = '00:00'
				local minutos = math.floor(t/60)
				local segundos = math.floor(t%60)
				formatado = ('%s:%s'):format(minutos, segundos)
				return formatado
			end
			local duracao = info[3]:match('(%d+)$')
			local atual = info[4]:match('(%d+)$')
			vim.notify(('Duração: %s\nPosição: %s'):format(tempo(duracao), tempo(atual)))
		end,
		status = function()
			local s = info[1]:match('(%a+)$')
			vim.notify(s)
		end,
	}
	if opcoes[opt] then
		opcoes[opt]()
	end
end

Cmus.acoes = {
    play = function()
        -- -p, --play
        -- Start playing.
        Cmus.comando('-p')
		Cmus.notificar('music')
    end,
    pause = function()
        -- -u, --pause
        -- Toggle pause.
        Cmus.comando('-u')
		Cmus.notificar('music')
    end,
    stop = function()
        -- -s, --stop
        -- Stop playing.
        Cmus.comando('-s')
		Cmus.notificar('music')
    end,
    next = function()
        -- -n, --next
        -- Skip forward in playlist.
        Cmus.comando('-n')
		Cmus.notificar('music')
    end,
    prev = function()
        -- -r, --prev
        -- Skip backward in playlist.
        Cmus.comando('-r')
		Cmus.notificar('music')
    end,
    redo = function()
        -- -R, --repeat
        -- Toggle repeat.
        Cmus.comando('-R')
		Cmus.notificar('redo')
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
        Cmus.comando('-c', opt)
		vim.notify(('lista "%s" esvaziada'):format(opt))
    end,
    shuffle = function()
        -- -S, --shuffle
        -- Toggle shuffle.
        Cmus.comando('-S')
		Cmus.notificar('shuffle')
    end,
    volume = function(volume)
        -- -v, --volume VOL
        -- Change volume. See vol command in cmus(1).
        -- cmus-remote -v <volume>%
        -- cmus-remote -v +<volume>%
        -- cmus-remote -v -<volume>%
		if not volume or volume == '' or not volume:match('^[+-]%d+[%%]$') then
			goto mostrar_volume
			do return end
		end
        -- if not volume:match('%%$') then
        --     volume = volume .. '%'
        -- end
        Cmus.comando('-v', volume)
		::mostrar_volume::
		Cmus.notificar('volume')
    end,
    seek = function(tempo)
        -- -k, --seek SEEK
        -- Seek. See seek command in cmus(1).
        -- cmus-remote -k <tempo> (relativo a posição atual da faixa, não ao tempo total da faixa)
        -- cmus-remote -k +<tempo>
        -- cmus-remote -k -<tempo>
		if tempo and tempo:match('^[+-]%d+$')then
			Cmus.comando('-k', tempo)
		end
		Cmus.notificar('seek')
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
		Cmus.notificar('music')
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
		Cmus.notificar('music')
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
        dir = vim.fn.fnameescape((Cmus.Musicas / dir).diretorio)
        Cmus.comando('-c', '-q')
        Cmus.comando('-q', dir)
        Cmus.comando('-n') -- reproduzir a primeira música da nova playlist
		Cmus.notificar('music')
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
            raw = function() -- TODO: acrescentar mais comandos?
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

Utils.Cmus = Cmus.new()

--- Mostra notificação para usuário, registrando em :messages
---@param msg string
Utils.notify = function(msg)
    vim.api.nvim_echo({{msg, 'DiagnosticInfo'}}, true, {})
    vim.cmd.redraw({bang = true})
end

--- Mostra uma notificação para o usuário, mas sem registrar em :messages
---@param msg string
Utils.echo = function(msg)
    vim.api.nvim_echo({{msg, 'DiagnosticInfo'}}, false, {})
    vim.cmd.redraw({bang = true})
end

Utils.npcall = vim.F.npcall

---@type string | nil
Utils.win7 = string.match(vim.loop.os_uname()['version'], 'Windows 7')

Utils.cursorline = {
    toggle = function(opts)
        opts = opts or {'number', 'line'}
        vim.opt.cursorlineopt = opts
        vim.o.cursorline = not vim.o.cursorline
    end,
    on = function(opts)
        opts = opts or {'number', 'line'}
        vim.opt.cursorlineopt = opts
        vim.o.cursorline = true
    end,
    off = function()
        vim.o.cursorline = false
    end

}

Utils.reload = function()
	for name,_ in pairs(package.loaded) do
		if name:match('^andrikin') then
			package.loaded[name] = nil
		end
	end
	require('andrikin')
end

return Utils

