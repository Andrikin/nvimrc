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

---@return valido boolean
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
    return Diretorio._sanitize(self.diretorio .. Diretorio._suffix(str))
end

---@return string
Diretorio.__tostring = function(self)
    return self.diretorio
end

Utils.Diretorio = Diretorio

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

