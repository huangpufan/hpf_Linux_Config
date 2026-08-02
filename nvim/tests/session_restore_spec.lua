local function fail(message)
  io.stderr:write(debug.traceback(message) .. "\n")
  vim.cmd "cquit 1"
end

assert(package.loaded.persisted ~= nil, "persisted.nvim was not loaded before VimEnter")
local persisted = require "persisted"
local original_cwd = vim.fn.getcwd()
local workdir = vim.fn.tempname()
local session_file

local function cleanup()
  persisted.stop()
  pcall(vim.cmd, "silent! %bwipeout!")
  pcall(vim.cmd, "cd " .. vim.fn.fnameescape(original_cwd))
  if session_file then
    vim.fn.delete(session_file)
  end
  vim.fn.delete(workdir, "rf")
end

local ok, err = xpcall(function()
  vim.opt.shadafile = "NONE"
  assert(vim.fn.mkdir(workdir, "p") == 1, "failed to create session fixture directory")

  local first = {}
  local second = {}
  for line = 1, 40 do
    first[line] = string.format("first line %02d", line)
  end
  for line = 1, 50 do
    second[line] = string.format("second line %02d", line)
  end
  assert(vim.fn.writefile(first, workdir .. "/first.txt") == 0, "failed to write first fixture")
  assert(vim.fn.writefile(second, workdir .. "/second.txt") == 0, "failed to write second fixture")

  vim.cmd("cd " .. vim.fn.fnameescape(workdir))
  vim.cmd "edit first.txt"
  vim.cmd "normal! 17G4|"
  vim.cmd "vsplit second.txt"
  vim.cmd "normal! 29G5|"

  session_file = persisted.current()
  persisted.save { force = true }
  assert(vim.fn.filereadable(session_file) == 1, "persisted.nvim did not write the session")

  vim.cmd "silent! %bwipeout!"
  vim.cmd "enew"
  vim.g.persisted_loaded_session = nil

  -- Headless Neovim does not emit VimEnter. Replaying it exercises the same
  -- startup contract and catches loading persisted.nvim after the event.
  vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })
  assert(
    vim.wait(2000, function()
      if vim.g.persisted_loaded_session ~= session_file then
        return false
      end
      local file_windows = 0
      for _, window in ipairs(vim.api.nvim_list_wins()) do
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(window))
        if name == workdir .. "/first.txt" or name == workdir .. "/second.txt" then
          file_windows = file_windows + 1
        end
      end
      return file_windows == 2
    end, 10),
    "saved session was not automatically restored on VimEnter"
  )

  local cursors = {}
  for _, window in ipairs(vim.api.nvim_list_wins()) do
    local buffer = vim.api.nvim_win_get_buf(window)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t")
    if name == "first.txt" or name == "second.txt" then
      local cursor = vim.api.nvim_win_get_cursor(window)
      cursors[#cursors + 1] = string.format("%s:%d:%d", name, cursor[1], cursor[2] + 1)
    end
  end
  table.sort(cursors)
  assert(
    vim.deep_equal(cursors, { "first.txt:17:4", "second.txt:29:5" }),
    "restored window cursors differ: " .. vim.inspect(cursors)
  )
end, debug.traceback)

cleanup()
if not ok then
  fail(err)
end

print "session_restore_spec: ok"
vim.cmd "qa!"
