return {
  'https://github.com/machakann/vim-sandwich',
  keys = {
    { 'ma', '<Plug>(operator-sandwich-add)', mode = {'n', 'v'} },
    { 'md', '<Plug>(operator-sandwich-delete)', mode = {'n', 'v'} },
    { 'mr', '<Plug>(operator-sandwich-replace)', mode = {'n', 'v'} },
  },
  init = function()
    vim.g.sandwich_no_default_key_mappings = 1
  end,
  config = function()
    vim.fn['operator#sandwich#set']('all', 'all', 'highlight', 0)
  end,
}
