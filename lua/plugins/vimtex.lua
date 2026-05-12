return {
    "lervag/vimtex",
    lazy = false,
    init = function()
        vim.g.tex_flavor = "latex"
        vim.g.vimtex_view_method = "zathura"
    end,
}
