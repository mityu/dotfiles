local helper = require('vimrc.helper')
local now = require('vimrc.helper.now')

if helper.is_plugin_loaded('cmp-nvim-lsp') then
  vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })
end

local setup_server = now(function()
  local configurated_servers = {}

  ---@param filetypes string[]
  ---@param server string
  ---@param config nil|table
  return function(filetypes, server, config)
    helper.create_autocmd('FileType', {
      group = 'vimrc-nvim-lsp-setup',
      pattern = filetypes,
      once = true,
      callback = function()
        if configurated_servers[server] then
          return
        end
        configurated_servers[server] = true
        if config ~= nil then
          vim.lsp.config(server, config)
        end
        vim.lsp.enable(server)
      end,
    })
  end
end)

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
setup_server({ 'haskell' }, 'hls')
setup_server({ 'typst' }, 'tinymist')
setup_server(
  { 'ocaml', 'menhir', 'ocamlinterface', 'ocamllex', 'reason', 'dune' },
  'ocamllsp'
)
setup_server({ 'coq', 'rocq' }, 'coq_lsp')
setup_server({ 'tex', 'latex', 'plaintex', 'bib', 'otex' }, 'texlab', {
  filetypes = { 'tex', 'latex', 'plaintex', 'bib', 'otex' },
})
setup_server({ 'rust' }, 'rust_analyzer')
setup_server({ 'fish' }, 'fish_lsp')
setup_server({ 'bash' }, 'bashls')
setup_server({ 'yaml' }, 'efm')

local efm_filetypes = { 'python' }
setup_server(efm_filetypes, 'efm', { filetypes = efm_filetypes })

-- setup_server({ 'typescript' }, 'denols')
helper.create_autocmd('FileType', {
  group = 'vimrc-nvim-lsp-setup',
  callback = function(ctx)
    if
      not vim.tbl_contains(
        {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        ctx.match
      )
    then
      return
    end

    -- node
    if vim.fn.findfile('package.json', '.;') ~= '' then
      vim.lsp.start(vim.lsp.config.ts_ls)
      return
    end

    -- deno
    vim.lsp.start(vim.lsp.config.denols)
  end,
})
