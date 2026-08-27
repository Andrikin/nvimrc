local buf = vim.api.nvim_get_current_buf()
vim.treesitter.start()
vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
vim.wo.makeprg = 'python3 %:S'

