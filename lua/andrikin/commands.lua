-- CUSTOM COMMANDS
local command = vim.api.nvim_create_user_command

command(
    'HexEditor',
    '%!xxd', {}
)

-- command(
-- 	'Dicas',
-- 	function()
-- 		vim.cmd.edit('documentos/misc/dicas/tips-gerais')
-- 	end, {}
-- )
--
-- command(
-- 	'ListaMusicas',
-- 	function()
-- 		vim.cmd.edit('~/.config/dmenu_player/lista_de_musicas_completa.dmenu')
-- 	end, {}
-- )

command(
	'Documentos',
	function()
		vim.cmd.Dirvish('documentos')
	end, {}
)

command(
	'Downloads',
	function()
		vim.cmd.Dirvish('downloads')
	end, {}
)

command(
	'Projetos',
	function()
		vim.cmd.Dirvish('documentos/projetos/git')
	end, {}
)

command(
	'Config',
	function()
		vim.cmd.Dirvish('~/.config')
	end, {}
)

command(
	'Local',
	function()
		vim.cmd.Dirvish('~/.local')
	end, {}
)

-- Sort paths in dirvish buffer, from newest to oldest
command('SortingDirvish',
    function()
        local buf = vim.api.nvim_get_current_buf()
        local plist = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        if #plist == 1 and plist[1] == '' then
            do return end
        end
		-- somente diretórios
		vim.cmd('silent! sort :/$:')
		vim.cmd('silent! g/[^/]$/d')
        local dlist = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		if #dlist == 1 and dlist[1] == '' then
			dlist = {}
		end
        local fpaths = {}
        for _, p in ipairs(plist) do
            local m = vim.uv.fs_stat(p)
            local path = {
                path = p,
                mtime = m.mtime.sec or m.mtime,
            }
			if m.type ~= 'directory' then
				table.insert(fpaths, path)
			end
        end
		-- ordernar arquivos
        table.sort(fpaths, function (a, b)
            return a.mtime > b.mtime
        end)
		-- adicionar arquivos aos diretórios
        for _, path in ipairs(fpaths) do
			table.insert(dlist, path.path)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, dlist)
    end,
{})

