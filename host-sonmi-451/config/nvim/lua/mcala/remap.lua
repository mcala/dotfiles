vim.g.mapleader = " "
vim.keymap.set("i", "jk", "<Esc>", { silent = true})
vim.keymap.set("n", "<leader>n", vim.cmd.Ex)
vim.keymap.set("n", ";", ":")

-- Window mappings
-- Use <ctrl>+hjkl to move around.
-- Use <leader>w to open vertical split.
vim.keymap.set("n", "<leader>w", "<C-w>v<C-w>l")
vim.keymap.set("n", "<C-h>","<C-w>h")
vim.keymap.set("n", "<C-j>","<C-w>j")
vim.keymap.set("n", "<C-k>","<C-w>k")
vim.keymap.set("n", "<C-l>","<C-w>l")

-- Unhighlight
vim.keymap.set("n", "<leader><space>", ":noh<cr>")

-- Fixes movement with j and k
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Keep cursor at begininning when combining lines with J
vim.keymap.set("n", "J", "mzJ`z")

-- Center searches
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Center Page Up and Down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Move blocks with J and K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Delete highlighted word and put it into void instead of current register
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>p", "\"_dP")
vim.keymap.set("v", "<leader>p", "\"_dP")

-- For when you accidentally leave visual mode with C-c instead of Esc and lose all your changes.
vim.keymap.set("i", "C-c", "<Esc>")

-- Unset line numbers and blank characters 
vim.keymap.set("n", "<leader>c", ":set nu!<cr>:set rnu!<cr>:set list!<cr>:GitGutterToggle<cr>")
