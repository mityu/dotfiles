---@param tabnr number
---@return string
local function generate_tabinfo(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  local dirty_buflist = vim.tbl_filter(function(buf)
    return vim.bo[buf].modified
  end, buflist)
  local dirty = #dirty_buflist > 0

  return ('%s'):format(dirty and '[+]' or '')
end

---@return string
local function generate_tabline()
  local tabline = ''
  local t = vim.fn.tabpagenr()

  for n = 1, vim.fn.tabpagenr('$') do
    tabline = tabline .. '%' .. n .. 'T'
    local info = ' ' .. generate_tabinfo(n) .. ' '
    if vim.trim(info) == '' then
      info = ' '
    end
    if t == n then
      tabline = tabline .. '%#TabLineSel# %999Xx%X' .. info .. '%#TabLine#'
    else
      tabline = tabline .. info
    end
    tabline = tabline .. '%T|'
  end
  tabline = tabline .. '%>%=%#VimrcTablineNvimIndicator# NVIM %#TabLine# '

  return tabline
end

local function set_indicator_color()
  ---@return vim.api.keyset.get_hl_info
  local hlget = function(group)
    return vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
  end

  local color = hlget('Normal')
  local title_color = hlget('Title')
  color.fg = title_color.fg
  color.ctermfg = color.ctermfg

  vim.api.nvim_set_hl(0, 'VimrcTablineNvimIndicator', color)
end

require('vimrc.helper').create_autocmd('ColorScheme', {
  group = 'vimrc',
  callback = set_indicator_color,
})
set_indicator_color()

return generate_tabline
