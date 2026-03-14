-- clear highlights when pressing esc
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic Quickfix list" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })

-- quickfix
vim.keymap.set("n", "<leader>cn", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>cp", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })

--Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy UI" })

-- diagnostics
vim.keymap.set(
	"n",
	"<Leader>dd",
	":lua vim.diagnostic.open_float()<CR>",
	{ noremap = true, silent = true, desc = "Open diagnostics in float" }
)

-- mini.files
vim.keymap.set("n", "<leader>E", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Open Mini.Files" })
