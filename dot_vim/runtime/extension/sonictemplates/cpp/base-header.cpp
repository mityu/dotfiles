:keeppatterns %s/LOADGUARD/\=toupper(substitute(expand('%:p:t'),'\.','_','g'))/ge
#ifndef LOADGUARD
#define LOADGUARD

namespace {{_cursor_}}{

}

#endif //  LOADGUARD
