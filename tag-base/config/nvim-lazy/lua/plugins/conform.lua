return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      markdown = { "rumdl" },
    },
    formatters = {
      rumdl = {
        command = "rumdl",
        args = { "fmt", "--stdin", "--stdin-filename", "$FILENAME" },
        stdin = true,
      },
    },
  },
}
