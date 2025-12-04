--[[
  Git related plugins
--]]

return {
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
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

  -- Git messenger
  {
    "rhysd/git-messenger.vim",
    cmd = "GitMessenger",
    init = function()
      vim.g.git_messenger_always_into_popup = true
      vim.g.git_messenger_no_default_mappings = 1
    end,
  },

  -- Git blame
  {
    "f-person/git-blame.nvim",
    cmd = "GitBlameToggle",
    init = function()
      vim.g.gitblame_delay = 0
    end,
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

