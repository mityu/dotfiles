local thisfile = vim.fn.resolve(vim.fn.expand('<sfile>:p'))
local dotfiles = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(thisfile)))
local colorscheme = vim.fs.joinpath(dotfiles, 'vim', 'runtime', 'colors', 'domusaurea.vim')
vim.cmd.source(colorscheme)
vim.cmd.highlight [[IblIndent guifg=black ctermfg=black]]
