return {
  'https://github.com/mityu/vim-cmdhistory',
  event = 'VeryLazy',
  config = function()
    local helper = require('vimrc.helper')
    helper.create_autocmd('User', {
      group = 'vimrc',
      pattern = 'cmdhistory-initialize',
      callback = function()
        vim.fn['cmdhistory#set_default_mappings']()
        vim.fn['cmdhistory#map_action']('<ESC>', { 'no-operation' })
        vim.fn['cmdhistory#map_action']('<C-@>', { 'no-operation' })
      end,
    })
    helper.create_autocmd('CmdwinEnter', {
      group = 'vimrc',
      callback = function()
        vim.keymap.set('n', '/', '<Cmd>call cmdhistory#select()<CR>', { buffer = true })
      end,
    })
    vim.keymap.set('c', '/', '<Cmd>call cmdhistory#select()<CR>')
  end,
}
