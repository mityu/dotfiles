return {
  'https://github.com/shellRaining/hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('hlchunk').setup({
      chunk = {
        enable = false,
        use_treesitter = false,
        duration = 0,
        delay = 10,
        style = '#60aaaa',
      },
      indent = {
        enable = true,
        delay = 0,
      },
    })
  end,
}
