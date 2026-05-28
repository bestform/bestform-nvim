package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local session = require("trail.session")
local tracker = require("trail.tracker")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local temp = vim.fn.getcwd() .. "/.trail-lsp-stale-test-a.lua"
local stale = vim.fn.getcwd() .. "/.trail-lsp-stale-test-b.lua"
vim.fn.writefile({ "-- temp" }, temp)
vim.fn.writefile({ "-- stale" }, stale)

session.reset()
session.start({ root = vim.fn.getcwd() })
tracker.setup()

local original_definition = vim.lsp.buf.definition
vim.lsp.buf.definition = function()
	return nil
end

vim.cmd.edit(vim.fn.fnameescape(temp))
vim.lsp.buf.definition()
vim.wait(300)
vim.cmd.edit(vim.fn.fnameescape(stale))

local record = session.get_record(stale)
assert_equal(record.edges.buffer_switch, 1, "expired LSP pending state falls back to buffer_switch")
assert_equal(record.edges.definition, nil, "expired LSP pending state does not leak definition edge")

vim.lsp.buf.definition = original_definition
session.reset()
vim.fn.delete(temp)
vim.fn.delete(stale)

print("trail_lsp_tracking_spec: ok")
