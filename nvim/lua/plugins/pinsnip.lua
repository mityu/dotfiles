return {
  'https://github.com/mityu/vim-pinsnip',
  event = 'VeryLazy',
  config = function()
    local helper = require('vimrc.helper')
    vim.keymap.set('i', '<C-j>', function()
      if helper.is_plugin_loaded('ddc.vim') and vim.fnok['ddc#visible']() then
        vim.fn['ddc#hide']()
      end
      return '<Plug>(pinsnip-expand)'
    end, { expr = true })
  end,
}
