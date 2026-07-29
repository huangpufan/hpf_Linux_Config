--[[
  Terminal plugins
--]]

local function sync_terminal_labels()
  local terminals = require("toggleterm.terminal").get_all()

  for index, term in ipairs(terminals) do
    local label = string.format("Terminal %d / %d", index, #terminals)
    term.display_name = label

    if term:is_float() and term:is_open() and vim.api.nvim_win_is_valid(term.window) then
      vim.api.nvim_win_set_config(term.window, {
        title = label,
        title_pos = "center",
      })
    end
  end
end

local function open_terminal(target)
  local terminals = require("toggleterm.terminal").get_all()

  for _, term in ipairs(terminals) do
    if term ~= target and term:is_open() then
      term:close()
    end
  end

  if target:is_open() then
    target:focus()
  else
    target:open(nil, "float")
  end
end

local function select_terminal()
  local terminals = require("toggleterm.terminal").get_all()

  if #terminals == 0 then
    vim.cmd "TermNew direction=float"
    return
  end

  vim.ui.select(terminals, {
    prompt = "Select terminal: ",
    format_item = function(term)
      return term.display_name
    end,
  }, function(term)
    if term then
      open_terminal(term)
    end
  end)
end

local function cycle_terminal(step)
  local terminal = require "toggleterm.terminal"
  local terminals = terminal.get_all()

  if #terminals == 0 then
    vim.cmd "TermNew direction=float"
    return
  end

  local current_id = terminal.get_focused_id()
  if not current_id then
    local last_focused = terminal.get_last_focused()
    current_id = last_focused and last_focused.id or nil
  end

  local current_index = 1
  for index, term in ipairs(terminals) do
    if term.id == current_id then
      current_index = index
      break
    end
  end

  local target_index = ((current_index - 1 + step) % #terminals) + 1
  local target = terminals[target_index]

  open_terminal(target)
end

local function find_edit_window()
  local current_win = vim.api.nvim_get_current_win()

  local function is_edit_window(win)
    if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
      return false
    end

    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype ~= "NvimTree" and vim.bo[buf].buftype ~= "terminal"
  end

  if is_edit_window(current_win) then
    return current_win
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_edit_window(win) then
      return win
    end
  end
end

local function toggle_vertical_terminal()
  local edit_win = find_edit_window()
  if not edit_win then
    vim.notify("No edit window available for the vertical terminal", vim.log.levels.WARN)
    return
  end

  local ok, tree_api = pcall(require, "nvim-tree.api")
  local tree_was_visible = ok and tree_api.tree.is_visible()

  vim.api.nvim_set_current_win(edit_win)
  local width = math.floor(vim.api.nvim_win_get_width(edit_win) * 0.5)
  vim.cmd(string.format("ToggleTerm size=%d direction=vertical", width))

  if tree_was_visible and not tree_api.tree.is_visible() then
    local active_win = vim.api.nvim_get_current_win()
    tree_api.tree.open()
    if vim.api.nvim_win_is_valid(active_win) then
      vim.api.nvim_set_current_win(active_win)
    end
  end
end

return {
  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec", "TermNew", "TermSelect" },
    keys = {
      {
        "<C-p>",
        "<cmd>ToggleTerm direction=float<cr>",
        mode = { "n", "t" },
        desc = "Toggle floating terminal",
      },
      {
        "<C-q>",
        "<cmd>TermNew direction=float<cr>",
        mode = { "n", "t" },
        desc = "New floating terminal",
      },
      {
        "<C-left>",
        function()
          cycle_terminal(-1)
        end,
        mode = { "n", "t" },
        desc = "Previous floating terminal",
      },
      {
        "<C-right>",
        function()
          cycle_terminal(1)
        end,
        mode = { "n", "t" },
        desc = "Next floating terminal",
      },
      {
        "<C-up>",
        select_terminal,
        mode = { "n", "t" },
        desc = "Select floating terminal",
      },
      { "-", desc = "Toggle horizontal terminal" },
      { "=", desc = "Toggle vertical terminal" },
    },
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      on_create = function()
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.signcolumn = "no"
        sync_terminal_labels()
      end,
      on_open = sync_terminal_labels,
      on_exit = function()
        vim.schedule(sync_terminal_labels)
      end,
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "rounded", title_pos = "center" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Custom toggle function with nvim-tree support
      vim.cmd [[
        function! ToggleTermWithNvimTree()
          NvimTreeClose
          let height = float2nr(winheight(0) * 0.32)
          execute 'ToggleTerm size=' . height . ' direction=horizontal'
          execute 'sleep 1m | NvimTreeOpen'
          let term_win_id = win_getid(winnr('#'))
          call win_gotoid(term_win_id)
        endfunction
      ]]

      vim.keymap.set("n", "-", ":call ToggleTermWithNvimTree()<CR>", { desc = "Toggle horizontal terminal" })
      vim.keymap.set("n", "=", toggle_vertical_terminal, { desc = "Toggle vertical terminal" })
    end,
  },
}
