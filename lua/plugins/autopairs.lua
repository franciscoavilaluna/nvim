return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter', -- Se carga únicamente al entrar en modo inserción
  opts = {
    check_ts = true, -- Habilita integración con Treesitter para evitar autopairs dentro de strings/comentarios
    ts_config = {
      lua = { 'string' }, -- No añadir autopairs en strings de Lua
      javascript = { 'template_string' }, -- No añadir autopairs en template strings de JS
    },
    fast_wrap = {
      map = '<M-e>', -- Alt + e para envolver la palabra/expresión más cercana entre paréntesis o corchetes
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
