-- mini.files
vim.keymap.set("n", "<leader>E", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Open Mini.Files" })
