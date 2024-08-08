-- CUSTOM COMMANDS

local Cmus = require('andrikin.utils').Cmus
local Ouvidoria = require('andrikin.utils').Ouvidoria

vim.api.nvim_create_user_command(
    'HexEditor',
    '%!xxd',
    {}
)

vim.api.nvim_create_user_command(
    'CmusRemote',
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

