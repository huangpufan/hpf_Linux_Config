local function assert_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function contains(list, value)
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
end

vim.cmd "enew"
vim.bo.filetype = "markdown"
require("lazy").load { plugins = { "markdown-preview.nvim", "which-key.nvim" }, wait = true }
vim.api.nvim_exec_autocmds("VimEnter", {})
vim.wait(100)

local preview = require "config.markdown_preview"

assert_equal(vim.g.mkdp_auto_start, 0, "Markdown preview should only start explicitly")
assert_equal(vim.g.mkdp_auto_close, 0, "reading mode should survive buffer switches")
assert_equal(vim.g.mkdp_combine_preview, 1, "Markdown buffers should share one preview window")
assert_equal(vim.g.mkdp_preview_options.sync_scroll_type, "relative", "preview scroll mode")
assert(vim.g.mkdp_markdown_css:match "markdown%-reading%.css$", "custom reading CSS should be configured")
assert_equal(vim.g.mkdp_browserfunc, "OpenMarkdownReadingPreview", "browser callback")
assert_equal(vim.fn.exists "*OpenMarkdownReadingPreview", 1, "browser callback should be callable through Vim RPC")

local css = table.concat(vim.fn.readfile(vim.g.mkdp_markdown_css), "\n")
assert(css:find "font%-size: 17px", "reading CSS font size")
assert(css:find "line%-height: 1%.75", "reading CSS line height")
assert(css:find "max%-width: 900px", "reading CSS prose width")
assert(css:find "padding: 32px 48px", "reading CSS page padding")

local mapping = vim.fn.maparg("<Space>md", "n", false, true)
assert_equal(mapping.desc, "Markdown reading mode", "Space md mapping")

local autocmds = vim.api.nvim_get_autocmds { group = "MarkdownReadingMode" }
local events = {}
local leave_callback
for _, autocmd in ipairs(autocmds) do
  events[autocmd.event] = true
  if autocmd.event == "VimLeavePre" then
    leave_callback = autocmd.callback
  end
end
assert(events.WinScrolled, "WinScrolled refresh should be registered")
assert(leave_callback, "VimLeavePre cleanup should be registered")

