return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "rumdl" },
    },
    formatters = {
      rumdl = {
        command = "rumdl",
        args = { "--fix", "$FILENAME" },
        stdin = false,
      },
    },
  },
}
