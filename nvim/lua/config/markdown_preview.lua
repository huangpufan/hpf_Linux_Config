local M = {}

local state = {
  active = false,
  content_generation = 0,
  generation = 0,
  scroll_intent = nil,
  session_id = nil,
  setup_done = false,
  sync_generation = 0,
  z_prefix_at = nil,
  warned_fallback = false,
}

local CONTENT_DEBOUNCE_MS = 100
local SCROLL_INTENT_TTL_MS = 250
local SYNC_SCROLL_WINDOW_MS = 120
local Z_PREFIX_TTL_MS = 500

local function default_windows_path(path)
  local output = vim.fn.system { "wslpath", "-w", path }
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(output)
end

local defaults = {
  buffer_filetype = function(bufnr)
    return vim.bo[bufnr].filetype
  end,
  clear_plugin_refresh = function(bufnr)
    local ok, autocmds = pcall(vim.api.nvim_get_autocmds, {
      group = "MKDP_REFRESH_INIT" .. bufnr,
    })
    if not ok then
      return 0
    end

    local refresh_events = {}
    for _, autocmd in ipairs(autocmds) do
      if autocmd.buffer == bufnr and autocmd.command and autocmd.command:find("mkdp#rpc#preview_refresh", 1, true) then
        refresh_events[autocmd.event] = true
      end
    end

    local removed = 0
    for event in pairs(refresh_events) do
      local cleared = pcall(vim.api.nvim_clear_autocmds, {
        buffer = bufnr,
        event = event,
        group = "MKDP_REFRESH_INIT" .. bufnr,
      })
      if cleared then
        removed = removed + 1
      end
    end
    return removed
  end,
  command = vim.cmd,
  current_buffer = vim.api.nvim_get_current_buf,
  defer = vim.defer_fn,
  executable = function(command)
    return vim.fn.executable(command) == 1
  end,
  filetype = function()
    return vim.bo.filetype
  end,
  getenv = function(name)
    return vim.env[name]
  end,
  mode = function()
    return vim.api.nvim_get_mode().mode
  end,
  now = function()
    return vim.uv.hrtime() / 1000000
  end,
  notify = vim.notify,
  open_url = function(url)
    local _, err = vim.ui.open(url)
    return err == nil, err
  end,
  read_osrelease = function()
    local ok, lines = pcall(vim.fn.readfile, "/proc/sys/kernel/osrelease")
    return ok and table.concat(lines, " ") or ""
  end,
  readable = function(path)
    return vim.fn.filereadable(path) == 1
  end,
  refresh = function()
    return vim.fn["mkdp#rpc#preview_refresh"]()
  end,
  schedule = vim.schedule,
  set_sync_scroll = function(enabled)
    local options = vim.deepcopy(vim.g.mkdp_preview_options or {})
    options.disable_sync_scroll = enabled and 0 or 1
    options.sync_scroll_type = "relative"
    vim.g.mkdp_preview_options = options
  end,
  stop_preview = function()
    return vim.fn["mkdp#util#stop_preview"]()
  end,
  system = function(command, options, callback)
    return vim.system(command, options, callback)
  end,
  windows_path = default_windows_path,
}

local deps = defaults

local direct_scroll_keys = {
  ["<C-B>"] = true,
  ["<C-D>"] = true,
  ["<C-E>"] = true,
  ["<C-F>"] = true,
  ["<C-U>"] = true,
  ["<C-Y>"] = true,
}

local universal_scroll_keys = {
  ["<PageDown>"] = true,
  ["<PageUp>"] = true,
  ["<ScrollWheelDown>"] = true,
  ["<ScrollWheelUp>"] = true,
  ["<kPageDown>"] = true,
  ["<kPageUp>"] = true,
}

local function config_path(relative)
  return vim.fs.joinpath(vim.fn.stdpath "config", relative)
end

local function is_wsl2()
  if deps.getenv "WSL_INTEROP" then
    return true
  end
  return deps.read_osrelease():lower():find("microsoft", 1, true) ~= nil
end

local function is_markdown_buffer(bufnr)
  local ok, filetype = pcall(deps.buffer_filetype, bufnr)
  return ok and filetype == "markdown"
end

local function is_current_markdown_buffer(bufnr)
  bufnr = bufnr or deps.current_buffer()
  return bufnr == deps.current_buffer() and is_markdown_buffer(bufnr)
end

local function disable_sync_scroll()
  state.sync_generation = state.sync_generation + 1
  deps.set_sync_scroll(false)
end

local function clear_scroll_intent()
  state.scroll_intent = nil
  state.z_prefix_at = nil
end

