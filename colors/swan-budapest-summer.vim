" =============================================================================
" swan-budapest-summer.vim — the Grand Budapest in high season
" =============================================================================
"
" The hotel at its height: the pink facade, the goose yellow of the pastry
" cream, the pastel tiers of Mendl's Courtesan au chocolat.  This pair
" replaced swan-budapest, whose late edition put brown, dark blue and ochre in
" front of a C++ file: measured on a 50-line C++ class as clangd and the
" user's vimrc paint it, the hotel pink covered 4.1% of the coloured code.
" Here the pink family covers 21.5% and the goose yellow 18%.
"
" swan-budapest-winter is the same assignment at lower chroma.
"
"   role       late     day      paints
"   cmd        #ff86c0  #9b2867  keywords; storage too (const, static)
"   env        #ffb9c9  #804555  #include, macros; ns too (std::)
"   struct     #fbea85  #5f5800  class names; class / struct / template
"   quote      #ffb878  #804a0c  built-in types: int, double, bool
"   verb       #65ccfe  #065e7d  strings
"   ref        #82e5b1  #01643f  functions, links
"   opt        #becafe  #465582  fields, constants
"   math       #ff9c80  #913d28  numbers, escapes
"   alert      #fd6467  #ad122c  errors; except too (try, catch)
"   marker     #60193f  #fbea85  search fill
"   marker_hot #fbea85  #ff86c0  the live match
"
" Why the yellow is split: with class names and built-in types on one yellow
" it covered a quarter of the file, so the built-in types take the peach.  The
" `ns` key keeps namespaces with the preprocessor while `struct` exists (see
" the core); without it every std:: would turn yellow too.
"
" The yellow was softened one step on 2026-11-19, at the user's request:
" #fcea72 (chroma 60) was the loudest frequent colour on the page.  #fbea85
" keeps L 92 at chroma 51, just under the keyword pink (53) and still dE 9.5
" from winter's yellow.  Pressed for the day edition it still gives #5f5800.
"
" The built-in types went through four colours first: the film's burnt
" orange (#d67236) was too dark at L 60, a bright tangerine (chroma 67) jumped
" out of a page of pastels, lilac sat between fields and keywords.  Peach is
" warm, pastry-coloured, and far from what a built-in type touches most:
" fields dE 70, keywords dE 62, function names dE 65.
"
" The day edition presses every accent down its own hue line until it clears
" 4.5:1 on all four paper steps, so nothing sinks under a selection or the
" completion menu.  On paper every ink has to be dark; the season shows in
" the pink paper and in the yellow and pink highlighter marks.
"
" Measured with scripts/colorlib.py; both editions pass its audit.
"   late  tightest emitted text pair 5.17:1
"         closest accents: types/numbers dE 20.5, strings/fields dE 23.9
"   day   law 2 declared (it describes a dark page)
"         tightest emitted text pair 4.51:1
"         closest accents: strings/fields dE 18.6, types/numbers dE 20.0
"
"   :set background=dark      late edition   (a summer night at the hotel)
"   :set background=light     day edition    (the facade in the sun)
"
" Nothing in this theme is bold and it asks for the 'code' profile; see
" swan-tokyonight.vim for the reasoning.  Group assignments live in
" autoload/broadsheet.vim.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'swan-budapest-summer: no autoload/broadsheet.vim on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — pink paper; every accent pressed down its own hue line.
  let s:palette = {
        \ 'bg'        : ['#f6e9ef', '255'],
        \ 'bg_alt'    : ['#eedee6', '254'],
        \ 'bg_soft'   : ['#e4d0d9', '253'],
        \ 'bg_deep'   : ['#ddc6d1', '252'],
        \ 'ink'       : ['#231a2c', '234'],
        \ 'ink_soft'  : ['#4a3b4c', '238'],
        \ 'ink_mute'  : ['#715e68', '241'],
        \ 'ink_faint' : ['#a5949c', '246'],
        \ 'cmd'       : ['#9b2867', '89'],
        \ 'alert'     : ['#ad122c', '88'],
        \ 'ref'       : ['#01643f', '29'],
        \ 'env'       : ['#804555', '95'],
        \ 'ns'        : ['#804555', '95'],
        \ 'math'      : ['#913d28', '52'],
        \ 'verb'      : ['#065e7d', '24'],
        \ 'opt'       : ['#465582', '60'],
        \ 'quote'     : ['#804a0c', '94'],
        \ 'struct'    : ['#5f5800', '58'],
        \ 'oper'      : ['#231a2c', '234'],
        \ 'storage'   : ['#9b2867', '89'],
        \ 'except'    : ['#ad122c', '88'],
        \ 'marker'    : ['#fbea85', '228'],
        \ 'marker_hot': ['#ff86c0', '211'],
        \ 'on_hot'    : ['#231a2c', '234'],
        \ 'diff_add'  : ['#c5e8d5', '152'],
        \ 'diff_chg'  : ['#dbdef5', '189'],
        \ 'diff_del'  : ['#fdd3d2', '224'],
        \ 'diff_txt'  : ['#c6cdf7', '147'],
        \ }
  let s:ansi = [
        \ '#ddc6d1', '#ad122c', '#01643f', '#5f5800',
        \ '#065e7d', '#9b2867', '#465582', '#4a3b4c',
        \ '#715e68', '#c02a39', '#1c734d', '#6f6613',
        \ '#236d8c', '#ac3976', '#556392', '#231a2c',
        \ ]
else
  " Late edition — the vivid pastels on the uniform purple.
  let s:palette = {
        \ 'bg'        : ['#1a131f', '234'],
        \ 'bg_alt'    : ['#241c2b', '235'],
        \ 'bg_soft'   : ['#2d2336', '236'],
        \ 'bg_deep'   : ['#34293d', '237'],
        \ 'ink'       : ['#f6eae9', '255'],
        \ 'ink_soft'  : ['#cfc3cd', '251'],
        \ 'ink_mute'  : ['#9e92a2', '246'],
        \ 'ink_faint' : ['#655b6b', '59'],
        \ 'cmd'       : ['#ff86c0', '211'],
        \ 'alert'     : ['#fd6467', '203'],
        \ 'ref'       : ['#82e5b1', '79'],
        \ 'env'       : ['#ffb9c9', '217'],
        \ 'ns'        : ['#ffb9c9', '217'],
        \ 'math'      : ['#ff9c80', '216'],
        \ 'verb'      : ['#65ccfe', '117'],
        \ 'opt'       : ['#becafe', '189'],
        \ 'quote'     : ['#ffb878', '215'],
        \ 'struct'    : ['#fbea85', '228'],
        \ 'oper'      : ['#f6eae9', '255'],
        \ 'storage'   : ['#ff86c0', '211'],
        \ 'except'    : ['#fd6467', '203'],
        \ 'marker'    : ['#60193f', '89'],
        \ 'marker_hot': ['#fbea85', '228'],
        \ 'on_hot'    : ['#1a131f', '234'],
        \ 'diff_add'  : ['#162f23', '22'],
        \ 'diff_chg'  : ['#17233b', '17'],
        \ 'diff_del'  : ['#45171b', '52'],
        \ 'diff_txt'  : ['#243e68', '24'],
        \ }
  let s:ansi = [
        \ '#241c2b', '#fd6467', '#82e5b1', '#fbea85',
        \ '#65ccfe', '#ff86c0', '#becafe', '#cfc3cd',
        \ '#837888', '#ff8b88', '#99fcc7', '#fff4c6',
        \ '#a8defe', '#feabd0', '#dce1fe', '#f6eae9',
        \ ]
endif

call broadsheet#apply('swan-budapest-summer', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
