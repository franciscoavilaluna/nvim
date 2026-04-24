local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.ruler = true
opt.mouse = "a"
opt.showmatch = true
opt.showcmd = true
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.linebreak = true
opt.breakindent = true
opt.history = 1000
opt.laststatus = 2
opt.swapfile = false
opt.autoread = true
opt.mousehide = true
opt.backspace = { "indent", "eol", "start" }

opt.errorbells = false
opt.visualbell = false

vim.cmd("syntax on")
vim.cmd("syntax enable")

local hl = vim.api.nvim_set_hl

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

hl(0, "Comment", { italic = true })
hl(0, "Function", { italic = true })
hl(0, "Keyword", { bold = true })
hl(0, "Statement", { bold = true })

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.magic = true

opt.complete = ".,w,b,u,t"
opt.pumheight = 10
vim.cmd("filetype plugin indent on")
opt.shortmess:append("cI")
vim.g.loaded_sql_completion = 1
vim.g.omni_sql_no_default_maps = 1

opt.cmdheight = 1
opt.showmode = true
