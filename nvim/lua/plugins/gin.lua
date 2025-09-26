---@param compare_to string
local function gin_log_diff(compare_to)
  local hash = vim.fn.matchstr(vim.fn.getline('.'), [[^commit\s\+\zs\<\w\+\>]])
  if hash == '' then
    require('vimrc.helper').echo('Failed to find commit hash.')
    return
  end
  vim.cmd(('GinDiff %s..%s'):format(hash, compare_to))
end

local function gin_buffer_opened()
  local helper = require('vimrc.helper')

  vim.opt_local.modeline = false
  if helper.is_plugin_installed('fall.vim') then
    -- Postpone the mapping definition a bit later in order to make sure the
    -- mappings be defined after gin's built-in ftplugins are loaded.
    helper.create_autocmd('FileType', {
      group = 'vimrc-gin',
      pattern = '<buffer>',
      once = true,
      callback = function()
        vim.defer_fn(function()
          if string.match(vim.bo.filetype, '^gin') then
            vim.keymap.set('n', 'a', '<Cmd>Fall gin-action<CR>', { buffer = true })
            vim.keymap.set('n', 'A', '<Plug>(gin-action-choice)', { buffer = true })
          end
        end, 0)
      end,
    })
  end

  if vim.fn.stridx(vim.fn.bufname('%'), 'vimdoc-ja-working') ~= -1 then
    vim.opt_local.tabstop = 8
  end
end

local function gin_status_opened()
  vim.keymap.set('n', '<Space>g', '<Cmd>Gin commit<CR>', { buffer = true })
  vim.keymap.set('n', '<C-l>', '<Cmd>call gin#util#reload()<CR>', { buffer = true })
end

local function gin_log_opened()
  vim.keymap.set('n', '<C-l>', '<Cmd>call gin#util#reload()<CR>', { buffer = true })
  vim.keymap.set(
    'n',
    '<C-p>',
    [[<Cmd>call search('^commit\s\w\+', 'bW')<CR>]],
    { buffer = true }
  )
  vim.keymap.set(
    'n',
    '<C-n>',
    [[<Cmd>call search('^commit\s\w\+', 'W')<CR>]],
    { buffer = true }
  )
  vim.keymap.set('n', '<Plug>(gin-action-diff:HEAD)', function()
    gin_log_diff('HEAD')
  end, { buffer = true })
end

local function gin_edit_opened()
  if vim.opt_local.modifiable then
    return
  end

  -- This buffer may opened by :GinPatch.
  -- Check if the local file is opened in the same tab.
  local bufnr = vim.fn.bufnr(vim.fn['gin#util#expand']('%'))
  if not vim.list_contains(vim.fn.tabpagebuflist(), bufnr) then
    -- The local file is not opened in this tab.  Exit.
    return
  end

  -- This buffer must be opened by :GinPatch.  Unset unnecessary default
  -- mappings for the local file's buffer.
  local winid = vim.fn.bufwinid(bufnr)
  local remover = vim.iter({ 'do', 'dor', 'dol', 'dp' }):fold('', function(acc, v)
    local cmd = 'xunmap <buffer> ' .. v
    return acc .. cmd .. '\n'
  end)
  vim.fn.win_execute(winid, remover, 'silent!')

  -- TODO:
  -- Setup autocmd to remove all :GinPatch related mappings on closing the tab.
  -- autocmd_add([{
  --   group: 'vimrc-gin-patch-remove-mappings',
  --   event: 'TabClosed',
  --   bufnr: bufnr,
  --   cmd: $'call {SIDPrefix()}GinRemoveBufferLocalMappings()',
  --   once: true,
  --   nested: true,
  --   replace: true,
  -- }])
end

local function gin_diff_opened()
  ---@param info vim.api.keyset.cmd
  local function gin_patch_command_on_gin_diff_window(info)
    local options = {}
    local args = vim.deepcopy(info.args or {})

    while #args > 0 do
      local arg = args[1]
      if arg:match([[^\+\+]]) ~= nil then
        options:insert(arg)
      else
        break
      end
      table.remove(args, 1)
    end

    if
      vim.iter(options):any(function(v)
        return v:match([[^\+\+opener]]) ~= nil
      end)
    then
      options:insert('++opener=tabedit')
    end

    local ginpatch = function(args)
      local bang = info.bang or false
      local mods = ''
      if args.mods then
        -- Convert mods table into string representation
        mods = vim
          .iter(ipairs(args.mods))
          :map(function(arg)
            local kind, value = arg:unpack()
            if kind == 'filter' then
              return nil
            elseif kind == 'split' then
              return value
            elseif kind == 'emsg_silent' then
              return value and 'silent' or nil
            else
              return kind
            end
          end)
          :join(' ')
      end

      -- Invoking :GinPatch here causes command execution recursion, so
      -- instead of fire the command, call the internal gin API directly.
      vim.fn['denops#request']('gin', 'patch:command', { bang, mods, args })
    end

    local path = vim.trim(table.concat(args))
    if path:match([[^%\?$]]) then
      ginpatch(options:insert(vim.fn['gin#util#expand']('%')))
    else
      ginpatch(args)
    end
  end

  vim.api.nvim_buf_create_user_command(
    vim.fn.bufnr(),
    'GinPatch',
    gin_patch_command_on_gin_diff_window,
    { bar = true, bang = true, nargs = '*' }
  )
end

return {
  'https://github.com/lambdalisue/vim-gin',
  lazy = false,
  config = function()
    local helper = require('vimrc.helper')

    vim.g['gin_patch_default_args'] = { '++opener=tabedit' }
    vim.g['gin_patch_persistent_args'] = { '++no-head' }
    vim.g['gin_chaperon_default_args'] = { '++opener=tabedit' }
    vim.g['gin_proxy_apply_without_confirm'] = true

    vim.keymap.set('n', '<Space>g', '<Cmd>GinStatus<CR>')

    local function hook_on_buffer(pattern, callback)
      helper.create_autocmd('BufReadCmd', {
        group = 'vimrc-gin',
        pattern = pattern,
        callback = callback,
      })
    end
    hook_on_buffer('gin*://*', gin_buffer_opened)
    hook_on_buffer('ginstatus://*', gin_status_opened)
    hook_on_buffer('ginlog://*', gin_log_opened)
    hook_on_buffer('ginedit://*', gin_edit_opened)
    hook_on_buffer('gindiff://*', gin_diff_opened)
  end,
}
