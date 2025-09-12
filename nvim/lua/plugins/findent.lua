return {
  'https://github.com/lambdalisue/vim-findent',
  cmd = 'Findent',
  init = function()
    local helper = require('vimrc.helper')
    helper.create_autocmd('FileType', {
      group = 'vimrc',
      callback = function()
        local rejectBuftypes = { 'quickfix', 'help', 'terminal', 'prompt', 'popup' }
        if
            not vim.bo.modifiable
            or vim.bo.filetype == 'help'
            or vim.list_contains(rejectBuftypes, vim.bo.buftype)
        then
          return
        end
        vim.cmd('Findent')
      end,
    })
  end,
}
