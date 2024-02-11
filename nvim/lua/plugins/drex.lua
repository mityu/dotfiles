local function get_launch_path()
  if vim.fn.expand('%') ~= '' and vim.bo.buftype == '' and vim.bo.buflisted then
    return vim.fn.expand('%:h')
  else
    return vim.fn.getcwd(vim.fn.winnr())
  end
end

local function search_action()
  local search = require('drex.actions.search')
  search.search({
    keybindings = {
      ['<C-k>'] = search.actions.goto_prev,
      ['<C-j>'] = search.actions.goto_next,
      ['<C-c>'] = search.actions.close,
      ['<C-h>'] = search.actions.backspace,
      ['<C-u>'] = function(_) return '' end,
      ['<C-w>'] = function(args) return vim.fn.substitute(args.input, [[\w\+\s*$]], '', '') end,
    },
  })
end

return {
  'https://github.com/TheBlob42/drex.nvim',
  cmd = 'Drex',
  keys = { '<Space>f' },
  config = function()
    local drex = require('drex')
    local elements = require('drex.elements')
    local utils = require('drex.utils')

    vim.keymap.set('n', '<Space>f', function() drex.open_directory_buffer(get_launch_path()) end)

    require('drex.config').configure({
      colored_icons = true,
      hide_cursor = true,
      hijack_netrw = false,
      disable_default_keybindings = true,
      keybindings = {
        ['n'] = {
          ['o'] = function()
            local line = vim.api.nvim_get_current_line()
            if utils.is_open_directory(line) then
              elements.collapse_directory()
            else
              elements.expand_element()
            end
          end,
          ['h'] = function() elements.open_parent_directory() end,
          ['l'] = function() elements.open_directory() end,
          ['<CR>'] = function() elements.open_file('edit') end,
          ['<C-g>'] = function() require("drex.actions.stats").stats() end,
          ['/'] = search_action,
          ['i'] = search_action,
        },
      }
    })
  end,
}
