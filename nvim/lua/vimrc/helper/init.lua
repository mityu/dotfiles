local lazy = require('lazy.core.config')
local now = require('vimrc.helper.now')

local M = {}

local function gen_create_autocmd()
  local augroups = {}
  return function(event, opts)
    local augroup = opts and opts['group']
    if augroup ~= nil and augroups[augroup] == nil then
      vim.api.nvim_create_augroup(augroup, { clear = true })
      augroups[augroup] = true
    end
    vim.api.nvim_create_autocmd(event, opts)
  end
end

function M.refresh_augroup_cache()
  M.create_autocmd = gen_create_autocmd()
end

M.refresh_augroup_cache()

---@param s string
---@return string
function M.get_msg_string(s)
  return '[nvimrc] ' .. s
end

---@param msg string
function M.echo(msg)
  vim.api.nvim_echo({ { M.get_msg_string(msg) } }, false, {})
end

---@param msg string
---@param color string
function M.echomsg_with_color(msg, color)
  vim.api.nvim_echo({ { M.get_msg_string(msg), color } }, true, {})
end

---@param msg string
function M.echomsg(msg)
  M.echomsg_with_color(msg, 'None')
end

---@param msg string
function M.echomsg_error(msg)
  M.echomsg_with_color(msg, 'Error')
end

---@param msg string
function M.echomsg_warning(msg)
  M.echomsg_with_color(msg, 'WarningMsg')
end

---@param plugin string
---@return boolean
function M.is_plugin_installed(plugin)
  return lazy.plugins[plugin] ~= nil
end

---@param plugin string
---@return boolean
function M.is_plugin_loaded(plugin)
  local p = lazy.plugins[plugin]
  return p ~= nil and p._.loaded ~= nil
end

---@return boolean
function M.is_string(v)
  return type(v) == 'string'
end

---@param tester string[]
---@return boolean
function M.is_invokable(tester)
  local ok, _ = pcall(vim.system, tester)
  return ok
end

M.stdpath = now(function()
  local dotfiles = vim.fs.dirname(vim.fs.dirname(vim.env.MYVIMRC))
  local dotvim = vim.fs.joinpath(dotfiles, 'vim')

  local path_table = {
    dotfiles = dotfiles,
    dotvim = dotvim,
    ['dotvim-runtime'] = vim.fs.joinpath(dotvim, 'runtime'),
  }

  ---@string what string
  ---@return string
  return function(what)
    return path_table[what] or vim.fs.stdpath(what)
  end
end)

---@param s string
function M.throw(s)
  vim.cmd.throw(vim.fn.string(s))
end

return M
