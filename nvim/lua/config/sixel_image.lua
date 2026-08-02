local M = {}

local IMAGE_EXTENSIONS = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "avif" }
local EAGAIN = 11
local EINTR = 4

local function case_insensitive_extension(extension)
  return (
    extension:gsub("%a", function(character)
      return string.format("[%s%s]", character:lower(), character:upper())
    end)
  )
end

local states = {}
local window_owners = {}
local pending_window_options = {}
local setup_done = false
local exiting = false
local provider_namespace = vim.api.nvim_create_namespace "SixelImageViewer"

local ffi_loaded, ffi = pcall(require, "ffi")
local has_ffi = false
local ffi_init_error
if ffi_loaded then
  local declarations_exist = pcall(ffi.typeof, "sixel_pollfd")
  if declarations_exist then
    has_ffi = true
  else
    local ok, err = pcall(
      ffi.cdef,
      [[
      typedef long ssize_t;
      typedef unsigned long nfds_t;
      typedef struct { int fd; short events; short revents; } sixel_pollfd;
      typedef struct {
        unsigned short row;
        unsigned short col;
        unsigned short xpixel;
        unsigned short ypixel;
      } sixel_winsize;
      int ioctl(int fd, int request, ...);
      int isatty(int fd);
      ssize_t write(int fd, const void *buf, size_t count);
      int poll(sixel_pollfd *fds, nfds_t nfds, int timeout);
    ]]
    )
    has_ffi = ok
    ffi_init_error = ok and nil or tostring(err)
  end
else
  ffi_init_error = tostring(ffi)
end

local defaults = {
  cell_width = nil,
  cell_height = nil,
  fallback_cell_width = 8,
  fallback_cell_height = 16,
  windows_terminal_cell_width = 10,
  windows_terminal_cell_height = 20,
  horizontal_padding = 1,
  vertical_padding = 1,
  initial_render_delay_ms = 150,
  redraw_delay_ms = 80,
  max_render_wait_ms = 300,
  resize_delay_ms = 180,
  write_timeout_ms = 5000,
}

local options = vim.deepcopy(defaults)

local function now_ms()
  return vim.uv.hrtime() / 1000000
end

---Drain a non-blocking file descriptor without losing short writes.
---writer(offset, remaining) returns bytes_written or nil, errno.
---waiter(timeout_ms) returns true when writable, false on a poll timeout,
---or nil, error for a permanent failure.
---@param total number
---@param writer fun(offset: number, remaining: number): number?, number?
---@param waiter fun(timeout_ms: number): boolean?, any?
---@param timeout_ms number
---@param clock? fun(): number
---@return boolean
---@return table
local function drain_writes(total, writer, waiter, timeout_ms, clock)
  clock = clock or now_ms
  local started = clock()
  local offset = 0
  local writes = 0
  local polls = 0

  while offset < total do
    if clock() - started >= timeout_ms then
      return false,
        {
          error = "timeout",
          bytes = offset,
          total = total,
          writes = writes,
          polls = polls,
          elapsed_ms = clock() - started,
        }
    end

    local written, errno = writer(offset, total - offset)
    writes = writes + 1
    if written and written > 0 then
      offset = offset + written
    elseif written == 0 then
      return false,
        {
          error = "zero write",
          bytes = offset,
          total = total,
          writes = writes,
          polls = polls,
          elapsed_ms = clock() - started,
        }
    elseif errno == EINTR then
      -- Interrupted writes are safe to retry immediately.
    elseif errno == EAGAIN then
      local remaining_ms = math.max(1, timeout_ms - (clock() - started))
      polls = polls + 1
      local writable, wait_error = waiter(remaining_ms)
      if writable == nil then
        return false,
          {
            error = "poll failed: " .. tostring(wait_error),
            bytes = offset,
            total = total,
            writes = writes,
            polls = polls,
            elapsed_ms = clock() - started,
          }
      end
      -- false means a bounded poll interval elapsed. The deadline check at
      -- the top of the loop decides whether another wait is still allowed.
    else
      return false,
        {
          error = "write failed",
          errno = errno,
          bytes = offset,
          total = total,
          writes = writes,
          polls = polls,
          elapsed_ms = clock() - started,
        }
    end
  end

  return true,
    {
      bytes = offset,
      total = total,
      writes = writes,
      polls = polls,
      elapsed_ms = clock() - started,
    }
