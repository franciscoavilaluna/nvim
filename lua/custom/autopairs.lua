local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function feed(keys)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local map_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["`"] = "`" }

for open, close in pairs(map_pairs) do
	map("i", open, open .. close .. "<Left>", opts)

	map("i", close, function()
		local col = vim.api.nvim_win_get_cursor(0)[2]
		local line = vim.api.nvim_get_current_line()
		local char_after = line:sub(col + 1, col + 1)

		if char_after == close then
			feed("<Right>")
		else
			feed(close)
		end
	end, opts)
end

map("i", "'", function()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local char_before = line:sub(col, col)
	local char_after = line:sub(col + 1, col + 1)

	if char_before:match("[%w]") then
		feed("'")
	elseif char_after == "'" then
		feed("<Right>")
	else
		feed("''<Left>")
	end
end, opts)

map("i", "<BS>", function()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local char_before = line:sub(col, col)
	local char_after = line:sub(col + 1, col + 1)
	local del_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'", ["`"] = "`" }

	if del_pairs[char_before] == char_after then
		feed("<BS><Del>")
	else
		feed("<BS>")
	end
end, opts)

map("i", "<CR>", function()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	if line:sub(col, col) == "{" and line:sub(col + 1, col + 1) == "}" then
		feed("<CR><Esc>O")
	else
		feed("<CR>")
	end
end, opts)

local visual_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ['"'] = '"', ["'"] = "'" }
for open, close in pairs(visual_pairs) do
	map("v", open, string.format("<Esc>`>a%s<Esc>`<i%s<Esc>", close, open), opts)
end
