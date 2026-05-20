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
session.start()
assert_equal(session.is_active(), true, "start activates session")
assert_equal(session.record_file(cwd .. "/first.lua"), true, "active session records first file")
assert_equal(session.record_file(cwd .. "/second.lua"), true, "active session records second file")
assert_equal(session.record_file(cwd .. "/first.lua"), false, "duplicate file is ignored")
assert_list_equal(session.get_files(), { cwd .. "/first.lua", cwd .. "/second.lua" }, "files stay in first-visit order")
assert_equal(session.get_current_file(), cwd .. "/first.lua", "duplicate entries still update current file")

session.stop()
assert_equal(session.is_active(), false, "stop deactivates session")
assert_equal(session.record_file(cwd .. "/after-stop.lua"), false, "stopped session does not record new files")
assert_list_equal(session.get_files(), { cwd .. "/first.lua", cwd .. "/second.lua" }, "stop preserves session data")


session.reset()
assert_list_equal(session.get_files(), {}, "reset clears files")

print("trail_session_spec: ok")
