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
    lazy = false,
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
}
