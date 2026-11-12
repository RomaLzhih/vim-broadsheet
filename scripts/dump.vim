" dump.vim — emit every highlight group for one theme/edition, resolved.
"
" Usage (see CLAUDE.md "How to verify a change"):
"   THEME=swan-vga BGSET=dark DUMP_OUT=/tmp/swan-vga_dark.tsv \
"     vim -N -X -u NONE --cmd 'set rtp^=~/code/vim-broadsheet' \
"         -S scripts/dump.vim </dev/null 2>/dev/null
"
" Never wrap the colorscheme load in silent! — the whole point is that
" messages (W18 and friends) surface.  They are written to $DUMP_OUT.msg.
"
" Ex mode has no colour context, so every synIDattr() call passes 'gui'
" explicitly; without it colours read back empty and only term attributes
" leak through.
set nocompatible
set termguicolors
if !empty($BGSET)
  execute 'set background=' . $BGSET
endif

redir => s:msg
execute 'colorscheme ' . $THEME
redir END
call writefile(split(s:msg, "\n"), $DUMP_OUT . '.msg')

" Walk group ids until the name comes back empty; resolve links with
" synIDtrans() and record fg/bg/attrs.  Empty fg/bg mean "inherit Normal" —
" the audit script resolves those.
let s:out = []
let s:i = 1
while 1
  let s:name = synIDattr(s:i, 'name')
  if empty(s:name)
    break
  endif
  let s:t = synIDtrans(s:i)
  let s:fg = synIDattr(s:t, 'fg', 'gui')
  let s:bg = synIDattr(s:t, 'bg', 'gui')
  let s:attrs = []
  for s:a in ['bold', 'italic', 'underline', 'undercurl', 'strikethrough',
        \ 'reverse', 'standout']
    if synIDattr(s:t, s:a, 'gui') ==# '1'
      call add(s:attrs, s:a)
    endif
  endfor
  call add(s:out, join([s:name, synIDattr(s:t, 'name'), s:fg, s:bg,
        \ join(s:attrs, ',')], "\t"))
  let s:i += 1
endwhile
call writefile(s:out, $DUMP_OUT)
qall!
