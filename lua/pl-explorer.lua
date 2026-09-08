-- Repo root of the cwd (git toplevel), falling back to cwd. The tree is
-- always rooted here; nothing in the sidebar changes it.
local function repo_root()
	return vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
end

-- Sidebar tree keymaps: defaults plus arrow-key folder navigation, minus
-- every mapping that would move the root (cd / dir_up).
local function tree_on_attach(bufnr)
	local api = require("nvim-tree.api")
	api.config.mappings.default_on_attach(bufnr)

	for _, lhs in ipairs({ "<C-]>", "-", "<2-RightMouse>" }) do
		pcall(vim.keymap.del, "n", lhs, { buffer = bufnr })
	end

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, {
			buffer = bufnr, noremap = true, silent = true, nowait = true,
			desc = "nvim-tree: " .. desc,
		})
	end

	-- Right / l: expand folder, or open file.
	map("<Right>", api.node.open.edit, "Open / expand")
	map("l", api.node.open.edit, "Open / expand")

	-- Left / h: collapse the folder under the cursor; on a file or a closed
	-- folder, jump to the parent folder and collapse it.
	local function close_or_parent()
		local node = api.tree.get_node_under_cursor()
		if node and node.nodes and node.open then
			api.node.open.edit()
		else
			api.node.navigate.parent_close()
		end
	end
	map("<Left>", close_or_parent, "Collapse / parent")
	map("h", close_or_parent, "Collapse / parent")
end

return {
	{
		"nvim-tree/nvim-tree.lua",
		-- icons come from mini.icons (mock_nvim_web_devicons in pl-mini)
		cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeFocus" },
		keys = {
			{
				"<leader>ee",
				function()
					require("nvim-tree.api").tree.toggle({
						path = repo_root(),
						find_file = true,
						focus = true,
						update_root = false,
					})
				end,
				mode = "n",
				desc = "Toggle file tree (repo root)",
			},
		},
		opts = {
			on_attach = tree_on_attach,
			-- leave netrw / directory buffers to oil
			disable_netrw = false,
			hijack_netrw = false,
			hijack_directories = { enable = false },
			hijack_cursor = true,
			-- root is fixed to the repo root: never follow :cd or the buffer
			sync_root_with_cwd = false,
			respect_buf_cwd = false,
			update_focused_file = { enable = true, update_root = false },
			view = { side = "left", width = 32, preserve_window_proportions = true },
			renderer = {
				group_empty = true,
				highlight_git = "name",
				indent_markers = { enable = true },
				icons = {
					-- git status icon in its own column before the name (like
					-- coc-explorer); folders show the status of their contents
					git_placement = "before",
					show = { file = true, folder = true, folder_arrow = true, git = true },
					glyphs = {
						git = {
							unstaged = "M", staged = "S", unmerged = "U", renamed = "R",
							untracked = "?", deleted = "D", ignored = "-",
						},
					},
				},
			},
			-- dotfiles stay visible, but the .git dir is never listed (vim regex
			-- on the basename, so nested worktrees / submodules hide too)
			filters = { dotfiles = false, git_ignored = false, custom = { "^\\.git$" } },
			git = { enable = true, ignore = false, show_on_dirs = true, show_on_open_dirs = true },
			actions = {
				change_dir = { enable = false },
				open_file = { quit_on_open = false, resize_window = true },
			},
		},
	},
	{
		"stevearc/oil.nvim",
		keys = {
			{
				"<leader>eo",
				function() vim.cmd((vim.bo.filetype == "oil") and "bd" or "Oil") end,
				mode = "n",
				desc = "Toggle Oil (buffer-style explorer)",
			},
		},
		opts = {
			default_file_explorer = true,
			columns = { "icon" },
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "no",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			delete_to_trash = false,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				timeout_ms = 1000,
				autosave_changes = false,
			},
			constrain_cursor = "editable",
			watch_for_changes = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-v>"] = "actions.select_vsplit",
				["<C-s>"] = "actions.select_split",
				["<C-t>"] = "actions.select_tab",
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = "actions.tcd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, bufnr) return vim.startswith(name, ".") end,
				is_always_hidden = function(name, bufnr) return false end,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			float = {
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = { winblend = 0, },
				override = function(conf) return conf end,
			},
			preview = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.9,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
			},
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = { winblend = 0, },
			},
		},
	},
}
