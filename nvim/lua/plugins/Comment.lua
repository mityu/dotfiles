return {
  'https://github.com/numToStr/Comment.nvim',
  keys = { { 'm/', mode = {'n', 'v'} }, { '<C-l><C-j>', mode = 'i' } },
  config = function()
    local utils = require('Comment.utils')
    local ft = require('Comment.ft')

    require('Comment').setup({
      mappings = { basic = false, extra = false },
    })
    vim.keymap.set('i', '<C-l><C-j>', '<ESC><Cmd>lua require("Comment.api").insert.linewise.eol()<CR>')
    vim.keymap.set('n', 'm/', '<Plug>(comment_toggle_linewise)')
    vim.keymap.set('v', 'm/', '<Plug>(comment_toggle_linewise_visual)')
  end,
}
