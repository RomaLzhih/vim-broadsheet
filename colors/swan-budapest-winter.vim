" =============================================================================
" swan-budapest-winter.vim — the Grand Budapest in the snow
" =============================================================================
"
" The same hotel in winter: swan-budapest-summer's assignment at lower
" chroma, so the pastels read as frosted rather than sunlit.  The lavender is
" still the published GrandBudapest2 value.  This pair replaced swan-budapest;
" see swan-budapest-summer.vim for the measurement that started it.
"
"   role       late     day      paints
"   cmd        #ffa7ce  #873e61  keywords; storage too (const, static)
"   env        #fecad1  #764b52  #include, macros; ns too (std::)
"   struct     #fae594  #625719  class names; class / struct / template
"   quote      #fac89f  #754e2b  built-in types: int, double, bool
"   verb       #90cef7  #035d81  strings
"   ref        #99e1bc  #196244  functions, links
"   opt        #c6cdf7  #4d5579  fields, constants
"   math       #fea58e  #874333  numbers, escapes
"   alert      #fd6467  #ad122c  errors; except too (try, catch)
"   marker     #59203d  #fae594  search fill
"   marker_hot #fae594  #ffa7ce  the live match
"
" Built-in types wear a soft peach, far from what they touch most: fields
" dE 49, keywords dE 43, function names dE 45.
"
" The day edition sits on a cooler, paler lilac paper at the same lightness
" steps as summer's pink one, and its inks are held to a lower chroma, so it
" stays the quieter of the two.  Every accent is pressed down its own hue
" line until it clears 4.5:1 on all four paper steps.
"
" Measured with scripts/colorlib.py; both editions pass its audit.
"   late  tightest emitted text pair 5.17:1
"         closest accents: strings/fields dE 16.7, types/numbers dE 19.8
"   day   law 2 declared (it describes a dark page)
"         tightest emitted text pair 4.52:1
"         closest accents: types/numbers dE 15.6, strings/fields dE 16.5
"
"   :set background=dark      late edition   (a winter night at the hotel)
"   :set background=light     day edition    (snow light on the facade)
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
  echomsg 'swan-budapest-winter: no autoload/broadsheet.vim on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — cool lilac paper; every accent pressed down its own hue line.
  let s:palette = {
        \ 'bg'        : ['#eeebf2', '255'],
        \ 'bg_alt'    : ['#e5e1ea', '254'],
        \ 'bg_soft'   : ['#d8d3de', '253'],
        \ 'bg_deep'   : ['#d0cad7', '252'],
        \ 'ink'       : ['#211b28', '234'],
        \ 'ink_soft'  : ['#433e4b', '238'],
        \ 'ink_mute'  : ['#66616c', '241'],
        \ 'ink_faint' : ['#9b97a0', '246'],
        \ 'cmd'       : ['#873e61', '132'],
        \ 'alert'     : ['#ad122c', '88'],
        \ 'ref'       : ['#196244', '29'],
        \ 'env'       : ['#764b52', '95'],
        \ 'ns'        : ['#764b52', '95'],
        \ 'math'      : ['#874333', '131'],
        \ 'verb'      : ['#035d81', '24'],
        \ 'opt'       : ['#4d5579', '60'],
        \ 'quote'     : ['#754e2b', '94'],
        \ 'struct'    : ['#625719', '58'],
        \ 'oper'      : ['#211b28', '234'],
        \ 'storage'   : ['#873e61', '132'],
        \ 'except'    : ['#ad122c', '88'],
        \ 'marker'    : ['#fae594', '222'],
        \ 'marker_hot': ['#ffa7ce', '218'],
        \ 'on_hot'    : ['#211b28', '234'],
        \ 'diff_add'  : ['#c5e8d5', '152'],
        \ 'diff_chg'  : ['#dbdef5', '189'],
        \ 'diff_del'  : ['#fdd3d2', '224'],
        \ 'diff_txt'  : ['#c6cdf7', '147'],
        \ }
  let s:ansi = [
        \ '#d0cad7', '#ad122c', '#196244', '#625719',
        \ '#035d81', '#873e61', '#4d5579', '#433e4b',
        \ '#66616c', '#c02a39', '#2b7152', '#726527',
        \ '#226c91', '#974d70', '#5c6388', '#211b28',
        \ ]
else
  " Late edition — the soft pastels on the uniform purple.
  let s:palette = {
        \ 'bg'        : ['#1a131f', '234'],
        \ 'bg_alt'    : ['#241c2b', '235'],
        \ 'bg_soft'   : ['#2d2336', '236'],
        \ 'bg_deep'   : ['#34293d', '237'],
        \ 'ink'       : ['#f6eae9', '255'],
        \ 'ink_soft'  : ['#cfc3cd', '251'],
        \ 'ink_mute'  : ['#9e92a2', '246'],
        \ 'ink_faint' : ['#655b6b', '59'],
        \ 'cmd'       : ['#ffa7ce', '218'],
        \ 'alert'     : ['#fd6467', '203'],
        \ 'ref'       : ['#99e1bc', '115'],
        \ 'env'       : ['#fecad1', '224'],
        \ 'ns'        : ['#fecad1', '224'],
        \ 'math'      : ['#fea58e', '216'],
        \ 'verb'      : ['#90cef7', '117'],
        \ 'opt'       : ['#c6cdf7', '189'],
        \ 'quote'     : ['#fac89f', '223'],
        \ 'struct'    : ['#fae594', '222'],
        \ 'oper'      : ['#f6eae9', '255'],
        \ 'storage'   : ['#ffa7ce', '218'],
        \ 'except'    : ['#fd6467', '203'],
        \ 'marker'    : ['#59203d', '96'],
        \ 'marker_hot': ['#fae594', '222'],
        \ 'on_hot'    : ['#1a131f', '234'],
        \ 'diff_add'  : ['#162f23', '22'],
        \ 'diff_chg'  : ['#17233b', '17'],
        \ 'diff_del'  : ['#45171b', '52'],
        \ 'diff_txt'  : ['#243e68', '24'],
        \ }
  let s:ansi = [
        \ '#241c2b', '#fd6467', '#99e1bc', '#fae594',
        \ '#90cef7', '#ffa7ce', '#c6cdf7', '#cfc3cd',
        \ '#837888', '#ff8b88', '#aff8d2', '#fff3cf',
        \ '#bbe2fe', '#fec9df', '#dde1ff', '#f6eae9',
        \ ]
endif

call broadsheet#apply('swan-budapest-winter', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
