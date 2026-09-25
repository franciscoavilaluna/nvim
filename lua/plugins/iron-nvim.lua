return {
  "Vigemus/iron.nvim",
  enabled = true,
  config = function()
    local iron = require("iron.core")
    local view = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup({
      config = {
        scratch_repl = true,
        repl_definition = {
          sh = {
            command = { "bash" },
          },
          python = {
            command = { "ipython", "--no-autoindent" },
            format = require("iron.fts.common").bracketed_paste,
            block_dividers = { "# %%", "#%%" },
          },
          matlab ={
            command = { "matlab", "-nodesktop", "-nosplash" }
          }
        },
        repl_filetype = function(bufnr, ft)
          return ft
        end,
        dap_integration = true,
        repl_open_cmd = view.split.vertical.rightbelow("%40"),
      },
      keymaps = {
        toggle_repl = "<space>jr",
        restart_repl = "<space>jR",
        send_motion = "<space>js",
        visual_send = "<space>js",
        send_file = "<space>jf",
        send_line = "<space>jl",
        send_paragraph = "<space>jp",
        send_until_cursor = "<space>ju",
        send_mark = "<space>jm",
        send_code_block = "<space>jb",
        send_code_block_and_move = "<space>jn",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>j<cr>",
        interrupt = "<space>j<space>",
        exit = "<space>jq",
        clear = "<space>kl",
      },
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true,
      env = {
        BROWSER = "firefox",
      },
    })

    vim.keymap.set("n", "<space>jf", "<cmd>IronFocus<cr>", { desc = "Iron: Focus REPL" })
    vim.keymap.set("n", "<space>jh", "<cmd>IronHide<cr>", { desc = "Iron: Hide REPL" })
  end,
}
