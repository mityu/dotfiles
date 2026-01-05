local helper = require('vimrc.helper')

local M = {}

---@param path string
---@return string
function M.search_project_root(path)
  if path == '' then
    return ''
  elseif not vim.fnok.isabsolutepath(path) then
    error(('Path should be absolute: %s'):format(path))
  end

  local root_marker_dirs = {
    '.git',
    'autoload',
    'plugin',
    'denops',
  }
  local root_marker_files = {
    'go.mod',
    'compile_flags.txt',
    'compile_commands.json',
    '.clang-format',
    'Cargo.toml',
    'dune-project',
    'deno.json',
    'deno.jsonc',
    'import_map.json',
  }

  local root = ''

  local dirs =
    vim.fs.find(root_marker_dirs, { type = 'directory', path = path, upward = true })
  if #dirs > 0 then
    root = vim.fs.dirname(dirs[1])
  end

  local files =
    vim.fs.find(root_marker_files, { type = 'file', path = path, upward = true })
  if #files > 0 then
    local dir = vim.fs.dirname(files[1])
    if dir:len() > root:len() then
      root = dir
    end
  end

  return root
end

---@param path string
---@param silent boolean
---@return string
function M.find_project_root(path, silent)
  if path == '' then
    local curbuf = vim.fn.expand('%:p')
    if curbuf:match([[^gin[^:]*://]]) then
      return vim.fn['gin#util#worktree']()
    elseif curbuf:match([[^fern://]]) then
      return vim.fn['vimrc#helper#get_project_root_from_fern_buffer']()
    else
      local dir = M.search_project_root(curbuf)
      if dir == '' then
        return vim.fn.getcwd(vim.fn.winnr())
      end
      return dir
    end
  end

  path = vim.fn.expand(path)
  if not vim.fnok.isdirectory(path) then
    if not silent then
      helper.echomsg_error(('Directory not found: %s'):format(path))
    end
    return ''
  end

  return path
end

---@param target? string
---@return string?
function M.find_git_root(target)
  target = vim.fn.resolve(target or vim.fs.abspath(vim.fn.bufname('%')))
  local gitdir = vim.fs.find(
    { '.git' },
    { type = 'directory', path = target, upward = true, limit = 1 }
  )
  if #gitdir == 0 then
    return nil
  end
  return vim.fs.dirname(vim.fs.abspath(gitdir[1]))
end

---@param cdcmd string
function M.cd_project_root(cdcmd)
  local root = M.search_project_root(vim.fn.expand('%:p:h'))
  if root ~= '' then
    vim.cmd(('%s %s'):format(cdcmd, vim.fn.fnameescape(root)))
  end
end

function M.show_highlight_group()
  local hlgroup =
    vim.fn.synIDattr(vim.fn.synID(vim.fn.line('.'), vim.fn.col('.'), 1), 'name')
  local group_chain = {}

  while hlgroup ~= '' do
    table.insert(group_chain, hlgroup)
    hlgroup = vim.fn.matchstr(
      vim.trim(vim.fn.execute(('highlight %s'):format(hlgroup))),
      [[\<links\s\+to\>\s\+\zs\w\+$]]
    )
  end

  if #group_chain == 0 then
    vim.cmd.echo([['No highlight groups']])
    return
  end

  for _, group in pairs(group_chain) do
    vim.cmd.highlight(group)
  end
end

---@param arg vim.api.keyset.create_user_command.command_args
function M.clipbuffer(arg)
  local catchup = function()
    if not vim.bo.modified then
      -- TODO: Catch error
      local ok, r = pcall(function()
        vim.cmd([[
          %delete _
          1 put +
          1 delete _
          setlocal nomodified
        ]])
      end)
      if not ok then
        helper.echomsg_error(tostring(r))
      end
    end
  end

  local opener = 'tabedit'
  if arg.args ~= '' then
    opener = arg.args
  end

  vim.cmd(('hide %s clipboard://buffer'):format(opener))

  local bufnr = vim.fn.bufnr()
  vim.fn.setbufvar(bufnr, 'clipbuffer_bufhidden', vim.bo.bufhidden)
  vim.bo.buftype = 'acwrite'
  vim.bo.modified = false
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
  catchup()

  vim.api.nvim_clear_autocmds({
    buffer = bufnr,
  })
  helper.create_autocmd('BufWriteCmd', {
    buffer = bufnr,
    group = 'vimrc-clipbuffer',
    nested = true,
    callback = function()
      vim.cmd('%yank +')
      vim.bo.modified = false
    end,
  })
  helper.create_autocmd('BufEnter', {
    buffer = bufnr,
    group = 'vimrc-clipbuffer',
    nested = true,
    callback = catchup,
  })
  helper.create_autocmd('BufWipeout', {
    buffer = bufnr,
    group = 'vimrc-clipbuffer',
    nested = true,
    callback = function()
      vim.fn.setbufvar(vim.fn.bufnr(), '&bufhidden', vim.b.clipbuffer_bufhidden)
    end,
  })
end

---@param arglist string[]
---@return string
function M.tapi_drop(_bufnr, arglist)
  local cwd = arglist[1]
  local filepath = arglist[2]
  if not vim.fnok.isabsolutepath(filepath) then
    filepath = vim.fs.joinpath(cwd, filepath)
  end

  local opencmd = 'drop'
  if vim.fn.bufwinnr(vim.fn.bufnr(filepath)) == -1 then
    opencmd = 'split'
  end
  vim.cmd(opencmd .. ' ' .. vim.fn.fnameescape(filepath))
  return ''
end

---@param cmd string
function M.set_undo_ftplugin(cmd)
  local restorer = 'execute ' .. vim.fn.string(cmd)
  if vim.b['undo_ftplugin'] then
    vim.b['undo_ftplugin'] = restorer .. '|' .. vim.b['undo_ftplugin']
  else
    vim.fn.setbufvar('%', 'undo_ftplugin', restorer)
  end
end

return M
