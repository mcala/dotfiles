return {
	'nvim-telescope/telescope.nvim', tag = '0.1.8',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('telescope').setup({})
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})  --find files
		vim.keymap.set('n', '<leader>gf', builtin.git_files, {})   --git find
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})   --find via grep
		vim.keymap.set('n', '<leader>fb', builtin.buffers, {})	   --find buffer
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})   --find help
	end
}
