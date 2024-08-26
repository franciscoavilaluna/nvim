-- Set block cursor
vim.opt.guicursor = ""

-- Set nu and rnu
vim.opt.nu = true
vim.opt.relativenumber = true

-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Smart Indenting
vim.opt.smartindent = true

-- Line Wrap
vim.opt.wrap = false

-- Swapfiles
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Incremental Search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Terminal Colors
vim.opt.termguicolors = true

-- Scroll
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Update Time
vim.opt.updatetime = 50
