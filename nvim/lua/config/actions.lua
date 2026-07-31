local M = {}

local actions = {}
local groups = {
  { id = "group.git", lhs = "<space>g", group = "Git" },
  { id = "group.misc", lhs = "<space>a", group = "Misc" },
  { id = "group.switch", lhs = "<space>c", group = "Switch h/c" },
  { id = "group.find", lhs = "<space>f", group = "Find" },
  { id = "group.language", lhs = "<space>l", group = "Language" },
  { id = "group.rename", lhs = "<space>r", group = "Rename" },
  { id = "group.search", lhs = "<space>s", group = "Search" },
  { id = "group.multicursor", lhs = "<space>x", group = "Multiple cursors" },
  { id = "group.toggle", lhs = "<space>t", group = "Toggle/Theme" },
}

local allowed_owners = {
  multicursor = true,
  grug_far = true,
  flash = true,
  goto_preview = true,
  snacks = true,
  spider = true,
  telescope = true,
  toggleterm = true,
  treesitter_textobjects = true,
}

local function add(id, spec)
  assert(actions[id] == nil, "duplicate action id: " .. id)
  spec.id = id
  spec.scope = spec.scope or "global"
  spec.mode = spec.mode or "n"
  actions[id] = spec
end

local function command(value)
  return "<cmd>" .. value .. "<cr>"
end

local function modes(value)
  if type(value) == "table" then
    return value
  end
  if value == "v" then
    return { "x", "s" }
  end
  return { value }
end

