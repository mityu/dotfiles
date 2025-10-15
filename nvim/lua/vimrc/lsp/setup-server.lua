local helper = require('vimrc.helper')

if helper.is_plugin_loaded('cmp-nvim-lsp') then
  vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })
end

---@param filetypes string[]
---@param server string
---@param config nil|table
local function setup_server(filetypes, server, config)
  helper.create_autocmd('FileType', {
    group = 'vimrc-nvim-lsp-setup',
    pattern = filetypes,
    once = true,
    callback = function()
      if config ~= nil then
        vim.lsp.config(server, config)
      end
      vim.lsp.enable(server)
    end,
  })
end

setup_server({ 'lua' }, 'lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = vim.list_extend(vim.api.nvim_get_runtime_file('lua', true), {
          '${3rd}/luv/library',
          '${3rd}/busted/library',
        }),
      },
    },
  },
})
setup_server({ 'lua' }, 'stylua')

setup_server({ 'nix' }, 'nixd', {
  settings = {
    formatting = { command = { 'nixfmt' } },
  },
})
setup_server({ 'c', 'cpp', 'objective-c' }, 'clangd')
setup_server({ 'go' }, 'gopls')
setup_server({ 'typescript' }, 'denols')
setup_server({ 'haskell' }, 'hls')
setup_server({ 'typst' }, 'tinymist')
setup_server(
  { 'ocaml', 'menhir', 'ocamlinterface', 'ocamllex', 'reason', 'dune' },
  'ocamllsp'
)
setup_server({ 'coq', 'rocq' }, 'coq_lsp')
setup_server({ 'tex', 'latex', 'plaintex' }, 'texlab')
setup_server({ 'rust' }, 'rust_analyzer')
setup_server({ 'fish' }, 'fish_lsp')
setup_server({ 'bash' }, 'bashls')

local efm_filetypes = { 'python' }
setup_server(efm_filetypes, 'efm', { filetypes = efm_filetypes })
