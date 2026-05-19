local M = {}

local edges = require("trail.edges")

local state = {
	active = false,
	files = {},
	seen = {},
	records = {},
	current_file = nil,
}

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end

	if vim.fs and vim.fs.normalize then
		return vim.fs.normalize(path)
	end

	return vim.fn.fnamemodify(path, ":p")
end

function M.start()
	state.active = true
end

function M.stop()
	state.active = false
end

function M.is_active()
	return state.active
end

function M.record_file(path, edge_type)
	if not state.active then
		return false
	end

	local normalized = normalize_path(path)
	if not normalized then
		return false
	end

	state.current_file = normalized

	local is_new_file = not state.seen[normalized]
	if is_new_file then
		state.seen[normalized] = true
		state.records[normalized] = {
			path = normalized,
			edges = {},
		}
		table.insert(state.files, normalized)
	end

	local record = state.records[normalized]
	local edge_recorded = false
	if edge_type and edges.is_known(edge_type) then
		record.edges[edge_type] = (record.edges[edge_type] or 0) + 1
		edge_recorded = true
	end

	return is_new_file or edge_recorded
end

function M.record_buffer(bufnr, edge_type)
	if not state.active then
		return false
	end

	bufnr = bufnr or 0
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
		return false
	end

	local path = vim.api.nvim_buf_get_name(bufnr)
	return M.record_file(path, edge_type)
end

function M.get_files()
	return vim.list_slice(state.files)
end

function M.get_current_file()
	return state.current_file
end

function M.get_record(path)
	local normalized = normalize_path(path)
	if not normalized then
		return nil
	end

	local record = state.records[normalized]
	if not record then
		return nil
	end

	return {
		path = record.path,
		edges = vim.deepcopy(record.edges),
	}
end

function M.get_records()
	local records = {}
	for _, path in ipairs(state.files) do
		table.insert(records, M.get_record(path))
	end
	return records
end

function M.reset()
	state.active = false
	state.files = {}
	state.seen = {}
	state.records = {}
	state.current_file = nil
end

return M