end

---Write binary terminal data to Neovim's non-blocking stderr completely.
---@param data string
---@return boolean
---@return table
local function write_all(data)
  if not has_ffi then
    return false, { error = "LuaJIT FFI is unavailable", bytes = 0, total = #data }
  end

  local POLLOUT = 0x004
  local POLLERR = 0x008
  local POLLHUP = 0x010
  local POLLNVAL = 0x020
  local pointer = ffi.cast("const uint8_t *", data)
  local pollfd = ffi.new "sixel_pollfd[1]"
  pollfd[0].fd = 2
  pollfd[0].events = POLLOUT

  return drain_writes(#data, function(offset, remaining)
    local written = ffi.C.write(2, pointer + offset, remaining)
    if written >= 0 then
      return tonumber(written)
    end
    return nil, ffi.errno()
  end, function(timeout_ms)
    pollfd[0].revents = 0
    local result = ffi.C.poll(pollfd, 1, math.max(1, math.min(100, math.ceil(timeout_ms))))
    if result > 0 then
      local revents = tonumber(pollfd[0].revents)
      if bit.band(revents, bit.bor(POLLERR, POLLHUP, POLLNVAL)) ~= 0 then
        return nil, string.format("terminal fd revents=0x%x", revents)
      end
      return bit.band(revents, POLLOUT) ~= 0
    elseif result == 0 then
      return false, "timeout"
    elseif ffi.errno() == EINTR then
      return false, "interrupted"
    end
    return nil, ffi.errno()
  end, options.write_timeout_ms)
end

local function fit_dimensions(source_width, source_height, max_width, max_height)
  if source_width <= 0 or source_height <= 0 or max_width <= 0 or max_height <= 0 then
    return nil, nil
  end
  local scale = math.min(max_width / source_width, max_height / source_height)
  return math.max(1, math.floor(source_width * scale + 0.5)), math.max(1, math.floor(source_height * scale + 0.5))
end

local function parse_sixel_dimensions(data)
  local width, height = data:match '"%d+;%d+;(%d+);(%d+)'
  return tonumber(width), tonumber(height)
end

local function placement(window_width, window_height, pixel_width, pixel_height, cell_width, cell_height)
  local image_columns = math.max(1, math.ceil(pixel_width / cell_width))
  local image_rows = math.max(1, math.ceil(pixel_height / cell_height))
  return {
    columns = image_columns,
    rows = image_rows,
    column_offset = math.max(0, math.floor((window_width - image_columns) / 2)),
    row_offset = math.max(0, math.floor((window_height - image_rows) / 2)),
  }
end

local function get_cell_size()
  if options.cell_width and options.cell_height then
    return options.cell_width, options.cell_height, "configured"
  end

  if has_ffi then
    local size = ffi.new "sixel_winsize"
    if ffi.C.ioctl(1, 0x5413, size) == 0 and size.xpixel > 0 and size.ypixel > 0 and size.col > 0 and size.row > 0 then
      return tonumber(size.xpixel) / tonumber(size.col), tonumber(size.ypixel) / tonumber(size.row), "ioctl"
    end
  end

  -- Windows Terminal reports xpixel=ypixel=0 through WSL/ConPTY. Its
  -- CSI 16 t response uses 10x20 Sixel pixels per cell for this profile.
  -- Keep these values configurable for users who change terminal fonts.
  if vim.env.WT_SESSION and vim.env.WT_SESSION ~= "" then
    return options.windows_terminal_cell_width, options.windows_terminal_cell_height, "windows-terminal"
  end

  return options.fallback_cell_width, options.fallback_cell_height, "fallback"
end

local function ensure_dcs(data)
  if not data:match "^\27P" and not data:match "^\155" then
    data = "\27P0;1;0q" .. data
  end
  if not data:match "\27\\$" and not data:match "\156$" then
    data = data .. "\27\\"
  end
  return data
end

local function image_source(path)
  if path:lower():match "%.gif$" then
    return path .. "[0]"
  end
  return path
end

local function encode_image(path, max_width, max_height)
  local executable
  local command
  if vim.fn.executable "magick" == 1 then
    executable = "magick"
    command = { executable, image_source(path), "-resize", string.format("%dx%d", max_width, max_height), "sixel:-" }
  elseif vim.fn.executable "convert" == 1 then
    executable = "convert"
    command = { executable, image_source(path), "-resize", string.format("%dx%d", max_width, max_height), "sixel:-" }
  else
    return nil, nil, nil, "ImageMagick is unavailable (need magick or convert)"
  end

  local data = vim.fn.system(command)
  local exit_code = vim.v.shell_error
  if exit_code ~= 0 then
    return nil, nil, nil, string.format("%s exited with code %d: %s", executable, exit_code, vim.trim(data))
  end
  if not data or data == "" then
    return nil, nil, nil, executable .. " produced empty Sixel output"
  end

  local pixel_width, pixel_height = parse_sixel_dimensions(data)
  if not pixel_width or not pixel_height then
    return nil, nil, nil, "ImageMagick output has no Sixel raster dimensions"
  end

  return ensure_dcs(data), pixel_width, pixel_height
end

local function visible_window(buffer)
  local current = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_is_valid(current) and vim.api.nvim_win_get_buf(current) == buffer then
    return current
  end

  for _, window in ipairs(vim.fn.win_findbuf(buffer)) do
    if vim.api.nvim_win_is_valid(window) then
      return window
    end
  end
  return nil
end

local function set_buffer_lines(buffer, lines)
  if not vim.api.nvim_buf_is_valid(buffer) then
    return false
  end
  vim.bo[buffer].readonly = false
  vim.bo[buffer].modifiable = true
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.bo[buffer].modified = false
  vim.bo[buffer].modifiable = false
  vim.bo[buffer].readonly = true
  return true
end

local function configure_buffer(buffer)
  vim.bo[buffer].buftype = "nowrite"
  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].swapfile = false
  vim.bo[buffer].undofile = false
  vim.bo[buffer].filetype = "image_sixel"
  set_buffer_lines(buffer, { "" })
