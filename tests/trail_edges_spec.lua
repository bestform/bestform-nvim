package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local edges = require("trail.edges")
local session = require("trail.session")

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

session.reset()

local cwd = vim.fn.getcwd()
session.start()

assert_equal(session.record_file(cwd .. "/a.lua", "definition"), true, "definition records a new file")
assert_equal(session.record_file(cwd .. "/a.lua", "definition"), true, "definition count accumulates")
assert_equal(session.record_file(cwd .. "/a.lua", "reference"), true, "reference count accumulates")
assert_equal(session.record_file(cwd .. "/a.lua"), false, "generic duplicate does not change edge state")

local record = session.get_record(cwd .. "/a.lua")
assert_deep_equal(record.edges, {
	definition = 2,
	reference = 1,
}, "edge counts are stored per file")

assert_equal(edges.format_suffix(record.edges), " [def*2, ref*1]", "suffix follows edge display order")
assert_equal(edges.strongest(record.edges), "definition", "definition is the strongest LSP edge")

assert_equal(session.record_file(cwd .. "/b.lua", "type_definition"), true, "type definition records")
assert_equal(session.record_file(cwd .. "/b.lua", "implementation"), true, "implementation records")
assert_equal(edges.strongest(session.get_record(cwd .. "/b.lua").edges), "implementation", "implementation outranks type definition")

session.reset()

print("trail_edges_spec: ok")
