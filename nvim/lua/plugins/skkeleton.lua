return {
  {
    'https://github.com/vim-skk/skkeleton',
    dependencies = {
      'https://github.com/skk-dev/dict',
    },
    lazy = false,
    init = function()
      local helper = require('vimrc.helper')

      vim.keymap.set('i', '<C-/>', '<Plug>(skkeleton-toggle)')
      helper.create_autocmd('User', {
        group = 'vimrc',
        pattern = 'skkeleton-initialize-pre',
        callback = function()
          vim.fn['skkeleton#config']({
            globalDictionaries = vim
              .iter({ 'SKK-JISYO.L.json' })
              :map(function(file)
                return vim.fs.joinpath(helper.get_plugin_dir('dict'), 'json', file)
              end)
              :totable(),
            userDictionary = '~/.cache/skkeleton',
            eggLikeNewline = true,
          })

          if vim.g['skkeleton#mapped_keys'] == nil then
            vim.g['skkeleton#mapped_keys'] = {}
          end
          vim.fn.extend(vim.g['skkeleton#mapped_keys'], {
            '<C-n>',
            '<C-p>',
            '<C-y>',
            '<CR>',
            '<C-j>',
            '<C-d>',
          })

          local register_keymap = vim.fn['skkeleton#register_keymap']
          register_keymap('input', ';', 'henkanPoint')
          register_keymap('input', '<C-n>', 'henkanFirst')
          register_keymap('input', '<C-y>', 'kakutei')
          register_keymap('input', '<C-j>', 'kakutei')
          register_keymap('input', '<CR>', 'newline')
          register_keymap('henkan', '<C-p>', 'henkanBackward')
          register_keymap('henkan', '<C-n>', 'henkanForward')
          register_keymap('henkan', '<C-y>', 'kakutei')
          register_keymap('henkan', '<C-j>', 'kakutei')
          register_keymap('henkan', '<CR>', 'newline')
          register_keymap('henkan', '<C-d>', 'purgeCandidate')
        end,
      })
    end,
  },
  {
    'https://github.com/NI57721/skkeleton-state-popup',
    event = 'VeryLazy',
    config = function()
      local helper = require('vimrc.helper')
      helper.create_autocmd('User', {
        group = 'vimrc',
        pattern = 'skkeleton-initialize-pre',
        callback = function()
          vim.fn['skkeleton_state_popup#config']({
            labels = {
              input = { hira = 'あ', kata = 'ア', hankata = 'ｶﾅ', zenkaku = 'Ａ' },
              ['input:okurinasi'] = {
                hira = '▽',
                kata = '▽',
                hankata = '▽',
                abbrev = 'ab',
              },
              ['input:okuriari'] = {
                hira = '▽',
                kata = '▽',
                hankata = '▽',
              },
              henkan = {
                hira = '▼',
                kata = '▼',
                hankata = '▼',
                abbrev = 'ab',
              },
              latin = '_A',
            },
            opts = {
              relative = 'cursor',
              col = 0,
              row = 1,
              anchor = 'NW',
              style = 'minimal',
            },
          })
          vim.fn['skkeleton#config']({
            markerHenkan = '',
            markerHenkanSelect = '',
          })
        end,
      })
      helper.create_autocmd('User', {
        group = 'vimrc',
        pattern = 'skkeleton-enable-pre',
        callback = function()
          vim.fn['skkeleton_state_popup#enable']()
        end,
      })
      helper.create_autocmd('User', {
        group = 'vimrc',
        pattern = 'skkeleton-disable-pre',
        callback = function()
          vim.fn['skkeleton_state_popup#disable']()
        end,
      })
    end,
  },
  {
    'https://github.com/NI57721/skkeleton-henkan-highlight',
    event = 'VeryLazy',
    init = function()
      vim.cmd('highlight SkkeletonHenkan gui=underline term=underline cterm=reverse')
    end,
  },
}
