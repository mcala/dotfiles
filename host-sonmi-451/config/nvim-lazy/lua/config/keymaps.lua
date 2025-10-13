local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- These are also lazyvim defaults
--vim.g.mapleader = " "
--vim.g.maplocalleader = "\\"

keymap.set("i", "jk", "<Esc>", opts)

-- get to command mode with a single key
vim.keymap.set("n", ";", ":")

-- Window mappings
-- Use <leader>w to open vertical split.
-- Mappings for window movement are now through vim-tmux-navigator
vim.keymap.set("n", "<leader>w", "<C-w>v<C-w>l")

-- Unhighligh
vim.keymap.set("n", "<leader><space>", ":noh<cr>")

-- Fixes movement with j and k over lines of different lengths
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
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Delete highlighted word and put it into void instead of current register
vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set("n", "<leader>p", '"_dP')
vim.keymap.set("v", "<leader>p", '"_dP')

-- For when you accidentally leave visual mode with C-c instead of Esc and lose all your changes.
vim.keymap.set("i", "C-c", "<Esc>")

-- toggle checked / create checkbox if it doesn't exist
--vim.keymap.set("n", "<leader>xx", require("markdown-togglecheck").toggle, { desc = "Toggle Checkmark" })
-- Unset line numbers and blank characters

--vim.keymap.set(
--  "n",
--  "<leader>C",
--  ":set nu!<cr>:set rnu!<cr>:set list!<cr>",
--  { desc = "Unset line numbers and blank chars" }
--)

-- Include in Which Key

local wk = require("which-key")
wk.add({
  { "<leader>C", ":set nu!<cr>:set rnu!<cr>:set list!<cr>", mode = "n", desc = "Unset line numbers and blanks." },
})
