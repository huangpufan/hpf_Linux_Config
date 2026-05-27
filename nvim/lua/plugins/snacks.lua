--[[
  Snacks utility modules
--]]

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      bufdelete = { enabled = true },
      words = { enabled = true },
      lazygit = { enabled = true },
    },
    keys = {
      {
        "g=",
        function()
          Snacks.lazygit()
        end,
        desc = "Open Lazygit",
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Keep :checkhealth focused on the intentionally enabled snacks modules.
      local health_modules = {
        bigfile = true,
        quickfile = true,
        bufdelete = true,
        words = true,
        lazygit = true,
      }
      for _, plugin in ipairs(Snacks.meta.get()) do
        if not health_modules[plugin.name] then
          plugin.meta.health = false
        end
      end

      vim.api.nvim_create_user_command("LazyGit", function()
        Snacks.lazygit()
      end, { desc = "Open Lazygit" })
    end,
  },
}
