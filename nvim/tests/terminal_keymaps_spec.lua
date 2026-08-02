local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function focused_terminal()
  local terminal = require "toggleterm.terminal"
  local id = terminal.get_focused_id()
  return id and terminal.get(id) or nil
end

local function feed(keys)
  local encoded = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(encoded, "x", false)
  vim.wait(100, function()
    return false
  end)
end

vim.cmd "enew"

feed "<C-q>"
local first = focused_terminal()
assert(first, "Ctrl-Q should create and focus a terminal")
assert_equal(first.direction, "float", "Ctrl-Q should default to a float")

feed "<C-q>"
local second = focused_terminal()
assert(second and second.id ~= first.id, "Ctrl-Q should create another terminal from terminal mode")
assert_equal(second.display_name, "Terminal 2 / 2", "new terminal should display the unified count")

feed "<C-d>"
feed "="
second = focused_terminal()
assert_equal(second.direction, "vertical", "equals should move the current terminal to a vertical split")
assert(vim.wo[second.window].winbar:find("Terminal 2 / 2", 1, true), "vertical split should display the count")

feed "<C-Left>"
first = focused_terminal()
assert_equal(first.direction, "vertical", "Ctrl-Left should preserve the vertical split")
assert(vim.wo[first.window].winbar:find("Terminal 1 / 2", 1, true), "cycled split should display the selected count")

feed "<C-d>"
feed "-"
first = focused_terminal()
assert_equal(first.direction, "horizontal", "minus should move the same terminal to a horizontal split")
assert(vim.wo[first.window].winbar:find("Terminal 1 / 2", 1, true), "horizontal split should display the count")

feed "<C-Right>"
second = focused_terminal()
assert_equal(second.direction, "horizontal", "Ctrl-Right should preserve the horizontal split")
assert(vim.wo[second.window].winbar:find("Terminal 2 / 2", 1, true), "next terminal should display the selected count")

feed "<C-p>"
second = focused_terminal()
assert_equal(second.direction, "float", "Ctrl-P should move the current terminal to a float")
assert_equal(vim.wo[second.window].winbar, "", "floating terminal should show only its border title")

-- Ctrl-W on a terminal must switch to the previous terminal instead of killing it
feed "<C-d>"
feed "<C-w>"
local focused = focused_terminal()
assert(focused and focused.id == first.id, "Ctrl-W should switch to the previous terminal, not close it")
local terminal = require "toggleterm.terminal"
assert_equal(#terminal.get_all(), 2, "Ctrl-W should keep both terminals in the pool")

print "terminal_keymaps_spec: ok"
vim.cmd "qa!"
