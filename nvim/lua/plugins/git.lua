--[[
  Git related plugins
--]]

return {
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signcolumn = true,
        numhl = true,
      })
    end,
  },

  -- Fugitive
  {
    "tpope/vim-fugitive",
    cmd = "Git",
  },

  -- Diffview
  {
    "sindrets/diffview.nvim",
    cmd = "DiffviewOpen",
    config = function()
      require("diffview").setup({
        hooks = {
          diff_buf_win_enter = function()
            vim.opt_local.foldenable = false
          end,
        },
      })
    end,
  },
}
