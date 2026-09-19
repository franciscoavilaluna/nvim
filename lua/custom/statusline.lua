local M = {}

local function update_colors()
    local bg_color = "NONE"

    vim.api.nvim_set_hl(0, "StatusLine", { 
        ctermfg = 7, ctermbg = "NONE", 
        fg = "NONE", bg = bg_color 
    })
    
    vim.api.nvim_set_hl(0, "StatusLineNC", { 
        ctermfg = 8, ctermbg = "NONE", 
        fg = "#444444", bg = bg_color 
    }) 

    vim.api.nvim_set_hl(0, "StatusLineFile", { 
        ctermfg = 2, ctermbg = "NONE", 
        bold = true 
    })
    
    vim.api.nvim_set_hl(0, "StatusLineMedium", { 
        ctermfg = 4, ctermbg = "NONE" 
    })
    
    vim.api.nvim_set_hl(0, "StatusLineAccent", { 
        ctermfg = 7, ctermbg = "NONE", 
        bold = true 
    })
end

update_colors()

vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
    callback = function()
        update_colors()
    end,
})

function M.active()
    local status_info = ""
    
    if vim.bo.filetype == "sql" then
        local ok, sql = pcall(require, "custom.sql")
        if ok then
            status_info = sql.statusline()
        end
    end

    local sections = {
        "%#StatusLineFile#  %f ",
        "%#StatusLine# %m ",
        status_info,
        "%=",
        "%#StatusLineMedium# %y ",
        "%#StatusLine# %l:%c ",
        "%#StatusLineAccent# %P  ",
    }
    return table.concat(sections)
end

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require('custom.statusline').active()"

return M
