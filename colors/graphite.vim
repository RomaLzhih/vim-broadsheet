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
"   cmd     345°  #6e1128  burgundy           #8c1c13  press-red
"   alert   348°  #ac283f  red                #a52019
"   ref     217°  #1a488d  blueprint blue     #1f4e79  navy
"   env     190°  #0a5262  cyan               #2c5f5d  verdigris
"   math    164°  #175a49  teal               #7d5f0e  ochre     (was warm)
"   verb    125°  #29662e  green              #4f5d16  olive     (was warm)
"   opt     272°  #62388b  violet             #70386b  plum
"   quote   209°  #46525e  slate, 25% sat     #7a5c3e  sepia     (was warm)
"
" The stock is newspaper grey — #e3e5e6, a dull light grey rather than an
" off-white, with only a faint cool cast so it stays distinct from coffee's
" cream.  The accents are pitched to sit on it: a greyer page needs slightly
" deeper inks than a near-white one to hold the same separation.
"
" Commands are a deep burgundy, not a bright red.  They are the most frequent
" thing in a .tex file, so making them the loudest colour on the page is a
" mistake — it turns ordinary prose into a field of flashing markup.
"
" The depth matters more than the hue here.  Chroma in Lab is the useful
" measure: the bright red this replaced sits at 55, and a classic burgundy
" (#800020) at 53 — barely calmer, so it would shout just as much.  #6e1128 is
" at 42, dark enough to settle while still reading as wine rather than as ink.
" The loud red is reserved for `alert`, which is the thing that should actually
" grab you.
"
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
  " Day edition — newspaper grey stock.
  let s:palette = {
        \ 'bg'        : ['#e3e5e6', '255'],
        \ 'bg_alt'    : ['#d8dadb', '254'],
        \ 'bg_soft'   : ['#cccecf', '253'],
        \ 'bg_deep'   : ['#babdbf', '251'],
        \ 'ink'       : ['#000000', '16'],
        \ 'ink_soft'  : ['#35393c', '238'],
        \ 'ink_mute'  : ['#585c60', '242'],
        \ 'ink_faint' : ['#949a9f', '247'],
        \ 'cmd'       : ['#6e1128', '89'],
        \ 'alert'     : ['#ac283f', '161'],
        \ 'ref'       : ['#1a488d', '25'],
        \ 'env'       : ['#0a5262', '24'],
        \ 'math'      : ['#175a49', '23'],
        \ 'verb'      : ['#29662e', '28'],
        \ 'opt'       : ['#62388b', '54'],
        \ 'quote'     : ['#46525e', '59'],
        \ 'marker'    : ['#c6d6e8', '189'],
        \ 'marker_hot': ['#8fbce2', '110'],
        \ 'on_hot'    : ['#000000', '16'],
        \ 'diff_add'  : ['#cedecb', '151'],
        \ 'diff_chg'  : ['#cdd8e2', '188'],
        \ 'diff_del'  : ['#ecdcdc', '224'],
        \ 'diff_txt'  : ['#b4c9dc', '152'],
        \ }
  " On light stock the "bright" half stays dark enough to read on the page.
  let s:ansi = [
        \ '#000000', '#ac283f', '#29662e', '#77682d',
        \ '#1a488d', '#62388b', '#0a5262', '#585c60',
        \ '#949a9f', '#c53f57', '#357f3d', '#927f38',
        \ '#2b5eab', '#7849a1', '#17738b', '#35393c',
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
        \ 'cmd'       : ['#d78fa0', '175'],
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