local function fake_dependencies(options)
  options = options or {}
  local calls = {
    commands = {},
    deferred = {},
    notifications = {},
    opened_urls = {},
    refreshes = 0,
    stops = 0,
    systems = {},
    waits = 0,
  }
  local filetype = options.filetype or "markdown"
  local environment = options.environment or { WT_SESSION = "session-1", WSL_INTEROP = "/run/WSL/1_interop" }

  preview._reset_for_test()
  preview._set_dependencies {
    command = function(command)
      calls.commands[#calls.commands + 1] = command
      if options.command_error then
        error(options.command_error)
      end
    end,
    defer = function(callback, milliseconds)
      calls.deferred[#calls.deferred + 1] = { callback = callback, milliseconds = milliseconds }
    end,
    executable = function(command)
      return command == "powershell.exe" and options.powershell ~= false
    end,
    filetype = function()
      return filetype
    end,
    getenv = function(name)
      return environment[name]
    end,
    notify = function(message, level)
      calls.notifications[#calls.notifications + 1] = { message = message, level = level }
    end,
    open_url = function(url)
      calls.opened_urls[#calls.opened_urls + 1] = url
      return options.open_url_ok ~= false, options.open_url_error
    end,
    read_osrelease = function()
      return options.osrelease or "6.6.0-microsoft-standard-WSL2"
    end,
    readable = function()
      return options.script_readable ~= false
    end,
    refresh = function()
      calls.refreshes = calls.refreshes + 1
    end,
    schedule = function(callback)
      callback()
    end,
    stop_preview = function()
      calls.stops = calls.stops + 1
    end,
    system = function(command, _, callback)
      calls.systems[#calls.systems + 1] = command
      local result = options.system_result or { code = 0, stdout = '{"status":"opened"}', stderr = "" }
      if callback then
        callback(result)
      end
      return {
        wait = function()
          calls.waits = calls.waits + 1
          return result
        end,
      }
    end,
    windows_path = function()
      return "C:\\nvim\\scripts\\markdown-reading-mode.ps1"
    end,
  }

  return calls, function(value)
    filetype = value
  end
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "Markdown buffer should start reading mode")
  assert_equal(calls.commands, { "MarkdownPreview" }, "start command")
  assert_equal(
    vim.fn.OpenMarkdownReadingPreview "http://localhost:1234/page/1",
    true,
    "Vim RPC callback should use the PowerShell layout"
  )
  local command = calls.systems[1]
  assert(contains(command, "open"), "PowerShell action should be open")
  assert(contains(command, "session-1"), "PowerShell command should include WT_SESSION")
  assert(contains(command, "55"), "PowerShell command should include the 55 percent split")
  assert(contains(command, "http://localhost:1234/page/1"), "PowerShell command should include the preview URL")
  assert_equal(#calls.opened_urls, 0, "successful WSL layout should not use fallback browser")
end

do
  local calls, set_filetype = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "reading mode should open")
  set_filetype "text"
  assert(preview.toggle(), "second toggle should close reading mode")
  assert_equal(calls.stops, 1, "closing should stop the preview server")
  assert(contains(calls.systems[1], "close"), "closing should restore the Windows layout")
  assert_equal(preview._state().active, false, "closed state")
end

do
  local calls = fake_dependencies { environment = {}, osrelease = "6.8.0-generic" }
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "non-WSL Markdown preview should still start")
  assert(not preview.open_browser "http://localhost:1234/page/2", "non-WSL should report fallback")
  assert_equal(calls.opened_urls, { "http://localhost:1234/page/2" }, "non-WSL fallback URL")
end

do
  local calls = fake_dependencies { environment = { WSL_INTEROP = "/run/WSL/1_interop" } }
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start without WT_SESSION")
  assert(not preview.open_browser "http://localhost:1234/page/no-session", "missing WT_SESSION should use fallback")
  assert_equal(calls.opened_urls, { "http://localhost:1234/page/no-session" }, "missing-session fallback URL")
end

do
  local calls = fake_dependencies {
    system_result = { code = 1, stdout = "", stderr = "layout failed" },
  }
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before layout failure")
  assert(preview.open_browser "http://localhost:1234/page/3", "PowerShell launch was attempted")
  assert_equal(calls.opened_urls, { "http://localhost:1234/page/3" }, "layout failure should open the normal browser")
  assert(calls.notifications[1].message:find("layout failed", 1, true), "fallback should explain the layout failure")
end

do
  local calls = fake_dependencies {
    system_result = { code = 0, stdout = '{"status":"busy"}', stderr = "" },
  }
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before ownership check")
  assert(preview.open_browser "http://localhost:1234/page/busy", "PowerShell ownership check was attempted")
  assert_equal(preview._state().active, false, "busy terminal should not create a second reading-mode owner")
  assert_equal(calls.stops, 1, "busy ownership should stop the unused preview server")
  assert(calls.notifications[1].message:find("已有一个", 1, true), "busy ownership warning")
end

do
  local calls = fake_dependencies { command_error = "missing preview command" }
  vim.bo.filetype = "markdown"
  assert(not preview.toggle(), "preview command failure should roll back active state")
  assert_equal(preview._state().active, false, "command failure state")
  assert(calls.notifications[1].message:find("missing preview command", 1, true), "command failure warning")
end

do
  local calls, set_filetype = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before scroll checks")
  preview.refresh_on_scroll()
  preview.refresh_on_scroll()
  assert_equal(#calls.deferred, 1, "WinScrolled refresh should be throttled")
  assert_equal(calls.deferred[1].milliseconds, 80, "scroll throttle interval")
  calls.deferred[1].callback()
  assert_equal(calls.refreshes, 1, "scroll refresh should call the plugin once")
  set_filetype "text"
  preview.refresh_on_scroll()
  assert_equal(#calls.deferred, 1, "non-Markdown scrolling should not refresh the preview")
end

do
  local calls = fake_dependencies { filetype = "text" }
  vim.bo.filetype = "text"
  assert(not preview.toggle(), "non-Markdown buffer should not start reading mode")
  assert_equal(#calls.commands, 0, "non-Markdown toggle should not run the preview command")
  assert(calls.notifications[1].message:find("Markdown buffer", 1, true), "non-Markdown warning")
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before exit cleanup")
  leave_callback()
  assert_equal(calls.stops, 1, "exit cleanup should stop preview")
  assert_equal(calls.waits, 1, "exit cleanup should wait for terminal restoration")
end

print "markdown_preview_spec: ok"
vim.cmd "qa!"
