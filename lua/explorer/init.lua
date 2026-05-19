local session = require("explorer.session")
local explorer = require("explorer.explorer")
local tracker = require("explorer.tracker")

local M = {}
local did_setup = false

function M.start()
	session.start()
	session.record_buffer(0)
	explorer.open()
end

function M.stop()
	session.stop()
	explorer.render()
end

function M.setup()
	if did_setup then
		return
	end
	did_setup = true

	tracker.setup()

	vim.api.nvim_create_user_command("Trail", function()
		M.start()
	end, { desc = "Start an exploration trail session" })

	vim.api.nvim_create_user_command("TrailStop", function()
		M.stop()
	end, { desc = "Stop tracking the active exploration trail session" })
end

return M
