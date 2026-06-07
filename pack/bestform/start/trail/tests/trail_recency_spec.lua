package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local recency = require("trail.recency")
local session = require("trail.session")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

session.reset()
session.start()

local cwd = vim.fn.getcwd()
local first = cwd .. "/first.lua"
local second = cwd .. "/second.lua"
local third = cwd .. "/third.lua"

session.record_file(first)
session.record_file(second)
session.record_file(third)

assert_equal(session.get_record(first).last_visit_seq, 1, "first visit gets first sequence")
assert_equal(session.get_record(second).last_visit_seq, 2, "second visit gets second sequence")
assert_equal(session.get_record(third).last_visit_seq, 3, "third visit gets third sequence")

session.record_file(first)
assert_equal(session.get_record(first).last_visit_seq, 4, "revisiting a file updates recency")

local highlights = recency.by_path(session.get_records())
assert_equal(highlights[first], "TrailRecency01", "most recent file gets first shade")
assert_equal(highlights[third], "TrailRecency02", "second most recent file gets second shade")
assert_equal(highlights[second], "TrailRecency03", "third most recent file gets third shade")

for index = 1, 9 do
	session.record_file(cwd .. "/extra-" .. index .. ".lua")
end

local oldest_group = string.format("TrailRecency%02d", recency.defaults.steps)
highlights = recency.by_path(session.get_records())
assert_equal(highlights[cwd .. "/extra-9.lua"], "TrailRecency01", "newest extra file gets first shade")
assert_equal(highlights[second], oldest_group, "files older than the configured steps use the final shade")

session.reset()

print("trail_recency_spec: ok")
