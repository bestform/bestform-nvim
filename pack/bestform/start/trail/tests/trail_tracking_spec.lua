package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local tracker = require("trail.tracker")

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

local temp = vim.fn.getcwd() .. "/.trail-tracking-test"
vim.fn.delete(temp, "rf")
vim.fn.mkdir(temp, "p")

local first = temp .. "/first.lua"
local second = temp .. "/second.lua"
vim.fn.writefile({ "-- first" }, first)
vim.fn.writefile({ "-- second" }, second)

local function make_file_buffer(path)
	local bufnr = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(bufnr, path)
	return bufnr
end

local function make_scratch_buffer()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	return bufnr
end

local function switch_to(bufnr)
	vim.api.nvim_set_current_buf(bufnr)
	vim.wait(20)
end

tracker.setup()
session.reset()
session.start({ root = temp })

local first_buf = make_file_buffer(first)
local second_buf = make_file_buffer(second)
local scratch = make_scratch_buffer()

switch_to(first_buf)
assert_list_equal(session.get_files(), { first }, "entering a normal file buffer records it")
assert_equal(session.get_record(first).last_visit_seq, 1, "first file gets first recency sequence")

switch_to(scratch)
assert_list_equal(session.get_files(), { first }, "non-file buffers are ignored")

switch_to(second_buf)
assert_list_equal(session.get_files(), { first, second }, "second normal file buffer is recorded")
assert_equal(session.get_record(second).last_visit_seq, 2, "second file gets second recency sequence")

switch_to(first_buf)
assert_list_equal(session.get_files(), { first, second }, "revisits do not duplicate files")
assert_equal(session.get_current_file(), first, "revisits update current file")
assert_equal(session.get_record(first).last_visit_seq, 3, "revisits update recency sequence")

session.stop()
switch_to(second_buf)
assert_equal(session.get_record(second).last_visit_seq, 2, "stopped sessions ignore buffer entries")

session.reset()
vim.fn.delete(temp, "rf")

print("trail_tracking_spec: ok")
