return {
  'https://github.com/lambdalisue/vim-mr',
  lazy = false,
  init = function()
    local helper = require('vimrc.helper')
    local function predicate(filename)
      if vim.regex([[\.git\%([\/]\%(config\|hooks\)\>\)\@!\>]]):match_str(filename) then
        return false
      elseif
        vim.fn.resolve(vim.fn.expand('%:p')) == filename and vim.bo.buftype ~= ''
      then
        return false
      end
      return true
    end

    vim.g['mr#mru#predicates'] = { predicate }
    vim.g['mr#mrw#predicates'] = { predicate }
    vim.g['vimrc#mruw#predicates'] = { predicate }
    vim.g['mr_mrr_disabled'] = true
    vim.g['mr_mrd_disabled'] = true

    helper.create_autocmd('SourcePost', {
      group = 'vimrc',
      pattern = '*/plugin/mr.vim',
      once = true,
      command = 'call vimrc#mruw#start_recording()',
    })
  end,
}