end

local IMAGE_WINDOW_OPTIONS = {
  number = false,
  relativenumber = false,
  signcolumn = "no",
  foldcolumn = "0",
  foldenable = false,
  wrap = false,
  cursorline = false,
  cursorcolumn = false,
  colorcolumn = "",
  statuscolumn = "",
  list = false,
  spell = false,
}

local function apply_window_options(window, snapshot)
  if not vim.api.nvim_win_is_valid(window) then
    return
  end
  for name, value in pairs(snapshot) do
    pcall(function()
      vim.wo[window][name] = value
    end)
  end
end

local function restore_window_options(state, window)
  local snapshot = state.window_options and state.window_options[window]
  if not snapshot then
    return
  end

  if window_owners[window] == state then
    window_owners[window] = nil
    -- Preserve the baseline through the remainder of this buffer transition.
    -- A following image owner consumes it synchronously in M.open(); an
    -- ordinary replacement keeps its own lifecycle changes because this
    -- scheduled callback only discards the transfer record.
    pending_window_options[window] = snapshot
    apply_window_options(window, snapshot)
    vim.schedule(function()
      if window_owners[window] == nil and pending_window_options[window] == snapshot then
        pending_window_options[window] = nil
      end
    end)
  end
  state.window_options[window] = nil
end

