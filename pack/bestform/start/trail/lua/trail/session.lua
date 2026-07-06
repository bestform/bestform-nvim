local M = {}

local state = {
	active = false,
	files = {},
	seen = {},
	records = {},
	root = nil,
	current_file = nil,
	visit_sequence = 0,
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

function M.get_root()
	return state.root
end

function M.start(opts)
	opts = opts or {}
	if not state.root then
		state.root = normalize_path(opts.root or vim.fn.getcwd())
	end
	state.active = true
end

function M.stop()
	state.active = false
end

function M.is_active()
	return state.active
end

function M.record_file(path)
	if not state.active then
		return false
	end

	local normalized = normalize_path(path)
	if not normalized then
		return false
	end

	if state.root then
		local root_prefix = state.root .. "/"
		if normalized ~= state.root and not vim.startswith(normalized, root_prefix) then
			return false
		end
	end

	state.current_file = normalized

	if not state.seen[normalized] then
		state.seen[normalized] = true
		state.records[normalized] = {
			path = normalized,
			last_visit_seq = 0,
		}
		table.insert(state.files, normalized)
	end

	local record = state.records[normalized]
	state.visit_sequence = state.visit_sequence + 1
	record.last_visit_seq = state.visit_sequence

	return true
end

function M.record_buffer(bufnr)
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
	return M.record_file(path)
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
		last_visit_seq = record.last_visit_seq,
	}
end

function M.get_records()
	local records = {}
	for _, path in ipairs(state.files) do
		table.insert(records, M.get_record(path))
	end
	return records
end

function M.clear()
	state.files = {}
	state.seen = {}
	state.records = {}
	state.current_file = nil
	state.visit_sequence = 0
end

function M.reset()
	state.active = false
	M.clear()
	state.root = nil
end

return M
