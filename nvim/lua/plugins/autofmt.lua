return {
  'https://github.com/vim-jp/autofmt',
  lazy = false,
  config = function()
    vim.opt_global.formatexpr = 'autofmt#japanese#formatexpr()'
  end,
}
