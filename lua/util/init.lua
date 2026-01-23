local M = {}

---@type table<number, string>
M.cache = {}

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.getRoot(opts)
	opts = opts or {}
	local buf = opts.buf or vim.api.nvim_get_current_buf()
	local ret = M.cache[buf]
	if not ret then
		-- local roots = M.detect({ all = false, buf = buf })
		-- ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
		M.cache[buf] = vim.uv.cwd()
	end
	if opts and opts.normalize then
		return ret
	end
	return ret
	-- no windows support
	-- return LazyVim.is_win() and ret:gsub("/", "\\") or ret
end

return M
