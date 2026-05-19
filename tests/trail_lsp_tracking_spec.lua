package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local tracker = require("trail.tracker")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local temp = vim.fn.getcwd() .. "/.trail-lsp-tracking-test.lua"
vim.fn.writefile({ "-- lsp target" }, temp)

session.reset()
session.start()
vim.cmd.edit(vim.fn.fnameescape(temp))

local definition_called = false
vim.lsp.handlers["textDocument/definition"] = function()
	definition_called = true
	return "original-result"
end

tracker.wrap_lsp_handlers()
local result = vim.lsp.handlers["textDocument/definition"]()
vim.wait(100, function()
	local record = session.get_record(temp)
	return record and record.edges.definition == 1
end)

assert_equal(result, "original-result", "wrapped handler returns original result")
assert_equal(definition_called, true, "wrapped handler calls original handler")
assert_equal(session.get_record(temp).edges.definition, 1, "definition handler records landed buffer")

session.reset()
vim.fn.delete(temp)

print("trail_lsp_tracking_spec: ok")
