-- Claude Code integration.
--
-- 1. claudecode.nvim speaks the same WebSocket "IDE protocol" as the official
--    VS Code extension. The server starts on VeryLazy, so a `claude` running in
--    another tmux pane can attach with `/ide` (it sees the open file, cursor
--    selection, diagnostics; its edits open as diffs inside nvim).
--    <leader>ac toggles an in-nvim Claude terminal if you prefer that instead.
--
-- 2. When Claude Code opens the prompt in nvim (Ctrl-G / Ctrl-X Ctrl-E) the
--    file is a temp file: make it a wrapped, non-auto-hard-wrapping markdown
--    scratch buffer so long prompts don't get broken at textwidth=120.
return {
	{
		"coder/claudecode.nvim",
		event = "VeryLazy",
		opts = {
			auto_start = true,
			log_level = "warn",
			terminal = {
				provider = "native",
				split_side = "right",
				split_width_percentage = 0.4,
			},
			diff_opts = {
				auto_close_on_accept = true,
				vertical_split = true,
				open_in_current_tab = true,
			},
		},
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude terminal" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude terminal" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Claude: resume session" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Claude: add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v", desc = "Claude: send selection" },
			{ "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>",     desc = "Claude: add file", ft = { "oil", "minifiles", "netrw" } },
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Claude: accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Claude: deny diff" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
		},
		init = function()
			-- Ctrl-G prompt editing: temp files from Claude Code (or any editor-from-CLI temp file).
			local tmp_roots = {}
			for _, d in ipairs({ vim.env.TMPDIR, "/tmp", "/private/tmp", "/var/folders", "/private/var/folders" }) do
				if d and d ~= "" then table.insert(tmp_roots, vim.fs.normalize(d)) end
			end
			local function is_prompt_file(path)
				if path == "" then return false end
				local lower = path:lower()
				if lower:find("claude", 1, true) then return true end
				local ext = vim.fn.fnamemodify(path, ":e")
				if ext ~= "" and ext ~= "md" and ext ~= "txt" then return false end
				for _, root in ipairs(tmp_roots) do
					if vim.startswith(path, root .. "/") then return true end
				end
				return false
			end
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				group = vim.api.nvim_create_augroup("claude-prompt-edit", { clear = true }),
				callback = function(ev)
					local path = vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf))
					if not is_prompt_file(path) then return end
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(ev.buf) then return end
						if vim.bo[ev.buf].filetype == "" then vim.bo[ev.buf].filetype = "markdown" end
						vim.bo[ev.buf].textwidth = 0
						vim.opt_local.formatoptions:remove({ "t", "c" })
						vim.opt_local.wrap = true
						vim.opt_local.linebreak = true
						vim.opt_local.breakindent = true
						vim.opt_local.spell = true
						vim.opt_local.number = false
						vim.opt_local.relativenumber = false
						vim.b[ev.buf].miniindentscope_disable = true
						vim.b[ev.buf].minitrailspace_disable = true
						-- Quick exit back to Claude Code: save + quit
						vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>wq<cr>", { buffer = ev.buf, desc = "Save & return to Claude" })
						-- j/k move by screen line in wrapped prompt text
						vim.keymap.set({ "n", "x" }, "j", "gj", { buffer = ev.buf })
						vim.keymap.set({ "n", "x" }, "k", "gk", { buffer = ev.buf })
					end)
				end,
			})
		end,
	},
}
