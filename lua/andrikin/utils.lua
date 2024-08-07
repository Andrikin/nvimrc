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

return Utils

