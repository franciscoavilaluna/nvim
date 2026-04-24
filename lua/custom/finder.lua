local M = {}

function M.find_files()
	local cmd = "fd --type f --strip-cwd-prefix --hidden --exclude .git"
	local handle = io.popen(cmd)
	local all_files = {}
	if handle then
		for file in handle:read("*a"):gmatch("[^\r\n]+") do
			table.insert(all_files, file)
		end
		handle:close()
	end

	local prompt_buf = vim.api.nvim_create_buf(false, true)
	local results_buf = vim.api.nvim_create_buf(false, true)
	local preview_buf = vim.api.nvim_create_buf(false, true)

	local w_width = vim.o.columns
	local w_height = vim.o.lines
	local width = math.floor(w_width * 0.9)
	local height = math.floor(w_height * 0.8)
	local col = math.floor((w_width - width) / 2)
	local row = math.floor((w_height - height) / 2)

	local left_width = math.floor(width * 0.4)
	local right_width = width - left_width - 2

	local res_win = vim.api.nvim_open_win(results_buf, false, {
		relative = "editor",
		width = left_width,
		height = height - 3,
		col = col,
		row = row + 3,
		style = "minimal",
		border = "rounded",
		title = " Results ",
		title_pos = "center",
	})

	local prev_win = vim.api.nvim_open_win(preview_buf, false, {
		relative = "editor",
		width = right_width,
		height = height,
		col = col + left_width + 1,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " Preview ",
		title_pos = "center",
	})

	local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
		relative = "editor",
		width = left_width,
		height = 1,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " Search ",
		title_pos = "center",
	})

	vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, all_files)
	vim.api.nvim_win_set_option(res_win, "cursorline", true)
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { "" })

	local function update_preview()
		if not vim.api.nvim_win_is_valid(res_win) or not vim.api.nvim_win_is_valid(prev_win) then
			return
		end

		local cursor = vim.api.nvim_win_get_cursor(res_win)
		local count = vim.api.nvim_buf_line_count(results_buf)

		if count == 0 or (count == 1 and vim.api.nvim_buf_get_lines(results_buf, 0, 1, false)[1] == "") then
			vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
			vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { " No matches found " })
			vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
			return
		end

		local file = vim.api.nvim_buf_get_lines(results_buf, cursor[1] - 1, cursor[1], false)[1]

		if file and file ~= "" and vim.fn.filereadable(file) == 1 then
			local lines = vim.fn.readfile(file, "", 100)
			local clean_lines = {}
			for _, line in ipairs(lines) do
				table.insert(clean_lines, (line:gsub("[\r\n]", " ")))
			end

			vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
			vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, clean_lines)
			vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)

			local ft = vim.filetype.match({ filename = file })
			if ft then
				vim.api.nvim_buf_set_option(preview_buf, "filetype", ft)
			end
		end
	end

	local function filter()
		if not vim.api.nvim_win_is_valid(prompt_win) or not vim.api.nvim_win_is_valid(res_win) then
			return
		end

		local input = vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1] or ""
		local filtered = {}
		for _, f in ipairs(all_files) do
			if f:lower():find(input:lower(), 1, true) then
				table.insert(filtered, f)
			end
		end

		vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, filtered)

		if #filtered > 0 then
			pcall(vim.api.nvim_win_set_cursor, res_win, { 1, 0 })
		end

		update_preview()
	end

	vim.api.nvim_buf_attach(prompt_buf, false, {
		on_lines = function()
			vim.schedule(filter)
		end,
	})

	local close = function()
		pcall(vim.api.nvim_win_close, prompt_win, true)
		pcall(vim.api.nvim_win_close, res_win, true)
		pcall(vim.api.nvim_win_close, prev_win, true)
		vim.cmd("stopinsert")
	end

	local opts = { buffer = prompt_buf, silent = true }

	vim.keymap.set("i", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(res_win)
		local file = vim.api.nvim_buf_get_lines(results_buf, cursor[1] - 1, cursor[1], false)[1]
		close()
		if file and file ~= "" then
			vim.cmd("edit " .. vim.fn.fnameescape(file))
		end
	end, opts)

	local move = function(dir)
		local cursor = vim.api.nvim_win_get_cursor(res_win)
		local count = vim.api.nvim_buf_line_count(results_buf)
		if dir == "down" and cursor[1] < count then
			vim.api.nvim_win_set_cursor(res_win, { cursor[1] + 1, 0 })
		elseif dir == "up" and cursor[1] > 1 then
			vim.api.nvim_win_set_cursor(res_win, { cursor[1] - 1, 0 })
		end
		update_preview()
	end

	vim.keymap.set("i", "<C-j>", function()
		move("down")
	end, opts)
	vim.keymap.set("i", "<C-k>", function()
		move("up")
	end, opts)
	vim.keymap.set("i", "<Esc>", close, opts)

	update_preview()
	vim.cmd("startinsert!")
end

return M
