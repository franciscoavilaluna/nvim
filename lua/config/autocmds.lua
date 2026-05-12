local au = vim.api.nvim_create_autocmd local group = vim.api.nvim_create_augroup("SQL", { clear = true })
local web_group = vim.api.nvim_create_augroup("WevDev", { clear = true })
local latex_group = vim.api.nvim_create_augroup("LatexConfig", { clear = true })

au("FileType", {
	pattern = "sql",
	group = group,
	callback = function()
		local sql = require("custom.sql")
		local map = vim.keymap.set
		local opts = { buffer = true, silent = true }

		vim.schedule(function()
			if sql.setup_session then
				sql.setup_session()
			end
		end)

		vim.api.nvim_buf_create_user_command(0, "SqlMenu", function()
			sql.main_menu()
		end, {})

		map("n", "<leader>db", "<cmd>SqlMenu<CR>", { buffer = true, desc = "SQL Menu" })
		map("n", "<F10>", "vip<esc><cmd>lua require('custom.sql').run_sql('v')<CR>", opts)
		map("v", "<F10>", function()
			sql.run_sql("v")
		end, opts)

		au("BufWinEnter", {
			pattern = "__SQL_Result__",
			group = group,
			callback = function()
				map("n", "q", "<cmd>close<CR>", { buffer = true })
			end,
		})
	end,
})

au("FileType", {
    pattern = { "html", "css", "javascript", "php" },
    group = web_group,
    callback = function()
        local opts = { buffer = true, silent = true }
	vim.keymap.set("n", "<F10>", function()
    os.execute("fuser -k 8080/tcp > /dev/null 2>&1")

    local file_path = vim.fn.expand("%:p")
    local file_dir = vim.fn.fnamemodify(file_path, ":h")
    local file_name = vim.fn.fnamemodify(file_path, ":t")

    local cmd = string.format(
        "cd %s && nohup php -S localhost:8080 > /dev/null 2>&1 &",
        vim.fn.shellescape(file_dir)
    )

    vim.cmd("silent ! " .. cmd)

    vim.defer_fn(function()
        local url = "http://localhost:8080/" .. file_name
        vim.cmd("silent !xdg-open " .. url .. " &")
    end, 1000)
end, opts)
    end,
})

au("FileType", {
    pattern = "tex",
    group = latex_group,
    callback = function()
        local map = vim.keymap.set
        local opts = { buffer = true, silent = true }

        map("n", "<F10>", function()
            local file = vim.fn.expand("%:t")
            local pdf = vim.fn.expand("%:r") .. ".pdf"
            
            vim.notify("Compiling latex file...")
            vim.cmd("silent !latexmk -xelatex " .. vim.fn.shellescape(file))

            local watch_cmd = string.format("latexmk -xelatex -pvc -interaction=nonstopmode -f %s > /dev/null 2>&1 &", vim.fn.shellescape(file))
            vim.cmd("silent ! " .. watch_cmd)

            if vim.fn.filereadable(pdf) == 1 then
                vim.cmd("silent !zathura " .. pdf .. " > /dev/null 2>&1 &")
                vim.notify("Engine and Visualizer active")
            else
                vim.notify("Error: PDF could not generate in time", vim.log.levels.ERROR)
            end
        end, opts)

    end,
})

au("VimLeave", {
    --group = web_group,
    callback = function()
        os.execute("fuser -k 8080/tcp > /dev/null 2>&1")
        os.execute("pkill latexmk")
        os.execute("latexmk -c > /dev/null 2>&1")
    end,
})
