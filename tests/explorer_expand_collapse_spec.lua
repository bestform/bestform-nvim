package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("explorer.session")
local explorer = require("explorer.explorer")

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

local temp = vim.fn.getcwd() .. "/explorer-expand-collapse-test"
vim.fn.delete(temp, "rf")
vim.fn.mkdir(temp .. "/src/nested", "p")
vim.fn.mkdir(temp .. "/test", "p")

local files = {
	temp .. "/src/nested/a.lua",
	temp .. "/src/b.lua",
	temp .. "/test/spec.lua",
}
for _, f in ipairs(files) do
	vim.fn.writefile({ "-- " .. vim.fn.fnamemodify(f, ":t") }, f)
end

session.reset()
session.start()
for _, f in ipairs(files) do
	session.record_file(f)
end

local source_win = vim.api.nvim_get_current_win()

explorer.open()
local explorer_win = vim.api.nvim_get_current_win()

local function get_lines()
	return vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(explorer_win), 0, -1, false)
end

local function cursor(line)
	vim.api.nvim_win_set_cursor(explorer_win, { line, 0 })
end

-- Initial: all expanded
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"    nested/",
	"      a.lua",
	"    b.lua",
	"  test/",
	"    spec.lua",
}, "initial fully expanded")

-- Collapse src/ (line 2)
cursor(2)
explorer.collapse()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"  test/",
	"    spec.lua",
}, "src collapsed")

-- h on collapsed src/ does nothing
explorer.collapse()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"  test/",
	"    spec.lua",
}, "h on collapsed dir does nothing")

-- l on expanded test/ does nothing
cursor(3)
explorer.expand_or_open()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"  test/",
	"    spec.lua",
}, "l on expanded dir does nothing")

-- Collapse root (line 1)
cursor(1)
explorer.collapse()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
}, "root collapsed")

-- Expand root (line 1)
explorer.expand_or_open()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"  test/",
	"    spec.lua",
}, "root expanded, src still collapsed")

-- Expand src/ (line 2)
cursor(2)
explorer.expand_or_open()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"    nested/",
	"      a.lua",
	"    b.lua",
	"  test/",
	"    spec.lua",
}, "fully expanded again")

-- h on a file does nothing
cursor(4)
explorer.collapse()
assert_list_equal(get_lines(), {
	"explorer-expand-collapse-test/",
	"  src/",
	"    nested/",
	"      a.lua",
	"    b.lua",
	"  test/",
	"    spec.lua",
}, "h on file leaves tree unchanged")

-- l on a file opens it in source window
cursor(4)
explorer.expand_or_open()
assert_equal(vim.api.nvim_get_current_win(), source_win, "l on file opens in source window")
assert_equal(vim.api.nvim_buf_get_name(0), temp .. "/src/nested/a.lua", "l on file opens correct file")

-- Cleanup
explorer.close()
session.reset()
vim.fn.delete(temp, "rf")

print("explorer_expand_collapse_spec: ok")
