local session = require("trail.session")
local view = require("trail.view")

local M = {}

local group = vim.api.nvim_create_augroup("trail-tracker", { clear = true })
local did_wrap_lsp = false

local lsp_methods = {
	["textDocument/definition"] = "definition",
	["textDocument/references"] = "reference",
	["textDocument/implementation"] = "implementation",
	["textDocument/typeDefinition"] = "type_definition",
}

-- Non-LSP edge detection design:
-- We use a contextual heuristic based on the previous buffer/window filetype.
-- When leaving a known UI buffer (Telescope, fzf-lua, neo-tree, nvim-tree,
-- netrw) we store the intended edge type. On the next BufEnter to a normal
-- file, if no LSP jump is pending, we attribute that edge type to the landed
-- file. For all other normal buffer entries we assume buffer_switch.
-- LSP jumps are coordinated by wrapping vim.lsp.buf.* entry points so that
-- BufEnter can consume the LSP edge type before falling back to heuristics.
-- To avoid false positives when a picker is cancelled and focus returns to the
-- same file, we compare the new buffer with the last normal buffer left; if
-- they match we downgrade the UI edge to buffer_switch.
local pending = {
	lsp = nil, -- { edge_type = string, consumed = boolean }
	ui = nil,  -- { edge_type = string }
}

local last_normal_bufnr = nil

local function render_if_needed(changed)
	if changed or view.is_open() then
		view.render()
	end
end

local function record_landed_buffer(edge_type)
	vim.schedule(function()
		-- If BufEnter already consumed this LSP jump, skip fallback recording.
		if pending.lsp and pending.lsp.consumed then
			pending.lsp = nil
			return
		end
		render_if_needed(session.record_buffer(0, edge_type))
	end)
end

local function set_pending_lsp(edge_type)
	pending.lsp = { edge_type = edge_type, consumed = false }
end

local function consume_pending_lsp()
	if pending.lsp then
		local edge_type = pending.lsp.edge_type
		pending.lsp = { edge_type = edge_type, consumed = true }
		return edge_type
	end
	return nil
end

local function set_pending_ui(edge_type)
	pending.ui = { edge_type = edge_type }
end

local function consume_pending_ui()
	if pending.ui then
		local edge_type = pending.ui.edge_type
		pending.ui = nil
		return edge_type
	end
	return nil
end

local ui_filetypes = {
	TelescopePrompt = "search",
	fzf = "search",
	["neo-tree"] = "file_tree",
	NvimTree = "file_tree",
	netrw = "file_tree",
}

local function infer_edge_type(bufnr)
	local lsp_edge = consume_pending_lsp()
	if lsp_edge then
		return lsp_edge
	end

	local ui_edge = consume_pending_ui()
	if ui_edge then
		-- If we returned to the same normal buffer we left, the picker was
		-- likely cancelled; downgrade to buffer_switch.
		if last_normal_bufnr and bufnr == last_normal_bufnr then
			return "buffer_switch"
		end
		return ui_edge
	end

	return "buffer_switch"
end

function M.wrap_lsp_handlers()
	if did_wrap_lsp then
		return
	end
	did_wrap_lsp = true

	-- Wrap vim.lsp.buf.* entry points so we know an LSP jump is starting
	-- before BufEnter fires on the destination buffer.
	local lsp_buf_methods = {
		definition = "definition",
		references = "reference",
		implementation = "implementation",
		typeDefinition = "type_definition",
	}
	for method, edge_type in pairs(lsp_buf_methods) do
		local original = vim.lsp.buf[method]
		if original then
			vim.lsp.buf[method] = function(...)
				set_pending_lsp(edge_type)
				return original(...)
			end
		end
	end

	for method, edge_type in pairs(lsp_methods) do
		local original_handler = vim.lsp.handlers[method]
		vim.lsp.handlers[method] = function(...)
			local result = nil
			if original_handler then
				result = original_handler(...)
			end
			record_landed_buffer(edge_type)
			return result
		end
	end

	local original_buf_request_all = vim.lsp.buf_request_all
	vim.lsp.buf_request_all = function(bufnr, method, params, handler)
		local edge_type = lsp_methods[method]
		if not edge_type or type(handler) ~= "function" then
			return original_buf_request_all(bufnr, method, params, handler)
		end

		return original_buf_request_all(bufnr, method, params, function(...)
			local result = handler(...)
			record_landed_buffer(edge_type)
			return result
		end)
	end

	local original_buf_request = vim.lsp.buf_request
	vim.lsp.buf_request = function(bufnr, method, params, handler, ...)
		local edge_type = lsp_methods[method]
		if not edge_type or type(handler) ~= "function" then
			return original_buf_request(bufnr, method, params, handler, ...)
		end

		return original_buf_request(bufnr, method, params, function(...)
			local result = handler(...)
			record_landed_buffer(edge_type)
			return result
		end, ...)
	end
end

function M.setup()
	vim.api.nvim_clear_autocmds({ group = group })
	M.wrap_lsp_handlers()

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		desc = "Track file visits for exploration sessions",
		callback = function(event)
			if vim.api.nvim_get_option_value("buftype", { buf = event.buf }) ~= "" then
				return
			end
			local edge_type = infer_edge_type(event.buf)
			render_if_needed(session.record_buffer(event.buf, edge_type))
		end,
	})

	vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
		group = group,
		desc = "Detect non-LSP UI navigation context",
		callback = function(event)
			local ft = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
			local edge_type = ui_filetypes[ft]
			if edge_type then
				set_pending_ui(edge_type)
			end

			if vim.api.nvim_get_option_value("buftype", { buf = event.buf }) == "" then
				last_normal_bufnr = event.buf
			end
		end,
	})
end

return M
