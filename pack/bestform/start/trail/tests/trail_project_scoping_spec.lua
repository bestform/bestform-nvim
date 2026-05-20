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

local temp_repo = vim.fn.getcwd() .. "/.trail-scoping-test-repo"
local temp_nogit = "/tmp/.trail-scoping-test-nogit"

-- Clean up any leftovers from previous runs
vim.fn.delete(temp_repo, "rf")
vim.fn.delete(temp_nogit, "rf")

-- Setup: create a git repo and a plain directory
vim.fn.mkdir(temp_repo .. "/sub", "p")
vim.fn.mkdir(temp_nogit, "p")
vim.fn.system("git init " .. vim.fn.shellescape(temp_repo) .. " 2>/dev/null")

-- detect_root should return the git root when inside a repo
local repo_root = session.detect_root(temp_repo)
assert_equal(repo_root, vim.fs.normalize(temp_repo), "detect_root returns git root for repo directory")

local sub_root = session.detect_root(temp_repo .. "/sub")
assert_equal(sub_root, vim.fs.normalize(temp_repo), "detect_root returns git root for subdirectory")

-- detect_root should fall back to cwd when not inside a repo
local nogit_root = session.detect_root(temp_nogit)
assert_equal(nogit_root, vim.fs.normalize(temp_nogit), "detect_root falls back to cwd outside git repo")

-- Scoping: files outside the project root are silently ignored
session.reset()
session.start({ root = temp_repo })
assert_equal(session.get_root(), vim.fs.normalize(temp_repo), "get_root returns the set root")

local inside_file = temp_repo .. "/inside.lua"
local outside_file = temp_nogit .. "/outside.lua"

assert_equal(session.record_file(inside_file), true, "file inside root is recorded")
assert_equal(session.record_file(outside_file), false, "file outside root is ignored")
assert_list_equal(session.get_files(), { inside_file }, "only inside files appear in session")

-- Root can be set via opts and persists across stop/start
session.stop()
session.start()
assert_equal(session.get_root(), vim.fs.normalize(temp_repo), "root persists across stop/start")

-- Reset clears root
session.reset()
assert_equal(session.get_root(), nil, "reset clears root")

-- Clean up
vim.fn.delete(temp_repo, "rf")
vim.fn.delete(temp_nogit, "rf")

print("trail_project_scoping_spec: ok")
