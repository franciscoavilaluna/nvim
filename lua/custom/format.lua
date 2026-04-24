local M = {}

local formatters = {
	sql = "sqlformat --reindent --keywords lower --identifiers lower -",
	python = "black -q -",
	c = "clang-format",
	cpp = "clang-format",
	rust = "rustfmt",
	lua = "stylua -",
}

function M.format_buffer()
	local ft = vim.bo.filetype
	local cmd = formatters[ft]

	if not cmd then
		vim.notify("There's no syntax formatting for " .. ft, vim.log.levels.WARN)
		return
	end

	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local content = table.concat(lines, "\n")

	local formatted = vim.fn.system(cmd, content)

	if vim.v.shell_error == 0 then
		local formatted_lines = vim.split(formatted:gsub("%s+$", ""), "\n")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
		pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
	else
		vim.notify("Couldn't format " .. ft, vim.log.levels.ERROR)
	end
end

return M
