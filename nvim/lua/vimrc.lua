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
    { type = file, path = target, upward = true, limit = 1 }
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

return M
