" =============================================================================
" swan-coffee.vim — the warm edition of the Broadsheet newspaper family
" =============================================================================
"
" Brown-based: warm newsprint stock and warm accents, with pure black body text
" (the warmth lives in the paper and the inks, not in the type).  Commands are a
" deep press-red; math sits in a band of ochre.
"
"   :set background=light     day edition    (warm newsprint stock)
"   :set background=dark      late edition   (press ink-stock)
"
" All group assignments live in autoload/broadsheet.vim — this file is only a
" palette.  See that file for the role each key plays.  Its cool-grey sibling
" is colors/swan-graphite.vim.
"
" Every text-bearing pair here is >= 4.5:1 WCAG contrast.  ink_faint is the one
" deliberate exception: it is for brace glyphs and hairline rules, never text.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'swan-coffee: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — warm newsprint stock, not white.
  let s:palette = {
        \ 'bg'        : ['#f5f2e9', '255'],
        \ 'bg_alt'    : ['#ebe7db', '254'],
        \ 'bg_soft'   : ['#e0dbcb', '253'],
        \ 'bg_deep'   : ['#d2ccb8', '251'],
        \ 'ink'       : ['#000000', '16'],
        \ 'ink_soft'  : ['#3f3b34', '238'],
        \ 'ink_mute'  : ['#6d675c', '243'],
        \ 'ink_faint' : ['#9a9384', '247'],
        \ 'cmd'       : ['#8c1c13', '88'],
        \ 'alert'     : ['#a52019', '124'],
        \ 'ref'       : ['#1f4e79', '24'],
        \ 'env'       : ['#2c5f5d', '23'],
        \ 'verb'      : ['#4f5d16', '58'],
        \ 'math'      : ['#7d5f0e', '94'],
        \ 'opt'       : ['#70386b', '89'],
        \ 'quote'     : ['#7a5c3e', '95'],
        \ 'marker'    : ['#f2df95', '229'],
        \ 'marker_hot': ['#f0c04a', '221'],
        \ 'on_hot'    : ['#000000', '16'],
        \ 'diff_add'  : ['#dde7c8', '194'],
        \ 'diff_chg'  : ['#d9e2ec', '189'],
        \ 'diff_del'  : ['#f0d9d4', '224'],
        \ 'diff_txt'  : ['#c3d4e3', '152'],
        \ }
  " On light stock the "bright" half stays dark enough to read on paper.
  let s:ansi = [
        \ '#000000', '#a52019', '#4f5d16', '#7d5f0e',
        \ '#1f4e79', '#70386b', '#2c5f5d', '#6d675c',
        \ '#9a9384', '#c0392b', '#6b7d24', '#a8811a',
        \ '#2d6ca8', '#94508e', '#3d8280', '#3f3b34',
        \ ]
else
  " Late edition — press ink-stock, the same hues relit for dark.
  let s:palette = {
        \ 'bg'        : ['#16181c', '234'],
        \ 'bg_alt'    : ['#1d2026', '235'],
        \ 'bg_soft'   : ['#272b33', '236'],
        \ 'bg_deep'   : ['#343943', '238'],
        \ 'ink'       : ['#ded8c8', '187'],
        \ 'ink_soft'  : ['#b8b2a2', '145'],
        \ 'ink_mute'  : ['#918b7d', '102'],
        \ 'ink_faint' : ['#5c5a52', '59'],
        \ 'cmd'       : ['#e08b7d', '174'],
        \ 'alert'     : ['#d4776a', '167'],
        \ 'ref'       : ['#7fa9d0', '110'],
        \ 'env'       : ['#79b3aa', '73'],
        \ 'verb'      : ['#a8b56a', '143'],
        \ 'math'      : ['#d7ac52', '179'],
        \ 'opt'       : ['#c193bd', '182'],
        \ 'quote'     : ['#c2a17c', '180'],
        \ 'marker'    : ['#4a4327', '58'],
        \ 'marker_hot': ['#d7ac52', '179'],
        \ 'on_hot'    : ['#16181c', '234'],
        \ 'diff_add'  : ['#22301f', '22'],
        \ 'diff_chg'  : ['#1e2833', '17'],
        \ 'diff_del'  : ['#33201f', '52'],
        \ 'diff_txt'  : ['#2d3f52', '24'],
        \ }
  let s:ansi = [
        \ '#2a2d34', '#d4776a', '#a8b56a', '#d7ac52',
        \ '#7fa9d0', '#c193bd', '#79b3aa', '#b8b2a2',
        \ '#5c5a52', '#e08b7d', '#bcc77f', '#e5c072',
        \ '#9dc0de', '#d3aacf', '#93c5bd', '#ded8c8',
        \ ]
endif

call broadsheet#apply('swan-coffee', s:palette, s:ansi)
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
