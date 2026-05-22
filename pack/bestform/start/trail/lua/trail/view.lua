local session = require("trail.session")
local tree = require("trail.tree")
local edges = require("trail.edges")
local recency = require("trail.recency")

local M = {}

local WIDTH = 40
local TRAIL_BUFFER_NAME = "trail://view"
local TRAIL_BUFFER_VAR = "trail_view"
local namespace = vim.api.nvim_create_namespace("trail-current-file")
local recency_namespace = vim.api.nvim_create_namespace("trail-recency-colors")
local directory_namespace = vim.api.nvim_create_namespace("trail-directories")
local edge_suffix_namespace = vim.api.nvim_create_namespace("trail-edge-suffix")

local DIRECTORY_HIGHLIGHT = "TrailDirectory"
local EDGE_SUFFIX_HIGHLIGHT = "TrailEdgeSuffix"

local state = {
	bufnr = nil,
	winid = nil,
	last_source_winid = nil,
	line_paths = {},
}

local function is_valid_window(winid)
	return winid and vim.api.nvim_win_is_valid(winid)
end

local function is_valid_buffer(bufnr)
	return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

local function is_trail_name(bufnr)
	return vim.fn.bufname(bufnr) == TRAIL_BUFFER_NAME
end

local function is_marked_trail_buffer(bufnr)
	local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, TRAIL_BUFFER_VAR)
	return ok and value == true
end

local function looks_like_restored_trail_buffer(bufnr)
	return is_trail_name(bufnr)
end

local function mark_trail_buffer(bufnr)
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].filetype = "trail"
	vim.bo[bufnr].swapfile = false
	vim.api.nvim_buf_set_var(bufnr, TRAIL_BUFFER_VAR, true)
end

local function find_existing_trail_buffer()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if is_marked_trail_buffer(bufnr) then
			return bufnr
		end
	end
	return nil
end

local function render_node(node, depth, lines, file_spans, directory_spans, edge_suffix_spans)
	local indent = string.rep(" ", depth)

	for _, child in ipairs(node.children) do
		if child.type == "directory" then
			table.insert(lines, indent .. child.name .. "/")
			directory_spans[#lines] = {
				start_col = #indent,
				end_col = #indent + #child.name + 1,
			}
			render_node(child, depth + 1, lines, file_spans, directory_spans, edge_suffix_spans)
		else
			local suffix = edges.format_suffix(child.edges)
			local line = indent .. child.name .. suffix
			table.insert(lines, line)
			state.line_paths[#lines] = child.path
			file_spans[#lines] = {
				start_col = #indent,
				end_col = #indent + #child.name,
				path = child.path,
			}
			if suffix ~= "" then
				edge_suffix_spans[#lines] = {
					start_col = #indent + #child.name,
					end_col = #indent + #child.name + #suffix,
				}
			end
		end
	end
end

local function setup_highlights()
	edges.setup_highlights()
	recency.setup_highlights()
	vim.api.nvim_set_hl(0, DIRECTORY_HIGHLIGHT, { fg = "#5c6370" })
	vim.api.nvim_set_hl(0, EDGE_SUFFIX_HIGHLIGHT, { fg = "#3b4048" })
end

local function first_file_line()
	for line = 1, vim.api.nvim_buf_line_count(state.bufnr) do
		if state.line_paths[line] then
			return line
		end
	end
	return nil
end

local function move_to_file_line(line)
	if line then
		vim.api.nvim_win_set_cursor(0, { line, 0 })
	end
end

local function ensure_buffer()
	if is_valid_buffer(state.bufnr) then
		return state.bufnr
	end

	state.bufnr = find_existing_trail_buffer()
	if not state.bufnr then
		state.bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(state.bufnr, TRAIL_BUFFER_NAME)
	end
	mark_trail_buffer(state.bufnr)

	vim.keymap.set("n", "q", M.close, { buffer = state.bufnr, silent = true, nowait = true })
	vim.keymap.set("n", "<CR>", M.open_selected, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "l", M.open_selected, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "j", M.move_next_file, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "k", M.move_previous_file, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "<Down>", M.move_next_file, { buffer = state.bufnr, silent = true })
	vim.keymap.set("n", "<Up>", M.move_previous_file, { buffer = state.bufnr, silent = true })

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
		vim.wo[state.winid].winfixwidth = true
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

function M.clean_invalid_session_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if is_valid_buffer(bufnr) and looks_like_restored_trail_buffer(bufnr) and not is_marked_trail_buffer(bufnr) then
			vim.api.nvim_buf_delete(bufnr, { force = true })
		end
	end
end

function M.render()
	if not is_valid_buffer(state.bufnr) then
		return
	end

	setup_highlights()

	local records = session.get_records()
	local recency_highlights = recency.by_path(records)
	local lines = {}
	local file_spans = {}
	local directory_spans = {}
	local edge_suffix_spans = {}
	state.line_paths = {}

	render_node(
		tree.build(records, { root = session.get_root() or vim.fn.getcwd() }),
		0,
		lines,
		file_spans,
		directory_spans,
		edge_suffix_spans
	)

	if #lines == 0 then
		lines = { "No files visited yet" }
	end

	vim.bo[state.bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
	vim.bo[state.bufnr].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.bufnr, namespace, 0, -1)
	vim.api.nvim_buf_clear_namespace(state.bufnr, recency_namespace, 0, -1)
	vim.api.nvim_buf_clear_namespace(state.bufnr, directory_namespace, 0, -1)
	vim.api.nvim_buf_clear_namespace(state.bufnr, edge_suffix_namespace, 0, -1)

	for line, span in pairs(directory_spans) do
		vim.api.nvim_buf_add_highlight(
			state.bufnr,
			directory_namespace,
			DIRECTORY_HIGHLIGHT,
			line - 1,
			span.start_col,
			span.end_col
		)
	end

	for line, span in pairs(edge_suffix_spans) do
		vim.api.nvim_buf_add_highlight(
			state.bufnr,
			edge_suffix_namespace,
			EDGE_SUFFIX_HIGHLIGHT,
			line - 1,
			span.start_col,
			span.end_col
		)
	end

	local current = session.get_current_file()
	local current_line = nil
	for line, span in pairs(file_spans) do
		local is_current = current and span.path == current
		local highlight = recency_highlights[span.path]

		if highlight then
			vim.api.nvim_buf_add_highlight(
				state.bufnr,
				recency_namespace,
				highlight,
				line - 1,
				span.start_col,
				span.end_col
			)
		end

		if is_current then
			current_line = line
			vim.api.nvim_buf_add_highlight(state.bufnr, namespace, "CursorLine", line - 1, 0, -1)
		end
	end

	if is_valid_window(state.winid) then
		vim.api.nvim_win_set_cursor(state.winid, { current_line or first_file_line() or 1, 0 })
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

function M.move_next_file()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	for line = current_line + 1, vim.api.nvim_buf_line_count(state.bufnr) do
		if state.line_paths[line] then
			move_to_file_line(line)
			return
		end
	end
end

function M.move_previous_file()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	for line = current_line - 1, 1, -1 do
		if state.line_paths[line] then
			move_to_file_line(line)
			return
		end
	end
end

function M.is_open()
	return is_valid_window(state.winid)
end

return M