local function url_encode(text)
  return (text:gsub("[^%w%-._~]", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function is_openable(target)
  if target:match "^[%a][%w+.-]*:" or target:match "^[/~]" or target:match "^%.?%./" then
    return true
  end
  local path = vim.fn.expand(target)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

local function open_or_search(target)
  target = vim.trim(target)
  if target == "" then
    return
  end
  if not is_openable(target) then
    target = "https://google.com/search?q=" .. url_encode(target)
  end
  local _, err = vim.ui.open(target)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

local function close_current_buffer()
  vim.cmd "wall"
  local buf = vim.api.nvim_get_current_buf()
  Snacks.bufdelete.delete { buf = buf, force = vim.bo[buf].buftype == "terminal" }
end

local function close_hidden_buffers()
  Snacks.bufdelete.invisible()
end

local function add_command(id, lhs, rhs, desc, mode, options)
  add(
    id,
    vim.tbl_extend("force", {
      lhs = lhs,
      rhs = rhs,
      desc = desc,
      mode = mode or "n",
    }, options or {})
  )
end

add_command("window.split_horizontal", "\\", ":split<CR>", "Horizontal split")
add_command("window.split_vertical", "|", ":vsplit<CR>", "Vertical split")
add_command("window.next", "<C-l>", command "wincmd w", "Switch to next window")
add_command("window.previous", "<C-h>", command "wincmd W", "Switch to prev window")
add_command("window.below", "<C-j>", "<C-w>j", "Switch to window below")
add_command("window.above", "<C-k>", "<C-w>k", "Switch to window above")

add_command("buffer.previous_alt", "<M-Left>", ":BufferLineCyclePrev<CR>", "Previous buffer")
add_command("buffer.next_alt", "<M-Right>", ":BufferLineCycleNext<CR>", "Next buffer")
add_command("buffer.previous", "<A-j>", ":BufferLineCyclePrev<CR>", "Previous buffer")
add_command("buffer.next", "<A-k>", ":BufferLineCycleNext<CR>", "Next buffer")
for index = 1, 9 do
  add_command(
    "buffer.goto_" .. index,
    "<A-" .. index .. ">",
    ":BufferLineGoToBuffer " .. index .. "<CR>",
    "Go to buffer " .. index
  )
end
add_command("buffer.pin", "<A-p>", ":BufferLineTogglePin<CR>", "Pin buffer")
add_command("buffer.close_right", "<A-d>", ":BufferLineCloseRight<CR>", "Close buffers to right")
add_command("buffer.move_left", "<A-i>", ":BufferLineMovePrev<CR>", "Move buffer left")
add_command("buffer.move_right", "<A-o>", ":BufferLineMoveNext<CR>", "Move buffer right")
add_command("buffer.first", "<M-Home>", ":BufferLineGoToBuffer 1<CR>", "Go to first buffer")
add_command("buffer.last", "<M-End>", ":BufferLineGoToBuffer 1000<CR>", "Go to last buffer")

add_command("edit.copy_normal", "<C-c>", '"+y', "Copy to clipboard")
add_command("edit.copy_visual", "<C-c>", '"+y', "Copy to clipboard", "v")
add_command("edit.cut_normal", "<C-x>", '"+x', "Cut to clipboard")
add_command("edit.cut_visual", "<C-x>", '"+x', "Cut to clipboard", "v")
add_command("edit.cut_insert", "<C-x>", "<C-o>dd", "Cut line", "i")
add_command("edit.save_normal", "<C-s>", ":wall<CR>", "Save all")
add_command("edit.save_insert", "<C-s>", "<C-o>:wall<CR>", "Save all", "i")
add_command("edit.select_all_normal", "<C-a>", "ggVG", "Select all")
add_command("edit.select_all_insert", "<C-a>", "<Esc>ggVG", "Select all", "i")
add_command("edit.duplicate_visual", "<C-d>", 'y<Esc>o<C-R>"<CR>', "Duplicate selection", "v")
add_command("edit.duplicate_insert", "<C-d>", "<Esc>:normal! yy<CR>p`[A", "Duplicate line", "i")
add_command("edit.undo_insert", "<C-z>", "<C-O>u", "Undo", "i")
add_command("edit.undo_normal", "<C-z>", "<C-O>u", "Undo")
add_command("edit.delete_visual", "<BS>", '"_d', "Delete selection", "v")
add_command("config.reload_normal", "<F5>", ":source $MYVIMRC<CR>", "Reload config")
add_command("config.reload_insert", "<F5>", "<C-O>:source $MYVIMRC<CR>", "Reload config", "i")

add("open.word", {
  lhs = "gx",
  desc = "Open URL/file or search word",
  run = function()
    local target = require("vim.ui")._get_urls()[1] or vim.fn.expand "<cword>"
    open_or_search(is_openable(target) and target or vim.fn.expand "<cword>")
  end,
})
add("open.selection", {
  lhs = "gx",
  mode = "x",
  desc = "Open URL/file or search selection",
  run = function()
    local lines = vim.fn.getregion(vim.fn.getpos ".", vim.fn.getpos "v", { type = vim.fn.mode() })
    open_or_search(table.concat(vim.iter(lines):map(vim.trim):totable(), " "))
  end,
})

for _, direction in ipairs { "Up", "Down", "Left", "Right" } do
  add_command("select.normal_" .. direction:lower(), "<S-" .. direction .. ">", "<Esc>v<" .. direction .. ">", nil, "n")
  add_command("select.visual_" .. direction:lower(), "<S-" .. direction .. ">", "<" .. direction .. ">", nil, "v")
end
actions["select.normal_down"].rhs = "<Esc>v<Down>"
add_command("select.insert_up", "<S-Up>", "<Esc>v<Up>", nil, "i")
add_command("select.insert_down", "<S-Down>", "<Esc>lv<Down>", nil, "i")
add_command("select.insert_left", "<S-Left>", "<Esc>v<Left>", nil, "i")
add_command("select.insert_right", "<S-Right>", "<Esc>lv<Right>", nil, "i")

add_command("motion.display_down", "j", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'", nil, "n", { expr = true })
add_command("motion.display_up", "k", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'", nil, "n", { expr = true })
add_command(
  "motion.arrow_down",
  "<Down>",
  "v:count == 0 && mode(1)[0:1] != 'no' ? 'gj' : 'j'",
  nil,
  "n",
  { expr = true }
)
add_command("motion.arrow_up", "<Up>", "v:count == 0 && mode(1)[0:1] != 'no' ? 'gk' : 'k'", nil, "n", { expr = true })
add_command("edit.indent", ">", ">>", "Indent right")
add_command("edit.unindent", "<", "<<", "Indent left")
add_command("motion.jump_back", "<C-o>", "<C-o>zz", "Jump back (centered)")
add_command("motion.jump_forward", "<C-i>", "<C-i>zz", "Jump forward (centered)")
add_command("motion.scroll_down", "<C-e>", "3<C-e>", "Scroll down")
add_command("motion.scroll_up", "<C-y>", "3<C-y>", "Scroll up")
add_command("search.clear", "<Esc>", ":noh<CR>", "Clear search highlight")
add_command("edit.visual_block", "<C-M>", "<C-V>", "Visual block mode")
add_command("edit.delete_char", "xx", "x", "Delete char (original x)")
add_command("window.close_normal", "q", command "q", "Close window")
add_command("window.close_visual", "q", command "q", "Close window", "v")
add_command("app.quit", "<space>q", command "qa", "Close nvim")
add("buffer.close", { lhs = "<C-w>", desc = "Close buffer", run = close_current_buffer })
add("buffer.close_hidden_normal", { lhs = "<A-x>", desc = "Close hidden buffers", run = close_hidden_buffers })
add(
  "buffer.close_hidden_insert",
  { lhs = "<A-x>", mode = "i", desc = "Close hidden buffers", run = close_hidden_buffers }
)
add_command("lsp.restart_clangd", "<Space>rs", ":LspRestart clangd<CR>", "Restart clangd")

add_command("tree.toggle", "<C-n>", command "NvimTreeToggle", "Toggle file tree")
add_command("diagnostics.workspace", "gw", command "Telescope diagnostics", "Diagnostics")
add_command("git.blame", "<space>gb", command "Gitsigns blame_line --full", "Blame current line")
add_command("git.blame_toggle", "<space>gB", command "Gitsigns toggle_current_line_blame", "Toggle line blame")
add_command("misc.trim_whitespace", "<space>ad", command "call TrimWhitespace()", "Remove trailing space")
add_command("switch.current", "<space>cc", command "Ouroboros", "Open file in current window")
add_command("switch.horizontal", "<space>ch", command "split | Ouroboros", "Open file in horizontal split")
add_command("switch.vertical", "<space>cv", command "vsplit | Ouroboros", "Open file in vertical split")
add_command("find.tree", "<space>fo", command "NvimTreeFindFile", "Open file in dir")
add_command("find.buffers", "<space>fb", command "Telescope buffers", "Search buffers")
add_command("find.files", "<space>ff", command "Telescope find_files", "Search files (include submodules)")
add_command("find.git_files", "<space>fF", command "Telescope git_files", "Search files (exclude gitignore)")
add_command("find.live_grep", "<space>fw", command "Telescope live_grep", "Search string")
add_command("find.cursor", "<space>fc", command "Telescope grep_string", "Search word under cursor")
add_command("find.help", "<space>fv", command "Telescope help_tags", "Search vim manual")
add_command("find.jumps", "<space>fj", command "Telescope jumplist", "Search jumplist")
add_command("find.symbols", "<space>fs", command "Telescope lsp_dynamic_workspace_symbols", "Search symbols in project")
add("find.grep_extension", {
  lhs = "<space>fg",
  desc = "Live grep with extension filter",
  run = function()
    local extension = vim.fn.input "Enter file extension(s) (e.g. lua,py): "
    local glob_args = {}
    if extension ~= "" then
      for match in extension:gmatch "[^,%s]+" do
        vim.list_extend(glob_args, { "--glob", "*." .. match })
      end
    end
    require("telescope.builtin").live_grep {
      additional_args = function()
        return glob_args
      end,
    }
  end,
})
add("markdown.read", {
  lhs = "<space>md",
  desc = "Markdown reading mode",
  run = function()
    require("config.markdown_preview").toggle()
  end,
})
add_command("markdown.paste_image", "<space>mp", command "PasteImage", "Paste image in md")
add_command("outline.toggle", "<space>ot", command "AerialToggle!", "Code outline")
add_command("lsp.code_action", "<space>la", command "lua vim.lsp.buf.code_action()", "Code action")
add("language.format", {
  lhs = "<space>lf",
  desc = "Format current buffer",
  run = function()
    require("conform").format { async = true, lsp_format = "fallback" }
  end,
})
add_command(
  "diagnostics.next",
  "<space>lj",
  command "lua vim.diagnostic.jump({ count = 1, bufnr = 0 })",
  "LSP goto next"
)
add_command(
  "diagnostics.previous",
  "<space>lk",
  command "lua vim.diagnostic.jump({ count = -1, bufnr = 0 })",
  "LSP goto prev"
)
add_command("lsp.rename", "<space>ln", command "lua vim.lsp.buf.rename()", "Rename")
add_command("lsp.signature", "<space>ls", command "lua vim.lsp.buf.signature_help()", "Signature help")
add_command("diagnostics.loclist", "<space>lq", command "lua vim.diagnostic.setloclist()", "Set loc list")
add("rename.incremental", {
  lhs = "<space>rn",
  desc = "Rename sign",
  expr = true,
  replace_keycodes = false,
  run = function()
    return ":IncRename " .. vim.fn.expand "<cword>"
  end,
})
add_command("search.buffer", "<space>sb", command "Telescope current_buffer_fuzzy_find", "Search in current buffer")
add_command("search.git_status", "<space>sg", command "Telescope git_status", "Search git status")
add_command("toggle.column_75", "<space>t7", command "let &cc = &cc == '' ? '75' : ''", "Highlight 75 line")
add_command("toggle.column_80", "<space>t8", command "let &cc = &cc == '' ? '81' : ''", "Highlight 80 line")
add_command("toggle.text_width", "<space>tb", command "let &tw = &tw == '0' ? '80' : '0'", "Auto break line at 80")
add("theme.search", {
  lhs = "<space>th",
  desc = "Search theme",
  run = function()
    require("telescope.builtin").colorscheme { enable_preview = true }
  end,
})
add_command("toggle.spell", "<space>ts", command "set spell!", "Spell check")
add_command("toggle.wrap", "<space>tw", command "set wrap!", "Wrap line")
add_command(
  "toggle.transparent",
  "<space>tt",
  "<cmd>set nocursorline<cr><cmd>TransparentToggle<cr>",
  "Make background transparent"
)
add("lsp.declaration", { lhs = "gD", scope = "lsp", desc = "Go to declaration", run = vim.lsp.buf.declaration })
add("lsp.definition", { lhs = "gd", scope = "lsp", desc = "Go to definition", run = vim.lsp.buf.definition })
add("lsp.hover", { lhs = "K", scope = "lsp", desc = "Document", run = vim.lsp.buf.hover })
add(
  "lsp.implementation",
  { lhs = "gi", scope = "lsp", desc = "Go to implementation", run = vim.lsp.buf.implementation }
)
add("lsp.signature_help", { lhs = "<C-k>", scope = "lsp", desc = "Signature help", run = vim.lsp.buf.signature_help })
add("lsp.references", {
  lhs = "gr",
  scope = "lsp",
  desc = "Go to reference",
  run = function()
    require("telescope.builtin").lsp_references { include_declaration = false, show_line = true, trim_text = true }
  end,
})
add("lsp.diagnostic_previous", {
  lhs = "[d",
  scope = "lsp",
  desc = "Previous diagnostic",
  run = function()
    vim.diagnostic.jump { count = -1, float = true }
  end,
})
add("lsp.diagnostic_next", {
  lhs = "]d",
  scope = "lsp",
  desc = "Next diagnostic",
  run = function()
    vim.diagnostic.jump { count = 1, float = true }
  end,
})

local function lazy(id, owner, lhs, mode, desc, run)
  add(id, { lazy_owner = owner, lhs = lhs, mode = mode or "n", desc = desc, run = run })
end

lazy("multicursor.next", "multicursor", "gb", { "n", "x" }, "Add cursor at next match", function()
  require("multicursor-nvim").matchAddCursor(1)
end)
lazy("multicursor.previous", "multicursor", "gB", { "n", "x" }, "Add cursor at previous match", function()
  require("multicursor-nvim").matchAddCursor(-1)
end)
lazy("multicursor.below", "multicursor", "<space>xj", { "n", "x" }, "Add cursor below", function()
  require("multicursor-nvim").lineAddCursor(1)
end)
lazy("multicursor.above", "multicursor", "<space>xk", { "n", "x" }, "Add cursor above", function()
  require("multicursor-nvim").lineAddCursor(-1)
end)
lazy("multicursor.all", "multicursor", "<space>xa", { "n", "x" }, "Add cursors at all matches", function()
  require("multicursor-nvim").matchAllAddCursors()
end)
lazy("multicursor.align", "multicursor", "<space>x=", "n", "Align cursor columns", function()
  require("multicursor-nvim").alignCursors()
end)
lazy("multicursor.split", "multicursor", "<space>xs", "x", "Split selections by regex", function()
  require("multicursor-nvim").splitCursors()
end)
lazy("multicursor.transpose", "multicursor", "<space>xt", "x", "Transpose cursor selections", function()
  require("multicursor-nvim").transposeCursors(1)
end)
lazy("multicursor.restore", "multicursor", "<space>xr", "n", "Restore cleared cursors", function()
  require("multicursor-nvim").restoreCursors()
end)
lazy("grug.open", "grug_far", "<space>sp", "n", "Search and replace", function()
  require("grug-far").open()
end)
lazy("grug.cursor", "grug_far", "<space>sP", "n", "Search and replace cursor word", function()
  require("grug-far").open { prefills = { search = vim.fn.expand "<cword>" } }
end)
lazy("grug.selection", "grug_far", "<space>sp", "x", "Search and replace selection", function()
  require("grug-far").open()
end)
lazy("flash.jump", "flash", "s", { "n", "x", "o" }, "Flash", function()
  require("flash").jump()
end)
lazy("flash.treesitter", "flash", "S", { "n", "x", "o" }, "Flash Treesitter", function()
  require("flash").treesitter()
end)
lazy("snacks.lazygit", "snacks", "g=", "n", "Open Lazygit", function()
  Snacks.lazygit()
end)
lazy("spider.word", "spider", "w", { "n", "o", "x" }, "Spider-w", function()
  require("spider").motion "w"
end)
lazy("spider.end_word", "spider", "e", { "n", "o", "x" }, "Spider-e", function()
  require("spider").motion "e"
end)
lazy("spider.back_word", "spider", "b", { "n", "o", "x" }, "Spider-b", function()
  require("spider").motion "b"
end)

lazy("goto_preview.definition", "goto_preview", "gpd", "n", "Preview definition", function()
  require("goto-preview").goto_preview_definition()
end)
lazy("goto_preview.type_definition", "goto_preview", "gpt", "n", "Preview type definition", function()
  require("goto-preview").goto_preview_type_definition()
end)
lazy("goto_preview.implementation", "goto_preview", "gpi", "n", "Preview implementation", function()
  require("goto-preview").goto_preview_implementation()
end)
lazy("goto_preview.declaration", "goto_preview", "gpD", "n", "Preview declaration", function()
  require("goto-preview").goto_preview_declaration()
end)
lazy("goto_preview.references", "goto_preview", "gpr", "n", "Preview references", function()
  require("goto-preview").goto_preview_references()
end)
lazy("goto_preview.close", "goto_preview", "gP", "n", "Close preview windows", function()
  require("goto-preview").close_all_win()
end)

local terminal_manager = require "config.terminal_manager"
lazy("terminal.float", "toggleterm", "<C-p>", { "n", "t" }, "Toggle floating terminal", function()
  terminal_manager.toggle "float"
end)
lazy(
  "terminal.new",
  "toggleterm",
  "<C-q>",
  { "n", "t" },
  "New terminal in current layout",
  terminal_manager.new_terminal
)
lazy("terminal.previous", "toggleterm", "<C-left>", { "n", "t" }, "Previous terminal in current layout", function()
  terminal_manager.cycle(-1)
end)
lazy("terminal.next", "toggleterm", "<C-right>", { "n", "t" }, "Next terminal in current layout", function()
  terminal_manager.cycle(1)
end)
lazy(
  "terminal.select",
  "toggleterm",
  "<C-up>",
  { "n", "t" },
  "Select terminal in current layout",
  terminal_manager.select_terminal
)
lazy("terminal.horizontal", "toggleterm", "-", "n", "Toggle horizontal terminal", function()
  terminal_manager.toggle "horizontal"
end)
lazy("terminal.vertical", "toggleterm", "=", "n", "Toggle vertical terminal", function()
  terminal_manager.toggle "vertical"
end)

function M.validate()
  local seen = {}
  for id, action in pairs(actions) do
    assert(type(id) == "string" and id ~= "", "action id must be a non-empty string")
    assert(type(action.lhs) == "string" and action.lhs ~= "", "action lhs is required: " .. id)
    assert(action.scope == "global" or action.scope == "lsp", "unknown action scope: " .. tostring(action.scope))
    assert(action.run ~= nil or action.rhs ~= nil, "action execution is required: " .. id)
    if action.lazy_owner then
      assert(allowed_owners[action.lazy_owner], "unknown lazy owner: " .. tostring(action.lazy_owner))
      assert(action.scope == "global", "lazy actions must be global: " .. id)
    end
    for _, mode in ipairs(modes(action.mode)) do
      local key = table.concat({ action.scope, mode, vim.keycode(action.lhs) }, "\0")
      assert(not seen[key], string.format("action conflict: %s and %s", seen[key] or "?", id))
      seen[key] = id
    end
  end
  return true
end

local function mapping_options(action, context)
  return {
    buffer = context and context.bufnr or nil,
    desc = action.desc,
    expr = action.expr,
    noremap = action.noremap ~= false,
    nowait = action.nowait,
    replace_keycodes = action.replace_keycodes,
    silent = action.silent ~= false,
  }
end

function M.install(scope, context)
  M.validate()
  if scope == "which-key" then
    assert(context and context.wk, "which-key context is required")
    local specs = {}
    for _, group in ipairs(groups) do
      specs[#specs + 1] = { group.lhs, group = group.group }
    end
    context.wk.add(specs)
    return
  end

  assert(scope == "global" or scope == "lsp", "unsupported action install scope: " .. tostring(scope))
  for _, action in pairs(actions) do
    if action.scope == scope and not action.lazy_owner then
      local execution = action.run or action.rhs
      vim.keymap.set(action.mode, action.lhs, execution, mapping_options(action, context))
    end
  end
end

function M.lazy_keys(owner)
  M.validate()
  assert(allowed_owners[owner], "unknown lazy owner: " .. tostring(owner))
  local result = {}
  for _, action in pairs(actions) do
    if action.lazy_owner == owner then
      result[#result + 1] = {
        action.lhs,
        action.run or action.rhs,
        mode = action.mode,
        desc = action.desc,
        expr = action.expr,
        noremap = action.noremap,
        nowait = action.nowait,
        silent = action.silent,
      }
    end
  end
  table.sort(result, function(left, right)
    local left_mode = type(left.mode) == "table" and table.concat(left.mode) or left.mode or "n"
    local right_mode = type(right.mode) == "table" and table.concat(right.mode) or right.mode or "n"
    return left_mode .. left[1] < right_mode .. right[1]
  end)
  return result
end

function M.catalog()
  return vim.deepcopy(actions)
end

return M
