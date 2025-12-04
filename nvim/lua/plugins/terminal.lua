--[[
  Terminal plugins
--]]

return {
  -- Floaterm
  {
    "voldikss/vim-floaterm",
    cmd = { "FloatermToggle", "FloatermNew" },
    init = function()
      vim.g.floaterm_width = 0.90
      vim.g.floaterm_height = 0.90
      vim.g.floaterm_keymap_prev = "<C-left>"
      vim.g.floaterm_keymap_next = "<C-right>"
      vim.g.floaterm_keymap_new = "<C-q>"
      vim.g.floaterm_keymap_toggle = "<C-p>"
    end,
  },

  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
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
      end,
      shading_factor = 2,
      direction = "float",
      float_opts = { border = "rounded" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Custom toggle function with nvim-tree support
      vim.cmd([[
        function! ToggleTermWithNvimTree()
          NvimTreeClose
          let height = float2nr(winheight(0) * 0.32)
          execute 'ToggleTerm size=' . height . ' direction=horizontal'
          execute 'sleep 1m | NvimTreeOpen'
          let term_win_id = win_getid(winnr('#'))
          call win_gotoid(term_win_id)
        endfunction
      ]])

      vim.keymap.set("n", "-", ":call ToggleTermWithNvimTree()<CR>", { desc = "Toggle horizontal terminal" })
      vim.keymap.set(
        "n",
        "=",
        ":let width=float2nr(winwidth(0) * 0.5) | execute 'ToggleTerm size=' . width . ' direction=vertical'<CR>",
        { desc = "Toggle vertical terminal" }
      )
    end,
  },

  -- Nvim-unception (nested nvim support)
  {
    "samjwill/nvim-unception",
    lazy = true,
  },
}

