return {
  'https://github.com/kyoh86/vim-ripgrep',
  event = 'VeryLazy',
  config = function()
    vim.api.nvim_create_user_command('RipGrep', function(args)
      local vimrc = require('vimrc')
      local helper = require('vimrc.helper')
      local cwd = vimrc.find_git_root() or vim.fn.getcwd(vim.fn.winnr())
      vim.ui.input({
        prompt = 'Grep here? ',
        default = cwd,
        completion = 'dir',
      }, function(cwd)
        if not cwd then
          helper.echo('Canceled.')
          return
        elseif not vim.fnok.isdirectory(cwd) then
          helper.echomsg_error(('Directory does not exist: %s'):format(cwd))
          return
        end
        local pat = args.args
        local input = vim.ui.input
        if pat ~= '' then
          input = function(_opts, callback)
            callback(pat)
          end
        end
        input({
          prompt = 'Search pattern: ',
        }, function(pat)
          -- Note that this may require vim.schedule() in the future.
          local command = ('rg --json -i %s'):format(pat)
          vim.cmd.redraw()
          helper.echo(('Invoked command: %s'):format(command))
          vim.fn['ripgrep#call'](
            command,
            cwd,
            vim.fs.joinpath(vim.fn.fnamemodify(cwd, ':.'), '')
          )
        end)
      end)
    end, { nargs = '*', complete = 'file' })
  end,
}
