local function expand(key)
  return vim.fn['ambicmd#expand'](key)
end

---@param query string
---@return string[]
local function build_rule(query)
  local rule = {}
  table.insert(rule, [[\c^]] .. query .. '$')
  table.insert(rule, [[\c^]] .. query)

  for len = 1, string.len(query) do
    local prefix = string.gsub(string.upper(string.sub(query, 1, len)), '.', [[%0.\{-}]])
    local suffix = string.sub(query, len + 1)
    local matcher = [[\C^]] .. prefix .. suffix
    table.insert(rule, matcher .. '$')
    table.insert(rule, matcher)
  end

  table.insert(rule, [[\c]] .. query)
  table.insert(rule, [[.\{-}]] .. string.gsub(query, '.', [[%0.\{-}]]))
  return rule
end

local function setup_for_cmdwin()
  local function setup_expand(lhs, rhs)
    vim.keymap.set('i', lhs, function()
      local expander = expand(rhs)
      return (expander == rhs and '' or '<C-g>u') .. expander
    end, { expr = true, buffer = true })
  end
  setup_expand('<Space>', '<Space>')
  setup_expand('<bar>', '<bar>')
  setup_expand('<CR>', '<CR>')
  setup_expand('<C-j>', '')
end

return {
  'https://github.com/thinca/vim-ambicmd',
  event = { 'CmdlineEnter', 'CmdwinEnter' },
  config = function()
    local helper = require('vimrc.helper')
    local function gen_expand(key)
      return function()
        return expand(key)
      end
    end

    vim.keymap.set('c', '<CR>', gen_expand('<CR>'), { expr = true })
    vim.keymap.set('c', '<Space>', gen_expand('<Space>'), { expr = true })
    helper.create_autocmd('CmdwinEnter', {
      group = 'vimrc-ambicmd',
      pattern = ':',
      callback = setup_for_cmdwin,
    })

    vim.g['ambicmd#show_completion_menu'] = true
    vim.g['ambicmd#build_rule'] = build_rule
  end,
}
