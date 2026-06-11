-- ABOUTME: nvim-treesitter parser config for LazyVim's main branch.
-- ABOUTME: Adds the zsh parser so zsh buffers get tree-sitter highlighting.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "zsh" } },
  },
}
