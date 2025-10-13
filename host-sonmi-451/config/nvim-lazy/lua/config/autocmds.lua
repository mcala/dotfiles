vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })
  end,
})
