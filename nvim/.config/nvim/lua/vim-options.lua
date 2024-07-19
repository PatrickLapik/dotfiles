local map = vim.keymap.set
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set number")
map("i", "<C-a>", "<ESC>^i", {})
map("i", "<C-e>", "<End>", {})
map("i", "<C-h>", "<Left>", {})
map("i", "<C-l>", "<Right>", {})
map("i", "<C-j>", "<Down>", {})
map("i", "<C-k>", "<Up>", {})
map("i", "<C-z>", "<c-o>u", {})
vim.g.mapleader = " "


