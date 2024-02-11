return {
  'https://github.com/hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'amarakon/nvim-cmp-buffer-lines',
    'L3MON4D3/LuaSnip',
  },

  event = 'InsertEnter',

  config = function()
    local luasnip = require('luasnip')
    local cmp = require('cmp')
    cmp.setup({
      snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
      }, {
        { name = 'buffer' },
        { name = 'buffer-lines', opt = { leading_whitespace = false } },
      }),
      mapping = {
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()),
        ['<C-y>'] = cmp.mapping(cmp.mapping.confirm()),
        ['<C-e>'] = cmp.mapping(cmp.mapping.close()),
      },
    })
    vim.keymap.set('i', '<C-l><C-u>', cmp.complete)
  end,
}
