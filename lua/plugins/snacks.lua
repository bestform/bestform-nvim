return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	enabled = true,
	opts = {
		terminal = {
			enabled = true,
		},
		scroll = {
			animate = {
				duration = { step = 15, total = 100 },
				easing = "linear",
			},
		},

		dashboard = {
			preset = {
				-- pick = function(cmd, opts)
				-- 	return LazyVim.pick(cmd, opts)()
				-- end,
				header = [[
                                           
 _           _   ___               
| |_ ___ ___| |_|  _|___ ___ _____ 
| . | -_|_ -|  _|  _| . |  _|     |
|___|___|___|_| |_| |___|_| |_|_|_|
                               nvim
 ]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
}
