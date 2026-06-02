return {
	{
		"dhruvasagar/vim-table-mode",
		cmd = { "TableModeToggle" },
		keys = { { "<leader>tm", "<cmd>TableModeToggle<cr>" } },
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>fmt",
				function()
					require("conform").format({ async = true })
				end,
			},
		},
		opts = {
			formatters_by_ft = {
				go = { "gofumpt" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				-- lua = { "stylua" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
			},
			default_format_opts = { lsp_format = "fallback" },
			format_on_save = { timeout_ms = 500 },
			formatters = { shfmt = { prepend_args = { "-i", "2" } } },
		},
		init = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
}
