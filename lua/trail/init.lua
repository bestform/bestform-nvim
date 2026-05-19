local session = require("trail.session")
local view = require("trail.view")
local tracker = require("trail.tracker")

local M = {}
local did_setup = false

function M.start()
	session.start()
	session.record_buffer(0)
	view.open()
end

function M.stop()
	session.stop()
	view.render()
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
