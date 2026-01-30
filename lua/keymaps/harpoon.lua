vim.keymap.set("n", "<leader>A", function()
	require("harpoon"):list():add()
end, { desc = "Add to harpoon" })

vim.keymap.set("n", "<leader>h", function()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Open harpoon" })
