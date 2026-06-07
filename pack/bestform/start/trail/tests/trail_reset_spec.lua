package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local trail = require("trail")
local view = require("trail.view")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local function assert_list_equal(actual, expected, message)
	assert_equal(#actual, #expected, message or "list length differs")
	for index, value in ipairs(expected) do
		assert_equal(actual[index], value, (message or "list differs") .. " at index " .. index)
	end
end

local temp = vim.fn.getcwd() .. "/.trail-reset-test"
vim.fn.delete(temp, "rf")
vim.fn.mkdir(temp, "p")
local first = temp .. "/first.lua"
local second = temp .. "/second.lua"
vim.fn.writefile({ "-- first" }, first)
vim.fn.writefile({ "-- second" }, second)

trail.setup()
session.reset()
session.start({ root = temp })
session.record_file(first)
view.open()
local trail_win = vim.api.nvim_get_current_win()

assert_equal(session.is_active(), true, "session starts active")
assert_list_equal(session.get_files(), { first }, "precondition records first file")

vim.cmd("TrailReset")

assert_equal(session.is_active(), true, "TrailReset keeps an active session active")
assert_equal(session.get_root(), temp, "TrailReset keeps the current session root")
assert_list_equal(session.get_files(), {}, "TrailReset clears visited files")
assert_list_equal(
	vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(trail_win), 0, -1, false),
	{ "No files visited yet" },
	"TrailReset re-renders an open view as empty"
)

assert_equal(session.record_file(second), true, "active reset session continues tracking new files")
assert_list_equal(session.get_files(), { second }, "new files are recorded after TrailReset")

session.stop()
vim.cmd("TrailReset")
assert_equal(session.is_active(), false, "TrailReset keeps a stopped session stopped")
assert_list_equal(session.get_files(), {}, "TrailReset clears stopped session data")

view.close()
session.reset()
vim.fn.delete(temp, "rf")

print("trail_reset_spec: ok")
