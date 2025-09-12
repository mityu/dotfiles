return {
  'https://github.com/thinca/vim-themis',
  event = 'VeryLazy',
  init = function()
    vim.env.THEMIS_VIM = vim.v.progpath
  end,
  -- init = function()
  --   local lazy = require('lazy.core.config')
  --   local themisbin = vim.fs.joinpath(lazy.plugins['vim-themis'].dir, 'bin')
  --
  --   vim.env.THEMIS_VIM = vim.v.progpath
  --
  --   if not string.find(vim.env.PATH, themisbin) then
  --     local sep = vim.fnok.has('win32') and ';' or ':'
  --     vim.env.PATH = themisbin .. sep .. vim.env.PATH
  --   end
  -- end
}
