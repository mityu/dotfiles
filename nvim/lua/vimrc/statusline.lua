local helper = require('vimrc.helper')

local function git_branch_default()
  return 'no-gin'
end
local function git_branch_by_gin()
  return '%{vimrc#helper#statusline_git_branch_by_gin()}'
end

local git_branch = helper.is_plugin_loaded('vim-gin') and git_branch_by_gin
  or git_branch_default

helper.create_autocmd('User', {
  group = 'vimrc',
  pattern = 'DenopsPluginPost:gin',
  callback = function()
    git_branch = git_branch_by_gin
    vim.cmd.redrawstatus()
  end,
})
helper.create_autocmd('User', {
  group = 'vimrc',
  pattern = 'DenopsPluginUnloadPre:gin',
  callback = function()
    git_branch = git_branch_default
  end,
})

---@return string
local function surround_by_bracket(s)
  return '[' .. s .. ']'
end

---@param v string
---@param default string
---@return string
local function or_if_empty(v, default)
  return vim.trim(v) == '' and default or v
end

---@return string
local function generate_statusline()
  return table.concat({
    '%m',
    surround_by_bracket(or_if_empty(vim.bo.filetype, 'No ft')),
    surround_by_bracket('#' .. vim.fn.bufnr('%')),
    surround_by_bracket(git_branch()),
    [[%{vimrc#helper#statusline_filename_label('%')}]],
    '%<%=',
    surround_by_bracket(vim.opt.fileformat:get()),
    surround_by_bracket(or_if_empty(vim.opt.fileencoding:get(), vim.opt.encoding:get())),
    surround_by_bracket(vim.fn.pathshorten(vim.fn.getcwd(vim.fn.winnr()))),
  }, '')
end

return generate_statusline
