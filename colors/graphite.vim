" =============================================================================
" graphite.vim — the cool edition of the Broadsheet newspaper family
" =============================================================================
"
" Grey-based: cool grey stock, neutral ink, and every accent re-lit cool so
" nothing clashes with the page.  Where coffee runs press-red and ochre, this
" runs oxblood and brass — same roles, same structure, no warmth.
"
"   coffee            graphite
"   #8c1c13 press-red  ->  #8f2530 oxblood      commands, headings
"   #2c5f5d verdigris  ->  #26605e teal         environments
"   #7d5f0e ochre      ->  #6b6220 brass        math
"   #7a5c3e sepia      ->  #4d5a66 steel        blockquotes, types
"   #1f4e79 navy       ->  #1f4e79 navy         refs (already cool)
"
"   :set background=light     day edition    (cool grey stock)
"   :set background=dark      late edition   (cool ink-stock)
"
" All group assignments live in autoload/broadsheet.vim — this file is only a
" palette.  See that file for the role each key plays.  Its warm sibling is
" colors/coffee.vim.
"
" Every text-bearing pair here is >= 4.5:1 WCAG contrast.  ink_faint is the one
" deliberate exception: it is for brace glyphs and hairline rules, never text.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'graphite: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — cool grey stock.
  let s:palette = {
        \ 'bg'        : ['#f0f1f2', '255'],
        \ 'bg_alt'    : ['#e5e7e9', '254'],
        \ 'bg_soft'   : ['#d9dcdf', '253'],
        \ 'bg_deep'   : ['#c7cbcf', '251'],
        \ 'ink'       : ['#191b1d', '235'],
        \ 'ink_soft'  : ['#3a3e42', '238'],
        \ 'ink_mute'  : ['#62666a', '242'],
        \ 'ink_faint' : ['#a3a7aa', '247'],
        \ 'cmd'       : ['#8e1f42', '89'],
        \ 'alert'     : ['#a82945', '125'],
        \ 'ref'       : ['#23488c', '25'],
        \ 'env'       : ['#0a5570', '24'],
        \ 'verb'      : ['#2d6135', '22'],
        \ 'math'      : ['#6b6220', '58'],
        \ 'opt'       : ['#653490', '54'],
        \ 'quote'     : ['#4d5a66', '59'],
        \ 'marker'    : ['#cddced', '189'],
        \ 'marker_hot': ['#93bfe4', '110'],
        \ 'on_hot'    : ['#191b1d', '235'],
        \ 'diff_add'  : ['#d6e4d2', '151'],
        \ 'diff_chg'  : ['#d5dfe8', '188'],
        \ 'diff_del'  : ['#ecd8d8', '224'],
        \ 'diff_txt'  : ['#bcd0e2', '152'],
        \ }
  " On light stock the "bright" half stays dark enough to read on the page.
  let s:ansi = [
        \ '#191b1d', '#a82945', '#2d6135', '#6b6220',
        \ '#23488c', '#653490', '#0a5570', '#62666a',
        \ '#a3a7aa', '#c13f5c', '#3d7a45', '#8a7f2c',
        \ '#3560a8', '#7d4aa8', '#166d8a', '#3a3e42',
        \ ]
else
  " Late edition — cool ink-stock, the same hues relit for dark.
  let s:palette = {
        \ 'bg'        : ['#15171a', '234'],
        \ 'bg_alt'    : ['#1c1f23', '235'],
        \ 'bg_soft'   : ['#262a2f', '236'],
        \ 'bg_deep'   : ['#333941', '238'],
        \ 'ink'       : ['#d2d6d9', '188'],
        \ 'ink_soft'  : ['#a8aeb3', '145'],
        \ 'ink_mute'  : ['#848a90', '102'],
        \ 'ink_faint' : ['#565c62', '59'],
        \ 'cmd'       : ['#e88fa5', '175'],
        \ 'alert'     : ['#dd7f93', '168'],
        \ 'ref'       : ['#8ba6e0', '111'],
        \ 'env'       : ['#5fbcd0', '80'],
        \ 'verb'      : ['#8fc08f', '114'],
        \ 'math'      : ['#c9b878', '180'],
        \ 'opt'       : ['#bb96e0', '141'],
        \ 'quote'     : ['#9fb0bd', '145'],
        \ 'marker'    : ['#2b3b4a', '23'],
        \ 'marker_hot': ['#93bfe4', '110'],
        \ 'on_hot'    : ['#15171a', '234'],
        \ 'diff_add'  : ['#1d2b22', '22'],
        \ 'diff_chg'  : ['#1b2733', '17'],
        \ 'diff_del'  : ['#301f22', '52'],
        \ 'diff_txt'  : ['#2b3d50', '24'],
        \ }
  let s:ansi = [
        \ '#262a2f', '#dd7f93', '#8fc08f', '#c9b878',
        \ '#8ba6e0', '#bb96e0', '#5fbcd0', '#a8aeb3',
        \ '#565c62', '#e88fa5', '#a3cea3', '#d9cb92',
        \ '#a3baea', '#cbb0ea', '#82cddd', '#d2d6d9',
        \ ]
endif

call broadsheet#apply('graphite', s:palette, s:ansi)
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
