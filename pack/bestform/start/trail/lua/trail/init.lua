local session = require("trail.session")
local view = require("trail.view")
local tracker = require("trail.tracker")
local recency = require("trail.recency")

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

function M.reset()
	session.clear()
	view.render()
end

-- The plugin never auto-starts a session on startup.
-- Users who want automatic tracking can configure their own autocmd, e.g.:
--   vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function() require("trail").start() end,
--   })
function M.setup(opts)
	recency.setup((opts or {}).recency)
	recency.setup_highlights()

	if did_setup then
		return
	end
	did_setup = true

	tracker.setup()

	vim.api.nvim_create_autocmd("SessionLoadPost", {
		group = vim.api.nvim_create_augroup("trail-session-restore", { clear = true }),
		desc = "Clean restored Trail view buffers",
		callback = function()
			view.clean_invalid_session_buffers()
		end,
	})

	vim.api.nvim_create_user_command("Trail", function()
		M.start()
	end, { desc = "Start an exploration trail session" })

	vim.api.nvim_create_user_command("TrailStop", function()
		M.stop()
	end, { desc = "Stop tracking the active exploration trail session" })

	vim.api.nvim_create_user_command("TrailReset", function()
		M.reset()
	end, { desc = "Reset the current exploration trail session" })
end

return M
