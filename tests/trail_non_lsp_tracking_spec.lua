package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local tracker = require("trail.tracker")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local function assert_deep_equal(actual, expected, message)
	if not vim.deep_equal(actual, expected) then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

-- Ensure tracker autocmds are fresh
vim.api.nvim_create_augroup("trail-tracker", { clear = true })
local did_setup = false
if not did_setup then
	tracker.setup()
	did_setup = true
end

local temp = vim.fn.getcwd() .. "/.trail-non-lsp-test"
vim.fn.mkdir(temp, "p")

local files = {
	a = temp .. "/a.lua",
	b = temp .. "/b.lua",
	c = temp .. "/c.lua",
	d = temp .. "/d.lua",
}

for _, path in pairs(files) do
	vim.fn.writefile({ "-- " .. vim.fn.fnamemodify(path, ":t") }, path)
end

local function make_file_buffer(path)
	local bufnr = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(bufnr, path)
	return bufnr
end

local function make_ui_buffer(ft)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("filetype", ft, { buf = bufnr })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
	return bufnr
end

local function switch_to(bufnr)
	vim.api.nvim_set_current_buf(bufnr)
	vim.wait(100)
end

session.reset()
session.start()

-- 1) Plain buffer switch records buffer_switch
local buf_a = make_file_buffer(files.a)
switch_to(buf_a)
assert_equal(session.get_record(files.a).edges.buffer_switch, 1, "plain buffer switch gets buffer_switch edge")

-- 2) Switch to another normal buffer accumulates buffer_switch
local buf_b = make_file_buffer(files.b)
switch_to(buf_b)
assert_equal(session.get_record(files.b).edges.buffer_switch, 1, "second buffer gets buffer_switch")
switch_to(buf_a)
assert_equal(session.get_record(files.a).edges.buffer_switch, 2, "returning to first buffer accumulates buffer_switch")

-- 3) Leaving TelescopePrompt attributes search
local tele = make_ui_buffer("TelescopePrompt")
switch_to(tele)
local buf_c = make_file_buffer(files.c)
switch_to(buf_c)
assert_equal(session.get_record(files.c).edges.search, 1, "Telescope -> file gives search edge")

-- 4) Leaving neo-tree attributes file_tree
local neotree = make_ui_buffer("neo-tree")
switch_to(neotree)
local buf_d = make_file_buffer(files.d)
switch_to(buf_d)
assert_equal(session.get_record(files.d).edges.file_tree, 1, "neo-tree -> file gives file_tree edge")

-- 5) fzf-lua also attributes search
local fzf = make_ui_buffer("fzf")
switch_to(fzf)
switch_to(buf_a)
assert_equal(session.get_record(files.a).edges.search, 1, "fzf -> file gives search edge")

-- 6) netrw attributes file_tree
local netrw = make_ui_buffer("netrw")
switch_to(netrw)
switch_to(buf_b)
assert_equal(session.get_record(files.b).edges.file_tree, 1, "netrw -> file gives file_tree edge")

-- 7) NvimTree attributes file_tree
local nvimtree = make_ui_buffer("NvimTree")
switch_to(nvimtree)
switch_to(buf_c)
assert_equal(session.get_record(files.c).edges.file_tree, 1, "NvimTree -> file gives file_tree edge")

-- 8) Cancelling a picker and returning to same buffer downgrades to buffer_switch
local before = session.get_record(files.c).edges.buffer_switch or 0
switch_to(tele)
switch_to(buf_c)
assert_equal(session.get_record(files.c).edges.buffer_switch, before + 1, "returning to same buffer after picker is buffer_switch")

-- 9) Edge counts accumulate across multiple visits
-- First go to a different buffer so last_normal_bufnr changes, then
-- return to buf_c via the picker; this simulates a successful selection.
switch_to(buf_a)
switch_to(tele)
switch_to(buf_c)
assert_equal(session.get_record(files.c).edges.search, 2, "search edge accumulates")

-- Cleanup
session.reset()
vim.fn.delete(temp, "rf")

print("trail_non_lsp_tracking_spec: ok")
