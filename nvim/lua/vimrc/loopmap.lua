local helper = require('vimrc.helper')
local cancelers = { '', '<ESC>', '<C-@>' }

---@param key string
---@return string
local function replace_special_keys(key)
  return key:gsub('|', '<bar>')
end

---@param keys string
---@return string
local function normalize_keys(keys)
  return vim.fn.keytrans(vim.api.nvim_replace_termcodes(keys, true, true, true))
end

local M = {}

---@class vimrc.loopmap.config
---@field id string
---@field enter_with string
---@field body [string, (string|function)][]
---@field mode? string
---
---@param config vimrc.loopmap.config
function M.loop_define(config)
  local mode = config.mode or 'n'

  if mode == 'n' then
    for _, body in ipairs(config.body) do
      local rhs = body[2]
      if helper.is_string(rhs) and rhs:lower():find('<sid>', 0, true) ~= nil then
        helper.echomsg_error(
          ('loop_define: %s: rhs cannot have <SID>: %s'):format(config.id, rhs)
        )
        return
      end
    end
  end

  local prefix = ('<Plug><SID>(loop:%s)'):format(config.id)
  for _, canceler in ipairs(cancelers) do
    vim.keymap.set(mode, prefix .. canceler, '<Nop>', {})
  end

  for _, body in ipairs(config.body) do
    local lhs = replace_special_keys(body[1])
    local rhs = body[2]

    if vim.is_callable(rhs) then
      local bridge = ('<Plug><SID>(loop-bridge-%s:%s)'):format(lhs, config.id)
      vim.keymap.set(mode, bridge, rhs, {})
      rhs = bridge
    else
      rhs = replace_special_keys(rhs)
    end

    vim.keymap.set(mode, prefix .. lhs, rhs .. prefix, {})
    vim.keymap.set(mode, config.enter_with .. lhs, rhs .. prefix, {})
  end

  -- It seems that Neovim terminal always come to be normal-mode when it losts focus.
  -- if mode == 'n' then
  --   for _, body in ipairs(config.body) do
  --     local bridgekeys = prefix .. replace_special_keys(body[1])
  --     local executor = nil
  --     if vim.is_callable(executor) then
  --       -- Just run given function
  --       executor = (function(fn)
  --         return function()
  --           fn()
  --           return prefix
  --         end
  --       end)(body[2])
  --     else
  --       -- Feed body[2] keys to Neovim as a normal command key
  --       executor = (function(key)
  --         return function()
  --           vim.cmd(('normal! %s'):format(key))
  --           return prefix
  --         end
  --       end)(body[2])
  --     end
  --     vim.keymap.set('t', bridgekeys, executor, { expr = true })
  --   end
  -- end
end

---@class vimrc.loopmap.config-simple
---@field id string
---@field enter_with string
---@field follow_key string
---@field mode? string
---
---@param simple_config vimrc.loopmap.config-simple
function M.simple_loop_define(simple_config)
  local config = vim.tbl_extend('error', vim.deepcopy(simple_config), { body = {} })
  config.body = vim
    .iter(vim.fn.split(simple_config.follow_key, [[.\zs]]))
    :map(function(v)
      return { v, simple_config.enter_with .. v }
    end)
    :totable()

  M.loop_define(config)
end

return M
