local colorscheme = vim.fs.joinpath(
  require('vimrc.helper').stdpath('dotvim-runtime'),
  'colors',
  'reliquiae.vim'
)
vim.cmd(string.format('source %s', colorscheme))
