local function fail(message)
  io.stderr:write(message .. "\n")
  vim.cmd "cquit 1"
end

local function find_float(filetype)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    local buffer = vim.api.nvim_win_get_buf(win)
    if config.relative ~= "" and vim.bo[buffer].filetype == filetype then
      return win, config
    end
  end
end

require("lazy").load { plugins = { "incline.nvim", "nvim-scrollview" } }

if not vim.wait(2000, function()
  return vim.fn.exists ":ScrollViewRefresh" == 2
end, 10) then
  fail "nvim-scrollview did not initialize"
end

local lines = {}
for line = 1, 240 do
  lines[line] = string.format("first-page scrollbar verification line %03d", line)
end
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.api.nvim_buf_set_name(0, "/tmp/nvim-scrollview-first-page.md")
vim.bo.filetype = "markdown"

local parent = vim.api.nvim_get_current_win()
vim.cmd "normal! ggzt"
require("incline").refresh()
require("scrollview").refresh()

local incline_win, incline_config
local scrollbar_win, scrollbar_config
local rendered = vim.wait(2000, function()
  incline_win, incline_config = find_float "incline"
  scrollbar_win, scrollbar_config = find_float "scrollview"
  return incline_win ~= nil and scrollbar_win ~= nil
end, 10)

if not rendered then
  fail "the first-page scrollbar was hidden by the Incline filename window"
end

local parent_position = vim.api.nvim_win_get_position(parent)
local incline_right = incline_config.col + incline_config.width - 1
local scrollbar_col = parent_position[2] + scrollbar_config.col
if incline_right >= scrollbar_col then
  fail(string.format("Incline still occupies the scrollbar column: %s >= %s", incline_right, scrollbar_col))
end

if scrollbar_config.row ~= 0 then
  fail(string.format("the first-page scrollbar did not start at the top: row=%s", scrollbar_config.row))
end

print "scrollview_spec: ok"
vim.cmd "qa!"
