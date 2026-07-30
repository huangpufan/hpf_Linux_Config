local M = {}

local state = {
  active = false,
  generation = 0,
  scroll_pending = false,
  session_id = nil,
  setup_done = false,
  warned_fallback = false,
}

local function default_windows_path(path)
  local output = vim.fn.system { "wslpath", "-w", path }
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.trim(output)
end

local defaults = {
  command = vim.cmd,
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
  stop_preview = function()
    return vim.fn["mkdp#util#stop_preview"]()
  end,
  system = function(command, options, callback)
    return vim.system(command, options, callback)
  end,
  windows_path = default_windows_path,
}

local deps = defaults

local function config_path(relative)
  return vim.fs.joinpath(vim.fn.stdpath "config", relative)
end

local function is_wsl2()
  if deps.getenv "WSL_INTEROP" then
    return true
  end
  return deps.read_osrelease():lower():find("microsoft", 1, true) ~= nil
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

function M.refresh_on_scroll()
  if not state.active or state.scroll_pending or deps.filetype() ~= "markdown" then
    return
  end

  state.scroll_pending = true
  deps.defer(function()
    state.scroll_pending = false
    if state.active and deps.filetype() == "markdown" then
      pcall(deps.refresh)
    end
  end, 80)
end

function M.close(options)
  options = options or {}
  if not state.active and not state.session_id then
    return false
  end

  state.active = false
  state.generation = state.generation + 1
  state.scroll_pending = false
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

  local ok, err = pcall(deps.command, "MarkdownPreview")
  if not ok then
    state.active = false
    state.session_id = nil
    deps.notify("无法启动 Markdown 预览：" .. tostring(err), vim.log.levels.ERROR)
    return false
  end
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
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = M.refresh_on_scroll,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      M.close { wait = true, notify = false }
    end,
  })
end

function M._set_dependencies(overrides)
  deps = vim.tbl_extend("force", defaults, overrides or {})
end

function M._reset_for_test()
  state.active = false
  state.generation = 0
  state.scroll_pending = false
  state.session_id = nil
  state.warned_fallback = false
  deps = defaults
end

function M._state()
  return vim.deepcopy(state)
end

return M
