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
assert_equal(vim.g.mkdp_refresh_slow, 1, "plugin cursor refresh should be disabled during preview startup")
assert_equal(vim.g.mkdp_preview_options.disable_sync_scroll, 1, "automatic browser scrolling should start disabled")
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
assert(events.TextChanged, "normal-mode content refresh should be registered")
assert(events.TextChangedI, "insert-mode content refresh should be registered")
assert(events.BufWritePost, "saved content refresh should be registered")
assert(events.BufEnter, "buffer-switch cleanup should be registered")
assert(events.FileType, "Markdown buffer cleanup should be registered")
assert(leave_callback, "VimLeavePre cleanup should be registered")

local function typed(notation)
  return vim.api.nvim_replace_termcodes(notation, true, false, true)
end

local function fake_dependencies(options)
  options = options or {}
  local calls = {
    commands = {},
    cleared_refresh = {},
    deferred = {},
    notifications = {},
    opened_urls = {},
    refreshes = 0,
    refresh_sync = {},
    stops = 0,
    sync_scroll = {},
    systems = {},
    waits = 0,
  }
  local filetype = options.filetype or "markdown"
  local current_buffer = options.current_buffer or 1
  local buffer_filetypes = options.buffer_filetypes or { [current_buffer] = filetype }
  local environment = options.environment or { WT_SESSION = "session-1", WSL_INTEROP = "/run/WSL/1_interop" }
  local mode = options.mode or "n"
  local now = options.now or 1000
  local sync_enabled = false

  preview._reset_for_test()
  preview._set_dependencies {
    buffer_filetype = function(bufnr)
      return buffer_filetypes[bufnr] or ""
    end,
    clear_plugin_refresh = function(bufnr)
      calls.cleared_refresh[#calls.cleared_refresh + 1] = bufnr
      return 3
    end,
    command = function(command)
      calls.commands[#calls.commands + 1] = command
      if options.command_error then
        error(options.command_error)
      end
    end,
    current_buffer = function()
      return current_buffer
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
    mode = function()
      return mode
    end,
    now = function()
      return now
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
      calls.refresh_sync[#calls.refresh_sync + 1] = sync_enabled
    end,
    schedule = function(callback)
      callback()
    end,
    set_sync_scroll = function(enabled)
      sync_enabled = enabled
      calls.sync_scroll[#calls.sync_scroll + 1] = enabled
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

  calls.advance_time = function(milliseconds)
    now = now + milliseconds
  end
  calls.set_buffer_filetype = function(bufnr, value)
    buffer_filetypes[bufnr] = value
    if bufnr == current_buffer then
      filetype = value
    end
  end
  calls.set_current_buffer = function(bufnr)
    current_buffer = bufnr
    filetype = buffer_filetypes[bufnr] or ""
  end
  calls.set_mode = function(value)
    mode = value
  end

  return calls, function(value)
    filetype = value
    buffer_filetypes[current_buffer] = value
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
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before ordinary movement checks")

  local ordinary_keys = {
    "j",
    "k",
    "g",
    "G",
    "/",
    "<CR>",
    "<LeftMouse>",
  }
  for _, key in ipairs(ordinary_keys) do
    preview._on_key(nil, typed "<C-D>")
    preview._on_key(nil, typed(key))
    preview.refresh_on_scroll()
  end
  preview._on_key(nil, "g")
  preview._on_key(nil, "g")
  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 0, "cursor movement, clicks, and jumps should never refresh browser scrolling")

  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 0, "viewport changes without explicit scroll input should be ignored")
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before explicit scroll checks")

  local scroll_keys = {
    "<C-D>",
    "<C-U>",
    "<C-E>",
    "<C-Y>",
    "<C-F>",
    "<C-B>",
    "<PageDown>",
    "<PageUp>",
    "<ScrollWheelDown>",
    "<ScrollWheelUp>",
  }
  for index, key in ipairs(scroll_keys) do
    preview._on_key(nil, typed(key))
    preview.refresh_on_scroll()
    preview.refresh_on_scroll()
    assert_equal(calls.refreshes, index, key .. " should produce exactly one synchronized refresh")
    assert_equal(calls.refresh_sync[index], true, key .. " refresh should enable relative browser scrolling")
    local deferred = calls.deferred[#calls.deferred]
    assert_equal(deferred.milliseconds, 120, "synchronized scroll window")
    deferred.callback()
    assert_equal(calls.sync_scroll[#calls.sync_scroll], false, "browser auto-scroll should be disabled afterward")
  end
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before z-scroll checks")

  for index, suffix in ipairs { "z", "t", "b" } do
    preview._on_key(nil, "z")
    preview._on_key(nil, suffix)
    preview.refresh_on_scroll()
    preview.refresh_on_scroll()
    assert_equal(calls.refreshes, index, "z" .. suffix .. " should produce exactly one synchronized refresh")
    calls.deferred[#calls.deferred].callback()
  end

  preview._on_key(nil, "z")
  preview._on_key(nil, "j")
  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 3, "an interrupted z prefix should leave no scroll intent")

  preview._on_key(nil, "z")
  calls.advance_time(501)
  preview._on_key(nil, "z")
  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 3, "an expired z prefix should not become a later scroll intent")

  preview._on_key(nil, "zz")
  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 4, "a combined zz input should also be recognized")
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before editing checks")

  preview.refresh_content { buf = 1 }
  preview.refresh_content { buf = 1 }
  preview.refresh_on_scroll()
  assert_equal(#calls.deferred, 2, "content refreshes should be debounced independently")
  assert_equal(calls.deferred[1].milliseconds, 100, "content debounce interval")
  calls.deferred[1].callback()
  assert_equal(calls.refreshes, 0, "an older content debounce should be ignored")
  calls.deferred[2].callback()
  assert_equal(calls.refreshes, 1, "continuous editing should end in one content refresh")
  assert_equal(calls.refresh_sync, { false }, "content refresh should preserve browser position")

  calls.set_buffer_filetype(1, "text")
  preview.refresh_content { buf = 1 }
  preview.refresh_on_scroll()
  assert_equal(#calls.deferred, 2, "non-Markdown changes should not refresh the preview")
end

do
  local calls = fake_dependencies()
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before mixed editing and scrolling")

  preview._on_key(nil, typed "<C-D>")
  preview.refresh_on_scroll()
  preview.refresh_content { buf = 1 }
  assert_equal(calls.refresh_sync, { true }, "explicit scroll should refresh with synchronization")
  assert_equal(calls.sync_scroll[#calls.sync_scroll], false, "editing should immediately cancel browser auto-scroll")

  calls.deferred[1].callback()
  calls.deferred[2].callback()
  assert_equal(calls.refresh_sync, { true, false }, "editing after scrolling should refresh without moving the page")
  assert_equal(calls.sync_scroll[#calls.sync_scroll], false, "mixed activity should finish with auto-scroll disabled")
end

do
  local calls = fake_dependencies { buffer_filetypes = { [1] = "markdown", [2] = "markdown", [3] = "text" } }
  vim.bo.filetype = "markdown"
  assert(preview.toggle(), "preview should start before buffer cleanup checks")
  preview._on_key(nil, typed "<C-D>")
  preview.on_buffer_enter { buf = 2 }
  preview.on_buffer_enter { buf = 3 }
  assert_equal(
    calls.cleared_refresh,
    { 1, 2 },
    "first preview and each Markdown buffer switch should clear plugin refreshes"
  )
  preview.refresh_on_scroll()
  assert_equal(calls.refreshes, 0, "switching through a non-Markdown buffer should discard old scroll intent")
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
  preview._on_key(nil, typed "<C-D>")
  preview.refresh_on_scroll()
  preview.refresh_content { buf = 1 }
  assert_equal(calls.refreshes, 0, "inactive reading mode should not refresh")
  assert_equal(#calls.deferred, 0, "inactive reading mode should not schedule refreshes")
end

local function plugin_refresh_count(bufnr)
  local ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
    group = "MKDP_REFRESH_INIT" .. bufnr,
  })
  if not ok then
    return 0
  end

  local count = 0
  for _, autocmd in ipairs(autocmds) do
    if autocmd.command and autocmd.command:find("mkdp#rpc#preview_refresh", 1, true) then
      count = count + 1
    end
  end
  return count
end

do
  preview._reset_for_test()
  for index = 1, 2 do
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.bo[bufnr].filetype = "markdown"
    vim.fn["mkdp#autocmd#init"]()
    assert(plugin_refresh_count(bufnr) > 0, "plugin should create refresh autocmds for Markdown buffer " .. index)
    assert(preview.cleanup_plugin_refresh(bufnr) > 0, "controller should remove plugin refreshes for buffer " .. index)
    assert_equal(plugin_refresh_count(bufnr), 0, "plugin cursor refreshes should remain absent for buffer " .. index)
  end
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
