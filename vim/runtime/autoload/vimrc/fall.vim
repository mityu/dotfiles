vim9script

import $MYVIMRC as Vimrc

class FallSubmode
  var _pluginMappings: list<dict<any>> = []
  var _cmdline: list<any> = []
  var RestoreSubmodeFn: func(): void = null_function

  def _inspectPluginMapping(idx: number, m: dict<any>): bool
    return m.mode ==# 'c' && m.lhs =~? '^<Plug>(\%(vimrc-\)\?fall-'
  enddef

  def _savePluginMappings()
    this._pluginMappings = maplist()->filter(this._inspectPluginMapping)
  enddef

  def SetupSubmode()
    augroup vimrc-fall-submode
      autocmd!
      autocmd CmdlineEnter @ ++once Invoke('NormalMode')
    augroup END
    this._savePluginMappings()
  enddef

  def ShutdownSubmode()
    this._clearMappings()
  enddef

  def RestoreSubmode()
    if this.RestoreSubmodeFn != null_function
      this.RestoreSubmodeFn()
    endif
  enddef

  def NormalMode()
    const cancelKey = '###DenopsStdHelperInputCancelled###'
    this.RestoreSubmodeFn = this.NormalMode
    this._clearMappings()
    autocmd vimrc-fall-submode KeyInputPre c Invoke('ThrowAwayUnmappedKeyTypes')
    execute $'cnoremap <ESC> <C-e><C-u>{cancelKey}<CR>'
    execute $'cnoremap <C-c> <C-e><C-u>{cancelKey}<CR>'
    execute $'cnoremap q <C-e><C-u>{cancelKey}<CR>'
    cnoremap i <Cmd>call <SID>Invoke('InsertMode')<CR>
    cnoremap j <Plug>(fall-list-next)
    cnoremap k <Plug>(fall-list-prev)
    cnoremap gg <Plug>(fall-list-first)
    cnoremap G <Plug>(fall-list-last)
    cnoremap m <Plug>(fall-select)
    cnoremap * <Plug>(fall-select-all)
    cnoremap <CR> <Cmd>call fall#action('')<CR>
    cnoremap a <Plug>(fall-action-select)
    cnoremap ? <Plug>(fall-help)
    cnoremap <C-n> <Plug>(fall-preview-next:scroll)
    cnoremap <C-p> <Plug>(fall-preview-prev:scroll)
    highlight! link FallInputCursor FallNormal
    redraw
  enddef

  def InsertMode()
    this.RestoreSubmodeFn = this.InsertMode
    this._clearMappings()
    this._cmdline = [getcmdline(), getcmdpos()]
    cnoremap <buffer> <ESC> <Cmd>call <SID>Invoke('NormalMode')<CR>
    cnoremap <buffer> <C-c> <Cmd>call <SID>Invoke('CancelInsert')<CR>
    cnoremap <CR> <Cmd>call <SID>Invoke('NormalMode')<CR>
    cnoremap <C-f> <Right>
    cnoremap <C-p> <Up>
    cnoremap <C-n> <Down>
    cnoremap <C-b> <Left>
    cnoremap <C-a> <C-b>
    highlight! link FallInputCursor Cursor
    redraw
  enddef

  def CancelInsert()
    this.NormalMode()
    call('setcmdline', this._cmdline)
  enddef

  def ThrowAwayUnmappedKeyTypes()
    if v:event.typed
      v:char = "\<Ignore>"
    endif
  enddef

  def _clearMappings()
    augroup vimrc-fall-submode
      autocmd!
    augroup END
    silent! cmapclear
    this._pluginMappings->foreach((_: number, m: dict<any>) => mapset(m))
  enddef
endclass

export def Setup()
  if !exists('g:fall_submode')
    g:fall_submode = []
  endif
  g:fall_submode->add(FallSubmode.new())
  Invoke('SetupSubmode')
enddef

export def Shutdown()
  Invoke('ShutdownSubmode')
  g:fall_submode->remove(-1)
  if !empty(g:fall_submode)
    Invoke('RestoreSubmode')
  endif
enddef

def Invoke(fn: string)
  if !exists('g:fall_submode') || empty(g:fall_submode)
    Vimrc.EchomsgError('Internal error: g:fall_submode does not exist.')
    return
  endif
  execute $'g:fall_submode[-1].{fn}()'
enddef
