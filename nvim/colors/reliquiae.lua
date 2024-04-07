local thisfile = vim.fn.resolve(vim.fn.expand('<sfile>:p'))
local dotfiles = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(thisfile)))
local colorscheme = vim.fs.joinpath(dotfiles, 'vim', 'runtime', 'colors', 'reliquiae.vim')
vim.cmd(string.format('source %s', colorscheme))
vim.cmd [[highlight IblIndent guifg=black ctermfg=black]]
