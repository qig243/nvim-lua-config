if vim.g.neovide then
  vim.g.neovide_opacity                 = 0.2
  vim.g.neovide_hide_mouse_when_typing  = true
  vim.g.neovide_no_idle                 = false
  vim.g.neovide_fullscreen              = true
  vim.g.neovide_remember_window_size    = true
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_antialiasing     = false
  vim.g.neovide_cursor_vfx_mode         = "torpedo"


  local keymap = vim.keymap
  keymap.set('n', '<D-s>', ':w<CR>')      -- Save
  keymap.set('v', '<D-c>', '"+y')         -- Copy
  keymap.set('n', '<D-v>', '"+P')         -- Paste normal mode
  keymap.set('v', '<D-v>', '"+P')         -- Paste visual mode
  keymap.set('c', '<D-v>', '<C-R>+')      -- Paste command mode
  keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode

  -- Allow clipboard copy paste in neovim
  keymap.set('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
  keymap.set('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
  keymap.set('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
  keymap.set('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })
end
