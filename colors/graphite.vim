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
"   cmd     341°  #86102f  drafting red       #8c1c13  press-red
"   alert   348°  #9c2439  brighter red       #a52019
"   ref     217°  #18417f  blueprint blue     #1f4e79  navy
"   env     190°  #094a58  cyan               #2c5f5d  verdigris
"   math    164°  #155142  teal               #7d5f0e  ochre     (was warm)
"   verb    125°  #255c2a  green              #4f5d16  olive     (was warm)
"   opt     272°  #583280  violet             #70386b  plum
"   quote   209°  #3f4a55  slate, 25% sat     #7a5c3e  sepia     (was warm)
"
" The stock is a properly grey #d7dce0, not an off-white.  The accents are
" pitched to sit on it: a darker page needs darker inks to hold the same
" separation, so they are deeper here than a light-stock theme would use.
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
        \ 'bg'        : ['#d7dce0', '255'],
        \ 'bg_alt'    : ['#ccd2d7', '254'],
        \ 'bg_soft'   : ['#c0c6cc', '253'],
        \ 'bg_deep'   : ['#aeb5bc', '251'],
        \ 'ink'       : ['#000000', '16'],
        \ 'ink_soft'  : ['#2f3337', '238'],
        \ 'ink_mute'  : ['#4e5256', '242'],
        \ 'ink_faint' : ['#848a8f', '247'],
        \ 'cmd'       : ['#86102f', '125'],
        \ 'alert'     : ['#9c2439', '161'],
        \ 'ref'       : ['#18417f', '25'],
        \ 'env'       : ['#094a58', '24'],
        \ 'math'      : ['#155142', '23'],
        \ 'verb'      : ['#255c2a', '28'],
        \ 'opt'       : ['#583280', '54'],
        \ 'quote'     : ['#3f4a55', '59'],
        \ 'marker'    : ['#bfd0e4', '189'],
        \ 'marker_hot': ['#8ab8e0', '110'],
        \ 'on_hot'    : ['#000000', '16'],
        \ 'diff_add'  : ['#c6d6c2', '151'],
        \ 'diff_chg'  : ['#c5d1dc', '188'],
        \ 'diff_del'  : ['#e6d4d4', '224'],
        \ 'diff_txt'  : ['#adc2d6', '152'],
        \ }
  " On light stock the "bright" half stays dark enough to read on the page.
  let s:ansi = [
        \ '#000000', '#9c2439', '#255c2a', '#6a5c28',
        \ '#18417f', '#583280', '#094a58', '#4e5256',
        \ '#848a8f', '#b8354e', '#31743a', '#847333',
        \ '#28579c', '#6f4394', '#156a80', '#2f3337',
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
