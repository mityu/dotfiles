return {
  'https://github.com/NeogitOrg/neogit',
  dependencies = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
  },
  branch = 'nightly',
  cmd = 'Neogit',
  keys = { '<Space>g' },
  config = function()
    local neogit = require('neogit')
    neogit.setup({
      kind = 'replace',
    })
    vim.keymap.set('n', '<Space>g', function()
      local path = vim.fn.expand('%:h')
      if path == '' then
        neogit.open()
      else
        neogit.open({ cwd = path })
      end
    end)
  end,
}
