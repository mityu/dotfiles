return {
  'https://github.com/monaqa/dial.nvim',
  init = function()
    vim.keymap.set('n', '<C-a>', function()
      require('dial.map').manipulate('increment', 'normal')
    end)
    vim.keymap.set('n', '<C-x>', function()
      require('dial.map').manipulate('decrement', 'normal')
    end)
    vim.keymap.set('n', 'g<C-a>', function()
      require('dial.map').manipulate('increment', 'gnormal')
    end)
    vim.keymap.set('n', 'g<C-x>', function()
      require('dial.map').manipulate('decrement', 'gnormal')
    end)
    vim.keymap.set('x', '<C-a>', function()
      require('dial.map').manipulate('increment', 'visual')
    end)
    vim.keymap.set('x', '<C-x>', function()
      require('dial.map').manipulate('decrement', 'visual')
    end)
    vim.keymap.set('x', 'g<C-a>', function()
      require('dial.map').manipulate('increment', 'gvisual')
    end)
    vim.keymap.set('x', 'g<C-x>', function()
      require('dial.map').manipulate('decrement', 'gvisual')
    end)
  end,
  config = function()
    local augend = require('dial.augend')
    local config = require('dial.config')
    local basics = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.constant.alias.bool,
    }
    config.augends:register_group({
      default = basics,
    })
    config.augends:on_filetype({
      otex = {
        unpack(basics),
        augend.constant.new({ elements = { 'begin', 'end' } }),
      },
    })
  end,
}
