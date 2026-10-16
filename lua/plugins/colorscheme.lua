return {
	"scottmckendry/cyberdream.nvim",
	lazy = false,
	priority = 1000,
    opts = {
        transparent = false,
        saturation = 0.8,
        italic_comments = true,
        hide_fillchars = false,
        borderless_pickers = false,
        cache = true,
    },
	config = function(_, opts)
		require("cyberdream").setup(opts)
        vim.cmd("colorscheme cyberdream")
	end,
}
