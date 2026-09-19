local map = vim.keymap.set

map("n", "<leader>lc", ":source $MYVIMRC<CR>", { desc = "Reload config" })
map("n", "<leader>pv", ":20Lex<CR>", { desc = "Open netrw" })
map("n", "Q", "<nop>")

map("n", "<C-w>-", ":split<CR>", { desc = "Vertical split" })
map("n", "<C-w>\\", ":vsplit<CR>", { desc = "Horizontal split" })
map("n", "H", "<C-w>h", { desc = "Left window" })
map("n", "J", "<C-w>j", { desc = "Down window" })
map("n", "K", "<C-w>k", { desc = "Up window" })
map("n", "L", "<C-w>l", { desc = "Right window" })

map("n", "<C-w>p", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<C-w>n", ":bnext<CR>", { desc = "Next buffer" })

map("n", "<C-d>", "<C-d>zz", { desc = "Center down scroll" })
map("n", "<C-u>", "<C-u>zz", { desc = "Center up scroll" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {desc = "Search and replace word under cursor",})

map("n", "<leader>f", function()
	require("custom.format").format_buffer()
end, { desc = "Format file" })

map("n", "<leader>a", function()
	require("custom.hook").add_file()
end, { desc = "Hook: Mark" })

map("n", "<leader>h", function()
	require("custom.hook").toggle_ui()
end, { desc = "Hook: Toggle Menu" })

map("n", "<leader>1", function()
	require("custom.hook").nav_file(1)
end)
map("n", "<leader>2", function()
	require("custom.hook").nav_file(2)
end)
map("n", "<leader>3", function()
	require("custom.hook").nav_file(3)
end)
map("n", "<leader>4", function()
	require("custom.hook").nav_file(4)
end)

map("n", "<leader>mi", ":MoltenInit<CR>", { desc = "Init Kernel Jupyter" })
map("n", "<leader>e", ":MoltenEvaluateOperator<CR>", { desc = "Evaluate operator" })
map("n", "<leader>rl", ":MoltenEvaluateLine<CR>", { desc = "Exec current line" })
map("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Exect visual selection" })
map("n", "<leader>rc", ":MoltenReevaluateCell<CR>", { desc = "Re exec section" })
map("n", "<leader>ho", ":MoltenHideOutput<CR>", { desc = "Hide output" })

vim.keymap.set("n", "<leader>vs", ":VenvSelect<CR>", { desc = "Seleccionar virtualenv" })
