return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("treesj").setup({
			use_default_keymaps = false,
			langs = {
				typescript = {
					array = {
						both = {
							last_separator = true,
						},
					},
					object = {
						both = {
							last_separator = true,
						},
					},
					formal_parameters = {
						split = {
							last_separator = true,
						},
					},
					statement_block = {
						join = {
							force_insert = "", -- avoid adding semicolons
						},
					},
				},
			},
		})
	end,
}
