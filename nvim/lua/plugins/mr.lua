return {
  'https://github.com/lambdalisue/mr.vim',
  lazy = false,
  init = function()
    local function predicates(filename)
      if vim.regex([[\.git\%([\/]\%(config\|hooks\)\>\)\@!\>]]):match_str(filename) then
        return false
      elseif vim.fn.resolve(vim.fn.expand('%:p')) == filename and vim.bo.buftype ~= '' then
        return false
      end
      return true
    end

    vim.g['mr#mru#predicates'] = { predicates }
    vim.g['mr#mrw#predicates'] = { predicates }
  end
}
