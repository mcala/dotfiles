-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Renamp esc to jk in insert mode
vim.keymap.set("i", "jk", "<Esc>", { silent = true })

-- Python scripting

-- Window mappings:
-- Lazy Vim already has your _movement_ commands
-- But use your own shorthand for opening vertical splits
-- vim.keymap.set("n", "<leader>w", "<C-w>v<C-w>l", { desc = "Split window right shorthand.", remap = true })
