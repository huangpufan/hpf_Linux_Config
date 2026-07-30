local M = {}

function M.setup(wk)
  require("config.actions").install("which-key", { wk = wk })
end

return M
