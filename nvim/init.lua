-- vim: shiftwidth=2 expandtab:

local vim_did_start = vim.fn.has('vim_starting') == 0
if not vim_did_start then
  vim.opt.encoding = 'utf-8'
  vim.env.MYVIMRC = vim.fn.resolve(vim.fn.expand('<sfile>'))
end

vim.scriptencoding = 'utf-8'

local lazy_root_path = vim.fn.stdpath('cache') .. '/lazy'
if not vim_did_start then
  -- Load lazy.nvim
  local lazy_plugin_path = lazy_root_path .. '/lazy.nvim'
  if not vim.uv.fs_stat(lazy_plugin_path) then
    vim
      .system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        lazy_plugin_path,
      })
      :wait()
  end
  vim.opt.runtimepath:prepend(lazy_plugin_path)
end

local helper = require('vimrc.helper')
local now = require('vimrc.helper.now')
helper.refresh_augroup_cache()
require('vimrc.helper.fnok')
require('vimrc.inherit-dotvim')

local opt = vim.opt
if vim_did_start then
  opt = vim.opt_global
end
local set_default = function(vimopt)
  vimopt._value = vimopt._info.default
  return vimopt
end

vim.cmd([[
  try
    language en_US.UTF-8
  catch /^Vim\%((\a\+)\)\=:E197:/
    language C
  catch
    lua << trim EOF
      local helper = require('vimrc.helper')
      helper.echomsg_error(vim.v.throwpoint)
      helper.echomsg_error(vim.v.exception)
    EOF
    language C
  endtry
]])
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.wildmenu = true
opt.complete = { '.', 'i', 'd', 'w', 'b', 'u' }
-- opt.completeopt = { 'menone', 'noselect', 'popup' }
opt.pumheight = 10
opt.incsearch = true
opt.ignorecase = true
opt.showmatch = true
opt.matchtime = 1
-- opt.imdisable = false
opt.wrapscan = false
opt.lazyredraw = true
opt.laststatus = 2
opt.scrolloff = 1
opt.wildoptions = { 'pum', 'fuzzy' }
set_default(opt.wildignore):append('*.DS_STORE')
opt.history = 500
opt.keywordprg = ':help'
opt.virtualedit = 'block'
opt.timeoutlen = 3000
opt.ttimeoutlen = 100
set_default(opt.isfname):remove('=')
set_default(opt.spelllang):append('cjk')
opt.statusline = '%m%y[#%n] %<%t'
opt.equalalways = false
opt.colorcolumn = '78'
opt.laststatus = 2
opt.showtabline = 2
opt.display = 'lastline'
opt.timeoutlen = 3000
opt.ttimeoutlen = 100
opt.autoread = true
opt.hidden = true
opt.showcmd = true
opt.diffopt = { 'internal', 'algorithm:histogram' }
set_default(opt.shortmess):append('Ic')
opt.backspace = { 'eol', 'start', 'indent' }
opt.cinoptions = { ':0', 'g0', 'N-s', 'E-s' }
opt.cmdheight = 2
opt.cursorline = true
opt.cursorlineopt = { 'number' }
vim.opt_global.fileformat = 'unix'
vim.opt_global.fileencodings = { 'utf-8', 'euc-jp', 'cp932', 'sjis' }

-- The undodir/directory/backupdir are automatically created by defaults.lua.
set_default(vim.opt_global.backupdir):remove('.')
vim.opt_global.undofile = true
vim.opt_global.swapfile = true
vim.opt_global.backup = true
vim.opt_global.writebackup = true

VimrcStatusline = require('vimrc.statusline')
VimrcTabline = require('vimrc.tabline')
vim.opt_global.statusline = '%{%v:lua.VimrcStatusline()%}'
vim.opt_global.tabline = '%!v:lua.VimrcTabline()'

vim.g.tex_conceal = '' -- Disable default TeX conceal

