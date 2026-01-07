local colorscheme = vim.fs.joinpath(
  require('vimrc.helper').stdpath('dotvim-runtime'),
  'colors',
  'domusaurea.vim'
)
vim.cmd.source(colorscheme)

vim.g['terminal_color_0'] = '#000000'
vim.g['terminal_color_1'] = '#d54e53'
vim.g['terminal_color_2'] = '#b9ca4a'
vim.g['terminal_color_3'] = '#e6c547'
vim.g['terminal_color_4'] = '#7aa6da'
vim.g['terminal_color_5'] = '#c397d8'
vim.g['terminal_color_6'] = '#70c0ba'
vim.g['terminal_color_7'] = '#eaeaea'
vim.g['terminal_color_8'] = '#666666'
vim.g['terminal_color_9'] = '#ff3334'
vim.g['terminal_color_10'] = '#9ec400'
vim.g['terminal_color_11'] = '#e7c547'
vim.g['terminal_color_12'] = '#7aa6da'
vim.g['terminal_color_13'] = '#b77ee0'
vim.g['terminal_color_14'] = '#54ced6'
vim.g['terminal_color_15'] = '#ffffff'
