return {
  'https://github.com/neovim/nvim-lspconfig',
  event = 'VeryLazy',
  config = function()
    require('vimrc.lsp')
  end,
}
