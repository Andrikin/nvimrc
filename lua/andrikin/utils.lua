---@class Utils
---@field Diretorio Diretorio
---@field OPT Diretorio
---@field win7 string | nil
local Utils = {}

---@class Diretorio
---@field diretorio string Caminho completo do diretório
local Diretorio = {}

Diretorio.__index = Diretorio

---@param caminho string | table
---@return Diretorio
Diretorio.new = function(caminho)
	vim.validate({caminho = {caminho, {'table', 'string'}}})
	if type(caminho) == 'table' then
		for _, valor in ipairs(caminho) do
			if type(valor) ~= 'string' then
				error('Diretorio: new: Elemento de lista diferente de "string"!')
			end
		end
	end
	local diretorio = setmetatable({
        diretorio = '',
    }, Diretorio)
	if type(caminho) == 'table' then
		local concatenar = caminho[1]
		for i=2, #caminho do
			concatenar = concatenar .. diretorio._suffix(caminho[i])
		end
		caminho = concatenar
	end
	diretorio.diretorio = diretorio._sanitize(caminho)
	return diretorio
end

---@private
---@param str string
---@return string
Diretorio._sanitize = function(str)
    local sanitarizado = ''
	vim.validate({ str = {str, 'string'} })
	sanitarizado = string.gsub(str, '/', '\\')
    return sanitarizado
end

---@private
---@param str string
---@return string
Diretorio._suffix = function(str)
	vim.validate({ str = {str, 'string'} })
	return (str:match('^[/\\]') or str == '') and str or '\\' .. str
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
    toggle = function(cursorlineopt)
        cursorlineopt = cursorlineopt or {'number', 'line'}
        vim.opt.cursorlineopt = cursorlineopt
        vim.o.cursorline = not vim.o.cursorline
    end,
    on = function(cursorlineopt)
        cursorlineopt = cursorlineopt or {'number', 'line'}
        vim.opt.cursorlineopt = cursorlineopt
        vim.o.cursorline = true
    end,
    off = function()
        vim.o.cursorline = false
    end

}

return Utils

