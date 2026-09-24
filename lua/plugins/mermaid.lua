return {
    "kevalin/mermaid.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("mermaid").setup({
            preview = {
                port = 0,
                renderer = "mermaid.js",
                theme = "dark",
            },
        })
    end,
}
