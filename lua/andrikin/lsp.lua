-- Configuração de LSP servers

local notify = require('andrikin.utils').notify
if not notify then
	notify = print
end

-- colorizer.lua
require('colorizer').setup(nil, { css = true })

-- Lazyev
require('lazydev').setup()

-- vim.diagnostic.config
vim.diagnostic.config({ underline = true })

vim.defer_fn( -- kickstart.nvim
    function()
        require('nvim-treesitter.install').compilers = {'gcc', 'cc', 'clang'}
        require('nvim-treesitter.configs').setup({
            modules = {}, -- padrao
            ignore_install = {}, -- padrao
            auto_install = false, -- padrao
            sync_install = false, -- padrao
            ensure_installed = { -- parsers para highlight - treesitter
                'css', 'html', 'javascript', 'vue',
                'diff',
                'git_config', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore',
                'jsdoc', 'json', 'json5', 'java',
                'lua', 'luadoc', 'luap', 'luau',
                'markdown', 'markdown_inline',
                'regex',
                'xml',
                'python',
                'vim', 'vimdoc',
                'latex',
                -- 'comment',
				'muttrc',
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = true,
				---@diagnostic disable-next-line: unused-local
				disable = function(lang, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
            },
            indent = { enable = true },
        })
    end,
    0
)

local telescope_tema = 'dropdown'
local telescope_actions = require('telescope.actions')
require('telescope').setup({
    extensions = { -- configurando extenções
        ["ui-select"] = {
            require("telescope.themes").get_dropdown()
        }
    },
    pickers = {
        buffers = {
            previewer = false,
            theme = telescope_tema,
            mappings = {
                n = {
                    ['dd'] = telescope_actions.delete_buffer,
                },
            },
        },
        find_files = {
            previewer = false,
            theme = telescope_tema,
        },
        file_browser = {
            previewer = false,
            theme = telescope_tema,
        },
    },
    defaults = {
        layout_config = {
            width = 0.5,
            height = 0.70,
        },
        path_display = {
            tail = true,
        },
        mappings = {
            i = {
                ['<c-j>'] = telescope_actions.select_default + telescope_actions.center,
                ['gq'] = telescope_actions.close, -- ruim para as buscas que precisarem de "gq"
                ['<c-u>'] = {'<c-u>', type = 'command'},
                ['<esc>'] = {'<esc>', type = 'command'},
            },
            n = {
                ['<c-j>'] = telescope_actions.select_default + telescope_actions.center,
                ['gq'] = telescope_actions.close,
            },
        },
    }
})
-- Carregando extenções do telescope
local carregar = function (extencao)
    local ok, _ = pcall(require('telescope').load_extension, extencao)
    if not ok then
        notify(('Telescope: não foi possível carregar a extenção %s.'):format(extencao))
    else
        notify(('Telescope: extenção %s carregada com sucesso'):format(extencao))
    end
 end
carregar('fzf')
carregar('ui-select')

-- LuaSnip configuração
require('luasnip').config.set_config({
	history = true,
})
require('luasnip.loaders.from_vscode').lazy_load() -- carregar snippets (templates)
 -- carregar snippets (templates)
require('luasnip.loaders.from_lua').lazy_load({
	---@diagnostic disable-next-line: assign-type-mismatch
	paths = {vim.fs.joinpath(
		---@diagnostic disable-next-line: param-type-mismatch
		vim.fn.stdpath('config'),
		'snippets'
	)}
})

-- Ativar LSP nos buffers, automaticamente -- Neovim 0.11
vim.lsp.enable({
    'luals',
    'texlab',
    'emmetls',
    'pyright',
    'denols',
    'vimls',
    'html',
    'jsonls',
    'cssls',
})
-- vim.lsp.set_log_level("debug")
