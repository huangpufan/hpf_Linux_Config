-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  vim.keymap.set("n", "<CR>", api.node.open.edit, opts "Open")
  vim.keymap.set("n", "o", api.node.open.edit, opts "Open")
  vim.keymap.set("n", "l", api.node.open.edit, opts "Open")
  vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts "Open")
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
  vim.keymap.set("n", "p", api.node.open.preview, opts "Open Preview")
  vim.keymap.set("n", "<C-r>", api.tree.reload, opts "Refresh")
  vim.keymap.set("n", "yn", api.fs.copy.filename, opts "Copy Name")
  vim.keymap.set("n", "yp", api.fs.copy.relative_path, opts "Copy Relative Path")
  vim.keymap.set("n", "yy", api.fs.copy.absolute_path, opts "Copy Absolute Path")
  vim.keymap.set("n", "a", api.fs.create, opts "Create")
  vim.keymap.set("n", "d", api.fs.remove, opts "Delete")
  vim.keymap.set("n", "r", api.fs.rename, opts "Rename")
  vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts "Toggle Git Ignore")
  vim.keymap.set("n", "R", api.tree.collapse_all, opts "Collapse")
  vim.keymap.set("n", "?", api.tree.toggle_help, opts "Help")
end

require("nvim-tree").setup {
  -- project.nvim set:
  -- respect_buf_cwd = true,
  -- auto_reload_on_write = true,
  -- Netrw plugin related settings
  disable_netrw = true, -- Disable the built-in netrw file explorer
  hijack_netrw = true, -- Make nvim-tree take over netrw functionality
  hijack_cursor = true, -- Move the cursor to the new file when opened
  hijack_unnamed_buffer_when_opening = false, -- Do not open the tree if no file is selected
  sync_root_with_cwd = false, -- Synchronize the root of the tree with the current working directory

  -- Settings related to updating the focused file in the tree
  update_focused_file = {
    enable = true, -- Enable updating the focused file in the tree
    update_cwd = true,
    update_root =false, -- Do not change the root of the tree when focusing a new file
  },
  -- Filesystem watcher settings
  filesystem_watchers = {
    enable = true, -- Enable watching the filesystem for changes
  },
  view = {
    side = "left",
  },
  on_attach = on_attach,
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true, -- Resize the window when a file is opened
      window_picker = {
        enable = false,
      },
    },
  },
  filters = {
    dotfiles = true,
    custom = { "^.git$" },
    exclude = {},
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },

  -- Renderer settings for the file tree
  renderer = {
    root_folder_label = false, -- Do not show a label for the root folder
    highlight_git = true, -- Do not highlight git status
    highlight_opened_files = "none", -- Do not highlight opened files

    -- Indent marker settings
    indent_markers = {
      enable = false, -- Do not show indent markers
    },

    -- Icon settings
    icons = {
      show = {
        file = true, -- Show file icons
        folder = true, -- Show folder icons
        folder_arrow = true, -- Show folder arrows
        git = true, -- Do not show git status icons
      },

      -- The glyphs/icons for the file tree
      glyphs = {
        default = "󰈚", -- Default file icon
        symlink = "", -- Symlink file icon
        folder = {
          default = "", -- Default folder icon
          empty = "", -- Empty folder icon
          empty_open = "", -- Open empty folder icon
          open = "", -- Open folder icon
          symlink = "", -- Symlink folder icon
          symlink_open = "", -- Open symlink folder icon
          arrow_open = "", -- Open arrow icon
          arrow_closed = "", -- Closed arrow icon
        },
        git = {
          unstaged = "✗", -- Unstaged git status icon
          staged = "✓", -- Staged git status icon
          unmerged = "", -- Unmerged git status icon
          renamed = "➜", -- Renamed git status icon
          untracked = "★", -- Untracked git status icon
          deleted = "", -- Deleted git status icon
          ignored = "◌", -- Ignored git status icon
        },
      },
    },
  },
}

local api = require "nvim-tree.api"
vim.api.nvim_create_autocmd("VimEnter", {
  once = true, -- 确保自动命令只执行一次
  callback = function()
    api.tree.toggle_gitignore_filter()
  end,
})
