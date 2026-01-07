---@param predicate fun(string): boolean
---@param check_in_it boolean?
local function in_syntax(predicate, check_in_it)
  local function do_check_syngroup()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local groups =
      require('insx.kit.Vim.Syntax').get_syntax_groups({ cursor[1] - 1, cursor[2] - 1 })
    for _, group in ipairs(groups) do
      if predicate(group) then
        return true
      end
    end
    return false
  end

  if check_in_it == nil then
    check_in_it = true
  end

  return {
    enabled = function(enabled, ctx)
      return do_check_syngroup() == check_in_it and enabled(ctx)
    end,
  }
end

---@param predicate fun(string): boolean
local function not_in_syntax(predicate)
  return in_syntax(predicate, false)
end

local function when_balanced(option)
  return {
    enabled = function(enabled, ctx)
      local text = ctx.text()
      local is_balanced = vim.fn.count(text, option.open)
        == vim.fn.count(text, option.close)
      return is_balanced and enabled(ctx)
    end,
  }
end

local function add_auto_pair(opener, closer)
  local insx = require('insx')
  local auto_pair = require('insx.recipe.auto_pair')
  local delete_pair = require('insx.recipe.delete_pair')
  local jump_next = require('insx.recipe.jump_next')
  local esc = insx.esc
  insx.add(opener, auto_pair({ open = opener, close = closer }))
  insx.add('<C-h>', delete_pair({ open_pat = esc(opener), close_pat = esc(closer) }))
  insx.add(
    closer,
    insx.with(jump_next({ jump_pat = { [[\%#]] .. esc(closer) .. [[\zs]] } }), {
      when_balanced({ open = opener, close = closer }),
    })
  )
end

local function config_pinsnip_like()
  local insx = require('insx')
  local add = function(recipe)
    insx.add('<Plug>(vimrc-insx-pinsnip)', recipe)
  end

  -- add('')
end

local function config()
  local insx = require('insx')
  local recipe = {
    auto_pair = require('insx.recipe.auto_pair'),
    delete_pair = require('insx.recipe.delete_pair'),
    pair_spacing = require('insx.recipe.pair_spacing'),
  }
  local esc = insx.esc
  vim.keymap.set('i', '<C-j>', '<Plug>(vimrc-insx-pinsnip)', {})
  config_pinsnip_like()

  add_auto_pair('(', ')')
  add_auto_pair('[', ']')
  add_auto_pair('{', '}')
  add_auto_pair('<', '>')

  insx.add(
    [[']],
    recipe.auto_pair.strings({
      open = [[']],
      close = [[']],
    })
  )
  insx.add(
    [["]],
    recipe.auto_pair.strings({
      open = [["]],
      close = [["]],
    })
  )
  insx.add(
    '<C-h>',
    recipe.delete_pair.strings({
      open_pat = esc([[']]),
      close_pat = esc([[']]),
    })
  )
  insx.add(
    '<C-h>',
    recipe.delete_pair.strings({
      open_pat = esc([["]]),
      close_pat = esc([["]]),
    })
  )

  insx.add(
    '<Space>',
    insx.with(
      recipe.pair_spacing.increase({ open_pat = esc('[['), close_pat = esc(']]') }),
      { insx.with.filetype({ 'otex' }) }
    )
  )
  insx.add(
    '<C-h>',
    insx.with(
      recipe.pair_spacing.decrease({ open_pat = esc('[['), close_pat = esc(']]') }),
      { insx.with.filetype({ 'otex' }) }
    )
  )

  insx.add(
    '<Space>',
    insx.with(
      recipe.pair_spacing.increase({ open_pat = esc('{{'), close_pat = esc('}}') }),
      { insx.with.filetype({ 'ott' }) }
    )
  )
  insx.add(
    '<C-h>',
    insx.with(
      recipe.pair_spacing.decrease({ open_pat = esc('{{'), close_pat = esc('}}') }),
      { insx.with.filetype({ 'ott' }) }
    )
  )

  local with_tex = insx.with.filetype({ 'tex', 'plaintex', 'otex' })
  -- TODO: Support substituting '$$ $$' into '\[ \]'
  insx.add(
    '$',
    insx.with(recipe.auto_pair({ open = '$', close = '$' }), {
      with_tex,
      not_in_syntax(function(group)
        return group:lower():match('texmathzone')
      end),
    })
  )
  insx.add(
    '<C-h>',
    insx.with(recipe.delete_pair({ open_pat = esc('$'), close_pat = esc('$') }), {
      with_tex,
      in_syntax(function(group)
        return group:lower():match('texdelimiter')
      end),
    })
  )
end

return {
  'https://github.com/hrsh7th/nvim-insx',
  event = { 'InsertEnter' },
  config = config,
}
