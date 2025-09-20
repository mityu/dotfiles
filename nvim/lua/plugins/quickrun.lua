return {
  'https://github.com/thinca/vim-quickrun',
  dependencies = {
    'https://github.com/lambdalisue/vim-quickrun-neovim-job',
  },
  keys = {
    { '<Space>r', '<Plug>(quickrun)', mode = { 'n', 'v' } },
  },
  cmd = 'QuickRun',
  config = function()
    local helper = require('vimrc.helper')
    local config = {
      _ = {
        runner = 'neovim_job',
        ['outputter/buffer/close_on_empty'] = true,
      },

      nix = {
        command = 'nix',
        exec = '%c eval --file %s',
        tempfile = '%{tempfile()}.nix',
      },
    }
    vim.keymap.set('n', '<C-c>', function()
      if vim.fnok['quickrun#session#exists']() then
        return '<Cmd>call quickrun#session#sweep()<CR>'
      end
      return '<C-c>'
    end, { expr = true })
    vim.g.quickrun_config = config

    helper.create_autocmd('FileType', {
      group = 'vimrc-quickrun',
      pattern = 'quickrun',
      command = [[nnoremap <buffer> q <C-w>q]],
    })
    helper.create_autocmd('CmdwinEnter', {
      group = 'vimrc-quickrun',
      callback = function()
        vim.keymap.set('n', '<Plug>(quickrun)', function()
          helper.echo(':QuickRun is disabled in cmdwin.')
        end, { buffer = true })
      end,
    })
  end,
}
