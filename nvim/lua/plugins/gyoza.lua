return {
  'https://github.com/mityu/vim-gyoza',
  event = { 'VeryLazy' },
  init = function()
    vim.g.gyoza_disable_auto_setup = true
  end,
  config = function()
    local helper = require('vimrc.helper')
    local now = require('vimrc.now')

    helper.create_autocmd('InsertEnter', {
      group = 'vimrc-gyoza',
      once = true,
      callback = function()
        vim.fn['gyoza#enable']()
        vim.fn['vimrc#gyoza#load_rules']()
      end,
    })

    helper.create_autocmd('FileType', {
      group = 'vimrc-gyoza',
      callback = now(function()
        local loaded_filetypes = {}
        local extend_rules = vim.fn['vimrc#gyoza#extend_rules']
        local inherit_table = {
          vimspec = 'vim',
          cpp = 'c',
          otex = 'tex',
          bash = 'sh',
          zsh = 'sh',
        }
        return function(ev)
          local filetype = ev.match
          if loaded_filetypes[filetype] then
            return
          end
          loaded_filetypes[filetype] = true

          local inherit = inherit_table[filetype]
          if inherit ~= nil then
            extend_rules(filetype, inherit)
          end
        end
      end),
    })
  end,
}
