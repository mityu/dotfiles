---@return string
local function get_launch_path()
  if vim.fn.expand('%') ~= '' and vim.bo.buftype == '' and vim.bo.buflisted then
    return vim.fn.expand('%:h')
  end
  return vim.fn.getcwd(vim.fn.winnr())
end

local function on_open()
  local helper = require('vimrc.helper')

  vim.keymap.set('n', 'o', function()
    return vim.fn['fern#smart#leaf'](
      '<Nop>',
      '<Plug>(fern-action-expand:stay)',
      '<Plug>(fern-action-collapse)'
    )
  end, { expr = true, buffer = true })
  vim.keymap.set('n', 'h', '<Plug>(fern-action-leave)', { buffer = true })
  vim.keymap.set('n', 'l', '<Plug>(fern-action-enter)', { buffer = true })
  vim.keymap.set('n', '<CR>', '<Plug>(fern-action-open:edit-or-error)', { buffer = true })
  vim.keymap.set('n', 'x', '<Plug>(fern-action-hidden:toggle)', { buffer = true })
  vim.keymap.set(
    'n',
    'm',
    '<Plug>(fern-action-mark:toggle)',
    { buffer = true, nowait = true }
  )
  vim.keymap.set('n', '<C-l>', '<Plug>(fern-action-reload:all)', { buffer = true })
  -- vim.keymap.set('n', '<C-g>', function()
  --   return vim.fn['fern#smart#scheme']('<C-g>', { file = '<Cmd>call fern#helper#call()<CR>' })
  -- end, { buffer = true, expr = true, silent = true })
  -- vim.keymap.set('n', 'q', '', {buffer = true})
  vim.keymap.set('n', '<Space>f', function()
    helper.echo('Fern is already open.')
  end, { buffer = true })
  vim.keymap.set('n', '/', '<Plug>(fern-action-include)', { buffer = true })
  vim.keymap.set(
    'n',
    '<C-h>',
    '<Plug>(fern-action-include=)<C-e><C-u><CR>',
    { buffer = true }
  )
  vim.keymap.set('n', 'p', '<Plug>(fern-action-preview)', { buffer = true })

  if helper.is_plugin_installed('fall.vim') then
    vim.keymap.set('n', 'a', '<Cmd>Fall fern-action<CR>', { buffer = true })
    vim.keymap.set('n', 'A', '<Plug>(fern-action-choice)', { buffer = true })
  else
    vim.keymap.set('n', 'a', '<Plug>(fern-action-choice)', { buffer = true })
  end
  -- nnoremap <buffer> <expr> <silent> <C-g> fern#smart#scheme('<C-g>',
  --       \ {'file': '<Cmd>call fern#helper#call("<SID>FernShowRootPath")<CR>'})
  -- nnoremap <buffer> q <Cmd>call <SID>FernClose()<CR>
end

return {
  {
    'https://github.com/lambdalisue/vim-fern',
    dependencies = {
      { 'https://github.com/lambdalisue/vim-fern-hijack', lazy = false },
      'https://github.com/lambdalisue/vim-fern-renderer-nerdfont',
      'https://github.com/lambdalisue/vim-nerdfont',
    },
    cmd = 'Fern',
    init = function()
      vim.keymap.set('n', '<Space>f', function()
        local path = vim.fn.fnameescape(get_launch_path())
        vim.cmd.Fern(path)
      end)
      vim.g['fern#renderer'] = 'nerdfont'
      vim.g['fern#renderer#nerdfont#padding'] = '  '
      vim.g['fern#default_exclude'] = '.DS_Store'
      vim.g['fern#disable_default_mappings'] = true
    end,
    config = function()
      local helper = require('vimrc.helper')

      helper.create_autocmd('FileType', {
        group = 'vimrc-fern',
        pattern = 'fern',
        callback = on_open,
      })
    end,
  },
}
