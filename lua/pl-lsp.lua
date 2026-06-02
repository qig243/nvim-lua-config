-- LSP servers are installed via system pkg manager (brew):
--   brew install lua-language-server pyright rust-analyzer marksman \
--                sql-language-server typescript-language-server yaml-language-server
-- gopls is installed via `go install golang.org/x/tools/gopls@latest`
return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "<C-]>",      vim.lsp.buf.definition },
			{ "gi",         vim.lsp.buf.implementation },
			{ "<leader>rn", vim.lsp.buf.rename },
			{ "<leader>D",  vim.lsp.buf.type_definition },
		},
		config = function()
			-- Ensure blink.cmp capabilities are used
			local capabilities = require('blink.cmp').get_lsp_capabilities()

			-- Helper to set up and enable a server
			local function setup_server(name, config)
				config = config or {}
				config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- Lua
			setup_server('lua_ls', {
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						diagnostics = { globals = { "vim" } },
					}
				},
			})

			-- Standard servers
			setup_server('marksman')
			setup_server('pyright')
			setup_server('rust_analyzer')
			setup_server('sqlls')
			setup_server('ts_ls')
			setup_server('yamlls')

			-- Go
			setup_server('gopls', {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						analyses = {
							nilness = true,
							unusedparams = true,
							unusedwrite = true,
							useany = true,
						},
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
						completeUnimported = true,
					},
				},
			})

			-- Auto-format on save for Go
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
				end,
			})
		end,
	},
}
