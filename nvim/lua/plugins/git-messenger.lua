return {
  'https://github.com/rhysd/git-messenger.vim',
  cmd = 'GitMessenger',
  keys = '<Plug>(git-messenger)',
  init = function()
    vim.g['git_messenger_no_default_mappings'] = true
    vim.g['git_messenger_floating_win_opts'] = { border = 'single' }
    vim.g['git_messenger_popup_content_margins'] = false
  end,
}
