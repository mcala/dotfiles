return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require('rose-pine').setup({
				variant = "dawn",
				styles = {
					italic = true,
				},
			})
		end
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
		"shaunsingh/nord.nvim",
		name = "nord",
	},


}