-- This is done in defaults.lua.  See :h nvim-defauts for the details.
-- if vim.fn.executable('rg') == 1 then
--   opt.grepprg = 'rg --vimgrep'
--   opt.grepformat = '%f:%l:%c:%m'
-- elseif vim.fn.executable('ag') then
--   opt.grepprg = 'ag --vimgrep'
--   opt.grepformat = '%f:%l:%c:%m'
-- end

---@param key string
local function smart_startinsert(key)
  ---@return string
  return function()
    if vim.fn.getline('.') == '' and vim.bo.modifiable then
      return '"_S'
    end
    return key
  end
end

local function operator_comment()
  return require('vim._comment').operator()
end

local function textobj_comment()
  return require('vim._comment').textobject()
end

vim.keymap.set({ 'n', 'v' }, ':', 'q:A')
vim.keymap.set({ 'n', 'v' }, '<Space>:', 'q:k')
vim.keymap.set({ 'n', 'v' }, '/', 'q/A')
vim.keymap.set({ 'n', 'v' }, '<Space>/', 'q/k')
vim.keymap.set({ 'n', 'v' }, '?', 'q?A')
vim.keymap.set({ 'n', 'v' }, '<Space>?', 'q?k')
vim.keymap.set({ 'n', 'v' }, '<Space>;', ':')
vim.keymap.set({ 'n', 'v' }, "'", ':', { remap = true })
vim.keymap.set({ 'n', 'v' }, 'k', 'gk')
vim.keymap.set({ 'n', 'v' }, 'j', 'gj')
vim.keymap.set({ 'n', 'v' }, 'gk', 'k')
vim.keymap.set({ 'n', 'v' }, 'gj', 'j')
vim.keymap.set({ 'n', 'x' }, 'm/', operator_comment, { expr = true })

vim.keymap.set('n', 'i', smart_startinsert('i'), { expr = true })
vim.keymap.set('n', 'I', smart_startinsert('I'), { expr = true })
vim.keymap.set('n', 'a', smart_startinsert('a'), { expr = true })
vim.keymap.set('n', 'A', smart_startinsert('A'), { expr = true })

