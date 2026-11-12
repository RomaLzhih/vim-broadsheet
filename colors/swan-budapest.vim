" =============================================================================
" swan-budapest.vim — the Grand Budapest edition of the Broadsheet family
" =============================================================================
"
" The page is cut from the lobby boy's uniform, and everything printed on it
" comes from the film's two published palettes: GrandBudapest1 and
" GrandBudapest2 in the wesanderson R package (karthik/wesanderson,
" R/colors.R).  On the late edition all eight hexes are used exactly as
" published — seven carry text, the eighth is the search fill.  One colour is
" added for the role they leave empty: the green tier of Mendl's Courtesan au
" chocolat.
"
" The three most frequent coloured tokens take the pastry's three tiers:
" keywords the pink, functions the green, fields the lavender.
"
"   role     late edition         source          used for
"   ink      #f6eae9  cream       picked          body, identifiers; `oper`
"                                                 shares it, as in vga
"   cmd      #e6a0c4  pink        GrandBudapest2  keywords, headings (8.81:1)
"   ref      #97dab8  green       added           functions, links (11.27:1).
"                                                 The one accent that is not a
"                                                 published hex: L 82, chroma
"                                                 30, hue 160
"   opt      #c6cdf7  lavender    GrandBudapest2  fields, constants (11.65:1)
"   quote    #f1bb7b  apricot     GrandBudapest1  types (10.49:1); also the
"                                                 IncSearch fill
"   env      #7294d4  blue        GrandBudapest2  preproc, macros, $VAR
"                                                 (5.97:1)
"   verb     #d8a499  dusty rose  GrandBudapest2  strings (8.38:1)
"   math     #d67236  orange      GrandBudapest1  numbers, escapes (5.46:1);
"                                                 `storage` shares it
"   alert    #fd6467  salmon      GrandBudapest1  errors (6.22:1); `except`
"                                                 shares it
"   marker   #5b1a18  oxblood     GrandBudapest1  the Search fill and Todo,
"                                                 with ink over it at 11.13:1
"
" Why they sit where they do.  Each line is a rule this family already holds:
"
"   - Keywords and functions are opposite hues, pink against green — dE 62.7,
"     the widest gap in the palette on the most frequent adjacency.
"   - Fields are on `opt` and functions on `ref`, so obj.field and
"     obj.method() are never one colour (dE 46.6).
"   - Types on the apricot and preproc on the blue is yellow against blue,
"     the tokyonight fix for `#include <vector>` over `std::vector<int>`
"     (dE 78.6).
"   - The two loud published values, salmon (chroma 65) and orange (60), land
"     only on rare tokens.  The orange is the one accent under the L 60 floor
"     (L 58.6) and sits where a darker accent is sanctioned: numbers and
"     static/const.
"   - There is no `struct` key: class names stay on `quote` and namespaces on
"     `env`, as in tokyonight.
"
" Soft spots, measured and accepted with the palette:
"
"   - env is the darkest frequent role at L 61.2, 1.2 above the floor, and
"     env on bg_deep is the tightest emitted pair at 4.51:1.
"   - The Search fill is 1.39:1 against the page, the softest in the family
"     (vga 1.58, phosphor 1.74, tokyonight 2.29).  It is the published oxblood.
"   - Closest pairs: strings/comments dE 24.5, keywords/strings 25.2,
"     fields/body 25.7.  The two published palettes are harmonies, so their
"     colours sit closer together than ones drawn for syntax would.
"
" The stock is picked rather than published: the uniform purple's hue line
" (h 312) pressed to near-black, the steps spaced so that CursorLine (1.10:1)
" and Visual (1.21:1) are as visible as in the rest of the family.  The ink
" ladder is the pastry box's cream over mauve greys.
"
" The day edition puts the page on the hotel pink's own hue line.  Paper needs
" dark inks, so every accent is pressed down its hue line until it clears AA,
" with fields held greyer and lighter than preproc to keep the two blues apart
" (dE 18.5, the closest pair on that page).  Four published hexes survive
" verbatim: the oxblood on `storage`, the apricot and the salmon as the Search
" and IncSearch fills, and the lavender as DiffText.  The frequent-roles-ride-
" light law describes a dark page; on paper AA already forces every ink dark,
" so it is declared an exception there rather than met.
"
"   role     day edition          pressed from
"   cmd      #8e3268              pink        (6.35:1)
"   ref      #1a6345              green       (6.11:1)
"   opt      #57618c              lavender    (5.10:1)
"   quote    #805619              apricot     (5.46:1)
"   env      #044c8b              blue        (7.39:1)
"   verb     #874c40              dusty rose  (5.68:1)
"   math     #a24910              orange      (5.10:1)
"   alert    #b82636              salmon      (5.29:1)
"   storage  #5b1a18              oxblood, verbatim (11.10:1)
"
"   :set background=dark      late edition   (the lobby at night)
"   :set background=light     day edition    (the hotel in daylight)
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
  echomsg 'swan-budapest: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — pink paper, every accent pressed down its own hue line.
  let s:palette = {
        \ 'bg'        : ['#f6e9ef', '255'],
        \ 'bg_alt'    : ['#eedee6', '254'],
        \ 'bg_soft'   : ['#e4d0d9', '253'],
        \ 'bg_deep'   : ['#ddc6d1', '252'],
        \ 'ink'       : ['#231a2c', '234'],
        \ 'ink_soft'  : ['#4a3b4c', '238'],
        \ 'ink_mute'  : ['#715e68', '241'],
        \ 'ink_faint' : ['#a5949c', '246'],
        \ 'cmd'       : ['#8e3268', '89'],
        \ 'alert'     : ['#b82636', '167'],
        \ 'ref'       : ['#1a6345', '29'],
        \ 'env'       : ['#044c8b', '25'],
        \ 'math'      : ['#a24910', '130'],
        \ 'verb'      : ['#874c40', '131'],
        \ 'opt'       : ['#57618c', '60'],
        \ 'quote'     : ['#805619', '94'],
        \ 'oper'      : ['#231a2c', '234'],
        \ 'storage'   : ['#5b1a18', '52'],
        \ 'except'    : ['#b82636', '167'],
        \ 'marker'    : ['#f1bb7b', '179'],
        \ 'marker_hot': ['#fd6467', '203'],
        \ 'on_hot'    : ['#231a2c', '234'],
        \ 'diff_add'  : ['#c5e8d5', '152'],
        \ 'diff_chg'  : ['#dbdef5', '189'],
        \ 'diff_del'  : ['#fdd3d2', '224'],
        \ 'diff_txt'  : ['#c6cdf7', '147'],
        \ }
  " The day inks again, with the bright half one step lighter so a terminal
  " still has two intensities to work with.
  let s:ansi = [
        \ '#ddc6d1', '#b82636', '#1a6345', '#805619',
        \ '#044c8b', '#8e3268', '#57618c', '#4a3b4c',
        \ '#715e68', '#ca3340', '#1e7350', '#94631b',
        \ '#045fac', '#a6407b', '#6370a2', '#231a2c',
        \ ]
