local map = vim.keymap.set
local function aug(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

local au = vim.api.nvim_create_autocmd
local group = aug("SQL")
local web_group = aug("WebDev")
local java_group = aug("JavaDev")
local typst_group = aug("TypstDev")

au("FileType", {
    pattern = "sql",
    group = group,
    callback = function()
        local sql = require("custom.sql")
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
        map("n", "<F10>", function()
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
    pattern = "java",
    group = java_group,
    callback = function(ev)
        map("n", "<F10>", function()
            if vim.fn.executable("javac") == 0 then
                vim.notify("javac not found in PATH", vim.log.levels.ERROR, { title = "Java Compiler" })
                return
            end

            vim.cmd("write")

            local dir = vim.fn.expand("%:p:h")
            local files = vim.fn.glob(dir .. "/*.java", false, true)

            if #files == 0 then
                vim.notify("No .java files found", vim.log.levels.WARN, { title = "Java Compiler" })
                return
            end

            vim.notify("Compiling Java files...", vim.log.levels.INFO, { title = "Java Compiler" })

            vim.system(vim.list_extend({ "javac" }, files), { text = true }, function(res)
                vim.schedule(function()
                    if res.code ~= 0 then
                        local msg = res.stderr ~= "" and res.stderr or res.stdout or "Unknown error"
                        vim.notify("Compilation failed:\n" .. msg, vim.log.levels.ERROR, { title = "Java Compiler" })
                    else
                        vim.notify("Compilation successful!", vim.log.levels.INFO, { title = "Java Compiler" })
                    end
                end)
            end)
        end, { buffer = ev.buf, silent = true, desc = "Compile Java files" })
    end,
})

au("FileType", {
    pattern = { "typst" },
    group = typst_group,
    callback = function()
        local opts = { buffer = true, silent = true }
        map("n", "<F10>", function()
            vim.cmd("write")
            vim.notify("Starting Typst Preview...", vim.log.levels.INFO, { title = "Typst" })
            vim.cmd("TypstPreview")
        end, opts)
    end,
})

au("VimLeave", {
    group = web_group,
    callback = function()
        os.execute("fuser -k 8080/tcp > /dev/null 2>&1")
    end,
})
