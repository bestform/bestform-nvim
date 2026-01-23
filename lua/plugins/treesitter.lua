return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
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
	-- TODO: somehow get treesitter-textobjects working. Tried with the lazyvim setup but without success
}
