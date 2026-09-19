return {
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      processor = "magick_cli",
      integrations = {
          typst = {
              enabled = false,
          },
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          floating_windows = true,
        },
      },
    },
  },
}
