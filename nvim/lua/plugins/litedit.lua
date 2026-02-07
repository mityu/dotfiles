return {
  'https://github.com/mityu/vim-litedit',
  cmd = { 'Normal', 'Macro' },
  init = function()
    vim.g.litedit_opts = {
      normal = { dotrepeat = true },
    }
  end,
}
