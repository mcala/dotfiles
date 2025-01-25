if vim.g.vscode then
    print("Loading vscode neovim...")
    require("mcala.vscode")
else
    require("mcala.remap")
    require("mcala.options")
    require("mcala.lazy")
    vim.cmd("colorscheme rose-pine-dawn")
end
