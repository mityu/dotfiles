local colorscheme = vim.fs.joinpath(
  require('vimrc.helper').stdpath('dotvim-runtime'),
  'colors',
  'reliquiae.vim'
)
vim.cmd(string.format('source %s', colorscheme))

for i, v in ipairs(vim.g.terminal_ansi_colors) do
  vim.g['terminal_color_' .. (i - 1)] = v
end
