-- Autocmds goosebumps
local autocmd = vim.api.nvim_create_autocmd
local Andrikin = vim.api.nvim_create_augroup('Andrikin', {clear = true})
local cursorline = require('andrikin.utils').cursorline

-- Highlight linha quando entrar em INSERT MODE
autocmd(
	'InsertEnter',
	{
		group = Andrikin,
		pattern = '*',
		callback = function()
			cursorline.on()
		end,
	}
)
autocmd(
	'InsertLeave',
	{
		group = Andrikin,
		pattern = '*',
		callback = function()
			local dirvish = vim.o.ft == 'dirvish' -- não desativar quando for Dirvish
			if not dirvish then
				cursorline.off()
			end
		end,
	}
)

-- Habilitar EmmetInstall
autocmd(
	'FileType',
	{
		group = Andrikin,
		pattern = {'*.html', '*.css'},
		callback = vim.cmd.EmmetInstall,
	}
)

-- 'gq' para fechar Undotree window
autocmd(
	'FileType',
	{
		group = Andrikin,
		pattern = 'undotree',
		callback = function(args)
			vim.keymap.set(
				'n',
				'gq',
				vim.cmd.UndotreeToggle,
				{
					silent = true,
					buffer = args.buf,
				}
			)
		end,
	}
)

-- 'gq' para fechar quickfix/loclist, checkhealth e help window
autocmd(
	'FileType',
	{
		group = Andrikin,
		pattern = {'qf', 'checkhealth', 'help', 'harpoon'},
		callback = function(args)
			vim.keymap.set(
				'n',
				'gq',
				function()
					local id = vim.fn.gettabinfo(vim.fn.tabpagenr())[1].windows[1]
					vim.cmd.quit()
					if id then
						vim.fn.win_gotoid(id) -- ir para a primeira window da tab
					end
				end,
				{ silent = true, buffer = args.buf }
			)
		end,
	}
)

-- Highlight configuração
autocmd(
	'TextYankPost',
	{
		group = Andrikin,
		pattern = '*',
		callback = function()
			vim.highlight.on_yank(
				{
					higroup = 'IncSearch',
					timeout = 300,
				}
			)
		end,
	}
)

-- Resize windows automatically
-- Tim Pope goodness
autocmd(
	'VimResized',
	{
		group = Andrikin,
		pattern = '*',
		callback = function()
			vim.cmd.wincmd('=')
		end,
	}
)

autocmd(
    'LspAttach',
    {
        group = Andrikin,
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client:supports_method('textDocument/completion') then
                vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
            end
        end
    }
)

-- neovim não está carregando esta configuração ao utilizar 'require'
-- FIX: como resolver?
-- PALEATIVO: setar vim.o.showtabline = 1 utilizando vim.defer_fn()
-- autocmd(
-- 	'VimEnter',
-- 	{
-- 		group = Andrikin,
-- 		pattern = '*',
-- 		once = true,
-- 		callback = function()
-- 			vim.defer_fn(
-- 				function() vim.cmd.lua('vim.o.showtabline = 1') end,
-- 				150
-- 			)
-- 		end,
-- 	}
-- )

autocmd(
	'FileType',
	{
		group = Andrikin,
		pattern =  'checkhealth',
		callback = function()
			vim.cmd.LualineRenameTab('checkhealth')
		end,
	}
)

