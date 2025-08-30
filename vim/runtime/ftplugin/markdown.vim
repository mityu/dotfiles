vim9script

SetUndoFtplugin delcommand -buffer PrevimStyleGithub
SetUndoFtplugin delcommand -buffer PrevimStyleDefault

def PrevimStyleGithub()
  g:previm_disable_default_css = 1
  g:previm_extra_libraries = [
    {
      name: 'GitHub',
      files: [{
        type: 'css',
        path: '_/css/extra/github.css',
        url: 'https://github.com/sindresorhus/github-markdown-css/raw/refs/heads/main/github-markdown.css',
      }],
    }
  ]
  previm#refresh()
enddef

def PrevimStyleDefault()
  g:previm_disable_default_css = 0
  g:previm_extra_libraries->filter((v: dict<any>, _: number): bool => v.name ==? 'GitHub')
enddef

command! -buffer PrevimStyleGithub PrevimStyleGithub()
command! -buffer PrevimStyleDefault PrevimStyleDefault()
