return {
  'https://github.com/hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'amarakon/nvim-cmp-buffer-lines',
  },
  event = 'InsertEnter',
  config = function()
    local cmp = require('cmp')
    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
          -- vim.snippet.stop()
        end,
      },
      sources = cmp.config.sources(
        { { name = 'nvim_lsp' } },
        { { name = 'buffer' } },
        { { name = 'buffer-lines', opt = { leading_whitespace = false } } }
      ),
      mapping = {
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()),
        ['<C-y>'] = cmp.mapping(cmp.mapping.confirm()),
        ['<C-e>'] = cmp.mapping(cmp.mapping.close()),
      },
      formatting = {
        ---@param entry cmp.Entry
        ---@param vim_item vim.CompletedItem
        ---@return vim.CompletedItem
        format = function(entry, vim_item)
          if entry.source.name == 'nvim_lsp' then
            if vim_item.menu ~= nil then
              vim_item.menu = vim_item.menu .. ' LSP'
            else
              vim_item.menu = 'LSP'
            end
          end
          return vim_item
        end,
      },
      -- window = {
      --   documentation = cmp.config.window.bordered({
      --     winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
      --   }),
      -- }
    })
    vim.keymap.set('i', '<C-l><C-u>', cmp.complete)
  end,
}
