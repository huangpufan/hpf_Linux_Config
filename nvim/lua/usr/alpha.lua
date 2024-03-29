local alpha = require "alpha"
local dashboard = require "alpha.themes.dashboard"

-- Use https://patorjk.com/software/taag to generate ASCII.
-- Font: ANSI SHADOW.

dashboard.section.header.val = {
  "            ██╗  ██╗██████╗ ███████╗              ",
  "            ██║  ██║██╔══██╗██╔════╝              ",
  "            ███████║██████╔╝█████╗                ",
  "            ██╔══██║██╔═══╝ ██╔══╝                ",
  "            ██║  ██║██║     ██║                   ",
  "            ╚═╝  ╚═╝╚═╝     ╚═╝                   ",
  "                                                  ",
  "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
  "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
  "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
  "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
  "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
  "                                                  ",
}

-- Set menu

dashboard.section.buttons.val = {
  dashboard.button("<Ctrl> n", "󰙅 FileTree", ":NvimTreeOpen<CR>"),
  dashboard.button("<Space> f f", " Find file", ":Telescope find_files<CR>"),
  dashboard.button("<Space> f w", "󰈭 Find Word", ":Telescope live_grep<CR>"),
  dashboard.button("<Space> f o", "󰈚 Recent Files", ":Telescope oldfiles<CR>"),
}

-- Send config to alpha
alpha.setup(dashboard.opts)
