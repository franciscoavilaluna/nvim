-- Set mapleader
vim.g.mapleader = " "

-- Open Netrw
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Disable netrw's banner
vim.g.netrw_banner = 0

-- Set minimal style for file listings
vim.g.netrw_liststyle = 3

-- Disable the file size and date
vim.g.netrw_sizestyle = "H"
vim.g.netrw_timefmt = ""

-- Set the window size for netrw (optional)
vim.g.netrw_winsize = 20

-- Disable netrw's preview window (optional)
vim.g.netrw_preview = 1

-- Move code
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Takes line below and appends in previous line
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in midde while scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search terms in the middle while scrolling
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Restart LSP server
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- Copy and paste without loosing the buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Sistem clipboard usage
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Ctrl+C have same functionality as Esc
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable 'Q'
vim.keymap.set("n", "Q", "<nop>")

-- Buffer format code
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-leaderj>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and Replace
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Automate 'chmod +x [file.sh]'
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
