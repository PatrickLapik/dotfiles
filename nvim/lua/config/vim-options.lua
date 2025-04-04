local map = vim.keymap.set

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.autoindent = true
map('i', '<C-h>', '<Left>', {})
map('i', '<C-l>', '<Right>', {})
map('i', '<C-j>', '<Down>', {})
map('i', '<C-k>', '<Up>', {})

-- Map <CR> to accept completion when an item is selected
map('i', '<CR>', function()
	return vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 and '<C-y>' or '<CR>'
end, { expr = true, noremap = true })

vim.g.mapleader = ' '

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'gdscript',
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})
