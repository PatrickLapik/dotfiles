local map = vim.keymap.set
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set number relativenumber")
vim.cmd("set noshowmode")
map("i", "<C-a>", "<ESC>^i", {})
map("i", "<C-e>", "<End>", {})
map("i", "<C-h>", "<Left>", {})
map("i", "<C-l>", "<Right>", {})
map("i", "<C-j>", "<Down>", {})
map("i", "<C-k>", "<Up>", {})
map("i", "<C-z>", "<c-o>u", {})
vim.g.mapleader = " "

vim.api.nvim_create_autocmd("FileType", {
    pattern = "gdscript", 
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.tabstop = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})
