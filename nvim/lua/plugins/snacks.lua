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
      input = { enabled = true },
      picker = {
        enabled = true,
        ui_select = true,
      },
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

      -- Headless sessions do not emit UIEnter, so install the UI handlers now
      -- instead of leaving health checks and automation on the defaults.
      Snacks.input.enable()
      Snacks.picker.setup()

      -- Keep :checkhealth focused on the intentionally enabled snacks modules.
      local health_modules = {
        bigfile = true,
        quickfile = true,
        bufdelete = true,
        words = true,
        lazygit = true,
        input = true,
        picker = true,
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
