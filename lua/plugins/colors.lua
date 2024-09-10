function ColorMyPencils(color)
    color = color or "base16-black-metal-bathory"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
end

return {
    {
        "RRethy/base16-nvim",
        config = function()
            ColorMyPencils()
        end,
    },
}
