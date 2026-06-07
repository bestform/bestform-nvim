local M = {}

M.defaults = {
	-- A warm amber reads as "fresh" without borrowing diagnostic red.
	newest = "#ffb86c",
	-- Muted moss keeps old entries distinct while avoiding a fixed blue metaphor.
	oldest = "#6f8f72",
	steps = 6,
}

local function hex_to_rgb(hex)
	local red, green, blue = hex:match("^#(%x%x)(%x%x)(%x%x)$")
	return {
		red = tonumber(red, 16),
		green = tonumber(green, 16),
		blue = tonumber(blue, 16),
	}
end

local function rgb_to_hex(color)
	return string.format("#%02x%02x%02x", color.red, color.green, color.blue)
end

local function mix(left, right, amount)
	local function channel(name)
		return math.floor(left[name] + (right[name] - left[name]) * amount + 0.5)
	end

	return {
		red = channel("red"),
		green = channel("green"),
		blue = channel("blue"),
	}
end

local function build_highlights(steps)
	local highlights = {}
	for index = 1, steps do
		highlights[index] = string.format("TrailRecency%02d", index)
	end
	return highlights
end

local function build_colors(theme)
	local steps = theme.steps
	local newest = hex_to_rgb(theme.newest)
	local oldest = hex_to_rgb(theme.oldest)
	local colors = {}

	for index = 1, steps do
		local amount = steps == 1 and 0 or (index - 1) / (steps - 1)
		colors[index] = rgb_to_hex(mix(newest, oldest, amount))
	end

	return colors
end

M.highlights = {}
local colors = {}
local options = {}

function M.setup(opts)
	options = vim.tbl_deep_extend("force", M.defaults, opts or {})
	options.steps = math.max(1, math.floor(tonumber(options.steps) or M.defaults.steps))

	M.highlights = build_highlights(options.steps)
	colors = build_colors(options)
end

function M.setup_highlights()
	for index, group in ipairs(M.highlights) do
		vim.api.nvim_set_hl(0, group, { fg = colors[index] })
	end
end

M.setup()

function M.by_path(records)
	local sorted = vim.deepcopy(records or {})

	table.sort(sorted, function(left, right)
		return (left.last_visit_seq or 0) > (right.last_visit_seq or 0)
	end)

	local result = {}
	for index, record in ipairs(sorted) do
		if record.path then
			local shade_index = math.min(index, #M.highlights)
			result[record.path] = M.highlights[shade_index]
		end
	end

	return result
end

return M
