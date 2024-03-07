return {
  {
    'https://github.com/rose-pine/neovim',
    name = 'rose-pine',
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd 'colorscheme rose-pine'
    end,
  },
  {
    'ribru17/bamboo.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      require('bamboo').setup({
        dim_inactive = true,
        code_style = {
          comments = 'none',
          conditionals = 'none',
          keywords = 'none',
          functions = 'none',
          namespaces = 'none',
          parameters = 'none',
          strings = 'none',
          variables = 'none',
        },
      })
      require('bamboo').load()
    end,
  },
  {
    'https://github.com/navarasu/onedark.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      local onedark = require('onedark')
      onedark.setup({
        style = 'warmer',
        code_style = {
          comments = 'none',
        },
      })
    end,
  },
  {
    "gmr458/vscode_modern_theme.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("vscode_modern").setup({
        cursorline = true,
        transparent_background = false,
        nvim_tree_darker = true,
      })
      vim.cmd.colorscheme("vscode_modern")
    end,
  },
  {
    'https://github.com/Mofiqul/vscode.nvim',
    lazy = true,
    priority = 1000,
    config = function()
      require('vscode').setup {
        style = 'dark',
        transparent = false,
        italic_comments = false,
      }
      require('vscode').load()
    end,
  },
  {
    "zootedb0t/citruszest.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('citruszest')
    end
  },
  {
    'https://github.com/lvim-tech/lvim-colorscheme',
    lazy = true,
    priority = 1000,
    config = function()
      require('lvim-colorscheme').setup {
        styles = {
          comments = { italic = false, bold = false },
          keywords = { italic = false, bold = false },
          functions = { italic = false, bold = false },
          variables = {},
        },
      }
    end,
  },
}
