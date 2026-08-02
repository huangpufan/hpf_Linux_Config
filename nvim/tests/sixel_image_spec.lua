local function assert_equal(actual, expected, message)
  if not vim.deep_equal(actual, expected) then
    error(string.format("%s: expected %s, got %s", message, vim.inspect(expected), vim.inspect(actual)))
  end
end

local viewer = require "config.sixel_image"

local ffi_ok, ffi_error = viewer._ffi_status()
assert(ffi_ok, "Sixel FFI should initialize: " .. tostring(ffi_error))
assert_equal(viewer._extension_pattern "PnG", "[pP][nN][gG]", "mixed-case extension pattern")

-- A generic struct pollfd may already be declared by another LuaJIT module.
-- Load the viewer in an isolated Neovim after predeclaring that tag to prove
-- its module-specific FFI types do not collide with load order.
do
  local config_root = vim.fn.stdpath "config"
  local fixture = vim.fs.joinpath(config_root, "tests", "sixel_ffi_collision_check.lua")
  local result = vim
    .system({
      vim.v.progpath,
      "--headless",
      "-u",
      "NONE",
      "--cmd",
      "set runtimepath^=" .. vim.fn.fnameescape(config_root),
      "+luafile " .. vim.fn.fnameescape(fixture),
    }, { text = true })
    :wait(10000)
  assert_equal(result.code, 0, "isolated FFI collision check: " .. tostring(result.stderr))
  local child_output = (result.stdout or "") .. (result.stderr or "")
  assert(child_output:find("sixel_ffi_collision_check: ok", 1, true), "isolated FFI check should execute")
end

local width, height = viewer._fit_dimensions(320, 360, 1410, 820)
assert_equal({ width, height }, { 729, 820 }, "portrait fit should preserve aspect ratio")
assert_equal(
  { viewer._fit_dimensions(1792, 1024, 1410, 820) },
  { 1410, 806 },
  "landscape fit should preserve aspect ratio"
)

local parsed_width, parsed_height = viewer._parse_sixel_dimensions '\27P0;0;0q"1;1;729;820#0;2;0;0;0\27\\'
assert_equal({ parsed_width, parsed_height }, { 729, 820 }, "Sixel raster dimensions")
assert_equal({ viewer._parse_sixel_dimensions "not sixel" }, {}, "invalid Sixel should not invent dimensions")

assert_equal(viewer._placement(143, 43, 729, 820, 10, 20), {
  columns = 73,
  rows = 41,
  column_offset = 35,
  row_offset = 1,
}, "image placement should center the fitted raster")

local old_footprint = viewer._placement(100, 40, 100, 200, 10, 20)
local smaller_footprint = viewer._placement(100, 40, 90, 200, 10, 20)
assert_equal(old_footprint.column_offset, smaller_footprint.column_offset, "a smaller payload can keep the same origin")
assert(old_footprint.columns ~= smaller_footprint.columns, "same-origin replacement can still leave stale edge pixels")

do
  local unrendered = {
    sixel = "encoded but never sent",
    rendered = false,
    last_screen_row = 3,
    last_screen_column = 10,
    last_layout = { columns = 10, rows = 10 },
  }
  assert(not viewer._clear_rendered_image(unrendered), "encoded-only state must not clear the terminal UI")
  assert_equal(unrendered.last_screen_row, 3, "unrendered state should retain placement metadata")

  local dirty = {
    rendered = false,
    terminal_dirty = true,
    last_screen_row = 3,
    last_screen_column = 10,
    last_layout = { columns = 10, rows = 10 },
  }
  assert(viewer._clear_rendered_image(dirty), "a partial failed write should clear its dirty terminal layer")
  assert_equal(dirty.terminal_dirty, false, "dirty clear should reset terminal state")
  assert_equal(dirty.last_screen_row, nil, "dirty clear should reset partial placement")

  unrendered.rendered = true
  assert(viewer._clear_rendered_image(unrendered), "a successfully rendered payload should be clearable")
  assert_equal(unrendered.rendered, false, "clear should reset rendered state")
  assert_equal(unrendered.last_screen_row, nil, "clear should reset rendered placement")
  assert_equal(unrendered.last_layout, nil, "clear should reset rendered footprint")
end

-- Regression for Neovim/libuv marking stderr O_NONBLOCK. The original viewer
-- made one 13,476-byte write; the pty accepted 11,776 bytes and silently lost
-- the remaining 1,700 bytes. The loop must retain the offset across EAGAIN.
do
  local now = 0
  local calls = 0
  local waits = 0
  local ok, diagnostics = viewer._drain_writes(
    13476,
    function(offset, remaining)
      calls = calls + 1
      if calls == 1 then
        assert_equal({ offset, remaining }, { 0, 13476 }, "first write range")
        return 11776
      elseif calls == 2 then
        assert_equal({ offset, remaining }, { 11776, 1700 }, "retry range after short write")
        return nil, 11
      end
      assert_equal({ offset, remaining }, { 11776, 1700 }, "final write range after EAGAIN")
      return 1700
    end,
    function()
      waits = waits + 1
      now = now + 1
      return true
    end,
    1000,
    function()
      return now
    end
  )

  assert(ok, "short-write drain should succeed")
  assert_equal(diagnostics.bytes, 13476, "all bytes should be written")
  assert_equal(diagnostics.writes, 3, "write attempt count")
  assert_equal(diagnostics.polls, 1, "EAGAIN should poll once")
  assert_equal(waits, 1, "writable waiter count")
end

do
  local now = 0
  local ok, diagnostics = viewer._drain_writes(
    100,
    function()
      return nil, 11
    end,
    function()
      now = now + 60
      return false, "timeout"
    end,
    100,
    function()
      return now
    end
  )

  assert(not ok, "permanent backpressure should time out")
  assert_equal(diagnostics.error, "timeout", "timeout error")
  assert_equal(diagnostics.bytes, 0, "timeout must not claim unwritten bytes")
