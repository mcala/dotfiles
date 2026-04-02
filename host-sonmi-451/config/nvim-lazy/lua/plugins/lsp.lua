return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {
          settings = {
            ty = {
              showSyntaxErrors = false,
            },
          },
        },
        ruff = {},
      },
    },
  },
}
