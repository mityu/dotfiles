return {
  'https://github.com/nvim-telescope/telescope.nvim',
  dependencies = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/lambdalisue/mr.vim',
  },
  cmd = 'Telescope',
  keys = { '<Space>b', '<Space>k' },
  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    local config = require('telescope.config')

    local function mru(opts_given)
      local opts = opts_given or {}
      local list = vim.fn['mr#mru#list']()
      require('telescope.pickers').new(opts, {
        prompt_title = 'MRU',
        finder = require('telescope.finders').new_table({
          results = list,
          entry_maker = require('telescope.make_entry').gen_from_file(opts),
        }),
        previewer = config.values.file_previewer(opts),
        sorter = config.values.file_sorter(opts),
      }):find()
    end

    telescope.setup({
      defaults = {
        initial_mode = 'normal',
        layout_strategy = 'horizontal',
        layout_config = {
          prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
        mappings = {
          n = {
            ['q'] = 'close',
          },
          i = {
            ['<C-u>'] = false,
            ['<C-m>'] = { '<ESC>', type = 'command' },
            ['<C-j>'] = 'move_selection_next',
            ['<C-k>'] = 'move_selection_previous',
          },
        },
      },
    })
    vim.keymap.set('n', '<Space>b', builtin.buffers)
    vim.keymap.set('n', '<Space>k', mru)
  end,
}
