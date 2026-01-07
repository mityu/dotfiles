return {
  {
    'https://github.com/kana/vim-operator-user',
    lazy = false,
  },
  {
    'https://github.com/kana/vim-operator-replace',
    keys = { { 'ms', '<Plug>(operator-replace)', mode = { 'x', 'n', 'o' } } },
  },
  {
    'https://github.com/osyo-manga/vim-operator-swap',
    keys = {
      { 'my', '<Plug>(operator-swap-marking)', mode = { 'x', 'n', 'o' } },
      { 'mp', '<Plug>(operator-swap)', mode = { 'x', 'n', 'o' } },
    },
  },
}