vim.keymap.set('n', '<Space>w', '<Cmd>update<CR>')
vim.keymap.set('n', '<Space>q', '<Cmd>quit<CR>')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'gl', 'gt')
vim.keymap.set('n', 'gh', 'gT')
vim.keymap.set('n', '<C-w>s', '<Cmd>belowright wincmd s<CR>')
vim.keymap.set('n', '<C-w><C-s>', '<Cmd>belowright wincmd s<CR>')
vim.keymap.set('n', '<C-w>v', '<Cmd>belowright wincmd v<CR>')
vim.keymap.set('n', '<C-w><C-v>', '<Cmd>belowright wincmd v<CR>')
vim.keymap.set('n', '<C-w>c', '<Cmd>belowright copen<CR>')
vim.keymap.set('n', '<C-w>t', '<Cmd>tabnew<CR>')
vim.keymap.set('n', '<C-w><C-t>', '<Cmd>tabnew<CR>')
vim.keymap.set('n', '<C-w>.', '<Cmd>copen<CR>')
vim.keymap.set('n', '<C-w>,', '<Cmd>lopen<CR>')
vim.keymap.set('n', '<Space>tk', '<Cmd>split | terminal<CR>')
vim.keymap.set('n', '<Space>tj', '<Cmd>belowright split | terminal<CR>')
vim.keymap.set('n', '<Space>th', '<Cmd>vsplit | terminal<CR>')
vim.keymap.set('n', '<Space>tl', '<Cmd>belowright vsplit | terminal<CR>')
vim.keymap.set('n', '<Space>tt', '<Cmd>tabnew | terminal<CR>')
vim.keymap.set('n', 'ZZ', '<Nop>')
vim.keymap.set('n', 'ZQ', '<Nop>')
vim.keymap.set('n', 'm', '<Nop>')
vim.keymap.set('n', '<Space>sv', '<Cmd>source $MYVIMRC<CR>')
vim.keymap.set('n', '<Space>ev', '<Cmd>edit $MYVIMRC<CR>')
vim.keymap.set('n', '<CR>', 'o<ESC>')
vim.keymap.set('n', '<Space><CR>', 'i<CR><ESC>')
vim.keymap.set('n', '<C-h>', '<Cmd>nohlsearch<CR>')
vim.keymap.set('n', '*', '*N')
vim.keymap.set('n', 'n', "'Nn'[v:searchforward]", { expr = true })
vim.keymap.set('n', 'N', "'nN'[v:searchforward]", { expr = true })
vim.keymap.set({ 'n', 'v' }, '<C-k>', '7gk')
vim.keymap.set({ 'n', 'v' }, '<C-j>', '7gj')
vim.keymap.set({ 'n', 'v', 'o', 'i', 'c' }, '<C-@>', '<ESC>')
vim.keymap.set('i', '<C-l>', '<C-x>')
vim.keymap.set('i', '<C-m>', '<C-g>u<C-m>')
vim.keymap.set('x', '*', [[<ESC>*Ngvne<Cmd>nohlsearch<CR>]])
vim.keymap.set('x', 'g*', [[<ESC>g*Ngvne<Cmd>nohlsearch<CR>]])
vim.keymap.set('x', 'n', [[n<Cmd>nohlsearch<CR>]])
vim.keymap.set('x', 'N', [[N<Cmd>nohlsearch<CR>]])
vim.keymap.set({ 'o', 'x' }, [[a"]], [[2i"]])
vim.keymap.set({ 'o', 'x' }, [[a']], [[2i']])
vim.keymap.set('o', 'ic', textobj_comment, { expr = true })
vim.keymap.set('c', '<C-l>', '<C-f>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-a>', '<C-b>')
vim.keymap.set('c', '<C-[>', '<C-c>')
vim.keymap.set('c', '<C-p>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<Up>'
end, { expr = true })
vim.keymap.set('c', '<C-n>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Down>'
end, { expr = true })
vim.keymap.set('n', 'Q', function()
  local opt = vim.wo
  if opt.number then
    opt.number = false
    opt.relativenumber = false
  else
    opt.number = true
    opt.relativenumber = true
  end
end)
vim.keymap.set('t', '<C-/>', [[<C-\><C-n>]])

---@param delta integer
local function map_tabmove(delta)
  local tab_count = vim.fn.tabpagenr('$')
  if tab_count == 1 then
    return
  end

  local current = vim.fn.tabpagenr() - 1
  local move_to = current + delta
  if move_to < 0 then
    while move_to < 0 do
      move_to = move_to + tab_count
    end
  end
  if move_to >= tab_count then
    move_to = move_to % tab_count
  end

  local movement = move_to - current
  if movement < 0 then
    vim.cmd.tabmove(movement)
  else
    vim.cmd.tabmove('+' .. movement)
  end
end

local loopmap = require('vimrc.loopmap')
loopmap.simple_loop_define({
  id = 'Window',
  enter_with = '<C-w>',
  follow_key = '<>-+',
})
loopmap.loop_define({
  id = 'Tab',
  enter_with = 'g',
  body = {
    { 'h', 'gT' },
    { 'l', 'gt' },
    {
      'T',
      function()
        map_tabmove(-1)
      end,
    },
    {
      't',
      function()
        map_tabmove(1)
      end,
    },
  },
})

---@param cdcmd string
---@return function
local function cd_project_root(cdcmd)
  return function()
    require('vimrc').cd_project_root(cdcmd)
  end
end

vim.cmd('iabbrev todo: TODO:')
vim.cmd('iabbrev fixme: FIXME:')
vim.cmd('iabbrev xxx: XXX:')
vim.cmd('iabbrev note: NOTE:')

