local function set_indent_color()
  local basehl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
  vim.api.nvim_set_hl(0, 'HlchunkIndent', {
    fg = basehl['bg'] or 0,
    ctermfg = basehl['ctermbg'] or 0,
  })
end

return {
  'https://github.com/shellRaining/hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local helper = require('vimrc.helper')
    helper.create_autocmd('ColorScheme', {
      group = 'vimrc',
      callback = set_indent_color,
    })
    set_indent_color()

    require('hlchunk').setup({
      indent = {
        enable = true,
        delay = 0,
        style = { { link = 'HlchunkIndent' } },
      },
    })
  end,
}
