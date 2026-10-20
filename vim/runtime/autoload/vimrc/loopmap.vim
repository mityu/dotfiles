vim9script

import 'vimrc.vim' as Vimrc

# From this config:
#   {
#       id: 'Tab',
#       enter_with: 'g',
#       body: [
#           ['h', 'gt<C-g>'],
#       ],
#   }
# We need to create these mappings:
#   gh                       <SID>(loop:Tab)h
#   <SID>(loop:Tab)          <Nop>
#   <SID>(loop:Tab)<ESC>     <Nop>
#   <SID>(loop:Tab)h         gt<C-g><SID>(loop:Tab)
#   <SID>(loop:Tab)h         <Cmd>execute "normal! gt\<C-g>"<CR><SID>(loop:Tab)    (tmap)
#   <C-w>gh                  <SID>(loop:Tab)h     (tmap)

# FIXME: Vim does not decode key sequence written in any key protocol when
# <ESC> comes at the end of mapping. As a workaround for this bug, at the
# tail of mappings to cancel loop mappings, put the hardcoded key sequences
# for keys that should work like <ESC>.
const cancelers = [
  '',
  '<C-@>',
  '<C-[>',
  '<ESC>[27;5;63~',  # <ESC> in modifyOtherKeys
  '<ESC>[27;5;91~',  # <C-[> in modifyOtherKeys
  '<ESC>[27;5;64~',  # <C-@> in modifyOtherKeys
  '<ESC>[27;1u',  # <ESC> in modifyOtherKeys
  '<ESC>[91;5u',  # <C-[> in modifyOtherKeys
  '<ESC>[64;5u',  # <C-@> in modifyOtherKeys
]
# const cancelers = ['', '<ESC>', '<C-@>']

export def LoopDefine(config: dict<any>)
  const mode = config->get('mode', 'n')

  if mode ==# 'n'
    for [_, rhs] in config.body
      if rhs =~? '<SID>'
        Vimrc.EchomsgError($'LoopDefine: {config.id}: rhs cannot have <SID>: {rhs}')
        return
      endif
    endfor
  endif

  const prefix = $'<Plug><SID>(loop:{config.id})'
  for canceler in cancelers
    execute $'{mode}noremap {prefix}{canceler} <Nop>'
  endfor

  for body in config.body
    const lhs = body[0]->ReplaceSpecialkeys()
    const rhs = body[1]->ReplaceSpecialkeys()
    execute $'{mode}noremap {prefix}{lhs} {rhs}{prefix}'
    execute $'{mode}noremap {config.enter_with}{lhs} {rhs}{prefix}'
  endfor

  if mode ==# 'n'
    const enterer = config.enter_with->Vimrc.ReplaceTermcodes()->keytrans()
    const termwinkey = &termwinkey ?? '<C-w>'
    const termwinkeyPrefix = (enterer =~? $'^{termwinkey}') ? '' : termwinkey

    for canceler in cancelers
      execute $'tnoremap {prefix}{canceler} <Nop>'
    endfor

    for body in config.body
      const switcher = body[0]
      const executor = prefix .. ReplaceSpecialkeys(switcher)
      const trigger = termwinkeyPrefix .. enterer .. switcher

      const rhs = body[1]
        ->Vimrc.ReplaceTermcodes()
        ->keytrans()
        ->substitute('\zs<\ze.\{-}>', '\\<lt>', 'g')
        ->ReplaceSpecialkeys()

      execute $'tnoremap {executor} <Cmd>execute "normal! {rhs}"<CR>{prefix}'
      execute $'tnoremap {trigger} {prefix}{switcher}'
    endfor
  endif
enddef

export def SimpleLoopDefine(simpleConfig: dict<any>)
  var config = deepcopy(simpleConfig)
  config.body = simpleConfig.follow_key
    ->split('\zs')
    ->mapnew((_, val): list<string> => [val, simpleConfig.enter_with .. val])
  LoopDefine(config)
enddef

def ReplaceSpecialkeys(key: string): string
  return key->substitute('|', '<bar>', 'g')
enddef
