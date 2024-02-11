return {
  'https://github.com/lambdalisue/vim-findent',
  cmd = 'Findent',
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      group = 'vimrc',
      callback = function()
        if (not vim.bo.modifiable) or vim.bo.filetype == 'help' then
          return
        end
        vim.cmd('Findent')
      end,
    })
  end
}
