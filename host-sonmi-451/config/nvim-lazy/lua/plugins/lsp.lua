return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {
          settings = {
            ty = {
              showSyntaxErrors = false, -- Let ruff handle syntax errors
            },
          },
        },
        ruff = {}, -- Keep ruff for linting/formatting
      },
    },
  },
}
