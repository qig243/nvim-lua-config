return {
	-- Mini.nvim suite - lightweight and fast
	{
		"echasnovski/mini.nvim",
		event = "VeryLazy",
		config = function()
			-- Comment
			require("mini.comment").setup({
				mappings = {
					comment = "gc",
					comment_line = "<leader>cc",
					comment_visual = "<leader>cc",
					textobject = "gc",
				},
			})

			-- Git diff signs
			require("mini.diff").setup({
				view = {
					style = "sign",
					signs = { add = "+", change = "~", delete = "_" },
				},
				source = nil, -- auto-detect git
				delay = { text_change = 200 },
				mappings = {
					apply = "gh",
					reset = "gH",
					textobject = "gh",
					goto_first = "[H",
					goto_prev = "[h",
					goto_next = "]h",
					goto_last = "]H",
				},
				options = {
					algorithm = "histogram",
					indent_heuristic = true,
					linematch = 60,
				},
			})

			-- Surround (replace vim-surround)
			require("mini.surround").setup({
				mappings = {
					add = "ys",
					delete = "ds",
					find = "",
					find_left = "",
					highlight = "",
					replace = "cs",
					update_n_lines = "",
				},
			})

			-- Pairs (replace nvim-autopairs)
			require("mini.pairs").setup()

			-- Splitjoin (replace treesj)
			require("mini.splitjoin").setup()

			-- Snippets (replace nvim-snippets)
			require("mini.snippets").setup({
				snippets = {
					-- Load friendly-snippets
					require("mini.snippets").gen_loader.from_file("~/.local/share/nvim/lazy/friendly-snippets/snippets"),
				},
			})

			-- Icons (replace nvim-web-devicons)
			require("mini.icons").setup()
			MiniIcons.mock_nvim_web_devicons()

			-- Align (replace vim-easy-align / tabular). Note: vim-table-mode handles live markdown table editing.
			require("mini.align").setup()

			-- Cursorword (replace vim-illuminate)
			require("mini.cursorword").setup()

			-- Trailspace (replace vim-trailing-whitespace)
			require("mini.trailspace").setup()

			-- AI (replace wildfire.nvim)
			require("mini.ai").setup()

			-- Clue (replace which-key.nvim)
			local miniclue = require("mini.clue")
			miniclue.setup({
				triggers = {
					-- Leader triggers
					{ mode = "n", keys = "<Leader>" },
					{ mode = "x", keys = "<Leader>" },

					-- Built-in completion
					{ mode = "i", keys = "<C-x>" },

					-- g key
					{ mode = "n", keys = "g" },
					{ mode = "x", keys = "g" },

					-- Marks
					{ mode = "n", keys = "'" },
					{ mode = "n", keys = "`" },
					{ mode = "x", keys = "'" },
					{ mode = "x", keys = "`" },

					-- Registers
					{ mode = "n", keys = '"' },
					{ mode = "x", keys = '"' },
					{ mode = "i", keys = "<C-r>" },
					{ mode = "c", keys = "<C-r>" },

					-- Window commands
					{ mode = "n", keys = "<C-w>" },

					-- z key
					{ mode = "n", keys = "z" },
					{ mode = "x", keys = "z" },
				},

				clues = {
					miniclue.gen_clues.builtin_completion(),
					miniclue.gen_clues.g(),
					miniclue.gen_clues.marks(),
					miniclue.gen_clues.registers(),
					miniclue.gen_clues.windows(),
					miniclue.gen_clues.z(),
				},
			})
		end,
	},
}
