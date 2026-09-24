return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "python", "lua", "c", "cpp", "java", "sql",
      "html", "css", "javascript", "typst",
      "markdown", "markdown_inline", "bash",
      "json", "yaml", "toml", "vim", "vimdoc", "query", "mermaid"
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "python", "lua", "c", "cpp", "java", "sql",
        "html", "css", "javascript", "typst",
        "markdown", "bash", "json", "yaml", "toml", "mermaid"
      },
      callback = function()
        pcall(vim.treesitter.start)
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
