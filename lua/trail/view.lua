local session = require("trail.session")
local tree = require("trail.tree")
local edges = require("trail.edges")

local M = {}

local WIDTH = 40
local namespace = vim.api.nvim_create_namespace("trail-current-file")
local edge_namespace = vim.api.nvim_create_namespace("trail-edge-colors")

local state = {
	bufnr = nil,
	winid = nil,
	last_source_winid = nil,
	line_paths = {},
	line_dirs = {},
	collapsed = {},
}

local function is_valid_window(winid)
	return winid and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_buffer(bufnr)
	return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

local function render_node(node, depth, lines, file_spans)
	local indent = string.rep("  ", depth)

	for _, child in ipairs(node.children) do
		if child.type == "directory" then
			table.insert(lines, indent .. child.name .. "/")
			state.line_dirs[#lines] = child.path
			if not state.collapsed[child.path] then
				render_node(child, depth + 1, lines, file_spans)
			end
		else
			local line = indent .. child.name .. edges.format_suffix(child.edges)
			table.insert(lines, line)
			state.line_paths[#lines] = child.path
			file_spans[#lines] = {
				start_col = #indent,
				end_col = #indent + #child.name,
				path = child.path,
				edge_type = edges.strongest(child.edges),
			}
		end
	end
end

local function ensure_buffer()
	if is_valid_buffer(state.bufnr) then
		return state.bufnr
	end

	state.bufnr = vim.api.nvim_create_buf(false, true)
	vim.bo[state.bufnr].bufhidden = "hide"
	vim.bo[state.bufnr].buftype = "nofile"
	vim.bo[state.bufnr].filetype = "trail"
	vim.bo[state.bufnr].swapfile = false
	vim.api.nvim_buf_set_name(state.bufnr, "Trail")

	vim.keymap.set("n", "q", M.close, { buffer = state.bufnr, silent = true, nowait = true })
	vim.keymap.set("n", "<CR>", M.open_selected, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "l", M.expand_or_open, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "h", M.collapse, { buffer = state.bufnr, silent = true })

	return state.bufnr
end

local function focus_existing_window()
	if not is_valid_window(state.winid) then
		return false
	end

	local current_win = vim.api.nvim_get_current_win()
	if current_win ~= state.winid then
		state.last_source_winid = current_win
	end

	vim.api.nvim_set_current_win(state.winid)
	return true
end

local function remember_source_window()
	local current_win = vim.api.nvim_get_current_win()
	if current_win ~= state.winid then
		state.last_source_winid = current_win
	end
end

local function find_source_window()
	if is_valid_window(state.last_source_winid) and state.last_source_winid ~= state.winid then
		return state.last_source_winid
	end

	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		if winid ~= state.winid then
			local bufnr = vim.api.nvim_win_get_buf(winid)
			if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "" then
				return winid
			end
		end
	end

	return nil
end

function M.open()
	state.collapsed = {}
	local bufnr = ensure_buffer()
	remember_source_window()

	if not focus_existing_window() then
		vim.cmd("botright vertical " .. WIDTH .. "split")
		state.winid = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(state.winid, bufnr)
		vim.wo[state.winid].number = false
		vim.wo[state.winid].relativenumber = false
		vim.wo[state.winid].signcolumn = "no"
		vim.wo[state.winid].wrap = false
		vim.api.nvim_win_set_width(state.winid, WIDTH)
	end

	M.render()
end

function M.close()
	if is_valid_window(state.winid) then
		vim.api.nvim_win_close(state.winid, true)
	end
	state.winid = nil
end

function M.render()
	if not is_valid_buffer(state.bufnr) then
		return
	end

	edges.setup_highlights()

	local records = session.get_records()
	local lines = {}
	local file_spans = {}
	state.line_paths = {}
	state.line_dirs = {}

	render_node(tree.build(records, { root = session.get_root() or vim.fn.getcwd() }), 0, lines, file_spans)

	if #lines == 0 then
		lines = { "No files visited yet" }
	end

	vim.bo[state.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
	vim.bo[state.bufnr].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.bufnr, namespace, 0, -1)
	vim.api.nvim_buf_clear_namespace(state.bufnr, edge_namespace, 0, -1)

	local current = session.get_current_file()
	for line, span in pairs(file_spans) do
		local is_current = current and span.path == current
		local highlight = span.edge_type and edges.highlights[span.edge_type]

		if highlight then
			vim.api.nvim_buf_add_highlight(state.bufnr, edge_namespace, highlight, line - 1, span.start_col, span.end_col)
		end

		if is_current then
			vim.api.nvim_buf_add_highlight(state.bufnr, namespace, "CursorLine", line - 1, 0, -1)
			if is_valid_window(state.winid) then
				vim.api.nvim_win_set_cursor(state.winid, { line, 0 })
			end
		end
	end
end

function M.open_selected()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local path = state.line_paths[line]
	if not path then
		return
	end

	local target_win = find_source_window()
	if target_win then
		vim.api.nvim_set_current_win(target_win)
	end

	vim.cmd.edit(vim.fn.fnameescape(path))
end

function M.expand_or_open()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local dir_path = state.line_dirs[line]
	if dir_path then
		if state.collapsed[dir_path] then
			state.collapsed[dir_path] = nil
			local saved_cursor = vim.api.nvim_win_get_cursor(0)
			M.render()
			vim.api.nvim_win_set_cursor(0, saved_cursor)
		end
	else
		M.open_selected()
	end
end

function M.collapse()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local dir_path = state.line_dirs[line]
	if dir_path and not state.collapsed[dir_path] then
		state.collapsed[dir_path] = true
		local saved_cursor = vim.api.nvim_win_get_cursor(0)
		M.render()
		vim.api.nvim_win_set_cursor(0, saved_cursor)
	end
end

function M.is_open()
	return is_valid_window(state.winid)
end

return M
