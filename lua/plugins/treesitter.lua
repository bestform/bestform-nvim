return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"tsx",
				"html",
				"typescript",
				"javascript",
				"lua",
				"zig",
				"go",
				"bash",
			},
		},
	},
}
