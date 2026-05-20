package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local trail = require("trail")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

session.reset()

-- No session active: statusline should be empty
assert_equal(trail.statusline(), "", "inactive session returns empty statusline")

session.start()
assert_equal(trail.statusline(), "", "active with no files returns empty statusline")

local cwd = vim.fn.getcwd()

session.record_file(cwd .. "/a.lua", "definition")
assert_equal(trail.statusline(), "Trail: 1 files, 1 edges", "single file single edge")

session.record_file(cwd .. "/b.lua", "definition")
assert_equal(trail.statusline(), "Trail: 2 files, 2 edges", "two files two edges")

session.record_file(cwd .. "/a.lua", "reference")
session.record_file(cwd .. "/a.lua", "reference")
assert_equal(trail.statusline(), "Trail: 2 files, 4 edges", "accumulated edges counted correctly")

session.stop()
assert_equal(trail.statusline(), "Trail: 2 files, 4 edges", "stopped session still reports stats")

session.reset()
assert_equal(trail.statusline(), "", "reset clears stats back to empty")

print("trail_statusline_spec: ok")
