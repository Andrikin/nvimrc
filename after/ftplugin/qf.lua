local open = vim.ui.open or function(arquivo, pagina, texto)
    if not arquivo then
        vim.print('pdfgrep: não foi encontrado arquivo.')
        return
    end
    local cmd = {'zathura', '-P', pagina, vim.fn.shellescape(arquivo, true)}
    if texto then
        cmd = table.insert(cmd, 4, '-f')
        cmd = table.insert(cmd, 5, texto)
    end
    vim.system(cmd, {detach = true})
end
vim.keymap.set('n', 'gq', function()
    local id = vim.api.nvim_get_current_win()
    vim.cmd.wincmd('p') -- voltar para window anterior
    vim.api.nvim_win_close(id, true)
end,
    { silent = true, buffer = vim.api.nvim_get_current_buf()}
)
vim.keymap.set('n', 'go', function()
    local entrada = vim.fn.getline('.')
    local arquivo = entrada:match('^([^|]+)')
    local pagina = entrada:match('|([^|]+)|')
    local texto = entrada:match('|([^|]+)$')
    local extencao = vim.fn.fnamemodify(arquivo, ':e')
    if (extencao ~= '' or vim.env.PATHEXT:lower():match(extencao)) and vim.fn.isdirectory(arquivo) == 0 then
        open(arquivo, pagina, texto)
    else
        print('qf: não foi encontrado arquivo para abrir')
        return
    end
end, {silent = true, buffer = buf})
