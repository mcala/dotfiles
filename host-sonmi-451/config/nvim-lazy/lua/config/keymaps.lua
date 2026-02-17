local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("i", "jk", "<Esc>", opts)

-- get to command mode with a single key
keymap.set("n", ";", ":")

-- Unhighlight
keymap.set("n", "<leader><space>", ":noh<cr>")

-- Keep cursor at begininning when combining lines with J
keymap.set("n", "J", "mzJ`z")

-- toggle checked / create checkbox if it doesn't exist
--vim.keymap.set("n", "<leader>xx", require("markdown-togglecheck").toggle, { desc = "Toggle Checkmark" })
-- Unset line numbers and blank characters

--vim.keymap.set(
--  "n",
--  "<leader>C",
--  ":set nu!<cr>:set rnu!<cr>:set list!<cr>",
--  { desc = "Unset line numbers and blank chars" }
--)
