return {
	-- theme
	{
		"morhetz/gruvbox",
		lazy = false,  -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			vim.g.gruvbox_contrast_dark = "hard"
			vim.g.gruvbox_transparent_bg = "1"
			vim.cmd("colorscheme gruvbox")
			vim.cmd("highlight Normal guibg=None ctermbg=None")
		end,
	},
}
