return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function(_, opts)
			local parsers = {
				"tsx",
				"typescript",
				"lua",
				"bash",
				"html",
				"zig",
				"javascript",
				"go",
			}

			local Ts = require("nvim-treesitter")
			Ts.install(parsers)

			for _, p in ipairs(parsers) do
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { p },
					callback = function()
						vim.treesitter.start()
					end,
				})
			end
		end,
	},
}
