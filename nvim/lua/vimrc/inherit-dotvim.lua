-- Inherit my Vim's ftdetct/ftplugin/syntax files for Neovim.

local helper = require('vimrc.helper')
local now = require('vimrc.helper.now')

now(function()
  local files = vim.fs.find(function(name, _)
    return vim.endswith(name, '.vim')
  end, {
    limit = math.huge,
    type = 'file',
    path = vim.fs.joinpath(helper.stdpath('dotvim-runtime'), 'ftdetect'),
  })
  for _, file in ipairs(files) do
    vim.cmd.source(file)
  end
end)
helper.create_autocmd('Syntax', {
  group = 'vimrc-dotvim-syntax',
  callback = function(arg)
    local filetype = arg.match
    local files = vim.fs.find(('%s.vim'):format(filetype), {
      limit = 1,
      type = 'file',
      path = vim.fs.joinpath(helper.stdpath('dotvim-runtime'), 'syntax'),
    })
    for _, file in ipairs(files) do
      vim.cmd.source(vim.fn.fnameescape(file))
    end
  end,
})
helper.create_autocmd('FileType', {
  group = 'vimrc-dotvim-ftplugin',
  callback = function(arg)
    local filetype = arg.match
    if vim.list_contains({ 'markdown', 'coq', 'vim', 'vimspec' }, filetype) then
      -- These ftplugin files are written in Vim9 script therefore disable them for now.
      return
    end

    local files = vim.fs.find(('%s.vim'):format(filetype), {
      limit = 1,
      type = 'file',
      path = vim.fs.joinpath(helper.stdpath('dotvim-runtime'), 'ftplugin'),
    })
    for _, file in ipairs(files) do
      vim.cmd.source(vim.fn.fnameescape(file))
    end
  end,
})
