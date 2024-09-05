-- Set block cursor
vim.opt.guicursor = ""

-- Set nu and rnu
vim.opt.number = true
vim.opt.relativenumber = true

-- Indenting
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Indenting
vim.opt.smartindent = true
vim.opt.autoindent = true

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

-- Search Settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Terminal Colors
vim.opt.termguicolors = true

-- Scroll
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Update Time
vim.opt.updatetime = 50

-- UI Settings
vim.opt.ruler = true
vim.opt.showmatch = false
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.showcmd = true
vim.opt.path:append('**')
vim.opt.wildmenu = true
vim.opt.wildmode = {'longest:full', 'full'}
vim.opt.autoread = true
vim.opt.errorbells = false
vim.opt.history = 1000

vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    desc = 'Highlight selection on yank',
    pattern = '*',
    callback = function ()
        vim.highlight.on_yank { higroup = 'Search', timeout = 50 }
    end,
})
