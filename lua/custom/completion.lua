local M = {}

vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
vim.opt.complete = ".,w,b,u,t"
vim.opt.shortmess:append("cIa")

local auto_menu_enabled = true

local function open_completion()
	if not auto_menu_enabled or vim.fn.pumvisible() ~= 0 or vim.fn.mode() ~= "i" or vim.fn.reg_recording() ~= "" then
		return
	end

	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local char_before = line:sub(col, col)

	if char_before:match("[%w_%.]") then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", true)

		vim.defer_fn(function()
			if vim.fn.pumvisible() == 0 and vim.bo.omnifunc ~= "" then
				pcall(function()
					if vim.bo.filetype ~= "sql" then
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true),
							"n",
							true
						)
					end
				end)
			end
		end, 15)
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("pacompletion", { clear = true })
	vim.api.nvim_create_autocmd("InsertCharPre", {
		group = group,
		pattern = "*",
		callback = function()
			vim.defer_fn(open_completion, 15)
		end,
	})
end

function M.toggle()
	auto_menu_enabled = not auto_menu_enabled
	local status = auto_menu_enabled and "ON" or "OFF"
	local color = auto_menu_enabled and "Identifier" or "WarningMsg"
	vim.api.nvim_echo({ { "󰭆 Auto-Completion: " .. status, color } }, false, {})
end

function M.super_tab()
	if vim.fn.pumvisible() ~= 0 then
		return vim.api.nvim_replace_termcodes("<C-n>", true, false, true)
	end
	return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
end

return M