end

do
  local ok, diagnostics = viewer._drain_writes(
    100,
    function()
      return nil, 5
    end,
    function()
      error "hard write errors must not poll"
    end,
    100,
    function()
      return 0
    end
  )

  assert(not ok, "hard write error should fail")
  assert_equal(diagnostics.error, "write failed", "hard write error label")
  assert_equal(diagnostics.errno, 5, "hard write errno")
end

do
  local window = vim.api.nvim_get_current_win()
  vim.wo[window].number = true
  vim.wo[window].wrap = false
  vim.wo[window].foldenable = true
  local expected = {
    number = vim.wo[window].number,
    wrap = vim.wo[window].wrap,
    foldenable = vim.wo[window].foldenable,
  }

  local path = vim.fn.tempname() .. ".PnG"
  vim.fn.writefile({ "headless image fixture" }, path, "b")
  vim.cmd.edit(vim.fn.fnameescape(path))
  local image_buffer = vim.api.nvim_get_current_buf()
  assert(
    vim.wait(1000, function()
      local state = viewer.state(image_buffer)
      return state and not state.refreshing and state.error ~= nil
    end, 10),
    "headless image state should settle without encoding"
  )
  assert(not viewer._terminal_output_available(), "headless Neovim must not target stderr with Sixel")
  assert_equal(vim.bo.filetype, "image_sixel", "mixed-case image extension should be intercepted")
  assert_equal(vim.wo.number, false, "image window number option")
  assert_equal(vim.wo.wrap, false, "image window wrap option")

  -- Replacing one image with another can happen before the deferred restore
  -- from the first BufWipeout runs. The second owner must inherit the original
  -- baseline instead of snapshotting image-viewer options.
  local second_path = vim.fn.tempname() .. ".JpG"
  vim.fn.writefile({ "second headless image fixture" }, second_path, "b")
  vim.cmd.edit(vim.fn.fnameescape(second_path))
  local second_image_buffer = vim.api.nvim_get_current_buf()
  assert(
    vim.wait(1000, function()
      local state = viewer.state(second_image_buffer)
      return state and not state.refreshing and state.error ~= nil and viewer.state(image_buffer) == nil
    end, 10),
    "second image should take ownership without losing the original option snapshot"
  )
  image_buffer = second_image_buffer

  local replacement_group = vim.api.nvim_create_augroup("SixelImageReplacementOptionTest", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = replacement_group,
    once = true,
    callback = function()
      vim.wo.wrap = true
    end,
  })
  local expected_after_replacement = vim.deepcopy(expected)
  expected_after_replacement.wrap = true

  vim.cmd.enew()
  assert(
    vim.wait(1000, function()
      return viewer.state(image_buffer) == nil
        and vim.wo.number == expected_after_replacement.number
        and vim.wo.wrap == expected_after_replacement.wrap
        and vim.wo.foldenable == expected_after_replacement.foldenable
    end, 10),
    "wiped image buffer should release viewer state"
  )
  assert_equal({
    number = vim.wo.number,
    wrap = vim.wo.wrap,
    foldenable = vim.wo.foldenable,
  }, expected_after_replacement, "ordinary buffer should keep replacement lifecycle options")
  vim.fn.delete(path)
  vim.fn.delete(second_path)
end

do
  local path = vim.fn.tempname() .. ".PnG"
  vim.fn.writefile({ "duplicate-window image fixture" }, path, "b")
  vim.cmd.edit(vim.fn.fnameescape(path))
  local image_buffer = vim.api.nvim_get_current_buf()
  assert(
    vim.wait(1000, function()
      local state = viewer.state(image_buffer)
      return state and not state.refreshing and state.error ~= nil
    end, 10),
    "duplicate-window image should initialize"
  )

  local first_window = vim.api.nvim_get_current_win()
  vim.cmd.vsplit()
  local second_window = vim.api.nvim_get_current_win()
  assert(first_window ~= second_window, "vsplit should create a second image window")
  assert(
    vim.wait(1000, function()
      local state = viewer.state(image_buffer)
      return state and state.window == second_window and not state.refreshing
    end, 10),
    "focused duplicate should become the active image owner"
  )

  local owner_state = viewer.state(image_buffer)
  owner_state.ready = true
  owner_state.window_width = vim.api.nvim_win_get_width(second_window)
  owner_state.window_height = vim.api.nvim_win_get_height(second_window)
  local render_token = owner_state.render_token or 0
  viewer._service_provider_state(owner_state)
  assert(
    (owner_state.render_token or 0) > render_token,
    "coalesced provider work should always target the active owner"
  )
  assert(
    vim.wait(1000, function()
      return not owner_state.render_pending
    end, 10),
    "provider render cycle should settle"
  )

  vim.cmd.enew()
  assert(
    vim.wait(1000, function()
      local state = viewer.state(image_buffer)
      return state
        and state.window == first_window
        and vim.api.nvim_win_is_valid(first_window)
        and vim.api.nvim_win_get_buf(first_window) == image_buffer
        and not state.refreshing
    end, 10),
    "remaining duplicate should automatically become the active image owner"
  )

  vim.api.nvim_set_current_win(first_window)
  vim.cmd.enew()
  assert(
    vim.wait(1000, function()
      return viewer.state(image_buffer) == nil
    end, 10),
    "last duplicate removal should clean viewer state"
  )
  if vim.api.nvim_win_is_valid(second_window) then
    vim.api.nvim_win_close(second_window, true)
  end
  vim.fn.delete(path)
end

print "sixel_image_spec: ok"
vim.cmd "qa!"
