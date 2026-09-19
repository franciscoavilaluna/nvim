return {
  {
    'williamboman/mason.nvim',
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'basedpyright',
        'jdtls',
        'clangd',
        'tinymist',
      },
      auto_update = true,
      run_on_start = true,
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup()

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        pyright = {},
        jdtls = {},
        sqlls = {},
        html = {},
        cssls = {},
        clangd = {},
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config[name] = config
        vim.lsp.enable(name)
      end

      vim.lsp.config['tinymist'] = {
        cmd = { 'tinymist' },
        filetypes = { 'typst' },
        root_markers = { 'typst.toml', '.git' },
        capabilities = capabilities,
        settings = {
          exportPdf = 'onType',
        },
      }
      vim.lsp.enable('tinymist')
    end,
  },
}
