package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
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

local temp = vim.fn.getcwd() .. "/trail-file-navigation-test"
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
session.start({ root = vim.fn.getcwd() })
for _, f in ipairs(files) do
	session.record_file(f)
end

local source_win = vim.api.nvim_get_current_win()

view.open()
local trail_win = vim.api.nvim_get_current_win()

local function get_lines()
	return vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(trail_win), 0, -1, false)
end

local function cursor(line)
	vim.api.nvim_win_set_cursor(trail_win, { line, 0 })
end

local function cursor_line()
	return vim.api.nvim_win_get_cursor(trail_win)[1]
end

assert_list_equal(get_lines(), {
	"trail-file-navigation-test/",
	" src/",
	"  nested/",
	"   a.lua",
	"  b.lua",
	" test/",
	"  spec.lua",
}, "tree is always fully expanded")

assert_equal(cursor_line(), 7, "current file is selected after render")

cursor(1)
view.move_next_file()
assert_equal(cursor_line(), 4, "j from a directory jumps to next file")

view.move_next_file()
assert_equal(cursor_line(), 5, "j moves to following file")

view.move_next_file()
assert_equal(cursor_line(), 7, "j skips directories between files")

view.move_next_file()
assert_equal(cursor_line(), 7, "j stays on the last file")

cursor(6)
view.move_previous_file()
assert_equal(cursor_line(), 5, "k from a directory jumps to previous file")

view.move_previous_file()
assert_equal(cursor_line(), 4, "k moves to previous file")

view.move_previous_file()
assert_equal(cursor_line(), 4, "k stays on the first file")

cursor(2)
view.open_selected()
assert_equal(vim.api.nvim_get_current_win(), trail_win, "opening a directory line does nothing")

cursor(4)
view.open_selected()
assert_equal(vim.api.nvim_get_current_win(), source_win, "opening a file uses the source window")
assert_equal(vim.api.nvim_buf_get_name(0), temp .. "/src/nested/a.lua", "opens correct file")

-- Cleanup
view.close()
session.reset()
vim.fn.delete(temp, "rf")

print("trail_file_navigation_spec: ok")
