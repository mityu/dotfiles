return {
  'https://github.com/Shougo/ddc.vim',
  dependencies = {
    'https://github.com/Shougo/ddc-ui-native',
    'https://github.com/Shougo/ddc-source-lsp',
    'https://github.com/Shougo/ddc-source-vim',
    'https://github.com/Shougo/ddc-source-around',
    'https://github.com/tani/ddc-fuzzy',
  },
  event = 'User DenopsReady',
  config = function()
    local helper = require('vimrc.helper')
    vim.fn['ddc#custom#load_config'](
      vim.fs.joinpath(helper.stdpath('dotvim'), 'ddc', 'config.ts')
    )
    vim.fn['ddc#custom#patch_global'](
      'sourceParams',
      { lsp = { lspEngine = 'nvim-lsp' } }
    )
    vim.fn['ddc#enable']()

    helper.create_autocmd('CmdwinEnter', {
      group = 'vimrc',
      callback = function()
        vim.fn['ddc#custom#patch_buffer']('specialBufferCompletion', false)
      end,
    })
  end,
}
