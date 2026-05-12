local M = {}

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

M.config = {
	max_entries = 30,
	data_file = vim.fn.stdpath("data") .. "/recent_files.json",
}

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- { [project_root] = { [filepath] = timestamp } }
M.data = {}
M.project_root = nil
M.last_viewed_file = nil

-- ---------------------------------------------------------------------------
-- Private helpers
-- ---------------------------------------------------------------------------

local function ensure_dir(path)
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

local function load_data()
	local path = M.config.data_file
	if vim.fn.filereadable(path) == 0 then
		return
	end

	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or not lines or #lines == 0 then
		return
	end

	local text = table.concat(lines, "\n")
	if text == "" then
		return
	end

	local ok_decode, decoded = pcall(vim.fn.json_decode, text)
	if ok_decode and type(decoded) == "table" then
		M.data = decoded
	end
end

local function save_data()
	-- Trim each project to max_entries, keeping only the newest
	local trimmed = {}
	for root, files in pairs(M.data) do
		local arr = {}
		for file, time in pairs(files) do
			table.insert(arr, { file = file, time = time })
		end
		table.sort(arr, function(a, b)
			return a.time > b.time
		end)

		local limited = {}
		for i = 1, math.min(M.config.max_entries, #arr) do
			limited[arr[i].file] = arr[i].time
		end
		trimmed[root] = limited
	end

	ensure_dir(M.config.data_file)

	local ok, encoded = pcall(vim.fn.json_encode, trimmed)
	if not ok then
		vim.notify("[recent_files] Failed to encode history", vim.log.levels.WARN)
		return
	end

	local ok_write = pcall(vim.fn.writefile, vim.split(encoded, "\n"), M.config.data_file)
	if not ok_write then
		vim.notify("[recent_files] Failed to write history file", vim.log.levels.WARN)
	end
end

local function detect_project_root()
	local cwd = vim.uv.cwd()

	-- Try git root first
	local git_root = vim.trim(
		vim.fn.system("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel 2>/dev/null")
	)
	if vim.v.shell_error == 0 and git_root ~= "" then
		return git_root
	end

	return cwd
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

function M.update_project_root()
	M.project_root = detect_project_root()
end

function M.track_buffer()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)

	-- Skip unnamed, non-file, and directory buffers
	if name == "" then
		return
	end
	local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
	if buftype ~= "" then
		return
	end
	if vim.fn.isdirectory(name) == 1 then
		return
	end

	if not M.project_root then
		M.update_project_root()
	end

	if not M.data[M.project_root] then
		M.data[M.project_root] = {}
	end

	M.data[M.project_root][name] = os.time()
	M.last_viewed_file = name
end

function M.get_recent_files(opts)
	opts = opts or {}

	if not M.project_root then
		M.update_project_root()
	end

	local files = M.data[M.project_root] or {}
	local arr = {}
	for file, time in pairs(files) do
		table.insert(arr, { file = file, time = time })
	end

	table.sort(arr, function(a, b)
		return a.time > b.time
	end)

	local current = opts.current_file or M.last_viewed_file or vim.api.nvim_buf_get_name(0)
	local result = {}
	for _, entry in ipairs(arr) do
		if entry.file ~= current then
			-- Skip files that no longer exist
			if vim.uv.fs_stat(entry.file) then
				table.insert(result, entry.file)
			end
		end
	end

	return result
end

function M.picker(opts)
	opts = opts or {}

	local current_file = opts.current_file
	-- Remove our internal key so it does not leak into Telescope
	opts.current_file = nil

	local finders = require("telescope.finders")
	local pickers = require("telescope.pickers")
	local conf = require("telescope.config").values
	local make_entry = require("telescope.make_entry")

	-- Apply dropdown theme by default unless a layout is already specified
	if not opts.layout_strategy then
		opts = require("telescope.themes").get_dropdown(opts)
	end

	pickers.new(opts, {
		prompt_title = "Recent Files",
		finder = finders.new_table({
			results = M.get_recent_files({ current_file = current_file }),
			entry_maker = make_entry.gen_from_file(opts),
		}),
		sorter = conf.file_sorter and conf.file_sorter(opts) or conf.generic_sorter(opts),
		previewer = conf.file_previewer and conf.file_previewer(opts) or conf.grep_previewer(opts),
	}):find()
end

function M.setup(user_config)
	if user_config then
		M.config = vim.tbl_deep_extend("force", M.config, user_config)
	end

	load_data()
	M.update_project_root()

	local group = vim.api.nvim_create_augroup("RecentFilesTracker", { clear = true })

	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function()
			M.track_buffer()
		end,
		desc = "Track recent file view time",
	})

	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			M.update_project_root()
		end,
		desc = "Update project root on directory change",
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			save_data()
		end,
		desc = "Save recent files history",
	})

	-- Register as a Telescope extension so :Telescope recent_files works
	local ok, telescope = pcall(require, "telescope")
	if ok then
		telescope.register_extension({
			exports = {
				recent_files = M.picker,
			},
		})
	end
end

return M
