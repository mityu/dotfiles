vim9script

import $MYVIMRC as Vimrc

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
#   <SID>(loop:Tab)h         gh<C-g><SID>(loop:Tab)
#   <SID>(loop:Tab)h         <Cmd>execute "normal! gt\<C-g>"<CR><SID>(loop:Tab)    (tmap)
#   <C-w>gh                  <SID>(loop:Tab)h     (tmap)

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
  execute $'{mode}noremap {prefix} <Nop>'
  execute $'{mode}noremap {prefix}<ESC> <Nop>'

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

    execute $'tnoremap {prefix} <Nop>'
    execute $'tnoremap {prefix}<ESC> <Nop>'

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
