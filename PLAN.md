# Nvim Config Lightweight Plan

Goal: trim the config toward lightweight, modern plugins — primarily the `mini.nvim` suite — without losing features I actually use.

## Current state — already lean

Mini modules in use (pl-mini.lua): comment, diff, surround, pairs, splitjoin, snippets, icons, align, cursorword, trailspace, ai, clue.
Other lightweight picks: `blink.cmp`, `oil.nvim`, `conform.nvim`, `flash.nvim`.

---

## Suggested swaps (biggest wins first)

### 1. `telescope.nvim` → `mini.pick` + `mini.extra`
File: `lua/pl-telescope.lua`
- Telescope is the heaviest single piece in the config.
- `mini.pick` is ~1 file, async, fast built-in fzf-style matching.
- `mini.extra` adds LSP / git / diagnostics pickers.
- Trade-off: lose telescope-fzf-native and the broader extension ecosystem.
- Alternative if mini.pick feels too minimal: **`fzf-lua`** — max speed, telescope-like UX.

### 2. `lualine.nvim` → `mini.statusline`
File: `lua/pl-ornament.lua`
- Drop-in replacement, ~200 LOC.
- Gruvbox-compatible via `set_vim_colors_from_reference_palette`.

### 3. `vim-startify` → `mini.starter`
File: `lua/pl-ornament.lua`
- More modern, faster, more configurable.
- vim-startify is in maintenance mode.

### 4. `noice.nvim` + `nvim-notify` → `mini.notify` (or `snacks.nvim`)
File: `init.lua` (noice block)
- Noice is heavy (nui.nvim dep + cmdline UI overrides).
- If the cmdline popup isn't loved, swap to `mini.notify` for just notifications.
- If keeping the cmdline UI matters: **`snacks.nvim`** (folke) — lighter spiritual successor with a modular notifier + dashboard + picker.

### 5. `numb.nvim` — maybe drop
File: `lua/pl-navigation.lua`
- Nvim 0.10+ has native `:123` peek behavior via `set jumpoptions`.
- Tiny plugin anyway, low-priority cleanup.

### 6. `nvim-bqf` — reconsider
File: `init.lua` editing block
- `mini.pick`'s quickfix view or plain native qf may be enough.
- Removing trims one ft-loaded plugin.

---

## Worth adding from mini.nvim

- **`mini.files`** — floating column file browser; complements or replaces `oil.nvim` (oil edits like a buffer; mini.files is a navigator). Pick by preference.
- **`mini.git`** — status/log/blame integrated with the `mini.diff` already in use. Could trim `vim-fugitive` if only basics are needed.
- **`mini.move`** — move lines/blocks via `<M-h/j/k/l>`.
- **`mini.bracketed`** — `[b/]b`, `[c/]c`, `[d/]d`, etc. Replaces the manual buffer keymaps in `init.lua` and adds ~20 more pair motions.
- **`mini.hipatterns`** — inline highlight for hex colors, TODO/FIXME/HACK markers.
- **`mini.operators`** — evaluate / exchange / multiply / replace / sort as operators.
- **`mini.bufremove`** — `:bd` without closing the window split.

---

## Other modern lightweight plugins to consider

- **`snacks.nvim`** (folke) — modular umbrella that could replace noice + nvim-notify + vim-startify + (optionally) telescope in one dependency.
- **`grug-far.nvim`** — modern project-wide search/replace UI, very light.
- **`tiny-inline-diagnostic.nvim`** — prettier inline diagnostics than the built-in `virtual_lines` set in `builtin.lua`.

---

## Keep as-is (justified and lightweight, or no good alternative)

`blink.cmp`, `oil.nvim`, `conform.nvim`, `flash.nvim`, `nvim-treesitter`, `nvim-lspconfig`, `vim-sleuth`, `vim-abolish`, `vim-tmux-navigator`, `diffview.nvim`, `dial.nvim`.

---

## Suggested rollout order

1. **Phase 1 — DONE** (commit `4bf98a5`): statusline + starter + notify → mini equivalents.
2. **Phase 2 — DONE** (commit `4bf98a5`): telescope → mini.pick + mini.extra; dropped numb + nvim-bqf; `<leader>ff` opens in preview view.
3. **Phase 3 — DONE**: mini.bracketed, mini.move, mini.hipatterns, mini.bufremove. Removed manual `[b/]b` from init.lua (handled by bracketed). Added `<leader>bd / <leader>bw` for buffer remove.
4. **Phase 4 (optional, deferred):** evaluate snacks.nvim — skipped for now since the mini equivalents work and consolidating would re-introduce a heavy dependency.

## Still open (not yet applied)

- **mini.files** — alternative to oil.nvim; keep oil for now (buffer-edit UX is preferred).
- **mini.git** — could trim vim-fugitive usage; defer until fugitive feels heavy.
- **mini.operators** — evaluate/exchange/multiply/replace/sort. Easy add when wanted.
- **grug-far.nvim** — modern project search/replace UI. Add when needed.
- **tiny-inline-diagnostic.nvim** — `virtual_lines = { current_line = true }` is already set in `builtin.lua`; revisit only if styling feels lacking.
