package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error(
			(message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual),
			2
		)
	end
end

local function assert_list_equal(actual, expected, message)
	assert_equal(#actual, #expected, message or "list length differs")
	for index, value in ipairs(expected) do
		assert_equal(actual[index], value, (message or "list differs") .. " at index " .. index)
	end
end

local temp_dir = vim.fn.getcwd() .. "/.trail-scoping-test"
local temp_other = "/tmp/.trail-scoping-test-other"

-- Clean up any leftovers from previous runs
vim.fn.delete(temp_dir, "rf")
vim.fn.delete(temp_other, "rf")

vim.fn.mkdir(temp_dir, "p")
vim.fn.mkdir(temp_other, "p")

-- Root is set to cwd when no explicit root is given
session.reset()
local cwd = vim.fn.getcwd()
session.start()
assert_equal(session.get_root(), vim.fs.normalize(cwd), "root defaults to cwd")

-- Root can be set explicitly via opts
session.reset()
session.start({ root = temp_dir })
assert_equal(session.get_root(), vim.fs.normalize(temp_dir), "get_root returns the explicitly set root")

-- Scoping: files outside the project root are silently ignored
local inside_file = temp_dir .. "/inside.lua"
local outside_file = temp_other .. "/outside.lua"

assert_equal(session.record_file(inside_file), true, "file inside root is recorded")
assert_equal(session.record_file(outside_file), false, "file outside root is ignored")
assert_list_equal(session.get_files(), { inside_file }, "only inside files appear in session")

-- Root persists across stop/start
session.stop()
session.start()
assert_equal(session.get_root(), vim.fs.normalize(temp_dir), "root persists across stop/start")

-- Reset clears root
session.reset()
assert_equal(session.get_root(), nil, "reset clears root")

-- Clean up
vim.fn.delete(temp_dir, "rf")
vim.fn.delete(temp_other, "rf")

print("trail_project_scoping_spec: ok")
