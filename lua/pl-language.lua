return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		priority = 1000,
		build = ":TSUpdate",
		opts = {
			-- add languages
			ensure_installed = {
				"bash", "query",
				"c", "cpp",
				"dockerfile",
				"json",
				"javascript", "typescript", "tsx", "css",
				"lua", "luadoc",
				"python",
				"rust",
				"go",
				"markdown", "markdown_inline",
				"regex",
				"vim", "vimdoc",
				"yaml",
			},
			ignore_install = { "org" },
			auto_install = true,

			highlight = { enable = true, disable = {} },
			indent = { enable = true },
			rainbow = {
				enable = true,
				extended_mode = true,
				max_file_lines = nil,
			},
		},
		config = function()
			require('nvim-treesitter.install').compilers = { 'gcc' }
			require 'nvim-treesitter.configs'.setup {
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn", -- set to `false` to disable one of the mappings
						node_incremental = "gnn",
						scope_incremental = "grc",
						node_decremental = "gnr",
					},
				},
			}
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
		ft = { "scala" },
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
