local M = {}

local function sort_keys(tbl)
	local keys = {}
	for key, _ in pairs(tbl) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function split_path(path)
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

local function relative_path(path, root)
	if not root or root == "" then
		return vim.fn.fnamemodify(path, ":.")
	end

	local normalized_root = root:gsub("/$", "")
	if path == normalized_root then
		return vim.fn.fnamemodify(path, ":t")
	end

	local prefix = normalized_root .. "/"
	if vim.startswith(path, prefix) then
		return string.sub(path, #prefix + 1)
	end

	return vim.fn.fnamemodify(path, ":.")
end

local function new_dir(name, path)
	return {
		type = "directory",
		name = name,
		path = path,
		directories = {},
		files = {},
		children = {},
	}
end

local function materialize(node)
	local children = {}

	for _, name in ipairs(sort_keys(node.directories)) do
		local child = node.directories[name]
		materialize(child)
		table.insert(children, child)
	end

	table.sort(node.files, function(left, right)
		return left.name < right.name
	end)

	for _, file in ipairs(node.files) do
		table.insert(children, file)
	end

	node.children = children
	return node
end

function M.build(files, opts)
	opts = opts or {}
	local root = new_dir("", "")

	for _, item in ipairs(files) do
		local path = type(item) == "table" and item.path or item
		local rel = relative_path(path, opts.root)
		if rel and rel ~= "" and rel ~= "." then
			local parts = split_path(rel)
			local filename = parts[#parts]
			local dir = root
			local current_path = ""

			for index = 1, #parts - 1 do
				local name = parts[index]
				current_path = current_path == "" and name or (current_path .. "/" .. name)
				if not dir.directories[name] then
					dir.directories[name] = new_dir(name, current_path)
				end
				dir = dir.directories[name]
			end

			table.insert(dir.files, {
				type = "file",
				name = filename,
				path = path,
				edges = type(item) == "table" and item.edges or nil,
				last_visit_seq = type(item) == "table" and item.last_visit_seq or nil,
			})
		end
	end

	return materialize(root)
end

return M
