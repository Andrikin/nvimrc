if not vim.g.pdfgrep then
    vim.b.current_compiler = 'pdfgrep'
end

vim.bo.makeprg = 'pdfgrep -Hin "$*" %*.pdf'
vim.bo.errorformat = { '%f:%l:%m' }
