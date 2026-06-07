package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")

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

session.reset()
assert_equal(session.is_active(), false, "session starts inactive")
assert_equal(session.record_file("/tmp/before-start.lua"), false, "inactive session does not record")
assert_list_equal(session.get_files(), {}, "inactive session keeps empty list")

local cwd = vim.fn.getcwd()
local first = cwd .. "/first.lua"
local second = cwd .. "/second.lua"

session.start()
assert_equal(session.is_active(), true, "start activates session")
assert_equal(session.record_file(first), true, "active session records first file")
assert_equal(session.record_file(second), true, "active session records second file")
assert_equal(session.record_file(first), true, "revisiting a file updates recency")
assert_list_equal(session.get_files(), { first, second }, "files stay in first-visit order")
assert_equal(session.get_current_file(), first, "duplicate entries still update current file")
assert_equal(session.get_record(first).last_visit_seq, 3, "duplicate entries update visit sequence")
assert_equal(session.get_record(second).last_visit_seq, 2, "other records keep their previous visit sequence")

session.stop()
assert_equal(session.is_active(), false, "stop deactivates session")
assert_equal(session.record_file(cwd .. "/after-stop.lua"), false, "stopped session does not record new files")
assert_list_equal(session.get_files(), { first, second }, "stop preserves session data")

session.reset()
assert_list_equal(session.get_files(), {}, "reset clears files")

print("trail_session_spec: ok")