local function release_state_windows(state)
  local windows = {}
  for window in pairs(state.window_options or {}) do
    windows[#windows + 1] = window
  end
  for _, window in ipairs(windows) do
    restore_window_options(state, window)
  end
end

local function configure_window(state, window)
  state.window_options = state.window_options or {}
  local owner = window_owners[window]
  if owner and owner ~= state then
    local inherited = owner.window_options and owner.window_options[window]
    if owner.window_options then
      owner.window_options[window] = nil
    end
    state.window_options[window] = inherited or pending_window_options[window]
    pending_window_options[window] = nil
  end

  if not state.window_options[window] then
    if pending_window_options[window] then
      state.window_options[window] = pending_window_options[window]
      pending_window_options[window] = nil
    else
      local snapshot = {}
      for name in pairs(IMAGE_WINDOW_OPTIONS) do
        snapshot[name] = vim.wo[window][name]
      end
      state.window_options[window] = snapshot
    end
  end
  window_owners[window] = state

  for name, value in pairs(IMAGE_WINDOW_OPTIONS) do
    vim.wo[window][name] = value
  end
end

local function terminal_ui_attached()
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.stdout_tty then
      return true
    end
  end
  return false
end

local function terminal_output_available()
  return terminal_ui_attached() and has_ffi and ffi.C.isatty(2) == 1
end

local function show_cursor()
  if terminal_output_available() then
    write_all "\27[?25h"
  end
end

local function clear_terminal_image_layer()
  if not terminal_output_available() or exiting then
    return
  end

  -- Sixel pixels survive normal redraws when Neovim uses a transparent
  -- background. ED2 removes the terminal raster layer; redraw! then rebuilds
  -- Neovim's character grid without clearing a still-visible image on mere
  -- focus changes.
  write_all "\27[2J"
  vim.defer_fn(function()
    if not exiting then
      pcall(vim.cmd, "redraw!")
    end
  end, 20)
end

local function clear_rendered_image(state)
  if not state or not (state.rendered or state.terminal_dirty) then
    return false
  end
  state.rendered = false
  state.terminal_dirty = false
  state.last_screen_row = nil
  state.last_screen_column = nil
  state.last_layout = nil
  clear_terminal_image_layer()
  return true
end

local function adopt_window(state, window)
  if state.window and state.window ~= window then
    restore_window_options(state, state.window)
  end
  state.window = window
  configure_window(state, window)
end

local schedule_refresh
local schedule_render

local function fail_state(state, message)
  clear_rendered_image(state)
  state.ready = false
  state.refreshing = false
  state.error = message
  show_cursor()
  set_buffer_lines(state.buffer, {
    "Image preview failed",
    "",
    message,
    "",
    state.path,
  })
  vim.notify("Sixel image preview: " .. message, vim.log.levels.ERROR)
end

local function render_state(state)
  if states[state.buffer] ~= state or not state.ready or state.refreshing or not terminal_output_available() then
    return
  end

  local window = visible_window(state.buffer)
  if not window then
    return
  end

  local window_width = vim.api.nvim_win_get_width(window)
  local window_height = vim.api.nvim_win_get_height(window)
  if window ~= state.window or window_width ~= state.window_width or window_height ~= state.window_height then
    state.ready = false
    schedule_refresh(state, options.resize_delay_ms)
    return
  end

  local info = vim.fn.getwininfo(window)[1]
  if not info then
    return
  end

  local layout =
    placement(window_width, window_height, state.pixel_width, state.pixel_height, state.cell_width, state.cell_height)
  local screen_row = info.winrow + layout.row_offset
  local screen_column = info.wincol + layout.column_offset
  if state.last_screen_row and (state.last_screen_row ~= screen_row or state.last_screen_column ~= screen_column) then
    clear_rendered_image(state)
    schedule_render(state, options.initial_render_delay_ms)
    return
  end
  local focused = vim.api.nvim_get_current_win() == window
  local hide_cursor = focused and "\27[?25l" or ""
  local sequence = hide_cursor
    .. "\27[s"
    .. string.format("\27[%d;%dH", screen_row, screen_column)
    .. state.sixel
    .. "\27[u"
    .. hide_cursor

  local ok, diagnostics = write_all(sequence)
  state.last_write = diagnostics
  if not ok then
    -- A failed DCS write can leave both the parser and a partial raster dirty.
    -- Close the DCS first, then clear even though this was not a complete render.
    write_all "\27\\\27[u\27[?25h"
    state.terminal_dirty = (diagnostics.bytes or 0) > 0
    clear_rendered_image(state)
    if not state.write_error_reported then
      state.write_error_reported = true
      vim.notify(
        string.format(
          "Sixel write incomplete (%d/%d bytes): %s",
          diagnostics.bytes or 0,
          diagnostics.total or #sequence,
          diagnostics.error or "unknown error"
        ),
        vim.log.levels.ERROR
      )
    end
  else
    state.rendered = true
    state.terminal_dirty = false
    state.last_layout = layout
    state.last_screen_row = screen_row
    state.last_screen_column = screen_column
    state.write_error_reported = false
  end
end

schedule_render = function(state, delay_ms)
  if states[state.buffer] ~= state or not state.ready then
    return
  end

  if not state.render_pending then
    state.render_pending = true
    state.render_cycle = (state.render_cycle or 0) + 1
    local max_wait_cycle = state.render_cycle
    vim.defer_fn(function()
      if states[state.buffer] == state and state.render_pending and state.render_cycle == max_wait_cycle then
        state.render_pending = false
        state.render_token = (state.render_token or 0) + 1
        state.render_cycle = max_wait_cycle + 1
        render_state(state)
      end
    end, options.max_render_wait_ms)
  end

  local cycle = state.render_cycle
  state.render_token = (state.render_token or 0) + 1
  local token = state.render_token
  vim.defer_fn(function()
    if
      states[state.buffer] == state
      and state.render_pending
      and state.render_cycle == cycle
      and state.render_token == token
    then
      state.render_pending = false
      state.render_cycle = cycle + 1
      render_state(state)
    end
  end, delay_ms or options.redraw_delay_ms)
end

local function refresh_state(state, token)
  if states[state.buffer] ~= state or state.refresh_token ~= token or not vim.api.nvim_buf_is_valid(state.buffer) then
    return
  end

  local window = visible_window(state.buffer)
  if not window then
    state.refreshing = false
    return
  end

  state.refreshing = true
  state.ready = false
  local window_width = vim.api.nvim_win_get_width(window)
  local window_height = vim.api.nvim_win_get_height(window)
  adopt_window(state, window)

  local cell_width, cell_height, cell_source = get_cell_size()
  local available_columns = math.max(1, window_width - options.horizontal_padding * 2)
  local available_rows = math.max(1, window_height - options.vertical_padding * 2)
  local max_pixel_width = math.max(1, math.floor(available_columns * cell_width))
  local max_pixel_height = math.max(1, math.floor(available_rows * cell_height))

  local blank_lines = {}
  for _ = 1, math.max(1, window_height) do
    blank_lines[#blank_lines + 1] = ""
  end
  if not set_buffer_lines(state.buffer, blank_lines) then
    state.refreshing = false
    return
  end

  if not terminal_output_available() then
    state.refreshing = false
    state.error = "Sixel preview requires a terminal UI with stderr attached to its TTY"
    set_buffer_lines(state.buffer, { state.error, "", state.path })
    return
  end

  local sixel, pixel_width, pixel_height, encode_error = encode_image(state.path, max_pixel_width, max_pixel_height)
  if not sixel then
    fail_state(state, encode_error)
    return
  end

  if states[state.buffer] ~= state or state.refresh_token ~= token then
    state.refreshing = false
    return
  end

  if state.sixel then
    clear_rendered_image(state)
  end

  state.sixel = sixel
  state.pixel_width = pixel_width
  state.pixel_height = pixel_height
  state.cell_width = cell_width
  state.cell_height = cell_height
  state.cell_source = cell_source
  state.window_width = window_width
  state.window_height = window_height
  state.error = nil
  state.ready = true
  state.refreshing = false

  pcall(vim.cmd, "redraw")
  schedule_render(state, options.initial_render_delay_ms)
end

schedule_refresh = function(state, delay_ms)
  if states[state.buffer] ~= state then
    return
  end
  state.refresh_token = state.refresh_token + 1
  local token = state.refresh_token
  state.ready = false
  vim.defer_fn(function()
    refresh_state(state, token)
  end, delay_ms or 0)
end

local function activate_buffer(buffer)
  local state = states[buffer]
  if not state then
    return
  end
  local window = visible_window(buffer)
  if not window then
    return
  end
  local same_window = state.window == window
  if not same_window then
    state.ready = false
  end
  adopt_window(state, window)
  if
    same_window
    and state.ready
    and state.window_width == vim.api.nvim_win_get_width(window)
    and state.window_height == vim.api.nvim_win_get_height(window)
  then
    schedule_render(state, options.redraw_delay_ms)
  else
    schedule_refresh(state, 20)
  end
end

local function owner_window_is_valid(state)
  return state.window
    and vim.api.nvim_win_is_valid(state.window)
    and vim.api.nvim_win_get_buf(state.window) == state.buffer
end

local function reconcile_buffer_owner(buffer)
  local state = states[buffer]
  if not state or owner_window_is_valid(state) then
    return
  end

  state.ready = false
  state.window = nil
  local window = visible_window(buffer)
  if window then
    adopt_window(state, window)
    schedule_refresh(state, 20)
  end
end

local function service_provider_state(state)
  if states[state.buffer] ~= state then
    return
  end
  if not owner_window_is_valid(state) then
    reconcile_buffer_owner(state.buffer)
  end
  local owner = state.window
  if state.ready and owner_window_is_valid(state) then
    if
      vim.api.nvim_win_get_width(owner) ~= state.window_width
      or vim.api.nvim_win_get_height(owner) ~= state.window_height
    then
      schedule_refresh(state, options.resize_delay_ms)
    else
      schedule_render(state, options.redraw_delay_ms)
    end
  end
end

local function release_buffer_window(buffer)
  local state = states[buffer]
  local window = vim.api.nvim_get_current_win()
  if not state or state.window ~= window then
    return
  end

  state.ready = false
  restore_window_options(state, window)
  state.window = nil
  show_cursor()
  vim.schedule(function()
    reconcile_buffer_owner(buffer)
  end)
end

local function cleanup_buffer(buffer)
  local state = states[buffer]
  if not state then
    return
  end
  state.refresh_token = state.refresh_token + 1
  states[buffer] = nil
  release_state_windows(state)
  show_cursor()
  clear_rendered_image(state)
end

function M.open(buffer, path)
  path = vim.fn.fnamemodify(path, ":p")
  if vim.fn.filereadable(path) ~= 1 then
    vim.notify("Image not found: " .. path, vim.log.levels.ERROR)
    return false
  end

  cleanup_buffer(buffer)
  configure_buffer(buffer)
  local state = {
    buffer = buffer,
    path = path,
    ready = false,
    refreshing = false,
    render_pending = false,
    provider_scheduled = false,
    refresh_token = 0,
  }
  states[buffer] = state
  local window = visible_window(buffer)
  if window then
    adopt_window(state, window)
  end
  schedule_refresh(state, 0)
  return true
end

function M.refresh(buffer)
  buffer = buffer or vim.api.nvim_get_current_buf()
  local state = states[buffer]
  if not state then
    return false
  end
  schedule_refresh(state, 0)
  return true
end

function M.state(buffer)
  return states[buffer or vim.api.nvim_get_current_buf()]
end

function M.setup(opts)
  options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.sixel_image_viewer or {}, opts or {})
  if setup_done then
    return
  end
  setup_done = true

  vim.api.nvim_set_decoration_provider(provider_namespace, {
    on_win = function(_, _window, buffer)
      local state = states[buffer]
      if state and not state.provider_scheduled then
        state.provider_scheduled = true
        vim.schedule(function()
          state.provider_scheduled = false
          service_provider_state(state)
        end)
      end
      return true
    end,
  })

  local patterns = {}
  for _, extension in ipairs(IMAGE_EXTENSIONS) do
    patterns[#patterns + 1] = "*." .. case_insensitive_extension(extension)
  end

  local group = vim.api.nvim_create_augroup("SixelImageViewer", { clear = true })
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = group,
    pattern = patterns,
    callback = function(event)
      M.open(event.buf, event.match)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = group,
    callback = function(event)
      activate_buffer(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    group = group,
    callback = function(event)
      release_buffer_window(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = function(event)
      release_buffer_window(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function(event)
      if states[event.buf] then
        show_cursor()
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(event)
      cleanup_buffer(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group,
    callback = function()
      for _, state in pairs(states) do
        schedule_refresh(state, options.resize_delay_ms)
      end
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      local state = states[vim.api.nvim_get_current_buf()]
      if state then
        schedule_render(state, options.redraw_delay_ms)
      end
    end,
  })
  vim.api.nvim_create_autocmd("ExitPre", {
    group = group,
    callback = function()
      exiting = true
      show_cursor()
    end,
  })

  vim.api.nvim_create_user_command("SixelImageRefresh", function()
    if not M.refresh() then
      vim.notify("Current buffer is not a Sixel image", vim.log.levels.WARN)
    end
  end, {})
end

function M._ffi_status()
  return has_ffi, ffi_init_error
end

M._drain_writes = drain_writes
M._clear_rendered_image = clear_rendered_image
M._extension_pattern = case_insensitive_extension
M._fit_dimensions = fit_dimensions
M._parse_sixel_dimensions = parse_sixel_dimensions
M._placement = placement
M._service_provider_state = service_provider_state
M._terminal_output_available = terminal_output_available
M._write_all = write_all

return M