vim.api.nvim_create_user_command('CdCurrent', 'cd %:p:h', { bar = true })
vim.api.nvim_create_user_command('LcdCurrent', 'lcd %:p:h', { bar = true })
vim.api.nvim_create_user_command('TcdCurrent', 'tcd %:p:h', { bar = true })
vim.api.nvim_create_user_command('CdRoot', cd_project_root('cd'), { bar = true })
vim.api.nvim_create_user_command('LcdRoot', cd_project_root('lcd'), { bar = true })
vim.api.nvim_create_user_command('TcdRoot', cd_project_root('tcd'), { bar = true })
vim.api.nvim_create_user_command('FileName', [[echo expand('%:p')]], { bar = true })
vim.api.nvim_create_user_command(
  'Rename',
  [[file <args>|call delete(expand('#'))|setlocal modified]],
  { bar = true, nargs = 1, complete = 'file' }
)
vim.api.nvim_create_user_command(
  'CopyToClipboard',
  [[call setreg('+', getreg(<q-args>, 1))]],
  { nargs = '?' }
)
vim.api.nvim_create_user_command(
  'ClipBuffer',
  require('vimrc').clipbuffer,
  { bar = true, nargs = '?' }
)
vim.api.nvim_create_user_command('Hlgroup', function()
  helper.show_highlight_group()
end, { bar = true })
vim.api.nvim_create_user_command('Draft', function(_)
  vim.bo.buftype = 'nofile'
  vim.bo.swapfile = false
  vim.bo.undofile = false
end, { bar = true })
vim.api.nvim_create_user_command('TMP', function(opts)
  vim.cmd.enew()
  vim.cmd.Draft()
  if opts.fargs[1] then
    vim.cmd.setfiletype(opts.fargs[1])
  end
end, {
  bar = true,
  nargs = '?',
  complete = 'filetype',
})
vim.api.nvim_create_user_command('SetUndoFtplugin', function(config)
  local restorer = 'execute ' .. vim.fn.string(config.args)
  if vim.b['undo_ftplugin'] then
    vim.b['undo_ftplugin'] = restorer .. '|' .. vim.b['undo_ftplugin']
  else
    vim.fn.setbufvar('%', 'undo_ftplugin', restorer)
  end
end, { nargs = 1, complete = 'command' })

helper.create_autocmd('CmdwinEnter', {
  group = 'vimrc-cmdwin',
  callback = function()
    -- Type <CR> to execute current line in command-line window.
    -- This mapping is overwritten when ambicmd.vim is installed.
    vim.keymap.set('n', '<CR>', '<CR>', { buffer = true })

    -- Return back to the current window from command-line window with
    -- inputting <C-c> once.
    vim.keymap.set('n', '<C-c>', '<Cmd>quit<CR>', { buffer = true })
    vim.keymap.set('n', 'q', '<Cmd>quit<CR>', { buffer = true })
    vim.keymap.set('i', '<C-c>', '<ESC><Cmd>quit<CR>', { buffer = true })

    vim.keymap.set({ 'n', 'x' }, ':', ':', { buffer = true })
    vim.keymap.set('i', '<C-l><C-n>', '<C-x><C-n>', { buffer = true })
    vim.keymap.set('i', '<C-l><C-p>', '<C-x><C-n>', { buffer = true })

    vim.keymap.set('n', '/', '/', { buffer = true })

    local cmdwin_type = vim.fn.expand('<afile>')
    if cmdwin_type == ':' then
      local function gen_cmdwin_completion(select_next)
        return function()
          if vim.fn.pumvisible() then
            return select_next and '<C-n>' or '<C-p>'
          else
            return '<C-x><C-v>' .. (select_next and '' or '<C-p><C-p>')
          end
        end
      end
      vim.keymap.set(
        'i',
        '<C-n>',
        gen_cmdwin_completion(true),
        { expr = true, buffer = true }
      )
      vim.keymap.set(
        'i',
        '<C-p>',
        gen_cmdwin_completion(false),
        { expr = true, buffer = true }
      )
      vim.opt_local.completeopt = { 'menu', 'preview' }

      if vim.fn.line('$') >= vim.opt.cmdwinheight:get() then
        vim.cmd(('silent! 1,$-%d delete _'):format(vim.opt.cmdwinheight:get()))
        vim.cmd('normal! G')
        vim.opt.undolevels = vim.opt.undolevels -- Separate undo sequence
      end
    end
  end,
})

