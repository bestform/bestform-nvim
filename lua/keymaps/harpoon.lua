vim.keymap.set("n", "<leader>A", function()
	require("harpoon"):list():add()
end)

vim.keymap.set("n", "<C-h>", function()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