else
  " Late edition — the eight published hexes on the uniform purple.
  let s:palette = {
        \ 'bg'        : ['#1a131f', '234'],
        \ 'bg_alt'    : ['#241c2b', '235'],
        \ 'bg_soft'   : ['#2d2336', '236'],
        \ 'bg_deep'   : ['#34293d', '237'],
        \ 'ink'       : ['#f6eae9', '255'],
        \ 'ink_soft'  : ['#cfc3cd', '251'],
        \ 'ink_mute'  : ['#9e92a2', '246'],
        \ 'ink_faint' : ['#655b6b', '59'],
        \ 'cmd'       : ['#e6a0c4', '218'],
        \ 'alert'     : ['#fd6467', '203'],
        \ 'ref'       : ['#97dab8', '115'],
        \ 'env'       : ['#7294d4', '68'],
        \ 'math'      : ['#d67236', '130'],
        \ 'verb'      : ['#d8a499', '181'],
        \ 'opt'       : ['#c6cdf7', '189'],
        \ 'quote'     : ['#f1bb7b', '179'],
        \ 'oper'      : ['#f6eae9', '255'],
        \ 'storage'   : ['#d67236', '130'],
        \ 'except'    : ['#fd6467', '203'],
        \ 'marker'    : ['#5b1a18', '52'],
        \ 'marker_hot': ['#f1bb7b', '179'],
        \ 'on_hot'    : ['#1a131f', '234'],
        \ 'diff_add'  : ['#162f23', '22'],
        \ 'diff_chg'  : ['#17233b', '17'],
        \ 'diff_del'  : ['#45171b', '52'],
        \ 'diff_txt'  : ['#243e68', '24'],
        \ }
  " The accents as published, with a lifted half for the bright eight.
  let s:ansi = [
        \ '#241c2b', '#fd6467', '#97dab8', '#f1bb7b',
        \ '#7294d4', '#e6a0c4', '#c6cdf7', '#cfc3cd',
        \ '#837888', '#ff8985', '#b0e9cb', '#ffcf98',
        \ '#89abef', '#f6b3d5', '#dadefb', '#f6eae9',
        \ ]
endif

call broadsheet#apply('swan-budapest', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
