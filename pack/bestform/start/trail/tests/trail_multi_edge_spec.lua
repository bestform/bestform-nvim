package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local view = require("trail.view")
local edges = require("trail.edges")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

-- ---- pure edge tests ----

-- Combined suffix sorted alphabetically by label
assert_equal(edges.format_suffix({
	search = 3,
	definition = 2,
	reference = 1,
}), " [def*2, ref*1, search*3]", "suffix sorted alphabetically by label")

assert_equal(edges.format_suffix({
	buffer_switch = 1,
	file_tree = 1,
	search = 1,
}), " [buf*1, search*1, tree*1]", "alphabetical handles all non-LSP types")

-- Strongest priority ordering
local function assert_strongest(edge_counts, expected, message)
	assert_equal(edges.strongest(edge_counts), expected, message)
end

assert_strongest({
	definition = 1,
	implementation = 1,
}, "definition", "definition > implementation")

assert_strongest({
	implementation = 1,
	type_definition = 1,
}, "implementation", "implementation > type_definition")

assert_strongest({
	type_definition = 1,
	reference = 1,
}, "type_definition", "type_definition > reference")

assert_strongest({
	reference = 1,
	file_tree = 1,
}, "reference", "reference > file_tree")

assert_strongest({
	file_tree = 1,
	search = 1,
}, "file_tree", "file_tree > search")

assert_strongest({
	search = 1,
	buffer_switch = 1,
}, "search", "search > buffer_switch")

-- ---- rendering / dimming tests ----

local temp = vim.fn.getcwd() .. "/.trail-multi-edge-test"
vim.fn.delete(temp, "rf")
vim.fn.mkdir(temp .. "/src", "p")

local files = {
	definition = temp .. "/src/definition.lua",
	reference = temp .. "/src/reference.lua",
	file_tree = temp .. "/src/file_tree.lua",
}

for _, path in pairs(files) do
	vim.fn.writefile({ "-- " .. vim.fn.fnamemodify(path, ":t") }, path)
end

session.reset()
session.start()

-- Record edges for each file (simulate visits)
session.record_file(files.definition, "definition")
session.record_file(files.reference, "reference")
session.record_file(files.file_tree, "file_tree")
session.record_file(files.definition, "definition") -- definition visited twice

-- current_file is now files.definition

view.open()
local trail_win = vim.api.nvim_get_current_win()
local bufnr = vim.api.nvim_win_get_buf(trail_win)

view.render()
local edge_ns = vim.api.nvim_create_namespace("trail-edge-colors")

local edge_marks = vim.api.nvim_buf_get_extmarks(bufnr, edge_ns, 0, -1, { details = true })

-- All visited files should have edge highlights
assert_equal(#edge_marks >= 1, true, "visited files have edge highlights")

-- Find line numbers for each file
local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
local function find_line(name)
	for i, line in ipairs(lines) do
		if line:match(name) then
			return i
		end
	end
	return nil
end

local current_line = find_line("definition%.lua")
local ref_line = find_line("reference%.lua")
local tree_line = find_line("file_tree%.lua")

assert_equal(current_line ~= nil, true, "definition.lua found in buffer")
assert_equal(ref_line ~= nil, true, "reference.lua found in buffer")
assert_equal(tree_line ~= nil, true, "file_tree.lua found in buffer")

local function has_mark_on_line(marks, line)
	for _, mark in ipairs(marks) do
		local row = mark[2] + 1 -- 0-indexed
		if row == line then
			return true
		end
	end
	return false
end

assert_equal(has_mark_on_line(edge_marks, current_line), true, "current file has edge color")

assert_equal(has_mark_on_line(edge_marks, ref_line), true, "non-current reference file has edge color")

assert_equal(has_mark_on_line(edge_marks, tree_line), true, "non-current file_tree file has edge color")

view.close()
session.reset()
vim.fn.delete(temp, "rf")

print("trail_multi_edge_spec: ok")
