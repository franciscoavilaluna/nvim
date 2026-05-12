return {
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")

    ls.setup({
      enable_autosnippets = true,
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    require("luasnip.loaders.from_lua").lazy_load({
      paths = { vim.fn.stdpath("config") .. "/lua/snippets" }
    })

    ls.filetype_extend("tex", { 
        "latex",
    })
    vim.keymap.set({ "i", "s" }, "<C-n>", function()
      if ls.jumpable(1) then ls.jump(1) end
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-p>p", function()
      if ls.jumpable(-1) then ls.jump(-1) end
    end, { silent = true })
  end,
}
