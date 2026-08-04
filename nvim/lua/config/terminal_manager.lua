local M = {}

local last_terminal_id

-- Per-terminal saved scroll view (id -> { topline, leftcol }).
-- Floating windows are destroyed on close and recreated on open, so the
-- window-level scroll position (topline) is lost. We persist it here so
-- switching terminals and coming back keeps the user's scroll position.
local terminal_views = {}

local frame_states = {
  editor = {
    color = "#e78284",
  },
  input = {
    color = "#a6d189",
    frame_highlight = "TerminalInputFrame",
    title_highlight = "TerminalInputTitle",
    marker = "● INPUT",
    title_foreground = "#303446",
  },
  normal = {
    color = "#e5c890",
    frame_highlight = "TerminalNormalFrame",
    title_highlight = "TerminalNormalTitle",
    marker = "◆ NAV",
    title_foreground = "#303446",
  },
  inactive = {
    color = "#626880",
    frame_highlight = "TerminalInactiveFrame",
    title_highlight = "TerminalInactiveTitle",
    marker = "○ IDLE",
    title_foreground = "#c6d0f5",
  },
}

local function terminal_api()
  return require "toggleterm.terminal"
end

local function is_valid_window(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_open(term)
  return term and term:is_open() and is_valid_window(term.window)
end

local function save_view(term)
  if not is_open(term) then return end
  local view = vim.api.nvim_win_call(term.window, function()
    return vim.fn.winsaveview()
  end)
  -- Only the window-level scroll position is meaningful for terminal
  -- buffers; lnum/curswant would fight the terminal cursor.
  terminal_views[term.id] = { topline = view.topline, leftcol = view.leftcol }
end

local function restore_view(term)
  local view = terminal_views[term.id]
  if not view or not is_open(term) then return end
  vim.api.nvim_win_call(term.window, function()
    pcall(vim.fn.winrestview, { topline = view.topline, leftcol = view.leftcol })
  end)
end

local function clear_view(term)
  if term then terminal_views[term.id] = nil end
end

local function define_frame_highlights()
  for name, state in pairs(frame_states) do
    if name ~= "editor" then
      vim.api.nvim_set_hl(0, state.frame_highlight, { fg = state.color, bold = true })
      vim.api.nvim_set_hl(0, state.title_highlight, {
        fg = state.title_foreground,
        bg = state.color,
        bold = true,
      })
    end
  end
end

local function set_window_highlights(win, replacements)
  local current = vim.api.nvim_get_option_value("winhighlight", { win = win })
  local values = {}
  local order = {}

  for entry in current:gmatch "[^,]+" do
    local source, target = entry:match "^([^:]+):(.+)$"
    if source and target then
      values[source] = target
      order[#order + 1] = source
    end
  end

  local additions = {}
  for source, target in pairs(replacements) do
    if not values[source] then
      additions[#additions + 1] = source
    end
    values[source] = target
  end
  table.sort(additions)
  vim.list_extend(order, additions)

  local result = {}
  for _, source in ipairs(order) do
    result[#result + 1] = source .. ":" .. values[source]
  end
  vim.api.nvim_set_option_value("winhighlight", table.concat(result, ","), { win = win })
end

local function terminal_state(term)
  if term.window ~= vim.api.nvim_get_current_win() then
    return frame_states.inactive
  end

  if vim.api.nvim_get_mode().mode:sub(1, 1) == "t" then
    return frame_states.input
  end

  return frame_states.normal
end

local function visible_label(term, label)
  return string.format("%s · %s", terminal_state(term).marker, label)
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

local function sync_active_split_frame()
  local color = frame_states.editor.color
  local current_win = vim.api.nvim_get_current_win()
  local current_config = vim.api.nvim_win_get_config(current_win)

  if current_config.relative == "" and vim.bo[vim.api.nvim_win_get_buf(current_win)].buftype == "terminal" then
    local focused = focused_terminal()
    if focused then
      color = terminal_state(focused).color
    end
  end

  local ok, colorful_winsep = pcall(require, "colorful-winsep")
  if ok then
    colorful_winsep.set_colors { color }
  end
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

  -- Persist window-level scroll positions before the floating windows are
  -- destroyed; they are recreated on open and would otherwise snap back to
  -- the bottom of the scrollback.
  if current and current ~= target and is_open(current) then
    save_view(current)
    current:close()
  end
  if is_open(target) then
    save_view(target)
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
      local state = terminal_state(term)
      local stateful_label = visible_label(term, label)
      set_window_highlights(term.window, {
        FloatBorder = state.frame_highlight,
        FloatTitle = state.title_highlight,
        WinBar = state.title_highlight,
        WinBarNC = state.title_highlight,
      })

      if term:is_float() then
        vim.wo[term.window].winbar = ""
        vim.api.nvim_win_set_config(term.window, {
          title = " " .. stateful_label .. " ",
          title_pos = "center",
        })
      else
        vim.wo[term.window].winbar = string.format("%%#%s#%%=  %s  %%=%%*", state.title_highlight, stateful_label)
      end
    end
  end

  sync_active_split_frame()
end

function M.toggle(direction)
  local presentation = current_presentation(direction)
  local target = presentation.term

  if target and is_open(target) and target.direction == direction then
    save_view(target)
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

function M.kill_current_and_previous()
  local terminal = terminal_api()
  local presentation = current_presentation "float"
  local current = presentation.term
  if not current then
    return
  end

  local terminals = terminal.get_all()
  if #terminals <= 1 then
    current:shutdown()
    M.sync_labels()
    return
  end

  -- Switch to the previous terminal first so the killed one is only hidden,
  -- then shut the original down (terminate its job and drop it from the pool).
  M.cycle(-1)

  local original = terminal.get(current.id)
  if original then
    original:shutdown()
  end
  M.sync_labels()
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
  restore_view(term)
  M.sync_labels()
end

function M.on_exit(term)
  clear_view(term)
  vim.schedule(M.sync_labels)
end

function M.setup()
  define_frame_highlights()

  local group = vim.api.nvim_create_augroup("terminal_state_frame", { clear = true })
  vim.api.nvim_create_autocmd({ "TermEnter", "TermLeave", "WinEnter", "WinLeave", "BufEnter" }, {
    group = group,
    callback = function()
      vim.schedule(M.sync_labels)
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      define_frame_highlights()
      vim.schedule(M.sync_labels)
    end,
  })
end

return M
