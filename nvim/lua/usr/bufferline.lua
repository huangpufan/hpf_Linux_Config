local bufferline = require("bufferline")

bufferline.setup({
  options = {
    numbers = "none",
    diagnostics = false,
    themable = false,
    indicator = {
      style = "underline",
    },
    highlights = {
      buffer_selected = {
        guifg = "white", -- 文字颜色为白色
        gui = "bold", -- 文字样式为加粗
        -- 如果你还想要更改背景颜色，可以加上下面这行：
        -- guibg = "<color>", -- 将 <color> 替换为你想要的颜色代码
			},
		},
		show_close_icon = true,
		max_name_length = 80,
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				text_align = "center",
			},
		},
		groups = {
			items = {
				require("bufferline.groups").builtin.pinned:with({ icon = "" }),
			},
		},
	},
})

