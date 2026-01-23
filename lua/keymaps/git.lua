vim.keymap.set("n", "<leader>gg", function()
	Snacks.terminal({ "lazygit" }, { cwd = require("util").getRoot() })
end, { desc = "LazyGit" })
