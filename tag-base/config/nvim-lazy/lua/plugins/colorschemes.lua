return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup({
        variant = "dawn",
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
      })
    end,
  },
  {
    "gbprod/nord.nvim",
    name = "nord",
  },
  {
    "shaunsingh/solarized.nvim",
    name = "solarized",
  },
  {
    "shaunsingh/moonlight.nvim",
    name = "moonlight",
  },
  {
    name = "everforest",
    "neanias/everforest-nvim",
    config = function()
      require("everforest").setup({
        variant = "dark",
        background = "soft",
        italics = true,
      })
    end,
  },
}
