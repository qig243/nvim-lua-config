return {
	-- Mini.nvim suite - lightweight and fast
	{
		"echasnovski/mini.nvim",
		event = "VeryLazy",
		keys = {
			-- mini.pick / mini.extra
			{
				"<leader>ff",
				function()
					-- Start in preview view by feeding the default toggle_preview key (<Tab>).
					vim.api.nvim_create_autocmd("User", {
						pattern = "MiniPickStart",
						once = true,
						callback = function()
							vim.schedule(function() vim.api.nvim_input("<Tab>") end)
						end,
					})
					require("mini.pick").builtin.files()
				end,
				desc = "Find files (preview)",
			},
			{ "<leader>fg", function() require("mini.pick").builtin.grep_live() end,                            desc = "Live grep" },
			{ "<leader>fb", function() require("mini.pick").builtin.buffers() end,                              desc = "Buffers" },
			{ "<leader>fh", function() require("mini.pick").builtin.help() end,                                 desc = "Help" },
			{ "<leader>fr", function() require("mini.pick").builtin.resume() end,                               desc = "Resume" },
			{ "<leader>fo", function() require("mini.extra").pickers.oldfiles() end,                            desc = "Oldfiles" },
			{ "<leader>fc", function() require("mini.extra").pickers.commands() end,                            desc = "Commands" },
			{ "<leader>fm", function() require("mini.extra").pickers.marks() end,                               desc = "Marks" },
			{ "<leader>ft", function() require("mini.extra").pickers.options() end,                             desc = "Options" },

			{ "<leader>sf", function() require("mini.pick").builtin.grep_live() end,                            desc = "Live grep" },
			{ "<leader>bb", function() require("mini.pick").builtin.buffers() end,                              desc = "Buffers" },
			{ "<leader>dd", function() require("mini.extra").pickers.diagnostic() end,                          desc = "Diagnostics" },
			{ "<leader>ts", function() require("mini.extra").pickers.treesitter() end,                          desc = "Treesitter" },
			{ "gr",         function() require("mini.extra").pickers.lsp({ scope = "references" }) end,         desc = "LSP references" },
			{ "gb",         function() require("mini.extra").pickers.git_branches() end,                        desc = "Git branches" },

			-- mini.bufremove
			{ "<leader>bd", function() require("mini.bufremove").delete() end,                                  desc = "Delete buffer (keep window)" },
			{ "<leader>bw", function() require("mini.bufremove").wipeout() end,                                 desc = "Wipeout buffer (keep window)" },
		},
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

			-- Bracketed: [b/]b, [d/]d, [q/]q, [c/]c, ... (also supersedes manual [b/]b mappings)
			require("mini.bracketed").setup()

			-- Move lines/blocks via <M-h/j/k/l>
			require("mini.move").setup()

			-- Hipatterns: highlight hex colors + TODO/FIXME/etc.
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack" },
					todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo" },
					note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote" },
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})

			-- Buffer remove: delete buffer without closing the window split
			require("mini.bufremove").setup()

			-- Pick (replace telescope.nvim)
			require("mini.pick").setup({
				mappings = {
					move_down = "<C-n>",
					move_up = "<C-p>",
				},
				window = {
					config = function()
						local height = math.floor(0.8 * vim.o.lines)
						local width = math.floor(0.8 * vim.o.columns)
						return {
							anchor = "NW",
							height = height,
							width = width,
							row = math.floor(0.5 * (vim.o.lines - height)),
							col = math.floor(0.5 * (vim.o.columns - width)),
						}
					end,
				},
			})

			-- Extra pickers for mini.pick (oldfiles, marks, diagnostics, lsp, git_branches, ...)
			require("mini.extra").setup()

			-- Use mini.pick as the vim.ui.select handler
			vim.ui.select = require("mini.pick").ui_select

			-- Statusline (replace lualine.nvim)
			require("mini.statusline").setup({
				use_icons = true,
			})

			-- Starter (replace vim-startify)
			local starter = require("mini.starter")

			-- Find VCS root for cwd, falling back to cwd itself.
			local function project_root()
				local found = vim.fs.find({ ".git" }, {
					upward = true,
					path = vim.fn.getcwd(),
					stop = (vim.uv or vim.loop).os_homedir(),
				})
				if found[1] then return vim.fs.dirname(found[1]) end
				return vim.fn.getcwd()
			end

			-- Recent files under the current repo (mimics startify_change_to_vcs_root=1).
			local function recent_in_repo(n)
				return function()
					local root = project_root() .. "/"
					local items = {}
					for _, path in ipairs(vim.v.oldfiles or {}) do
						if vim.startswith(path, root) and vim.fn.filereadable(path) == 1 then
							table.insert(items, {
								name = vim.fn.fnamemodify(path, ":~:."),
								action = "edit " .. vim.fn.fnameescape(path),
								section = "Recent files (this repo)",
							})
							if #items >= n then break end
						end
					end
					return items
				end
			end

			starter.setup({
				header = function()
					return "Neovim    " .. vim.fn.fnamemodify(project_root(), ":~")
				end,
				items = {
					recent_in_repo(20),
					starter.sections.recent_files(20, false, true),
					starter.sections.builtin_actions(),
				},
				content_hooks = {
					starter.gen_hook.adding_bullet(),
					starter.gen_hook.aligning("center", "center"),
				},
			})

			-- Notify (replace nvim-notify)
			require("mini.notify").setup({
				window = {
					config = { border = "rounded" },
					winblend = 0,
				},
			})
			vim.notify = require("mini.notify").make_notify()

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
