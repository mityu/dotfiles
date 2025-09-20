local helper = require('vimrc.helper')

---@param cmd string
---@return string[]
local function gen_nixrun(cmd)
  return {
    'nix',
    'run',
    '--extra-experimental-features',
    'nix-command',
    '--extra-experimental-features',
    'flakes',
    cmd,
    '--',
  }
end

local has_nix = (function()
  local has_nix = helper.is_invokable({ 'nix', '--version' })
  return function()
    return has_nix
  end
end)()

--- Extract startup command from LSP's config.  If a function is set, returns nil.  Otherwise, returns a list of strings to invoke LSP.
---
---@param config vim.lsp.Config|nil
---@return string[]|nil
local function get_cmd_from_config(config)
  if config == nil then
    return {}
  elseif vim.is_callable(config.cmd) then
    return nil
  else
    return config.cmd or {}
  end
end

---@param server string
---@param nixpkg string
---@param tester_arg string|string[]
local function set_fallback_cmd(server, nixpkg, tester_arg, callback)
  if has_nix() then
    local config = vim.lsp.config[server]
    local cmd = get_cmd_from_config(config)
    if cmd == nil then
      return
    end

    local should_overwrite = true
    if #cmd > 0 then
      local arg = (vim.islist(tester_arg) and tester_arg or { tester_arg }) --[[ @as string[] ]]
      should_overwrite = not helper.is_invokable(vim.list_extend({ cmd[1] }, arg))
    end

    if should_overwrite then
      local caller = vim.list_extend(gen_nixrun(nixpkg), vim.list_slice(cmd, 2, #cmd))
      vim.lsp.config(server, { cmd = caller })
    end
  end

  if callback then
    callback(server)
  end
end

if helper.is_plugin_loaded('cmp-nvim-lsp') then
  vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })
end

set_fallback_cmd('lua_ls', 'nixpkgs#lua-language-server', '--version', function(server)
  vim.lsp.config(server, {
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
    filetypes = { 'lua' },
  })
  vim.lsp.enable(server)
end)

vim.lsp.enable('clangd')
vim.lsp.enable('gopls')
vim.lsp.enable('denols')

vim.diagnostic.config({
  -- virtual_lines = true,
  virtual_text = {
    virt_text_pos = 'eol_right_align',
    severity_sort = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E>',
      [vim.diagnostic.severity.WARN] = 'W>',
      [vim.diagnostic.severity.HINT] = 'H>',
      [vim.diagnostic.severity.INFO] = 'I>',
    },
  }
})
-- highlight link LspDiagVirtualTextError Error
-- highlight link LspDiagVirtualTextWarning WarningMsg
-- highlight link LspDiagVirtualTextHint Normal
-- highlight link LspDiagVirtualTextInfo Normal
-- highlight link LspSigActiveParameter String

vim.lsp.semantic_tokens.enable(false)

---@param buffer number
local function gen_create_buflocal_command(buffer)
  ---@param name string
  ---@param command any
  ---@param opts vim.api.keyset.user_command
  return function(name, command, opts)
    vim.api.nvim_buf_create_user_command(buffer, name, command, opts)
  end
end

---@param bufnr number
---@param client vim.lsp.Client
---@return boolean
local function should_auto_formatting(bufnr, client)
  local ft = vim.bo[bufnr].filetype

  local disable_ft = {}
  if vim.list_contains(disable_ft, ft) then
    return false
  elseif ft == 'cpp' then
    -- TODO: Check .clang-format
    -- TODO: Check filename when in Vim repository
  end
  return true
end

helper.create_autocmd('LspAttach', {
  group = 'vimrc-nvim-lsp',
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local ft = vim.bo[args.buf].filetype
    local create_command = gen_create_buflocal_command(args.buf)

    -- TODO: Define `LspCodeAction` command
    create_command('LspRename', function() vim.lsp.buf.rename() end, {})
    create_command('LspFmt', function()
      vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
    end, { bar = true })
    create_command('LspDefinition', function() vim.lsp.buf.definition() end, { bar = true })
    create_command('LspDeclaration', function() vim.lsp.buf.declaration() end, { bar = true })
    create_command('LspHover', function() vim.lsp.buf.hover() end, { bar = true })
    create_command('LspImplementation', function() vim.lsp.buf.implementation() end, { bar = true })
    create_command('LspCodeAction', function() vim.lsp.buf.code_action() end, { bar = true })
    create_command('LspDiagnosticOpenFloat', function() vim.diagnostic.open_float() end, { bar = true })

    if client:supports_method('textDocument/formatting') then
      if should_auto_formatting(args.buf, client) then
        helper.create_autocmd('BufWritePre', {
          group = 'vimrc-nvim-lsp-buffer',
          buffer = args.buf,
          command = 'LspFmt',
        })
      end
    end

    if client:supports_method('textDocument/codeAction') then
      if ft == 'go' then
        helper.create_autocmd('BufWritePre', {
          group = 'vimrc-nvim-lsp-buffer',
          buffer = args.buf,
          callback = function()
            vim.lsp.buf.code_action({
              apply = true,
              ---@param action lsp.CodeAction|lsp.Command
              filter = function(action)
                return action == 'source.organizeImports'
              end
            })
          end,
        })
      end
    end

    vim.keymap.set('n', '<C-g>', function()
      vim.lsp.buf.hover({ silent = true })
      return '<C-g>'
    end, { buffer = true, expr = true })
    vim.keymap.set('n', 'gd', '<Cmd>LspDefinition<CR>', { buffer = true })

    -- TODO: Support for auto signature help
  end,
})

helper.create_autocmd('LspDetach', {
  group = 'vimrc-nvim-lsp',
  callback = function(args)
    local bufnr = args.buf
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients > 0 then
      -- Some LSP clients still attached to the buffer.  Do not clear LSP related configurations.
      return
    end

    vim.api.nvim_clear_autocmds({
      buffer = args.buf,
      group = 'vimrc-nvim-lsp-buffer',
    })

    local keymaps = { '<C-g>', 'gd' }
    for _, key in ipairs(keymaps) do
      vim.keymap.del('n', key, { buffer = bufnr })
    end

    local commands = vim.api.nvim_buf_get_commands(args.buf, {})
    for _, cmd in pairs(commands) do
      if vim.startswith(cmd.name, 'Lsp') then
        vim.api.nvim_buf_del_user_command(bufnr, cmd.name)
      end
    end
  end,
})
