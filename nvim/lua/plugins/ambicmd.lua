return {
  'https://github.com/thinca/vim-ambicmd',
  event = 'CmdlineEnter',
  config = function()
    vim.keymap.set('c', '<CR>', function()
      return vim.fn['ambicmd#expand']('<CR>')
    end, { expr = true })
    vim.keymap.set('c', '<Space>', function()
      return vim.fn['ambicmd#expand']('<Space>')
    end, { expr = true })
  end,
}
