return {
  'https://github.com/tyru/capture.vim',
  cmd = 'Capture',
  config = function()
    local helper = require('vimrc.helper')
    helper.create_autocmd('FileType', {
      group = 'vimrc',
      pattern = 'capture',
      command = [[nnoremap <buffer> q <C-w>q]],
    })
  end,
}
