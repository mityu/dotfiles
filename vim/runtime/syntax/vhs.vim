syntax keyword vhsKeyword Output Backspace Down Enter Escape Left Right Space Tab Up Set Type Sleep Hide Show Require
syntax match keyword /Ctrl+\a/

syntax keyword vhsType Shell FontFamily FontSize Framerate PlaybackSpeed Height LetterSpacing TypingSpeed LineHeight Padding Theme LoopOffset Width BorderRadius Margin MarginFill WindowBar WindowBarSize CursorBlink

syntax region vhsString start=/"/ end=/"/

syntax match vhsComment /^\s*#.*$/

syntax match vhsNumber /\d/
syntax match vhsTime /\d\+m\?s/ contains=vhsNumber

syntax match vhsOperator /@/

highlight default link vhsKeyword Keyword
highlight default link vhsType Type
highlight default link vhsComment Comment
highlight default link vhsString String
highlight default link vhsNumber Number
highlight default link vhsTime Number
highlight default link vhsOperator Operator
