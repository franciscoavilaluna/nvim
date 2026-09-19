return {
  "benlubas/molten-nvim",
  version = "^1.0.0",
  build = ":UpdateRemotePlugins",
  dependencies = { "3rd/image.nvim" },
  init = function()
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_output_win_max_height = 20
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
  end,
}
