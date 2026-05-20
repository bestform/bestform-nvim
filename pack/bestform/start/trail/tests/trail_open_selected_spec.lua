package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local view = require("trail.view")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local temp = vim.fn.getcwd() .. "/.trail-open-selected-test"
vim.fn.delete(temp, "rf")
vim.fn.mkdir(temp, "p")
local first = temp .. "/first.lua"
local second = temp .. "/second.lua"
vim.fn.writefile({ "-- first" }, first)
vim.fn.writefile({ "-- second" }, second)

session.reset()
session.start()

vim.cmd.edit(vim.fn.fnameescape(first))
local source_win = vim.api.nvim_get_current_win()
session.record_file(first)
session.record_file(second)

view.open()
local trail_win = vim.api.nvim_get_current_win()
assert_equal(trail_win ~= source_win, true, "trail opens in a side window")

-- The tree contains a directory row first, then files sorted alphabetically.
vim.api.nvim_win_set_cursor(trail_win, { 3, 0 })
view.open_selected()

assert_equal(vim.api.nvim_win_is_valid(trail_win), true, "trail window remains open")
assert_equal(vim.api.nvim_win_get_buf(trail_win) ~= vim.api.nvim_get_current_buf(), true, "selected file is not opened in trail")
assert_equal(vim.api.nvim_get_current_win(), source_win, "selected file opens in the previous source window")
assert_equal(vim.api.nvim_buf_get_name(0), second, "selected file is edited in source window")

view.close()
session.reset()
vim.fn.delete(temp, "rf")

print("trail_open_selected_spec: ok")
