vim9script

import $MYVIMRC as Vimrc

class FallSubmode
  var _pluginMappings: list<dict<any>> = []
  var _cmdline: list<any> = []

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

  def NormalMode()
    this._clearMappings()
    autocmd vimrc-fall-submode KeyInputPre c Invoke('ThrowAwayUnmappedKeyTypes')
    # We need to map <ESC>/<C-c> with <buffer> since denops input() helper
    # defines an original <ESC> mapping for the current buffer.
    # Note that mapping to <C-c> won't work.  Maybe Vim doesn't set up the
    # got_int flag if it is given via mappings or feedkeys.
    cnoremap <buffer> <ESC> <Cmd>call interrupt()<CR>
    cnoremap <buffer> <C-c> <Cmd>call interrupt()<CR>
    cnoremap q <Cmd>call interrupt()<CR>
    cnoremap i <Cmd>call <SID>Invoke('InsertMode')<CR>
    cnoremap j <Plug>(fall-cursor-next)
    cnoremap k <Plug>(fall-cursor-prev)
    cnoremap m <Plug>(fall-select)
    cnoremap * <Plug>(fall-select-all)
    cnoremap <CR> <Plug>(fall-action-default)
    cnoremap a <Plug>(fall-action-select)
    cnoremap <Tab> <Plug>(fall-action-select)
    highlight! link FallQueryCursor FallNormal
    redraw
  enddef

  def InsertMode()
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
    highlight! link FallQueryCursor Cursor
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
  if !exists('b:fall_submode')
    b:fall_submode = []
  endif
  b:fall_submode->add(FallSubmode.new())
  Invoke('SetupSubmode')
enddef

export def Shutdown()
  Invoke('ShutdownSubmode')
  b:fall_submode->remove(-1)
enddef

def Invoke(fn: string)
  if !exists('b:fall_submode') || empty(b:fall_submode)
    Vimrc.EchomsgError('Internal error: b:fall_submode does not exist.')
  endif
  execute $'b:fall_submode[-1].{fn}()'
enddef
