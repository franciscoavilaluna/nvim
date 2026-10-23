return {
	"techwizrd/render-latex.nvim",
	ft = "markdown",
	init = function()
		vim.opt.conceallevel = 2
		vim.opt.concealcursor = "nc"
	end,
	opts = {
		render = {
			preset = "compact",
			inline = "conceal",
			inline_symbols = true,
			live_preview = true,
			hide_on_cmdline = false,
		},
	},
}
