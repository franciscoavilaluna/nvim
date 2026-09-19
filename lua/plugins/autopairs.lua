return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    check_ts = true,
    ts_config = {
      lua = { 'string' },
      javascript = { 'template_string' },
    },
    fast_wrap = {
      map = '<S-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = [=[[%'%"%]%}%)% interrogate%s]=],
      end_key = '$',
      before_key = 'h',
      after_key = 'l',
      cursor_pos_before = true,
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      manual_position = true,
      highlight = 'Search',
      highlight_grey = 'Comment'
    },
  },
}
