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

-- Returns a formatted string suitable for any statusline plugin.
-- Returns "" when no session data exists, so the component hides naturally.
--
-- Usage example with lualine.nvim:
--   {
--     function() return require("trail").statusline() end,
--     color = { fg = "#5c6370" },
--   }
function M.statusline()
	local stats = session.stats()
	if stats.files == 0 and stats.edges == 0 then
		return ""
	end
	return string.format("Trail: %d files, %d edges", stats.files, stats.edges)
end

-- The plugin never auto-starts a session on startup.
-- Users who want automatic tracking can configure their own autocmd, e.g.:
--   vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function() require("trail").start() end,
--   })
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