local function schedule_plugin_refresh_cleanup(bufnr)
  deps.schedule(function()
    if state.active and is_markdown_buffer(bufnr) then
      deps.clear_plugin_refresh(bufnr)
    end
  end)
end

local function layout_command(action, url, session_id)
  if not is_wsl2() or not session_id or session_id == "" then
    return nil
  end
  if not deps.executable "powershell.exe" then
    return nil
  end

  local script = config_path "scripts/markdown-reading-mode.ps1"
  if not deps.readable(script) then
    return nil
  end
  local windows_script = deps.windows_path(script)
  if not windows_script or windows_script == "" then
    return nil
  end

  local command = {
    "powershell.exe",
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    windows_script,
    "-Action",
    action,
    "-SessionId",
    session_id,
    "-LeftPercent",
    "55",
  }
  if url then
    vim.list_extend(command, { "-Url", url })
  end
  return command
end

local function notify_fallback(reason)
  if not state.warned_fallback then
    state.warned_fallback = true
    deps.notify(
      "Markdown 阅读模式无法控制 Windows 双栏布局，已改用普通浏览器。"
        .. (reason and ("\n" .. reason) or ""),
      vim.log.levels.WARN
    )
  end
end

local function open_fallback(url, reason)
  notify_fallback(reason)
  local ok, err = deps.open_url(url)
  if not ok then
    deps.notify("无法打开 Markdown 预览：" .. tostring(err), vim.log.levels.ERROR)
  end
end

local function close_layout(options)
  options = options or {}
  local session_id = options.session_id or state.session_id
  if not session_id then
    return
  end

  local command = layout_command("close", nil, session_id)
  if not command then
    return
  end

  local ok, job = pcall(deps.system, command, { text = true })
  if not ok then
    if options.notify ~= false then
      deps.notify("无法恢复 Windows Terminal 布局：" .. tostring(job), vim.log.levels.WARN)
    end
    return
  end

  if options.wait and job and job.wait then
    local result = job:wait(5000)
    if result and result.code ~= 0 and options.notify ~= false then
      deps.notify("Windows Terminal 布局恢复失败：" .. vim.trim(result.stderr or ""), vim.log.levels.WARN)
    end
  end
end

function M.open_browser(url)
  schedule_plugin_refresh_cleanup(deps.current_buffer())

  local session_id = state.session_id or deps.getenv "WT_SESSION"
  local command = layout_command("open", url, session_id)
  if not command then
    open_fallback(url, "需要 WSL2、Windows Terminal 的 WT_SESSION 和 Windows PowerShell 5.1。")
    return false
  end

  local generation = state.generation
  local ok, err = pcall(deps.system, command, { text = true }, function(result)
    deps.schedule(function()
      if result.code ~= 0 then
        if state.active and state.generation == generation then
          open_fallback(url, vim.trim(result.stderr or result.stdout or "PowerShell 摆窗失败"))
        end
        return
      end

      local decoded_ok, response = pcall(vim.json.decode, result.stdout or "")
      if decoded_ok and response.status == "busy" and state.active and state.generation == generation then
        state.active = false
        state.session_id = nil
        pcall(deps.stop_preview)
        deps.notify(
          "当前 Windows Terminal 已有一个 Markdown 阅读模式占用双栏布局。",
          vim.log.levels.WARN
        )
        return
      end

      if not state.active or state.generation ~= generation then
        close_layout { notify = false, session_id = session_id }
      end
    end)
  end)
  if not ok then
    open_fallback(url, tostring(err))
    return false
  end
  return true
end

local function mark_scroll_intent(now)
  state.scroll_intent = {
    expires_at = now + SCROLL_INTENT_TTL_MS,
  }
end

function M._on_key(_, typed)
  if not state.active then
    return
  end
  if not is_current_markdown_buffer() then
    clear_scroll_intent()
    return
  end
  if typed == nil or typed == "" then
    return
  end

  local key = vim.fn.keytrans(typed)
  local now = deps.now()
  local mode = deps.mode()
  local normal_mode = mode:sub(1, 1) == "n"

  if key == "zz" or key == "zt" or key == "zb" then
    clear_scroll_intent()
    if normal_mode then
      mark_scroll_intent(now)
    end
    return
  end

  if universal_scroll_keys[key] or (normal_mode and direct_scroll_keys[key]) then
    clear_scroll_intent()
    mark_scroll_intent(now)
    return
  end

  if normal_mode and key == "z" then
    state.scroll_intent = nil
    if state.z_prefix_at and now - state.z_prefix_at <= Z_PREFIX_TTL_MS then
      mark_scroll_intent(now)
      state.z_prefix_at = nil
    else
      state.z_prefix_at = now
    end
    return
  end

  if
    normal_mode
    and (key == "t" or key == "b")
    and state.z_prefix_at
    and now - state.z_prefix_at <= Z_PREFIX_TTL_MS
  then
    state.z_prefix_at = nil
    mark_scroll_intent(now)
    return
  end

  clear_scroll_intent()