if not vim_did_start then
  helper.create_autocmd('StdinReadPost', {
    group = 'vimrc',
    once = true,
    command = 'set nomodified',
  })
end

helper.create_autocmd('TermOpen', {
  group = 'vimrc',
  command = 'startinsert!',
})

helper.create_autocmd('CursorHold', {
  group = 'vimrc',
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd.checktime()
    end
  end,
})

if helper.is_invokable({ 'chmod' }) then
  helper.create_autocmd('BufWritePost', {
    group = 'vimrc',
    callback = function()
      local file = vim.fn.expand('%:p')
      if
        vim.fn.stridx(vim.fn.getline(1), '#!') == 0
        and not vim.fnok.executable(file)
      then
        vim.system({ 'chmod', 'a+x', file }):wait()
      end
    end,
  })
end

-- From: https://zenn.dev/vim_jp/articles/f02adb4f325e51   Thanks!
helper.create_autocmd('BufWritePre', {
  group = 'vimrc',
  callback = function()
    if vim.bo.buftype ~= '' then
      return
    end

    local filename = vim.fn.expand('<afile>:t')
    local invalid_chars = [[!&()[]{}<>^*=+:;'",`~?|]]
    for i = 1, #invalid_chars do
      local c = invalid_chars:byte(i)
      if string.find(filename, c, 0, true) ~= nil then
        -- FIXME: This cannot block writing to file.
        helper.throw(('Filename has invalid char: %s'):format(filename))
      end
    end

    local valid_pattern = [[%.?%w+$]]
    if filename:match(valid_pattern) == nil then
      helper.throw(('Filename is invalid format: %s'):format(filename))
    end
  end,
})

helper.create_autocmd('QuickfixCmdPost', {
  group = 'vimrc',
  pattern = '[^l]*',
  command = 'cwindow',
})
helper.create_autocmd('QuickfixCmdPost', {
  group = 'vimrc',
  pattern = 'l*',
  command = 'lwindow',
})

helper.create_autocmd('BufRead', {
  group = 'vimrc',
  pattern = '*/vimdoc-ja-working/doc/*.jax',
  callback = function()
    vim.b['autofmt_allow_over_tw'] = 1
    vim.opt_local.formatoptions:append('mM')
    helper.create_autocmd('FileType', {
      pattern = '<buffer>',
      once = true,
      command = 'HelpEdit',
    })
  end,
})

helper.create_autocmd('TextYankPost', {
  group = 'vimrc',
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})

-- Don't override colorscheme if it's already set.
if vim.fn.exists('g:colors_name') == 0 then
  vim.cmd.colorscheme('domusaurea')
end

vim.treesitter.start = function(_bufnr, _lang) end -- Disable entire treesitter.

-- lvimrc
now(function()
  local lvimrc = vim.fs.joinpath('~', '.lnvimrc.lua')
  vim.api.nvim_create_user_command('LVimrc', function(args)
    local cmd = vim.trim(args.args)
    if cmd == '' then
      cmd = 'edit'
    end
    vim.cmd(('%s %s'):format(cmd, lvimrc))
  end, { bar = true, nargs = '*' })
  if vim.fn.filereadable(vim.fn.expand(lvimrc)) ~= 0 then
    vim.cmd.source(vim.fn.fnameescape(lvimrc))
  end
end)

-- Load plugin configurations (only when startup).
if not vim.g.lazy_did_setup then
  require('lazy').setup('plugins', {
    root = lazy_root_path,
    lockfile = vim.fs.joinpath(vim.fn.stdpath('cache'), 'lazy-lock.json'),
    defaults = { lazy = true },
    performance = {
      rtp = {
        disabled_plugins = {
          'gzip',
          'netrwPlugin',
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin',
          'rplugin',
        },
      },
    },
    change_detection = {
      enabled = false,
    },
  })
  require('vimrc.lsp')
end
