local M = {}
M.marks = {}
M.win = -1
M.buf = -1

function M.add_file()
	local file = vim.fn.expand("%:.")
	if file == "" or file == "." then
		return
	end
	for _, v in ipairs(M.marks) do
		if v == file then
			return
		end
	end
	table.insert(M.marks, file)
	vim.api.nvim_echo({ { "󰐃 Hooked: " .. file, "Identifier" } }, false, {})
end

function M.nav_file(id)
	local file = M.marks[id]
	if file then
		vim.cmd("edit " .. file)
	end
end

function M.toggle_ui()
	if vim.api.nvim_win_is_valid(M.win) then
		local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
		M.marks = {}
		for _, line in ipairs(lines) do
			if line ~= "" then
				table.insert(M.marks, line)
			end
		end

		vim.api.nvim_win_close(M.win, true)
		M.win = -1
		return
	end

	M.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, M.marks)

	local width = 30
	local height = 5
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " 󱡁 Files ",
		title_pos = "center",
	}

	M.win = vim.api.nvim_open_win(M.buf, true, opts)

	vim.opt_local.cursorline = true
	vim.opt_local.modifiable = true

	local map_opts = { buffer = M.buf, silent = true }

	vim.keymap.set("n", "<CR>", function()
		local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
		local current_file = vim.api.nvim_get_current_line()

		M.marks = {}
		for _, line in ipairs(lines) do
			if line ~= "" then
				table.insert(M.marks, line)
			end
		end

		vim.api.nvim_win_close(M.win, true)
		M.win = -1
		if current_file ~= "" then
			vim.cmd("edit " .. current_file)
		end
	end, map_opts)

	local close = function()
		if vim.api.nvim_win_is_valid(M.win) then
			local lines = vim.api.nvim_buf_get_lines(M.buf, 0, -1, false)
			M.marks = {}
			for _, line in ipairs(lines) do
				if line ~= "" then
					table.insert(M.marks, line)
				end
			end
			vim.api.nvim_win_close(M.win, true)
		end
		M.win = -1
	end

	vim.keymap.set("n", "q", close, map_opts)
	vim.keymap.set("n", "<Esc>", close, map_opts)
end

return M
