-- Autocmds goosebumps
local autocmd = vim.api.nvim_create_autocmd
local Andrikin = vim.api.nvim_create_augroup('Andrikin', {clear = true})

-- Highlight linha quando entrar em INSERT MODE
autocmd('InsertEnter', {
    group = Andrikin,
    pattern = '*',
    callback = function(w)
        local dirvish = vim.bo[w.buf].ft == 'dirvish' -- não desativar quando for Dirvish
        if dirvish then
            return
        end
        vim.wo.cursorline = true
    end,
})
autocmd('WinEnter', {
    group = Andrikin,
    pattern = '*',
    callback = function()
        vim.wo.cursorline = false
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
        vim.wo.cursorline = false
    end,
})

-- Highlight configuração
autocmd( 'TextYankPost', {
	group = Andrikin,
	pattern = '*',
	callback = function()
		vim.hl.hl_op(
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

autocmd('UIEnter', {
    group = Andrikin,
    -- experimental: ui2
    callback = require('vim._core.ui2').enable
})

-- maximizar tela do terminal - nvim
autocmd('UIEnter',{
	group = Andrikin,
	callback = function()
		if vim.fn.executable("wmctrl") == 1 then
			local wmctrl_list = vim.split(vim.system({
				'wmctrl', '-lx'
			}):wait().stdout, '\n')
			local winid = ''
			for _, id in ipairs(wmctrl_list) do
                -- look for the terminal hosting neovim
				if id:match('terminal') then
					winid = id:match('^(0x[0-9a-f]+)')
					break
				end
			end
			if not winid then
				error('Não foi possível redimentsionar neovim.')
			end
			vim.system({
				'wmctrl', '-i', '-b',
				'add,maximized_vert,maximized_horz',
				'-r', winid
			})
		end
	end
})

