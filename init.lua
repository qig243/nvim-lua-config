--
-- defaults
--
local opt = vim.opt
local keymap = vim.keymap
local cmd = vim.cmd
local g = vim.g

-- apperance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.number = true
opt.cursorline = true
opt.textwidth = 120

-- display
opt.relativenumber = true
opt.wrap = false
opt.hidden = true
opt.showcmd = false
opt.inccommand = "nosplit"
opt.laststatus = 2

-- mouse
-- opt.mouse:append("a")
opt.mouse = "nv"

-- split window
opt.splitright = true
opt.splitbelow = true

-- scroll
opt.scrolloff = 4
opt.sidescrolloff = 10

-- search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
-- opt.wildignorecase = true;

-- temp files, backup, swap, etc
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = false

-- editing
opt.autoread = true -- auto read if file is modified in other place
opt.title = true
opt.wildmenu = true
opt.errorbells = false
opt.spell = false
opt.history = 1000

-- match bracket
opt.showmatch = true
opt.matchtime = 2

-- fold
opt.foldenable = true
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- indentation
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

-- filetype spec
cmd([[autocmd FileType lua,json,yaml setlocal ts=2 sts=2 sw=2]])
cmd([[autocmd FileType json setlocal formatprg=jq]])
cmd([[autocmd BufNewFile,BufRead *.typst set filetype=typst]])
cmd([[autocmd BufNewFile,BufRead *.typ set filetype=typst]])

--
-- keymaps
--

g.mapleader = "," -- Make sure to set `mapleader` before lazy so your mappings are correct
g.maplocalleader = ","

-- unused remote-plugin providers (silences :checkhealth warnings, faster startup)
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0

keymap.set("n", "<esc>", "<cmd>nohl<CR>")
keymap.set("n", "Q", "<nop>")
keymap.set("n", "<c-q>", "<nop>")

-- clipboard
keymap.set("v", "Y", '"+y')

-- command mode and insert mode emacs-style {
keymap.set("c", "<c-b>", "<left>")
keymap.set("c", "<c-f>", "<right>")
keymap.set("c", "<c-n>", "<down>")
keymap.set("c", "<c-p>", "<up>")
keymap.set("c", "<c-a>", "<home>")
keymap.set("c", "<c-e>", "<end>")
keymap.set("c", "<c-d>", "<del>")
keymap.set("c", "<m-b>", "<s-left>")
keymap.set("c", "<m-f>", "<s-right>")

keymap.set("i", "<c-b>", "<left>")
keymap.set("i", "<c-f>", "<right>")
keymap.set("i", "<c-a>", "<home>")
keymap.set("i", "<c-e>", "<end>")
keymap.set("i", "<c-d>", "<del>")
keymap.set("i", "<c-k>", "<esc>lC")
keymap.set("i", "jk", "<esc>")

-- faster scroll
keymap.set("n", "<c-e>", "2<c-e>")

keymap.set("n", "<leader>wr", "<cmd>set wrap<cr>")

-- tab
keymap.set("n", "tu", "<cmd>tabe<cr>")
keymap.set("n", "tn", "<cmd>tabnew<cr>")
keymap.set("n", "t=", "<cmd>tabmove +<cr>")
keymap.set("n", "t-", "<cmd>tabmove -<cr>")

-- run vim run
keymap.set("n", "<leader>rr", "<cmd>call RunVimRun()<cr>")
keymap.set("n", "<leader>rt", "<cmd>call RunVimTest()<cr>")
keymap.set("n", "<leader>py", "<cmd>call RunPython()<cr>")

--
-- lazy plugins
--

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git", "--branch=stable",
		lazypath,
	})
end
opt.rtp:prepend(lazypath)

require("lazy").setup({

	require("pl-mini"),

	require("pl-completion"),
	require("pl-lsp"),
	require("pl-explorer"),
	require("pl-language"),
	require("pl-format"),
	require("pl-tpope"),

	require("pl-navigation"),
	require("pl-ornament"),
	require("pl-claude"),

	-- editing
	{
		-- narrow region
		{
			"andrewradev/inline_edit.vim",
			keys = { { "<leader>nr", mode = "v", "<cmd>InlineEdit<cr>" } },
			config = function()
				vim.g.inline_edit_autowrite = 1
			end,
		},

		{ "vim-scripts/swapcol.vim", cmd = { "Swapcols" } },
		{ "tani/dmacro.vim",         keys = { { "<c-y>", mode = { "n", "i" }, "<Plug>(dmacro-play-macro)" } } },

		-- increment
		{
			"monaqa/dial.nvim",
			event = "VeryLazy",
			keys = {
				{ "<c-a>", mode = { "n", "v" }, "<Plug>(dial-increment)" },
				{ "<c-x>", mode = { "n", "v" }, "<Plug>(dial-decrement)" },
			},
			config = function()
				local augend = require("dial.augend")
				local weekdays = augend.constant.new({
					elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
					word = true,
					cyclic = true,
				})
				require("dial.config").augends:register_group({
					default = {
						augend.integer.alias.decimal,
						augend.constant.alias.bool,
						augend.date.alias["%Y/%m/%d"],
						weekdays,
					},
				})
			end,
		},

	},

	-- others
	{ "sindrets/diffview.nvim", cmd = { "DiffviewOpen", "DiffviewFileHistory" } },
})

-- end of lazy plugins

require("builtin")
require("custom-fn")
require("neovide")
