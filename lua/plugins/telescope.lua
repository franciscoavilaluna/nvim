return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = {
      { '<leader>pf', function() require('telescope.builtin').find_files() end, desc = 'Buscar archivos' },
      
      { '<leader>pg', function() require('telescope.builtin').live_grep() end, desc = 'Buscar texto (Grep)' },
      { '<leader>pb', function() require('telescope.builtin').buffers() end, desc = 'Ver buffers abiertos' },
    },
    opts = {
      defaults = {
        prompt_prefix = ' 🔍 ',
        selection_caret = '  ',
        entry_prefix = '  ',
        sorting_strategy = 'ascending',
        layout_config = {
          horizontal = {
            prompt_position = 'top',
            preview_width = 0.55,
          },
        },
      },
    },
  },
}
