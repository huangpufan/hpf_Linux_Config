local M = {}

local last_terminal_id

local function terminal_api()
  return require "toggleterm.terminal"
end

local function is_valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_open(term)
  return term and term:is_open() and is_valid_window(term.window)
end

local function remember(term)
  if term then
    last_terminal_id = term.id
  end
end

local function focused_terminal()
  local terminal = terminal_api()
  local id = terminal.get_focused_id()
  return id and terminal.get(id) or nil
end

local function active_terminal()
  local terminal = terminal_api()
  local focused = focused_terminal()
  if focused then
    return focused
  end

  local remembered = last_terminal_id and terminal.get(last_terminal_id) or nil
  if remembered then
    return remembered
  end

  local plugin_remembered = terminal.get_last_focused()
  if plugin_remembered then
    return plugin_remembered
  end

  return terminal.get_all()[1]
end

local function terminal_size(term)
  if not is_open(term) then
    return nil
  end

  if term.direction == "vertical" then
    return vim.api.nvim_win_get_width(term.window)
  end
  if term.direction == "horizontal" then
    return vim.api.nvim_win_get_height(term.window)
  end
end

local function current_presentation(default_direction)
  local focused = focused_terminal()
  if focused then
    return {
      term = focused,
      direction = focused.direction,
      size = terminal_size(focused),
    }
  end

  local active = active_terminal()
  return {
    term = active,
    direction = default_direction or (active and active.direction) or "float",
  }
end

local function is_edit_window(win)
  if not is_valid_window(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].filetype ~= "NvimTree" and vim.bo[buf].buftype ~= "terminal"
end

local function focus_edit_window()
  local current_win = vim.api.nvim_get_current_win()
  if is_edit_window(current_win) then
    return true
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_edit_window(win) then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end

  return false
end

local function default_size(direction)
  if direction == "vertical" then
    return math.floor(vim.api.nvim_win_get_width(0) * 0.5)
  end
  if direction == "horizontal" then
    return math.floor(vim.api.nvim_win_get_height(0) * 0.32)
  end
end

local function open_in_presentation(target, presentation)
  local current = presentation.term
  local direction = presentation.direction or "float"
  local size = presentation.size

  remember(target)

  if current and current ~= target and is_open(current) then
    current:close()
  end
  if is_open(target) then
    target:close()
  end

  if not focus_edit_window() then
    vim.notify("No edit window available for the terminal", vim.log.levels.WARN)
    return
  end

  target:open(size or default_size(direction), direction)
  M.sync_labels()
  return target
end

function M.sync_labels()
  local terminals = terminal_api().get_all()

  for index, term in ipairs(terminals) do
    local label = string.format("Terminal %d / %d", index, #terminals)
    term.display_name = label

    if is_open(term) then
      if term:is_float() then
        vim.api.nvim_win_set_config(term.window, {
          title = label,
          title_pos = "center",
        })
      else
        vim.wo[term.window].winbar = "%=" .. label .. "%="
      end
    end
  end
end

function M.toggle(direction)
  local presentation = current_presentation(direction)
  local target = presentation.term

  if target and is_open(target) and target.direction == direction then
    remember(target)
    target:close()
    return target
  end

  if not target then
    target = terminal_api().Terminal:new { direction = direction }
  end

  presentation.direction = direction
  presentation.size = nil
  return open_in_presentation(target, presentation)
end

function M.new_terminal()
  local presentation = current_presentation "float"
  local target = terminal_api().Terminal:new { direction = presentation.direction }
  return open_in_presentation(target, presentation)
end

function M.cycle(step)
  local terminals = terminal_api().get_all()
  if #terminals == 0 then
    return M.new_terminal()
  end

  local presentation = current_presentation "float"
  local current_index = 1
  for index, term in ipairs(terminals) do
    if presentation.term and term.id == presentation.term.id then
      current_index = index
      break
    end
  end

  local target_index = ((current_index - 1 + step) % #terminals) + 1
  return open_in_presentation(terminals[target_index], presentation)
end

function M.select_terminal()
  local terminals = terminal_api().get_all()
  if #terminals == 0 then
    return M.new_terminal()
  end

  local presentation = current_presentation "float"
  vim.ui.select(terminals, {
    prompt = "Select terminal: ",
    format_item = function(term)
      return term.display_name
    end,
  }, function(term)
    if term then
      open_in_presentation(term, presentation)
    end
  end)
end

function M.on_create(term)
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.signcolumn = "no"
  remember(term)
  M.sync_labels()
end

function M.on_open(term)
  remember(term)
  M.sync_labels()
end

function M.on_exit()
  vim.schedule(M.sync_labels)
end

return M
