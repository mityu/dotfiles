return {
  'https://github.com/pogyomo/submode.nvim',
  keys = { 'gh', 'gl', '<C-w>+', '<C-w>-', '<C-w><', '<C-w>>' },
  config = function()
    local submode = require('submode')
    submode.setup()

    submode.create('tab-move', { mode = 'n', enter = 'g' })
    submode.register('tab-move', { lhs = 'l', rhs = 'gt' })
    submode.register('tab-move', { lhs = 'h', rhs = 'gT' })

    submode.create('win-resize', { mode = 'n', enter = '<C-w>' })
    submode.register('win-resize', { lhs = '+', rhs = '<C-w>+' })
    submode.register('win-resize', { lhs = '-', rhs = '<C-w>-' })
    submode.register('win-resize', { lhs = '<', rhs = '<C-w><' })
    submode.register('win-resize', { lhs = '>', rhs = '<C-w>>' })
  end,
}
