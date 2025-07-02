local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Inicializando caminho para git
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Temas - interface: nome, url
local blackhole = {
	nome = 'auto', -- Lualine não reconhece 'blackhole'
	link = 'https://github.com/biisal/blackhole',
	opts = {},
	config = function ()
		vim.opt.termguicolors = true
		vim.cmd.colorscheme('blackhole')
	end
}
local tokyonight = {
    nome = 'tokyonight',
    link = 'https://github.com/folke/tokyonight.nvim.git',
	opts = {},
    config = function()
		vim.opt.termguicolors = true
		vim.cmd.colorscheme('tokyonight')
    end
}
-- local tema = tokyonight
local tema = blackhole

local plugins = {
	-- Fork Tim Pope vim-capslock
	'https://github.com/Andrikin/vim-capslock',
	-- Tim Pope's miracles
    'https://github.com/tpope/vim-fugitive.git',
	'https://github.com/tpope/vim-surround.git',
	'https://github.com/tpope/vim-eunuch.git',
	-- Vim Cool,
	'https://github.com/romainl/vim-cool.git',
	-- Dirvirsh,
	'https://github.com/justinmk/vim-dirvish.git',
	-- Traces.vim,
	'https://github.com/markonm/traces.vim.git',
	-- Undotree,
	'https://github.com/mbbill/undotree.git',
	-- autocompletion engine
	{
		'https://github.com/Saghen/blink.cmp.git',
		version = '1.*',
		opts = {
			cmdline = {enabled = false},
			snippets = { preset = 'luasnip' },
			keymap = {
				preset = 'default',
				['<c-space>'] = {'fallback'},
				['<c-j>'] = {'select_and_accept', 'fallback'},
			},
			-- (Default) Only show the documentation popup when manually triggered
			completion = {
				menu = {
					border = 'none',
					draw = {
						columns = { { "label", "label_description", gap = 1 }, { "kind" } },
					}
				},
                list = {
                    selection = {
                        preselect = false, auto_insert = true
                    }
                },
				documentation = { auto_show = false },
			},
			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { 'lsp', 'snippets', 'buffer', 'path' },
			},
		},
		-- snippets
		dependencies = {
			'https://github.com/rafamadriz/friendly-snippets.git',
			'https://github.com/L3MON4D3/LuaSnip.git',
		},
	},
	-- snippets
	-- 'https://github.com/L3MON4D3/LuaSnip.git',
	-- 'https://github.com/rafamadriz/friendly-snippets.git',
	{
		'https://github.com/tpope/vim-dadbod.git',
		lazy = true,
	},
	{
		'https://github.com/tpope/vim-obsession.git',
		lazy = true,
	},
    -- Theme
    {
        tema.link,
        priority = 1000,
        lazy = false,
		config = tema.config,
		opts = tema.opts
    },
	-- Emmet,
	{
		'https://github.com/mattn/emmet-vim.git',
		lazy = true,
	},
	-- Harpoon2 - The Primeagen,
	{
		'https://github.com/ThePrimeagen/harpoon.git',
		branch = "harpoon2",
	},
	-- Lualine,
	{
		'https://github.com/nvim-lualine/lualine.nvim',
		config = function()
			require('lualine').setup(
				{
					options = { theme = tema.nome,
						component_separators = { left = '', right = ''},
						section_separators = { left = '', right = ''},
						always_show_tabline = false,
					},
                    sections = {
						lualine_a = {'mode', 'CapsLockStatusline'},
                    },
					winbar = {
						lualine_a = {},
						lualine_b = {},
						lualine_c = {'filename'},
						lualine_x = {},
						lualine_y = {},
						lualine_z = {}
					},
                    tabline = {
                        lualine_a = {
							{
								'tabs',
								mode = 1,
								path = 0,
							},
                        },
                    }
				}
			)
		end
	},
	-- Nvim-Colorizer,
	{
		'https://github.com/norcalli/nvim-colorizer.lua.git',
		lazy = true,
	},
	-- Nvim Lspconfig,
	{
        'https://github.com/neovim/nvim-lspconfig.git',
        dependencies = {
				'https://github.com/folke/lazydev.nvim.git',
				ft = 'lua',
        },
    },
    -- Java LSP
	{
		'https://github.com/mfussenegger/nvim-jdtls.git',
		lazy = true,
	},
	-- Telescope,
	{
		'https://github.com/nvim-telescope/telescope.nvim.git',
        lazy = true,
		dependencies = {
			'https://github.com/nvim-lua/plenary.nvim.git',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable('make') == 1
                end,
            },
		},
	},{ -- change how vim.ui.select works (telescope)
        'https://github.com/nvim-telescope/telescope-ui-select.nvim',
        lazy = true
    },
	-- Treesitter,
    {
        'https://github.com/nvim-treesitter/nvim-treesitter.git',
        lazy = true,
        build = ':TSUpdate',
    },
    {
---@diagnostic disable-next-line: undefined-field
        dir = vim.loop.os_homedir() .. '/Documents/nvim/projetos/himalaya-vim',
        lazy = true,
        enabled = function() return vim.fn.executable('himalaya') == 1 end,
    },
}

local opts = {
	performance = {
		rtp = {
			disabled_plugins = {
				-- "gzip",
				-- "matchit",
				-- "matchparen",
				"netrwPlugin",
				-- "tarPlugin",
				-- "tohtml",
				-- "tutor",
				-- "zipPlugin",
			},
		},
	},
    rocks = {
        hererocks = false,
        enabled = false,
    }
}

require("lazy").setup(plugins, opts)

-- builtin plugins
-- vim.cmd.packadd('cfilter') -- filtrar itens no quickfix/localfix list
-- vim.cmd.packadd('justify')
vim.cmd.packadd('matchit')
-- vim.cmd.packadd('shellmenu')
-- vim.cmd.packadd('swapmouse')
-- vim.cmd.packadd('termdebug')
-- vim.cmd.packadd('vimball')