end

function M.refresh_on_scroll()
  if not state.active or not is_current_markdown_buffer() then
    clear_scroll_intent()
    return
  end

  local intent = state.scroll_intent
  clear_scroll_intent()
  if not intent or intent.expires_at < deps.now() then
    return
  end

  state.sync_generation = state.sync_generation + 1
  local sync_generation = state.sync_generation
  deps.set_sync_scroll(true)
  pcall(deps.refresh)
  deps.defer(function()
    if state.sync_generation == sync_generation then
      deps.set_sync_scroll(false)
    end
  end, SYNC_SCROLL_WINDOW_MS)
end

function M.refresh_content(args)
  local bufnr = args and args.buf or deps.current_buffer()
  if not state.active or not is_current_markdown_buffer(bufnr) then
    return
  end

  clear_scroll_intent()
  disable_sync_scroll()
  state.content_generation = state.content_generation + 1
  local content_generation = state.content_generation
  local reading_generation = state.generation

  deps.defer(function()
    if
      state.active
      and state.generation == reading_generation
      and state.content_generation == content_generation
      and is_current_markdown_buffer(bufnr)
    then
      disable_sync_scroll()
      pcall(deps.refresh)
    end
  end, CONTENT_DEBOUNCE_MS)
end

function M.cleanup_plugin_refresh(bufnr)
  bufnr = bufnr or deps.current_buffer()
  if not is_markdown_buffer(bufnr) then
    return 0
  end
  return deps.clear_plugin_refresh(bufnr)
end

function M.on_buffer_enter(args)
  local bufnr = args and args.buf or deps.current_buffer()
  if not state.active then
    return
  end

  clear_scroll_intent()
  disable_sync_scroll()
  if not is_markdown_buffer(bufnr) then
    return
  end
  schedule_plugin_refresh_cleanup(bufnr)
end

function M.close(options)
  options = options or {}
  if not state.active and not state.session_id then
    return false
  end

  state.active = false
  state.generation = state.generation + 1
  state.content_generation = state.content_generation + 1
  clear_scroll_intent()
  disable_sync_scroll()
  pcall(deps.stop_preview)
  close_layout { wait = options.wait, notify = options.notify }
  state.session_id = nil
  return true
end

function M.toggle()
  if state.active then
    return M.close()
  end
  if deps.filetype() ~= "markdown" then
    deps.notify("Markdown 阅读模式只能从 Markdown buffer 开启。", vim.log.levels.WARN)
    return false
  end

  state.active = true
  state.generation = state.generation + 1
  state.session_id = deps.getenv "WT_SESSION"
  state.warned_fallback = false
  clear_scroll_intent()
  disable_sync_scroll()

  local ok, err = pcall(deps.command, "MarkdownPreview")
  if not ok then
    state.active = false
    state.session_id = nil
    deps.notify("无法启动 Markdown 预览：" .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  schedule_plugin_refresh_cleanup(deps.current_buffer())
  return true
end

function M.setup()
  if state.setup_done then
    return
  end
  state.setup_done = true

  vim.cmd [[
    function! OpenMarkdownReadingPreview(url) abort
      return luaeval("require('config.markdown_preview').open_browser(_A)", a:url)
    endfunction
  ]]
  vim.g.mkdp_browserfunc = "OpenMarkdownReadingPreview"

  vim.api.nvim_create_user_command("MarkdownReadingModeToggle", M.toggle, {
    desc = "Toggle Markdown reading mode",
  })

  local group = vim.api.nvim_create_augroup("MarkdownReadingMode", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    callback = M.refresh_content,
  })
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = M.refresh_on_scroll,
  })
  vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    group = group,
    callback = M.on_buffer_enter,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      M.close { wait = true, notify = false }
    end,
  })

  local namespace = vim.api.nvim_create_namespace "MarkdownReadingModeScrollIntent"
  vim.on_key(M._on_key, namespace)
end

function M._set_dependencies(overrides)
  deps = vim.tbl_extend("force", defaults, overrides or {})
end

function M._reset_for_test()
  state.active = false
  state.content_generation = 0
  state.generation = 0
  state.scroll_intent = nil
  state.session_id = nil
  state.sync_generation = 0
  state.z_prefix_at = nil
  state.warned_fallback = false
  deps = defaults
end

function M._state()
  return vim.deepcopy(state)
end

return M
