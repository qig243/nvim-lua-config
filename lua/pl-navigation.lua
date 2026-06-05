return {
	-- motion, leap, hop, or something like that
	{
		"folke/flash.nvim",
		opts = {},
		keys = {
			{ "ff",    mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "ft",    mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "fr",    mode = { "o" },           function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "st",    mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		cmd = { "TmuxNavigatePrevious", "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", },
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
		},
	},
}
