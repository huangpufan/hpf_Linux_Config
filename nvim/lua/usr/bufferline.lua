local bufferline = require("bufferline")
bufferline.setup({
	options = {
		numbers = "ordinal",
		diagnostics = false,
		themable = false,
		indicator = {
			style = "underline",
		},
		-- show_buffer_close_icons = false,
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
	},
})
