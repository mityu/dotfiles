return {
  'https://github.com/mityu/vim-backpair',
  event = { 'InsertEnter' },
  config = function()
    vim.fn['backpair#enable']()
    vim.fn['backpair#add_pair']('(', ')')
    vim.fn['backpair#add_pair']('[', ']', { skip_if_ongoing = { '[[]' } })
    vim.fn['backpair#add_pair']('<', '>')
    vim.fn['backpair#add_pair']('{', '}')
    vim.fn['backpair#add_pair']('"', '"')
    vim.fn['backpair#add_pair']("'", "'")
    vim.fn['backpair#add_pair']([[\(]], [[\)]])
    vim.fn['backpair#add_pair']([[\%(]], [[\)]])
    vim.fn['backpair#add_pair'](
      '[[',
      ']]',
      { enable_filetypes = { 'lua', 'sh', 'bash', 'zsh', 'toml' } }
    )
    vim.fn['backpair#add_pair']('`', '`', {
      condition = function()
        return vim.trim(vim.fn.getline('.')) ~= '``'
      end,
    })
  end,
}
