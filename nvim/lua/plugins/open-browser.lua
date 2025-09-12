---@param args vim.api.keyset.create_user_command.command_args
local function open_browser(args)
  local helper = require('vimrc.helper')
  local uri = vim.trim(args.args)
  local reg = ''

  if uri == '' then
    reg = vim.v.register
  elseif vim.startswith(uri, '@') and uri:len() == 2 then
    reg = uri:sub(2, 2)
  end

  if reg ~= '' then
    uri = vim.fn.getreg(reg)
    if uri == '' then
      helper.echomsg_error(('Register @%s is empty'):format(reg))
      return
    end
  end
  vim.fn['openbrowser#open'](uri)
end

return {
  'https://github.com/tyru/open-browser.vim',
  cmd = 'OpenBrowser',
  config = function()
    vim.api.nvim_create_user_command('OpenBrowser', open_browser, { nargs = '*' })
  end,
}
