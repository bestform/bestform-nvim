return { -- Autocompletion
	"saghen/blink.cmp",
	event = "VimEnter",
	version = "1.*",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			build = (function()
				-- we can avoid this on windows here, but we won't. Because why would you use this on windows?
				return "make install_jsregexp"
			end)(),
			opts = {},
		},
		"folke/lazydev.nvim",
	},
	opts = {
		keymap = {
			preset = "enter",
		},

		appearance = {
			nerd_font_variant = "Nerd Font Mono",
		},

		completion = {
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},

		sources = {
			default = { "lsp", "path", "snippets", "lazydev" },
			providers = {
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},

		snippets = { preset = "luasnip" },

		fuzzy = { implementation = "lua" },

		-- Shows a signature help window while you type arguments for a function
		signature = { enabled = true },
	},
}
