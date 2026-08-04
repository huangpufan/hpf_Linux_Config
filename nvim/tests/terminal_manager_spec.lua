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

vim.cmd "enew"
require("lazy").load { plugins = { "toggleterm.nvim" } }

local manager = require "config.terminal_manager"
local terminal = require "toggleterm.terminal"
local toggleterm_config = require "toggleterm.config"

assert_equal(toggleterm_config.get "auto_scroll", false, "terminal output should not force scrollback to the bottom")
assert_equal(toggleterm_config.get "persist_mode", false, "reopened terminals should not restore terminal normal mode")
assert_equal(toggleterm_config.get "start_in_insert", true, "opened terminals should accept input immediately")

manager.new_terminal()
local first = focused_terminal()
assert(first, "first terminal should be focused")
assert_equal(first.direction, "float", "first terminal layout")
assert_equal(first.display_name, "Terminal 1 / 1", "first terminal label")

manager.new_terminal()
local second = focused_terminal()
assert(second and second.id ~= first.id, "new terminal should create a distinct session")
assert_equal(second.direction, "float", "new terminal should preserve float layout")
assert_equal(second.display_name, "Terminal 2 / 2", "second terminal label")
assert(
  vim.inspect(vim.api.nvim_win_get_config(second.window).title):find("Terminal 2 / 2", 1, true),
  "float terminal should show its count"
)

assert(
  vim.wait(1000, function()
    local content = table.concat(vim.api.nvim_buf_get_lines(second.bufnr, 0, -1, false), "\n")
    return content:find("$ ", 1, true) ~= nil
  end),
  "terminal shell should be ready before the scrollback check"
)
second:send "seq 1 80"
assert(
  vim.wait(1000, function()
    return vim.api.nvim_buf_line_count(second.bufnr) >= 80
  end),
  "terminal should produce enough output for scrollback"
)
vim.cmd "stopinsert"
vim.api.nvim_win_set_cursor(second.window, { 2, 0 })
local scrollback_line = vim.api.nvim_win_get_cursor(second.window)[1]
local previous_line_count = vim.api.nvim_buf_line_count(second.bufnr)
vim.fn.chansend(second.job_id, "printf 'scrollback-new-output\\n'\r")
assert(
  vim.wait(1000, function()
    return vim.api.nvim_buf_line_count(second.bufnr) > previous_line_count
  end),
  "terminal should receive new output while viewing scrollback"
)
assert_equal(
  vim.api.nvim_win_get_cursor(second.window)[1],
  scrollback_line,
  "new terminal output should preserve the user's scrollback position"
)

-- Switching terminals must preserve the user's scroll position: floating
-- windows are destroyed on close and recreated on open, so the window-level
-- topline would otherwise snap back to the bottom of the scrollback.
vim.cmd "stopinsert"
vim.api.nvim_win_set_height(second.window, 10)
vim.api.nvim_win_set_cursor(second.window, { 40, 0 })
vim.api.nvim_win_call(second.window, function()
  vim.cmd "normal! zt"
end)
local preserved_topline = vim.api.nvim_win_call(second.window, function()
  return vim.fn.winsaveview().topline
end)
assert(preserved_topline > 1, "scrollback topline should be set above the bottom before cycling")

manager.cycle(-1)
assert_equal(focused_terminal().id, first.id, "cycle should switch terminal session")
assert_equal(focused_terminal().direction, "float", "cycle should preserve float layout")

manager.cycle(-1)
assert_equal(focused_terminal().id, second.id, "cycle should return to the scrolled terminal")
local restored_topline = vim.api.nvim_win_call(second.window, function()
  return vim.fn.winsaveview().topline
end)
assert_equal(restored_topline, preserved_topline, "cycling back should restore the saved scroll position")

manager.cycle(-1)
assert_equal(focused_terminal().id, first.id, "cycle should return to the first terminal for the layout change")

manager.toggle "vertical"
first = focused_terminal()
assert_equal(first.direction, "vertical", "layout change should preserve the terminal session")
assert(vim.wo[first.window].winbar:find("Terminal 1 / 2", 1, true), "vertical terminal should show its count")

manager.new_terminal()
local third = focused_terminal()
assert_equal(#terminal.get_all(), 3, "new terminal should extend the unified pool")
assert_equal(third.direction, "vertical", "new terminal should preserve vertical layout")
assert(vim.wo[third.window].winbar:find("Terminal 3 / 3", 1, true), "new vertical terminal should show its count")

manager.cycle(-1)
second = focused_terminal()
assert_equal(second.direction, "vertical", "cycle should preserve vertical layout")
assert(vim.wo[second.window].winbar:find("Terminal 2 / 3", 1, true), "cycled vertical terminal should show its count")

manager.toggle "horizontal"
second = focused_terminal()
assert_equal(second.direction, "horizontal", "layout change should preserve the selected session")
assert(vim.wo[second.window].winbar:find("Terminal 2 / 3", 1, true), "horizontal terminal should show its count")

local original_select = vim.ui.select
vim.ui.select = function(items, _, callback)
  assert_equal(#items, 3, "selector should list the unified terminal pool")
  callback(items[1])
end
manager.select_terminal()
vim.ui.select = original_select
first = focused_terminal()
assert_equal(first.direction, "horizontal", "selection should preserve horizontal layout")
assert(vim.wo[first.window].winbar:find("Terminal 1 / 3", 1, true), "selected terminal should show its count")

manager.toggle "horizontal"
assert(not first:is_open(), "toggling the active layout should hide its window")
manager.new_terminal()
local fourth = focused_terminal()
assert_equal(fourth.direction, "float", "new terminal should default to float when no terminal is visible")
assert_equal(fourth.display_name, "Terminal 4 / 4", "new float terminal should show the unified count")

manager.toggle "float"
require("lazy").load { plugins = { "nvim-tree.lua" } }
local tree = require "nvim-tree.api"
tree.tree.open()
manager.toggle "horizontal"
assert(tree.tree.is_visible(), "opening a split terminal should preserve the file tree")
assert_equal(focused_terminal().direction, "horizontal", "terminal should open beside the preserved file tree")

vim.fn.chanclose(third.job_id)
assert(
  vim.wait(1000, function()
    return #terminal.get_all() == 3
  end),
  "exited terminal should leave the unified pool"
)
assert(
  vim.wait(1000, function()
    return fourth.display_name == "Terminal 3 / 3"
  end),
  "remaining terminal labels should refresh after exit"
)
assert(vim.wo[fourth.window].winbar:find("Terminal 3 / 3", 1, true), "visible count should refresh after exit")

manager.toggle "float"
fourth = focused_terminal()
assert_equal(fourth.direction, "float", "split terminal should move to a float without changing sessions")
assert_equal(vim.wo[fourth.window].winbar, "", "float terminal should not retain the split title")

print "terminal_manager_spec: ok"
vim.cmd "qa!"
