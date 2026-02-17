local opt = vim.opt

vim.g.filetype = "on"
vim.g.python3_host_prog = "/Users/mcala/.venv/neovim/bin/python"
vim.g.python_recommended_style = 0

opt.nu = true
opt.relativenumber = true

opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

opt.termguicolors = true

opt.list = true
opt.listchars = "tab:▸ ,eol:¬,trail:."
opt.conceallevel = 1

opt.undofile = true
opt.undodir = "/Users/mcala/.config/nvim-lazy/undofiles/"
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false

opt.hlsearch = true
opt.incsearch = true

opt.scrolloff = 8

opt.signcolumn = "yes"
opt.colorcolumn = "80"

opt.winbar = "%=%m %f"

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
