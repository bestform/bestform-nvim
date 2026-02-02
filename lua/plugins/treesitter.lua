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

			local filetypeMap = {
				tsx = "typescriptreact",
			}

			local Ts = require("nvim-treesitter")
			Ts.install(parsers)

			for _, p in ipairs(parsers) do
				local pattern = filetypeMap[p] or p
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { pattern },
					callback = function()
						vim.treesitter.start()
					end,
				})
			end
		end,
	},
}
