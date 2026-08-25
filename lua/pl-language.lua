return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- `main` branch: nvim 0.11+/0.12 API (the old `master` branch is frozen).
		-- Needs the tree-sitter CLI (brew install tree-sitter-cli) + a C compiler.
		branch = "main",
		lazy = false,
		priority = 1000,
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({})

			local ensure_installed = {
				"bash", "query",
				"c", "cpp",
				"dockerfile",
				"json",
				"javascript", "typescript", "tsx", "css",
				"lua", "luadoc",
				"python",
				"rust",
				"go", "gomod", "gowork", "gosum",
				"markdown", "markdown_inline",
				"regex",
				"vim", "vimdoc",
				"yaml", "toml",
				"scala", "typst",
			}
			local installed = {}
			for _, lang in ipairs(ts.get_installed("parsers")) do installed[lang] = true end
			local missing = vim.tbl_filter(function(l) return not installed[l] end, ensure_installed)
			if #missing > 0 then ts.install(missing) end

			-- Enable highlight + indent per buffer; auto-install missing parsers.
			local function start(buf, lang)
				if not pcall(vim.treesitter.start, buf, lang) then return end
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("my-treesitter", { clear = true }),
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match)
					if not lang or lang == "org" then return end
					if vim.treesitter.language.add(lang) then
						start(ev.buf, lang)
					elseif vim.list_contains(ts.get_available(), lang) then
						ts.install({ lang }):await(function()
							if vim.api.nvim_buf_is_valid(ev.buf) then start(ev.buf, lang) end
						end)
					end
				end,
			})

			-- Incremental selection (gnn = start/expand, gnr = shrink), replaces the
			-- removed `incremental_selection` module from the master branch.
			local sel_stack = {}
			local function select_node(node)
				local sr, sc, er, ec = node:range()
				if ec == 0 then er, ec = er - 1, math.huge end
				vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
				vim.cmd("normal! v")
				vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
			end
			local function ts_expand()
				local in_visual = vim.fn.mode():match("[vV]") ~= nil
				if not in_visual then sel_stack = {} end
				local node
				if in_visual and #sel_stack > 0 then
					node = sel_stack[#sel_stack]:parent()
					vim.cmd("normal! \27")
				else
					node = vim.treesitter.get_node()
				end
				while node and #sel_stack > 0 and vim.deep_equal({ node:range() }, { sel_stack[#sel_stack]:range() }) do
					node = node:parent()
				end
				if not node then return end
				table.insert(sel_stack, node)
				select_node(node)
			end
			local function ts_shrink()
				if #sel_stack <= 1 then return end
				table.remove(sel_stack)
				vim.cmd("normal! \27")
				select_node(sel_stack[#sel_stack])
			end
			vim.keymap.set({ "n", "x" }, "gnn", ts_expand, { desc = "TS: expand selection" })
			vim.keymap.set("x", "gnr", ts_shrink, { desc = "TS: shrink selection" })
		end,
	},
	{ -- golang
		"ray-x/go.nvim",
		ft = { "go", "gomod", "gowork", "gotmpl" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup({
				goimports = "gopls",
				gofmt = "gofumpt",
				fillstruct = "gopls",

				lsp_cfg = false, -- Disable internal LSP setup, handled by pl-lsp.lua
				lsp_gofumpt = true,
				lsp_codelens = true,
				lsp_inlay_hints = {
					enable = true,
					style = 'eol',
					only_current_line = true,
					only_current_line_autocmd = "CursorHold",
					show_variable_name = true,
					parameter_hints_prefix = "󰊕 ",
					show_parameter_hints = true,
					other_hints_prefix = "=> ",
					max_len_align = false,
					max_len_align_padding = 1,
					right_align = false,
					right_align_padding = 6,
					highlight = "Comment",
				},

			})
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && npm install && git restore .",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		config = function()
			local g = vim.g
			g.mkdp_auto_start = 0
			g.mkdp_auto_close = 1
			g.mkdp_refresh_slow = 0
			g.mkdp_command_for_global = 0
			g.mkdp_open_to_the_world = 0
			g.mkdp_open_ip = ''
			g.mkdp_echo_preview_url = 0
			g.mkdp_browserfunc = ''
			g.mkdp_markdown_css = ''
			g.mkdp_highlight_css = ''
			g.mkdp_port = ''
			g.mkdp_page_title = "「${name}」"
			g.mkdp_preview_options = {
				disable_sync_scroll = 0,
				sync_scroll_type = "middle",
				hide_yaml_meta = 1,
			}
		end
	},
	{
		"scalameta/nvim-metals",
		ft = { "scala", "sbt" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			local metals_config = require("metals").bare_config()

			-- Example of settings
			metals_config.settings = {
				showImplicitArguments = true,
				excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
			}
			metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
				pattern = { "scala", "sbt" },
				callback = function() require("metals").initialize_or_attach(metals_config) end,
			})
			-- Attach to the buffer that triggered the ft-load as well
			require("metals").initialize_or_attach(metals_config)
		end
	},
	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
		version = "0.1.*",
		build = function() require "typst-preview".update() end,
	},
	{
		'nvim-orgmode/orgmode',
		event = 'VeryLazy',
		ft = { 'org' },
		config = function()
			require('orgmode').setup({
				org_agenda_files = '~/note/agenda/**/*',
				org_default_notes_file = '~/note/inbox.org',
			})
		end,
	},
}
