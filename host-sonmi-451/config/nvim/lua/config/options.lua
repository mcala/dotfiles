-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

vim.g.python3_host_prog = "/Users/mcala/anaconda3/envs/neovim/bin/python"
vim.g.python_recommended_style = 0

vim.opt.list = true
vim.opt.listchars = "tab:▸ ,eol:¬,trail:."

vim.opt.undofile = true
vim.opt.undodir = "/Users/mcala/.config/nvim/undofiles/"
vim.opt.undolevels = 10000

vim.opt.swapfile = true
vim.opt.directory = "/Users/mcala/.config/nvim/swapfiles/"
