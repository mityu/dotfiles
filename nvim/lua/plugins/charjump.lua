return {
  'https://github.com/mityu/vim-charjump',
  keys = {
    { 'f', '<Plug>(charjump-inclusive-forward)',  mode = { 'n', 'x', 'o' } },
    { 'F', '<Plug>(charjump-inclusive-backward)', mode = { 'n', 'x', 'o' } },
    { 't', '<Plug>(charjump-exclusive-forward)',  mode = { 'n', 'x', 'o' } },
    { 'T', '<Plug>(charjump-exclusive-backward)', mode = { 'n', 'x', 'o' } },
    { ';', '<Plug>(charjump-repeat-obverse)',     mode = { 'n', 'x', 'o' } },
    { ',', '<Plug>(charjump-repeat-reverse)',     mode = { 'n', 'x', 'o' } },
  },
}
