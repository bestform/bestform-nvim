package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local view = require("trail.view")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local function make_restored_trail_buffer()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, "trail://view")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	vim.api.nvim_set_option_value("filetype", "trail", { buf = bufnr })
	return bufnr
end

session.reset()
session.start({ root = vim.fn.getcwd() })

view.open()
local owned = vim.api.nvim_win_get_buf(0)
assert_equal(vim.api.nvim_buf_get_name(owned), "trail://view", "Trail uses the plugin URI buffer name")
assert_equal(vim.api.nvim_buf_get_var(owned, "trail_view"), true, "created buffer is marked as owned by Trail")

view.close()
view.clean_invalid_session_buffers()
assert_equal(vim.api.nvim_buf_is_valid(owned), true, "owned Trail buffer is kept during session cleanup")

vim.api.nvim_buf_delete(owned, { force = true })
local stale = make_restored_trail_buffer()
view.clean_invalid_session_buffers()
assert_equal(vim.api.nvim_buf_is_valid(stale), false, "unowned restored Trail buffer is cleaned up")

session.reset()

print("trail_session_restore_spec: ok")
