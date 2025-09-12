local function textobj_map(maps)
  local dst = {}
  for _, v in ipairs(maps) do
    table.insert(dst, { v, mode = { 'o', 'v' } })
  end
  return dst
end

return {
  {
    'https://github.com/kana/vim-textobj-user',
    lazy = false,
  },
  {
    'https://github.com/kana/vim-textobj-line',
    keys = textobj_map({ 'il', 'al' }),
  },
  {
    'https://github.com/kana/vim-textobj-entire',
    keys = textobj_map({ 'ia', 'aa' }),
    init = function()
      vim.g.textobj_entire_no_default_keymappings = true
    end,
    config = function()
      vim.keymap.set({ 'v', 'o' }, 'ia', '<Plug>(textobj-entire-i)')
      vim.keymap.set({ 'v', 'o' }, 'aa', '<Plug>(textobj-entire-a)')
    end,
  },
  {
    'https://github.com/kana/vim-textobj-indent',
    keys = textobj_map({ 'ii', 'iI', 'ai', 'aI' }),
  },
  {
    'https://github.com/thinca/vim-textobj-between',
    keys = textobj_map({ 'id', 'ad' }),
    init = function()
      vim.g.textobj_between_no_default_mappings = true
    end,
    config = function()
      vim.keymap.set({ 'v', 'o' }, 'id', '<Plug>(textobj-between-i)')
      vim.keymap.set({ 'v', 'o' }, 'ad', '<Plug>(textobj-between-a)')
    end,
  },
}
