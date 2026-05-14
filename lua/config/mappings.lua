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

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
	desc = "Search and replace word under cursor",
})

map("n", "<leader>f", function()
	require("custom.format").format_buffer()
end, { desc = "Format file" })

require("custom.completion").setup()

map("n", "<leader>o", function()
	require("custom.completion").toggle()
end, { desc = "Toggle Auto-Menu" })

map("i", "<Tab>", function()
	return require("custom.completion").super_tab()
end, { expr = true, noremap = true })
map("i", "<S-Tab>", function()
	if vim.fn.pumvisible() ~= 0 then
		return vim.api.nvim_replace_termcodes("<C-p>", true, false, true)
	end
	return vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true)
end, { expr = true, noremap = true })

map("n", "<leader>t", function()
	require("custom.terminal").toggle()
end, { desc = "Toggle Floating Terminal" })

map("n", "<leader>pf", function()
	require("custom.finder").find_files()
end)

map("n", "<leader>h", function()
	require("custom.hook").add_file()
end, { desc = "Hook: Mark" })

map("n", "<leader>a", function()
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

map("n", "<leader>img", function()
    local line = vim.api.nvim_get_current_line()
    local filename = line:match("{(.-)%.pdf}")
    if not filename then
        print("No se encontró nombre.pdf en la línea")
        return
    end

    local current_file = vim.fn.expand("%:p:h")
    local svg_path = vim.fn.fnamemodify(
        (filename:sub(1,1) == "." or filename:sub(1,1) == "/") and filename or (current_file .. "/" .. filename),
        ":p"
    ) .. ".svg"

    vim.fn.mkdir(vim.fn.fnamemodify(svg_path, ":h"), "p")

    if vim.fn.filereadable(svg_path) == 0 then
        local svg_content = [[
<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200">
  <rect width="100%" height="100%" fill="white"/>
</svg>]]
        vim.fn.writefile(vim.split(svg_content, "\n"), svg_path)
        print("Creado " .. svg_path)
    end

    vim.fn.jobstart({ "inkscape", svg_path }, { detach = true })
end, { desc = "Abrir/crear SVG con Inkscape" })
