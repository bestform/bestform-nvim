return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	init = function(_, opts)
		require("nvim-treesitter").install({
			"typescript",
			"javascript",
			"lua",
			"zig",
			"go",
			"bash",
		})
	end,
}
