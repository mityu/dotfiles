return {
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  event = 'VeryLazy',
  config = function()
    require('ibl').setup({
      scope = {
        show_start = false,
        show_end = false,
      },
    })
  end,
}
