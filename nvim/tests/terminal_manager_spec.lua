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

manager.cycle(-1)
assert_equal(focused_terminal().id, first.id, "cycle should switch terminal session")
assert_equal(focused_terminal().direction, "float", "cycle should preserve float layout")

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

print "terminal_manager_spec: ok"
vim.cmd "qa!"
