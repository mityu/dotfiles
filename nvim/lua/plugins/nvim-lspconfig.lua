---@param names string[]
---@return string[]
local function get_plugin_paths(names)
  local plugins = require("lazy.core.config").plugins
  local paths = {}
  for _, name in ipairs(names) do
    if plugins[name] then
      table.insert(paths, plugins[name].dir .. "/lua")
    else
      vim.notify("Invalid plugin name: " .. name)
    end
  end
  return paths
end

---@param plugins string[]
---@return string[]
local function library(plugins)
  local paths = get_plugin_paths(plugins)
  table.insert(paths, vim.fn.stdpath("config") .. "/lua")
  table.insert(paths, vim.env.VIMRUNTIME .. "/lua")
  table.insert(paths, "${3rd}/luv/library")
  table.insert(paths, "${3rd}/busted/library")
  table.insert(paths, "${3rd}/luassert/library")
  return paths
end

return {
  'https://github.com/neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
  config = function()
    local lspconfig = require('lspconfig')
    local util = require('lspconfig.util')

    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            pathStrict = true,
            path = { "?.lua", "?/init.lua" },
          },
          workspace = {
            library = library({ "lazy.nvim" }),
            checkThirdParty = "Disable",
          },
        },
      },
    })
    lspconfig.clangd.setup({})
    lspconfig.gopls.setup({})
    lspconfig.sourcekit.setup {
      filetypes = { "swift" },
      root_pattern = util.root_pattern("main.swift", "Package.swift", ".git"),
    }
  end,
  on_attach = function(client, _)
    vim.keymap.set('n', 'gd', vim.lsp.buf.type_definition, { buffer = true })
    vim.keymap.set('n', '<Space>i', vim.lsp.buf.signature_help, { buffer = true })
    if vim.bo.filetype == 'vim' then
      vim.keymap.del('n', 'K')
    end
  end,
}
