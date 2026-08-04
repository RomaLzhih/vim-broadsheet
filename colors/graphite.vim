" =============================================================================
" graphite.vim — the cool edition of the Broadsheet newspaper family
" =============================================================================
"
" Grey-based, and designed from the drafting table rather than from newsprint.
" Coffee's palette is weighted to the warm half of the wheel — five of its eight
" accents sit between 300° and 90° — which is what makes it read as printing ink
" on warm stock.  This one commits to the cool half instead:
"
"   role    hue   graphite                    coffee, for contrast
"   cmd     343°  #a3123a  drafting red       #8c1c13  press-red
"   alert   349°  #bd2b46  brighter red       #a52019
"   ref     216°  #1d4f9c  blueprint blue     #1f4e79  navy
"   env     191°  #0b5a6b  cyan               #2c5f5d  verdigris
"   math    164°  #1a6350  teal               #7d5f0e  ochre     (was warm)
"   verb    125°  #2d7033  green              #4f5d16  olive     (was warm)
"   opt     271°  #6b3d96  violet             #70386b  plum
"   quote   209°  #4d5a66  slate, 25% sat     #7a5c3e  sepia     (was warm)
"
" Commands are the single warm exception, because they have to pop hardest.
" Everything else is cool, and `quote` carries its role on low saturation rather
" than on a hue of its own — the native logic for a grey theme.
"
" Note math and verb are NOT coffee's slots re-lit: green goes to strings (the
" universal convention) and math takes the calmer teal, because a math zone is a
" large band of text and wants the quieter colour.  The cool half of the wheel
" only fits four or five well-separated hues, so the assignment had to change
" rather than just the values.
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
        \ 'ink'       : ['#000000', '16'],
        \ 'ink_soft'  : ['#3a3e42', '238'],
        \ 'ink_mute'  : ['#62666a', '242'],
        \ 'ink_faint' : ['#a3a7aa', '247'],
        \ 'cmd'       : ['#a3123a', '125'],
        \ 'alert'     : ['#bd2b46', '161'],
        \ 'ref'       : ['#1d4f9c', '25'],
        \ 'env'       : ['#0b5a6b', '24'],
        \ 'math'      : ['#1a6350', '23'],
        \ 'verb'      : ['#2d7033', '28'],
        \ 'opt'       : ['#6b3d96', '54'],
        \ 'quote'     : ['#4d5a66', '59'],
        \ 'marker'    : ['#cddced', '189'],
        \ 'marker_hot': ['#93bfe4', '110'],
        \ 'on_hot'    : ['#000000', '16'],
        \ 'diff_add'  : ['#d6e4d2', '151'],
        \ 'diff_chg'  : ['#d5dfe8', '188'],
        \ 'diff_del'  : ['#f2e3e3', '224'],
        \ 'diff_txt'  : ['#bcd0e2', '152'],
        \ }
  " On light stock the "bright" half stays dark enough to read on the page.
  let s:ansi = [
        \ '#000000', '#bd2b46', '#2d7033', '#7a6a2e',
        \ '#1d4f9c', '#6b3d96', '#0b5a6b', '#62666a',
        \ '#a3a7aa', '#d24560', '#3a8a41', '#96843a',
        \ '#2f66b5', '#8253ab', '#1a7c92', '#3a3e42',
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
        \ 'cmd'       : ['#ef7f95', '210'],
        \ 'alert'     : ['#e8697f', '204'],
        \ 'ref'       : ['#7fa8e8', '111'],
        \ 'env'       : ['#56b8cf', '80'],
        \ 'math'      : ['#5fbfa8', '79'],
        \ 'verb'      : ['#7ec97e', '114'],
        \ 'opt'       : ['#b189e8', '141'],
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
        \ '#262a2f', '#e8697f', '#7ec97e', '#c9bd82',
        \ '#7fa8e8', '#b189e8', '#56b8cf', '#a8aeb3',
        \ '#565c62', '#ef7f95', '#9ad79a', '#dad0a0',
        \ '#9dbef0', '#c5a5ef', '#7fcbdf', '#d2d6d9',
        \ ]
endif

call broadsheet#apply('graphite', s:palette, s:ansi)
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
