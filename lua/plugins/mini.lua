return {
	{
		"nvim-mini/mini.files",
		version = "*",
		opts = {
			mappings = {
				go_in = "L",
				go_in_plus = "l",
			},
		},
	},
	{
		"nvim-mini/mini.ai",
		version = "*",
		opts = {},
	},
	{
		"nvim-mini/mini.pairs",
		version = "*",
		opts = {},
	},
	{
		"nvim-mini/mini.diff",
		version = "*",
		opts = {
			view = {
				style = "sign",
				signs = { add = "▎", change = "▎", delete = "▁" },
			},
		},
	},
}
