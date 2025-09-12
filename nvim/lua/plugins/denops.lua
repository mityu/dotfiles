return {
  'https://github.com/vim-denops/denops.vim',
  lazy = false,
  init = function()
    local lazy = require('lazy.core.config')
    local helper = require('vimrc.helper')

    vim.env.DENOPS_TEST_DENOPS_PATH = lazy.plugins['denops.vim']['dir']
    vim.api.nvim_create_user_command('DenopsUpdateCache', function(_)
      vim.fn['denops#cache#update']({ reload = true })
    end, { bar = true })

    if helper.is_plugin_installed('nvim-notify') then
      local notify = require('notify')
      helper.create_autocmd('User', {
        group = 'vimrc',
        pattern = 'DenopsReady',
        callback = function()
          notify.notify('Denops is ready.')
        end,
      })
    end
  end,
}
