package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. vim.fn.getcwd() .. "/lua/?/init.lua;" .. package.path

local tree = require("trail.tree")

local function assert_equal(actual, expected, message)
	if actual ~= expected then
		error((message or "assertion failed") .. ": expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual), 2)
	end
end

local function assert_node(node, expected, message)
	assert_equal(node.type, expected.type, message .. " type")
	assert_equal(node.name, expected.name, message .. " name")
	if expected.path then
		assert_equal(node.path, expected.path, message .. " path")
	end

	local actual_children = node.children or {}
	local expected_children = expected.children or {}
	assert_equal(#actual_children, #expected_children, message .. " child count")

	for index, child in ipairs(expected_children) do
		assert_node(actual_children[index], child, message .. " child " .. index)
	end
end

local built = tree.build({
	"/repo/zeta.lua",
	"/repo/src/b.lua",
	"/repo/src/a.lua",
	"/repo/test/spec.lua",
	"/repo/src/nested/c.lua",
}, { root = "/repo" })

assert_node(built, {
	type = "directory",
	name = "",
	children = {
		{
			type = "directory",
			name = "src",
			children = {
				{
					type = "directory",
					name = "nested",
					children = {
						{ type = "file", name = "c.lua" },
					},
				},
				{ type = "file", name = "a.lua" },
				{ type = "file", name = "b.lua" },
			},
		},
		{
			type = "directory",
			name = "test",
			children = {
				{ type = "file", name = "spec.lua" },
			},
		},
		{ type = "file", name = "zeta.lua" },
	},
}, "tree")

assert_equal(built.children[1].children[2].path, "/repo/src/a.lua", "file path is preserved")

print("trail_tree_spec: ok")
