local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_contains(value, expected, message)
  if not value:find(expected, 1, true) then
    error(string.format("%s: expected %s in %s", message, vim.inspect(expected), vim.inspect(value)))
  end
end

local function fail(err)
  io.stderr:write(debug.traceback(err) .. "\n")
  vim.cmd "cquit 1"
end

local function later(callback)
  vim.defer_fn(function()
    local ok, err = xpcall(callback, debug.traceback)
    if not ok then
      fail(err)
    end
  end, 150)
end

local function focused_terminal()
  local terminal = require "toggleterm.terminal"
  local id = terminal.get_focused_id()
  return id and terminal.get(id) or nil
end

local function float_title(term)
  return vim.inspect(vim.api.nvim_win_get_config(term.window).title)
end

vim.cmd "enew"
local editor_window = vim.api.nvim_get_current_win()
require("lazy").load { plugins = { "toggleterm.nvim" } }

local manager = require "config.terminal_manager"
manager.new_terminal()
local term = focused_terminal()
assert(term, "terminal state frame test should open a terminal")

later(function()
  assert_equal(vim.api.nvim_get_mode().mode, "t", "opened terminal should accept input")
  assert_contains(float_title(term), "INPUT", "float title should show input mode")
  assert_contains(
    vim.wo[term.window].winhighlight,
    "FloatBorder:TerminalInputFrame",
    "float terminal should use the green input frame"
  )

  vim.cmd "stopinsert"
  later(function()
    assert_contains(vim.api.nvim_get_mode().mode, "nt", "terminal should enter navigation mode")
    assert_contains(float_title(term), "NAV", "float title should show navigation mode")
    assert_contains(
      vim.wo[term.window].winhighlight,
      "FloatBorder:TerminalNormalFrame",
      "float terminal should use the amber navigation frame"
    )

    manager.toggle "vertical"
    term = focused_terminal()
    later(function()
      assert_equal(term.direction, "vertical", "terminal should move to a vertical split")
      assert_equal(vim.api.nvim_get_mode().mode, "t", "split terminal should accept input")
      assert_contains(vim.wo[term.window].winbar, "INPUT", "split title band should show input mode")
      assert_equal(
        require("colorful-winsep").colors[1],
        "#a6d189",
        "focused split terminal should use the green full-window frame"
      )

      vim.cmd "stopinsert"
      later(function()
        assert_contains(vim.wo[term.window].winbar, "NAV", "split title band should show navigation mode")
        assert_equal(
          require("colorful-winsep").colors[1],
          "#e5c890",
          "terminal navigation mode should use the amber full-window frame"
        )

        vim.api.nvim_set_current_win(editor_window)
        later(function()
          assert_contains(vim.wo[term.window].winbar, "IDLE", "unfocused split title band should show idle state")
          assert_contains(
            vim.wo[term.window].winhighlight,
            "WinBarNC:TerminalInactiveTitle",
            "unfocused split terminal should use the muted title band"
          )
          assert_equal(
            require("colorful-winsep").colors[1],
            "#e78284",
            "editor focus should restore the normal active-window frame"
          )

          print "terminal_state_frame_spec: ok"
          vim.cmd "qa!"
        end)
      end)
    end)
  end)
end)
