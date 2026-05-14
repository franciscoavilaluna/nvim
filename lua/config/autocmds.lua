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

        map("n", "<leader>fi", function()
            local line = vim.api.nvim_get_current_line()
            local name = line:match("\\imfig%s*%{(.-)}")
            if not name then
                vim.notify("Couldn't find \\imfig{...} under cursor line", vim.log.levels.WARN)
                return
            end

            local tex_dir = vim.fn.expand("%:p:h")
            local svg_path = tex_dir .. "/figures/" .. name .. ".svg"

            vim.fn.mkdir(tex_dir .. "/figures", "p")

            if vim.fn.filereadable(svg_path) == 0 then
                local svg_content = [[
                <svg xmlns="http://www.w3.org/2000/svg" width="300" height="200">
                  <rect width="100%" height="100%" fill="white"/>
                </svg>]]
                vim.fn.writefile(vim.split(svg_content, "\n"), svg_path)
                vim.notify("Created " .. svg_path)
            end

            vim.fn.jobstart({ "inkscape", svg_path }, { detach = true })

            local pdf_path = tex_dir .. "/figures/" .. name .. ".pdf"
            local watcher_cmd = string.format(
                [[inotifywait -m -e close_write --format '%%w' "%s" 2>/dev/null | while read file; do
                     inkscape --export-filename="%s" --export-latex "$file"
                 done]],
                svg_path:gsub('"', '\\"'),
                pdf_path:gsub('"', '\\"')
            )
            vim.fn.jobstart(watcher_cmd, { detach = true, on_exit = function()
                vim.notify("Watcher for " .. svg_path .. " stopped")
            end })
            vim.notify("Watcher initialized for " .. svg_path)
        end, { desc = "Open SVG of \\imfig{...} on Inkscape + watcher" })
    end,
})

au("VimLeave", {
    group = web_group,
    callback = function()
        os.execute("fuser -k 8080/tcp > /dev/null 2>&1")
    end,
})
