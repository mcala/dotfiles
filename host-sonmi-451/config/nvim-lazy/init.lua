if vim.g.vscode then
  print("loading vscode neovim...")
  require("config.vscode")
else
  require("config.lazy")
  -- require("config.tinty")
  vim.cmd("colorscheme rose-pine-dawn")
end
