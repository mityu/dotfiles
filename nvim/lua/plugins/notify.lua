return {
  'https://github.com/rcarriga/nvim-notify',
  config = function()
    local notify = require('notify')
    -- vim.notify = notify
    notify.setup({
      render = 'compact',
      stages = 'slide',
    })
  end,
}
