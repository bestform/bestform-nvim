package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local trail = require("trail")
local recency = require("trail.recency")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

trail.setup({
	recency = {
		newest = "#ffffff",
		oldest = "#000000",
		steps = 3,
	},
})

assert_equal(#recency.highlights, 3, "custom step count controls highlight count")
assert_equal(recency.highlights[1], "TrailRecency01", "first custom highlight keeps public name")
assert_equal(recency.highlights[3], "TrailRecency03", "last custom highlight uses configured step count")

local newest = vim.api.nvim_get_hl(0, { name = "TrailRecency01" })
local middle = vim.api.nvim_get_hl(0, { name = "TrailRecency02" })
local oldest = vim.api.nvim_get_hl(0, { name = "TrailRecency03" })

assert_equal(newest.fg, 0xffffff, "custom newest color is applied")
assert_equal(middle.fg, 0x808080, "intermediate color is generated")
assert_equal(oldest.fg, 0x000000, "custom oldest color is applied")

trail.setup({
	recency = {
		newest = "#111111",
	},
})

assert_equal(#recency.highlights, recency.defaults.steps, "unspecified step count falls back to default")
local overridden_newest = vim.api.nvim_get_hl(0, { name = "TrailRecency01" })
local default_oldest = vim.api.nvim_get_hl(0, { name = string.format("TrailRecency%02d", recency.defaults.steps) })

assert_equal(overridden_newest.fg, 0x111111, "partial config overrides newest color")
assert_equal(default_oldest.fg, 0x6f8f72, "partial config keeps default oldest color")

recency.setup()

print("trail_setup_spec: ok")
