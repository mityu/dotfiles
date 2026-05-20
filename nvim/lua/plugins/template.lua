return {
  'https://github.com/thinca/vim-template',
  lazy = false,
  config = function()
    local helper = require('vimrc.helper')
    helper.create_autocmd('User', {
      group = 'vimrc',
      pattern = 'plugin-template-loaded',
      callback = function()
        if vim.fnok.search('<+CURSOR+>') then
          vim.cmd(([[normal! "_d%dl]]):format(('<+CURSOR+>'):len()))
        end
        if helper.is_plugin_installed('vim-findent') then
          vim.cmd('Findent!')
        end
        if not (vim.fn.line('$') == 1 and vim.fn.getline(1) == '') then
          vim.bo.modified = true
        end
      end,
    })
  end,
}
