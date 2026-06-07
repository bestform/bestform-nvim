local session = require("trail.session")
local view = require("trail.view")

local M = {}

local group = vim.api.nvim_create_augroup("trail-tracker", { clear = true })

function M.setup()
	vim.api.nvim_clear_autocmds({ group = group })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		desc = "Track viewed files for exploration sessions",
		callback = function(event)
			if vim.api.nvim_get_option_value("buftype", { buf = event.buf }) ~= "" then
				return
			end

			if session.record_buffer(event.buf) and view.is_open() then
				view.render()
			end
		end,
	})
end

return M
