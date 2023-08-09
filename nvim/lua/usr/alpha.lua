local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

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
  dashboard.button("<Space>ft", "  > FileTree", ":NvimTreeOpen<CR>"),
  dashboard.button("       ,f", "󰈞 > Find file", ":Telescope find_files<CR>"),

}

-- Send config to alpha
alpha.setup(dashboard.opts)
