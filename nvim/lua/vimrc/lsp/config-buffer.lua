local helper = require('vimrc.helper')

if helper.is_plugin_installed('nvim-notify') then
  local notify = require('notify')
  helper.create_autocmd('LspAttach', {
    group = 'vimrc',
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id).name
      notify.notify(
        ('%s\nServer attached: %s'):format(vim.fn.pathshorten(ev.match), client)
      )
    end,
  })
  helper.create_autocmd('LspDetach', {
    group = 'vimrc',
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id).name
      vim.schedule(function()
        notify.notify(('Server detached: %s'):format(client))
      end)
    end,
  })
end

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
  },
})

do
  local handler = vim.lsp.diagnostic.on_publish_diagnostics
  vim.lsp.diagnostic.on_publish_diagnostics = function(...)
    handler(...)
    vim.diagnostic.setloclist({ open = false })
  end
end
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

  local disable_ft = { 'tex' }
  if vim.list_contains(disable_ft, ft) then
    return false
  elseif ft == 'lua' then
    if client.name == 'stylua' then
      return true
    else
      return false
    end
  elseif ft == 'fish' then
    if vim.fn.bufname(bufnr):find('config.fish') then
      return false
    else
      return true
    end
  elseif ft == 'cpp' then
    -- TODO: Check .clang-format
    -- TODO: Check filename when in Vim repository
  end
  return true
end

---@param ft string
---@param client vim.lsp.Client
---@return boolean
local function should_use_as_formatter(ft, client)
  local formatter_preference = {
    lua = 'stylua',
  }
  local prf = formatter_preference[ft]
  return prf == nil or prf == client.name
end

helper.create_autocmd('LspAttach', {
  group = 'vimrc-nvim-lsp',
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local ft = vim.bo[args.buf].filetype
    local create_command = gen_create_buflocal_command(args.buf)

    -- TODO: Define `LspCodeAction` command
    if should_use_as_formatter(ft, client) then
      create_command('LspFmt', function()
        vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
      end, { bar = true })
    end
    create_command('LspRename', function()
      vim.lsp.buf.rename()
    end, {})
    create_command('LspDefinition', function()
      vim.lsp.buf.definition()
    end, { bar = true })
    create_command('LspDeclaration', function()
      vim.lsp.buf.declaration()
    end, { bar = true })
    create_command('LspHover', function()
      vim.lsp.buf.hover()
    end, { bar = true })
    create_command('LspImplementation', function()
      vim.lsp.buf.implementation()
    end, { bar = true })
    create_command('LspCodeAction', function()
      vim.lsp.buf.code_action()
    end, { bar = true })
    create_command('LspDiagnosticOpenFloat', function()
      vim.diagnostic.open_float()
    end, { bar = true })

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
              end,
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
