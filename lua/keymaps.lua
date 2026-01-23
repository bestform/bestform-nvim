-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader><space>", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Telescope keymaps" })

-- clear highlights when pressing esc
vim.keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>e", "<Cmd>Neotree<CR>")

-- TODO: test if this works. For now it does not habe an effect but it can be because we do not habe any diagnostics yet
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic Quickfix list" })

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
