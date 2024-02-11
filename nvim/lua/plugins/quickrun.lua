return {
  'https://github.com/thinca/vim-quickrun',
  dependencies = {
    'https://github.com/lambdalisue/vim-quickrun-neovim-job',
  },
  keys = {
    {'<Space>r', '<Plug>(quickrun)', mode = {'n', 'v'} },
  },
  cmd = 'Quickrun',
  config = function()
    local config = {
      _ = {
        runner = 'neovim_job',
      },
    }
    vim.keymap.set('n', '<C-c>', function()
      if vim.fn['quickrun#session#exists']() then
        return '<Cmd>call quickrun#session#sweep()<CR>'
      end
      return '<C-c>'
    end, { expr = true })
    vim.g.quickrun_config = config
  end
}
