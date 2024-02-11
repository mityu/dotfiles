local function textobj_map(maps)
  local dst = {}
  for _, v in ipairs(maps) do
    table.insert(dst, { v, mode = {'o', 'v'} })
  end
  return dst
end

return {
  {
    'https://github.com/kana/vim-textobj-user',
  },
  {
    'https://github.com/kana/vim-textobj-line',
    dependencies = { 'kana/vim-textobj-user' },
    keys = textobj_map({ 'il', 'al' }),
  },
  {
    'https://github.com/kana/vim-textobj-entire',
    dependencies = { 'kana/vim-textobj-user' },
    keys = textobj_map({ 'ia', 'aa' }),
    init = function() vim.g.textobj_entire_no_default_keymappings = true end,
    config = function()
      vim.keymap.set({'v', 'o'}, 'ia', '<Plug>(textobj-entire-i)')
      vim.keymap.set({'v', 'o'}, 'aa', '<Plug>(textobj-entire-a)')
    end,
  }
}
