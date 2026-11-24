-- CUSTOM COMMANDS
local command = vim.api.nvim_create_user_command

command(
    'HexEditor',
    '%!xxd', {}
)

command(
	'Desktop',
	function()
		vim.cmd.Dirvish('~/desktop')
	end, {}
)

command(
	'Documentos',
	function()
		vim.cmd.Dirvish('~/documentos')
	end, {}
)

command(
	'Downloads',
	function()
		vim.cmd.Dirvish('~/downloads')
	end, {}
)

command(
	'Projetos',
	function()
		vim.cmd.Dirvish('~/documentos/projetos/git')
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
		vim.cmd('silent! g/[^/]$/d _')
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

-- command(
-- 	'Dicas',
-- 	function()
-- 		vim.cmd.edit('documentos/misc/dicas/tips-gerais')
-- 	end, {}
-- )
  
-- command(
-- 	'ListaMusicas',
-- 	function()
-- 		vim.cmd.edit('~/.config/dmenu_player/lista_de_musicas_completa.dmenu')
-- 	end, {}
-- )

command('Pandoc',
    function(opts)
        if not vim.env.PANDOC_DATA_DIRS then
            vim.print('Pandoc: variável $PANDOC_DATA_DIRS não está configurada!')
            return
        end
        opts.args = opts.args and vim.trim(opts.args)
        local md = ''
        local doc = ''
        if opts.args == '' then
            md = vim.fn.expand('%')
            doc = md:gsub('%.md$', '.docx')
        else
            md = opts.args:match("^['](.-%.md)[' ]+")
            doc = opts.args:match("%.md['%s]+(.-%.docx)$")
        end
        if not md or not doc then
            vim.print('pandoc: não foram encontrados parâmetros. Abortando.')
            return
        end
        if not md:match('%.md$') then
            vim.print('Pandoc: não é um arquivo "md" válido para converção!')
            return
        end
        local cmd = {
            'pandoc',
            '-f',
            'markdown',
            '-t',
            'docx',
            '--resource-path=' .. vim.env.PANDOC_DATA_DIRS,
            '--reference-doc=carta.docx',
            '--template=modelo.openxml',
            '-o',
            doc,
            md,
        }
        vim.system(cmd, { detach = true, }, function (out)
            if out.code > 0 then
                vim.print('pandoc: erro encontrado.')
                vim.print('pandoc_error: '.. out.stderr)
                return
            end
            if vim.uv.fs_stat(doc) then
                vim.print('pandoc: conversão concluída!')
                vim.open(doc)
            end
        end)
    end, { nargs = "+", complete = 'file' }
)

