-- Autocmds goosebumps
local autocmd = vim.api.nvim_create_autocmd
local Andrikin = vim.api.nvim_create_augroup('Andrikin', {clear = true})
local cursorline = require('andrikin.utils').cursorline

-- Highlight linha quando entrar em INSERT MODE
autocmd('InsertEnter', {
    group = Andrikin,
    pattern = '*',
    callback = function(w)
        local dirvish = vim.bo[w.buf].ft == 'dirvish' -- não desativar quando for Dirvish
        if dirvish then
            return
        end
        cursorline.on()
    end,
})
autocmd('WinEnter', {
    group = Andrikin,
    pattern = '*',
    callback = function()
        cursorline.off()
    end,
})
autocmd('InsertLeave', {
    group = Andrikin,
    pattern = '*',
    callback = function(w)
        local dirvish = vim.bo[w.buf].ft == 'dirvish' -- não desativar quando for Dirvish
        if dirvish then
            return
        end
		cursorline.off()
    end,
})

-- Highlight configuração
autocmd( 'TextYankPost', {
	group = Andrikin,
	pattern = '*',
	callback = function()
		vim.hl.on_yank(
			{
				higroup = 'IncSearch',
				timeout = 300,
			}
		)
	end,
})

-- Resize windows automatically
-- Tim Pope goodness
autocmd( 'VimResized', {
	group = Andrikin,
	pattern = '*',
	callback = function()
		vim.cmd.wincmd('=')
	end,
})

autocmd( 'LspAttach', {
	group = Andrikin,
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
		end
	end
})

autocmd('VimEnter', {
	group = Andrikin,
	callback = function()
		-- experimental: ui2
		require('vim._core.ui2').enable()
	end,
})

autocmd('VimEnter',{
	group = Andrikin,
	callback = function()
		if vim.fn.executable("wmctrl") == 1 then
			local winid = vim.fn.split(vim.system({
				'wmctrl', '-pl', '|', 'grep',
				vim.fn.shellescape(vim.fn.getpid())
			}):wait().stdout)
			winid = winid[1]
			if not winid then
				error('Não foi possível redimentsionar neovim.')
			end
			vim.system({
				'wmctrl', '-i', '-b', 'add,maximized_vert,maximized_horz',
				'-r', winid
			})
		end
	end
})

-- neovim não está carregando esta configuração ao utilizar 'require'
-- FIX: como resolver?
-- PALEATIVO: setar vim.o.showtabline = 1 utilizando vim.defer_fn()
-- autocmd( 'VimEnter', {
-- 		group = Andrikin,
-- 		callback = function()
-- 			vim.defer_fn(
-- 				function() vim.cmd.lua('vim.o.showtabline = 1') end,
-- 				150
-- 			)
-- 		end,
-- 	})

