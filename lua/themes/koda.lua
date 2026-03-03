return {
	"oskarnurm/koda.nvim",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other start plugins
	opts = {
		transparent = false,
		styles = {
			comments = { italic = true },
		},
		colors = {
			comment = "#366e55",
			string = "#449e76",
		},
	},
}
