vim.opt.nu = true
vim.opt.relativenumber = true

vim.g.python3_host_prog = "/Users/mcala/.venv/neovim/bin/python"

vim.g.python_recommended_style = 0

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.list = true
vim.opt.listchars = "tab:▸ ,eol:¬,trail:."

vim.opt.clipboard = "unnamedplus"

vim.opt.undofile = true
vim.opt.undodir = "/Users/mcala/.config/nvim/undofiles/"
vim.opt.undolevels = 10000
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.scrolloff = 8

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

vim.opt.winbar = "%=%m %f"

-- Netrw Options
vim.g.netrw_banner=0
vim.g_netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 20
