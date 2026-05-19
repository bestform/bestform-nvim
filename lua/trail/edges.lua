local M = {}

M.labels = {
	definition = "def",
	reference = "ref",
	implementation = "impl",
	type_definition = "type",
	file_tree = "tree",
	search = "search",
	buffer_switch = "buf",
}

M.highlights = {
	definition = "TrailEdgeDefinition",
	reference = "TrailEdgeReference",
	implementation = "TrailEdgeImplementation",
	type_definition = "TrailEdgeTypeDefinition",
	file_tree = "TrailEdgeFileTree",
	search = "TrailEdgeSearch",
	buffer_switch = "TrailEdgeBufferSwitch",
}

local priority = {
	definition = 1,
	implementation = 2,
	type_definition = 3,
	reference = 4,
	file_tree = 5,
	search = 6,
	buffer_switch = 7,
}

function M.is_known(edge_type)
	return M.labels[edge_type] ~= nil
end

function M.format_suffix(edge_counts)
	if not edge_counts then
		return ""
	end

	local parts = {}
	for edge_type, count in pairs(edge_counts) do
		if count and count > 0 and M.labels[edge_type] then
			table.insert(parts, M.labels[edge_type] .. "*" .. count)
		end
	end

	if #parts == 0 then
		return ""
	end

	table.sort(parts)
	return " [" .. table.concat(parts, ", ") .. "]"
end

function M.strongest(edge_counts)
	if not edge_counts then
		return nil
	end

	local strongest_edge = nil
	local strongest_priority = math.huge

	for edge_type, count in pairs(edge_counts) do
		local edge_priority = priority[edge_type]
		if count > 0 and edge_priority and edge_priority < strongest_priority then
			strongest_edge = edge_type
			strongest_priority = edge_priority
		end
	end

	return strongest_edge
end

function M.setup_highlights()
	vim.api.nvim_set_hl(0, M.highlights.definition, { fg = "#98c379" })
	vim.api.nvim_set_hl(0, M.highlights.reference, { fg = "#56b6c2" })
	vim.api.nvim_set_hl(0, M.highlights.implementation, { fg = "#00bcd4" })
	vim.api.nvim_set_hl(0, M.highlights.type_definition, { fg = "#61afef" })
	vim.api.nvim_set_hl(0, M.highlights.file_tree, { fg = "#b39ddb" })
	vim.api.nvim_set_hl(0, M.highlights.search, { fg = "#e5c07b" })
	vim.api.nvim_set_hl(0, M.highlights.buffer_switch, { fg = "#5c6370" })
end

return M
