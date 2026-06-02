vim.api.nvim_exec2([[
  command! TidyJIRA call TidyJIRAFunc()
  function! TidyJIRAFunc()
    :set ft=markdown
    :v/SPPC/d
    :%s/\(SPPC-\d\{5\}\)\s*\nSPPC-\d\{5\}\s*/[[\1](https:\/\/jira.shopee.io\/browse\/\1)] /
    :%s/$/  /
  endfunc
]], {})

vim.api.nvim_exec2([[
func! RunVimRun()
  :w
  if &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'go'
    :GoRun %
    " set splitbelow
    " :sp
    " :term go run %
  elseif &filetype == 'python'
    set splitbelow
    :sp
    :term python3 %
  elseif &filetype == 'markdown'
    exec "MarkdownPreview"
  elseif &filetype == 'typst'
    exec "TypstPreview"
  elseif &filetype == 'xhtml'
    :!open % -a Google\ Chrome
  elseif &filetype == 'dot'
    let current_file_name=expand('%:r')
    let output_file_path=current_file_name . '.png'
    exec "!dot -Tpng % -o " . output_file_path
    exec "!open " . output_file_path
  elseif &filetype == 'mermaid'
    " let current_file_name=expand('%:r')
    " let output_file_path=current_file_name . '.png'
    " exec "!mmdc -H -i " . current_file_name . ".mmd -o " output_file_path . " -t bright -b transparent"
    " exec "!open " . output_file_path
    exec "!mermaid %"
  elseif &filetype == 'scala'
    set splitbelow
    :sp
    :term scala %
  endif
endfunc
]], {})

vim.api.nvim_exec2([[
func! RunVimTest()
  :w
  if &filetype == 'sh'
    :!time bash %
  elseif &filetype == 'go'
    :GoTestFile -v
  endif
endfunc
]], {})

function RunPython()
  -- Get current buffer lines
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tmpfile = vim.fn.tempname() .. ".py"

  -- Write to temp file
  vim.fn.writefile(lines, tmpfile)

  -- Run Python (capture both stdout and stderr)
  local output = vim.fn.systemlist("python3 " .. vim.fn.shellescape(tmpfile) .. " 2>&1")

  -- Set quickfix list
  vim.fn.setqflist({}, ' ', { title = 'Python Output', lines = output })

  -- Open quickfix if output exists
  if #output > 0 then
    vim.cmd("copen")
  else
    print("No output.")
  end
end

vim.api.nvim_create_user_command('RunPython', RunPython, {})
