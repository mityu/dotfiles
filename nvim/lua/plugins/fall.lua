local helper = require('vimrc.helper')

local function define_colors()
  vim.api.nvim_set_hl(0, 'FallListMatch', { link = 'Special' })
  vim.api.nvim_set_hl(0, 'FallBorder', { link = 'Normal' })
  vim.cmd([[sign define FallListSelectedSign text=>> linehl=Number]])
end

local function setup_fall_modal()
  vim.fn['fall_modal#default#setup']()

  helper.create_autocmd('User', {
    group = 'vimrc',
    pattern = 'FallModalEnterPrompt:*',
    callback = function(data)
      local picker = data.match:match([[^FallModalEnterPrompt:(.*)$]])
      if picker == 'gin-action' or picker == 'fern-action' then
        vim.fn['fall_modal#mode#change_mode']('insert')
      end
    end,
  })

  helper.create_autocmd('User', {
    group = 'vimrc',
    pattern = 'FallModalDefaultConfigPost:insert',
    callback = function()
      vim.keymap.set('c', '<C-f>', '<Right>')
      vim.keymap.set('c', '<C-b>', '<Left>')
      vim.keymap.set('c', '<C-a>', '<C-b>')
    end,
  })
end

return {
  'https://github.com/vim-fall/fall.vim',
  lazy = false,
  dependencies = {
    { 'https://github.com/mityu/vim-fall-modal' },
  },
  init = function()
    vim.g.fall_custom_path =
      vim.fs.joinpath(helper.stdpath('dotvim'), 'fall', 'custom.ts')

    vim.keymap.set('n', '<Space>k', '<Cmd>Fall mru<CR>')
    vim.keymap.set('n', '<Space>j', '<Cmd>Fall file:project<CR>')
    vim.keymap.set('n', '<Space>b', '<Cmd>Fall buffer<CR>')
    vim.keymap.set('n', '<Space>l', '<Cmd>Fall line<CR>')
    vim.api.nvim_create_user_command('PackFiles', 'Fall file:pack', {})
    vim.api.nvim_create_user_command('Dotfiles', 'Fall file:dotfiles', {})
    -- TODO: LiveGrep command
  end,
  config = function()
    helper.create_autocmd('User', {
      group = 'vimrc',
      pattern = 'FallModalSetup',
      callback = setup_fall_modal,
    })

    helper.create_autocmd('ColorScheme', {
      group = 'vimrc',
      callback = define_colors,
    })
    define_colors()
  end,
}
