-- TODO: refazer utils.lua -> linux.lua
if vim.g.started_by_firenvim then
    require('andrikin.firenvim')
    return
end

-- Chamar todos os arquivos
require('andrikin.pack')
require('andrikin.options')
require('andrikin.maps')
require('andrikin.commands')
require('andrikin.autocmds')

