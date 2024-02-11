-- vim: shiftwidth=2 expandtab:

local vim_did_start = vim.fn.has('vim_starting') == 0
if not vim_did_start then
  vim.opt.encoding = 'utf-8'
  vim.env.MYVIMRC = vim.fn.resolve(vim.fn.expand('<sfile>'))
end

vim.scriptencoding = 'utf-8'

vim.api.nvim_create_augroup('vimrc', { clear = true })

vim.language = 'C'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.wildmenu = true
vim.opt.pumheight = 10
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.showmatch = true
vim.opt.matchtime = 1
-- vim.opt.imdisable = false
vim.opt.wrapscan = false
vim.opt.lazyredraw = true
vim.opt.laststatus = 2
vim.opt.scrolloff = 1
vim.opt.wildoptions = { 'pum', 'fuzzy' }
-- vim.opt.wildignore&
vim.opt.wildignore:append('*.DS_STORE')
vim.opt.history = 500
vim.opt.keywordprg = ':help'
vim.opt.fileformat = 'unix'
vim.opt.virtualedit = 'block'
vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 100
vim.opt.isfname:remove('=')
-- vim.opt.spelllang&
vim.opt.spelllang:append('cjk')
vim.opt.statusline = '%m%y[#%n] %<%t'
vim.opt.equalalways = false

if vim.fn.executable('rg') == 1 then
  vim.opt.grepprg = 'rg --vimgrep'
  vim.opt.grepformat = '%f:%l:%c:%m'
elseif vim.fn.executable('ag') then
  vim.opt.grepprg = 'ag --vimgrep'
  vim.opt.grepformat = '%f:%l:%c:%m'
end

vim.keymap.set('n', '<Space>w', '<Cmd>update<CR>')
vim.keymap.set('n', '<Space>q', '<Cmd>quit<CR>')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'gl', 'gt')
vim.keymap.set('n', 'gh', 'gT')
vim.keymap.set('n', '<C-w>t', '<Cmd>tabnew<CR>')
vim.keymap.set('n', '<Space>tk', '<Cmd>split | terminal<CR>')
vim.keymap.set('n', '<Space>tj', '<Cmd>belowright split | terminal<CR>')
vim.keymap.set('n', '<Space>th', '<Cmd>vsplit | terminal<CR>')
vim.keymap.set('n', '<Space>tl', '<Cmd>belowright vsplit | terminal<CR>')
vim.keymap.set('n', '<Space>tt', '<Cmd>tabnew | terminal<CR>')
vim.keymap.set('n', 'ZZ', '<Nop>')
vim.keymap.set('n', 'ZQ', '<Nop>')
vim.keymap.set('n', 'm', '<Nop>')
vim.keymap.set('n', '<Space>sv', '<Cmd>source $MYVIMRC<CR>')
vim.keymap.set('n', '<Space>ev', '<Cmd>edit $MYVIMRC<CR>')
vim.keymap.set('n', '<CR>', 'o<ESC>')
vim.keymap.set('n', '<C-h>', '<Cmd>nohlsearch<CR>')
vim.keymap.set({'n', 'v'}, '<C-k>', '7gk')
vim.keymap.set({'n', 'v'}, '<C-j>', '7gj')
vim.keymap.set({'n', 'v'}, "'", ':', {noremap = false})
vim.keymap.set({'n', 'v', 'o', 'i', 'c'}, '<C-@>', '<ESC>')
vim.keymap.set('i', '<C-l>', '<C-x>')
vim.keymap.set('i', '<C-m>', '<C-g>u<C-m>')
vim.keymap.set('c', '<C-l>', '<C-f>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-a>', '<C-b>')
vim.keymap.set('c', '<C-[>', '<C-c>')
vim.keymap.set('c', '<C-p>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<Up>'
end, { expr = true })
vim.keymap.set('c', '<C-n>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Down>'
end, { expr = true })
vim.keymap.set('t', '<C-/>', [[<C-\><C-n>]])

vim.cmd 'iabbrev todo: TODO:'
vim.cmd 'iabbrev fixme: FIXME:'
vim.cmd 'iabbrev xxx: XXX:'
vim.cmd 'iabbrev note: NOTE:'

vim.api.nvim_create_autocmd('TermOpen', {
  group = 'vimrc',
  command = 'startinsert!',
})

-- Load plugin configurations only when startup.
if not vim_did_start then
  local lazy_root_path = vim.fn.stdpath('cache') .. '/lazy'
  local lazy_plugin_path = lazy_root_path .. '/lazy.nvim'
  if not vim.uv.fs_stat(lazy_plugin_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      lazy_plugin_path,
    })
  end
  vim.opt.runtimepath:prepend(lazy_plugin_path)

  -- vim.api.nvim_create_autocmd('User', {
  --   pattern = 'LazyVimStarted',
  --   callback = function() require('lazy').profile() end,
  --   once = true,
  -- })

  require("lazy").setup('plugins', {
    root = lazy_root_path,
    defaults = { lazy = true },
    performance = {
      rtp = {
        disabled_plugins = {
          'gzip', 'netrwPlugin', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin', 'rplugin',
        },
      },
    },
    change_detection = {
      enabled = false,
    },
  })
end

if not vim.g.colors_name then
  vim.cmd 'colorscheme habamax'
end
