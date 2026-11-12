" synwalk.vim — walk every cell of a sample file and report which syntax
" group actually fires and what colour it resolves to.  This is the check
" that catches upstream `hi def link` chains the group-table dump cannot —
" it is how the rAssign bug was found.
"
" Usage:
"   THEME=swan-vga WALK_FILE=scripts/samples/sample.cpp WALK_OUT=/tmp/walk.tsv \
"     vim -N -X -u NONE --cmd 'set rtp^=~/code/vim-broadsheet' \
"         -S scripts/synwalk.vim </dev/null 2>/dev/null
"
" Runs `filetype on` + `syntax on` from a clean state; sets c_functions so
" C/C++ calls highlight at all (house gotcha 10).
set nocompatible termguicolors
let c_functions = 1
filetype on
syntax on
execute 'colorscheme ' . $THEME
execute 'edit ' . $WALK_FILE
" Make sure the syntax script has run for this buffer.
doautocmd Syntax

let s:seen = {}
for s:l in range(1, line('$'))
  let s:line = getline(s:l)
  for s:c in range(1, strlen(s:line))
    let s:id = synID(s:l, s:c, 1)
    if s:id == 0
      continue
    endif
    let s:t = synIDtrans(s:id)
    let s:key = synIDattr(s:id, 'name') . "\t" . synIDattr(s:t, 'name')
          \ . "\t" . synIDattr(s:t, 'fg', 'gui')
    if !has_key(s:seen, s:key)
      let s:seen[s:key] = matchstr(s:line,
            \ '\%' . s:c . 'c\S\{1,24}')
    endif
  endfor
endfor

let s:out = []
for [s:k, s:v] in items(s:seen)
  call add(s:out, s:k . "\t" . s:v)
endfor
call writefile(sort(s:out), $WALK_OUT)
qall!
