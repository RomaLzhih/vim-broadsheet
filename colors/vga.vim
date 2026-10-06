" =============================================================================
" vga.vim — the DOS edition of the Broadsheet family
" =============================================================================
"
" IBM PC text mode on true black.  The hexes are IBM's DAC; the intensity bit
" does the work bold used to do.  White belongs to the prose alone: body text
" and identifiers — the most frequent thing on screen — take DAC bright
" white, and no other group is allowed to wear it.  Frequent tokens ride
" light colours; the one darker accent is reserved for specific modifiers and
" literals.  Blue never carries text at DAC value, exactly as DOS used it —
" it is the Norton-panel wash behind search, selection and diffs, and an
" electric descendant of it carries the constants.
"
" Two earlier cuts are recorded in the family notes: the first put white on
" keywords (Turbo Pascal style) over a lightgray body, the second put a dark
" violet on class/template.  Both were corrected — white is the variable
" colour and only that, and a dark accent among light ones reads as wrong.
"
" The assignment follows Vim's own `koehler`, which is the closest thing in
" the wild to what this theme is after.  That is not a resemblance, it is the
" same palette: koehler's keyword yellow #ffff60 is dE 4.1 from the DAC's
" bright yellow, its type green #60ff60 is dE 5.0 from the DAC's bright green,
" its identifier cyan #40ffff is dE 2.5 from the DAC's bright cyan.  Where the
" two differ is instructive:
"
"   - koehler has NO dim colours at all; every accent it uses sits at L 73-97.
"     Two of this theme's accents were on the dim half of the DAC and have
"     been driven up into that band (see `verb` below).  The dim eight now
"     appear only in the ANSI table, where a terminal asks for them by name.
"   - koehler puts strings, numbers and booleans on one salmon.  Here numbers
"     keep their own amber, because `storage` shares it and qualifiers want to
"     read as machinery rather than as text.
"   - koehler links Structure to Type, so `class` and `int` are one colour.
"     This theme splits them — that split is the whole point of the `struct`
"     key — and gives the green to class, so types take the yellow instead.
"   - koehler's own keywords are yellow and its white is `Normal`: variables
"     and unhighlighted text.  That is this family's law already.  Keywords
"     here are the magenta rather than koehler's yellow; green, yellow and
"     cyan then sit one place round from where koehler puts them.
"
"   role     value              used for
"   ink      #ffffff DAC 15     body, identifiers — the only white on the page
"   cmd      #ff55ff br.magenta keywords — DAC bright magenta verbatim
"                               (8.00:1).  It is the loudest hue the hardware
"                               had, and it sits on the most frequent coloured
"                               token by choice: this theme spends its shout on
"                               the words that give a line its shape
"   struct   #55ff55 br.green  class/template/namespace — DAC bright green
"                               verbatim (15.82:1), asked for directly.  A
"                               declaration is the line that introduces a name,
"                               and the brightest saturated colour the hardware
"                               had suits announcing one.  Under clangd every
"                               `std::` lands here too, so `namespace demo {`
"                               and its uses read alike
"   quote    #ffff55 br.yellow  types — DAC bright yellow verbatim (19.69:1).
"                               koehler puts types on the green and keywords on
"                               the yellow; here the green went to class and
"                               keywords to the magenta, so the yellow lands on
"                               types — the same three era values, rotated one
"                               place round
"   opt      #00b4ff            constants, properties — an electric blue, and
"                               the only accent here that is not a DAC byte.
"                               Four attempts at a blue got it wrong in an
"                               instructive way, so the reasoning is kept:
"                                 - #5555ff, the terminal blue itself, is
"                                   4.13:1 and L46.5 — too dark to sit among
"                                   accents living at L60-97;
"                                 - lifted along its own hue it desaturates
"                                   into lavender (#a996ff), which reads as
"                                   purple, not blue;
"                                 - royal blue #4169e1 is 4.33:1 and L47.8,
"                                   darker still, and lifting it lands dE 11.6
"                                   from that lavender — under the family bar;
"                                 - lifted and rotated to azure (#77aaff) it
"                                   is legible and blue but SOFT, because it
"                                   carries a red channel: HSV saturation 53%
"                                   where every DAC bright is 66.7%.
"                               sRGB caps blue chroma near 49 at this
"                               lightness — green and magenta reach 99, and no
"                               blue can — so vividness has to come from
"                               saturation rather than chroma.  Dropping the
"                               red channel to zero does it: L69.4, 8.97:1,
"                               chroma at the gamut ceiling, saturation 100%.
"   ref      #55ffff br.cyan    functions — the bright half of oper's cyan,
"                               and koehler's Identifier colour
"   oper     #ffffff DAC 15     operators — the body ink, the same white the
"                               variables wear.  This is the one role allowed
"                               to share it, and the reason is that an operator
"                               is CONTENT rather than chrome: `+` against `-`
"                               changes what a line means, so `x + y` reads as
"                               one phrase in one colour.  Delimiters stay a
"                               step back at #aaaaaa, because a bracket is
"                               scaffolding around content rather than content
"                               itself — which is this family's founding rule,
"                               delimiters recede and content advances, applied
"                               inside the expression.  Tried before this: the
"                               dim DAC cyan, then #8a8a8a, then #aaaaaa
"   env      #fe716b            preproc, $VAR — DAC bright red #ff5555 lifted
"                               one step (7.79:1); the middle of the three reds
"   verb     #fe9e96            strings — the same red driven up a second step
"                               (10.55:1), the lightest of the three.  Strings
"                               were on the dim green #00aa00 (L60.6), the
"                               darkest frequent token on the page; this is the
"                               koehler correction.  Arrived at by lifting,
"                               then found to be dE 4.5 from koehler's own
"                               Constant salmon #ffa0a0 — which is the evidence
"                               that koehler IS the DAC set lifted
"   alert    #ff5555 br.red     errors; `except` shares it (throw/raise).  The
"                               DAC red stays exact here — the other two moved.
"                               dE 13.5 from env and 37.0 from verb, and the
"                               cterm cells are pinned apart (203/210/217) so
"                               the three survive a 256-colour terminal
"   math     #dd8134            numbers, escapes — DOS brown #aa5500 (4.01:1)
"                               lifted along its own hue line
"   storage  = math             static/const.  Qualifiers and numeric literals
"                               are one category; the amber is deliberately
"                               the one darker accent, reserved for exactly
"                               these specific modifiers and literals
"
" The ink ladder is the DAC's own grays hung under the white: lightgray
" #aaaaaa delimiters, #8a8a8a comments, and darkgray nudged to #5c5c5c so the
" hairline role and ANSI 8 share one hex at 3.14:1, inside the sub-AA window.
"
" Deviations from the authentic bytes, all forced by measurement — do not
" "restore" them, the originals are unreadable on black:
"
"   env        #ff5555 -> #fe716b   6.68:1 -> 7.79:1  (not an AA fix: the
"                                   lift separates preproc from the error red,
"                                   dE 8.7 -> 13.5)
"   verb       #ff5555 -> #fe9e96   the same red two steps up, dE 23.5 from
"                                   env and 37.0 from alert.  The DAC red at
"                                   three intensities — errors exact, preproc
"                                   one up, strings two up — is the intensity
"                                   bit used as a family
"   opt        #5555ff -> #00b4ff   4.13:1 -> 8.97:1, lifted for legibility,
"                                   rotated to azure so the lift does not turn
"                                   it lavender, and stripped of red so it
"                                   shines rather than washing out
"   math       #aa5500 -> #dd8134   4.01:1 -> 7.26:1
"   ansi  1    #aa0000 -> #cc0000   2.71:1 -> 3.57:1
"   ansi  4    #0000aa -> #4444ff   1.58:1 -> 3.50:1 (the true DOS blue
"                                   survives as the search/diff wash, where
"                                   the core forces ink on top at 13.29:1)
"   ansi  5    #aa00aa -> #bb00bb   3.29:1 -> 3.83:1
"   ansi  8    #555555 -> #5c5c5c   2.82:1 -> 3.16:1
"   ansi 12    #5555ff -> #6666ff   4.13:1 -> 4.91:1, and dE 23 from slot 4
"                                   so the intensity bit still fires
"
" The near-black stock steps carry a faint Norton blue cast; text mode had no
" per-line raised surfaces, so the ladder is the family-architecture tax and
" the one deliberately modern element.  No bold anywhere ('bold': 0): the
" hardware had brightness, not weight.  One edition only — a CRT has no day
" side.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'vga: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

" Dark-only.  The guard keeps the colorscheme re-source that Vim triggers on
" a 'background' change from looping.
if &background !=# 'dark'
  set background=dark
endif

let s:palette = {
      \ 'bg'        : ['#000000', '16'],
      \ 'bg_alt'    : ['#101016', '233'],
      \ 'bg_soft'   : ['#16163a', '234'],
      \ 'bg_deep'   : ['#222250', '17'],
      \ 'ink'       : ['#ffffff', '231'],
      \ 'ink_soft'  : ['#aaaaaa', '248'],
      \ 'ink_mute'  : ['#8a8a8a', '245'],
      \ 'ink_faint' : ['#5c5c5c', '59'],
      \ 'cmd'       : ['#ff55ff', '207'],
      \ 'alert'     : ['#ff5555', '203'],
      \ 'ref'       : ['#55ffff', '87'],
      \ 'env'       : ['#fe716b', '210'],
      \ 'verb'      : ['#fe9e96', '217'],
      \ 'math'      : ['#dd8134', '130'],
      \ 'opt'       : ['#00b4ff', '39'],
      \ 'quote'     : ['#ffff55', '227'],
      \ 'oper'      : ['#ffffff', '231'],
      \ 'struct'    : ['#55ff55', '83'],
      \ 'storage'   : ['#dd8134', '130'],
      \ 'except'    : ['#ff5555', '203'],
      \ 'marker'    : ['#0000aa', '19'],
      \ 'marker_hot': ['#ffff55', '227'],
      \ 'on_hot'    : ['#000000', '16'],
      \ 'diff_add'  : ['#002800', '22'],
      \ 'diff_chg'  : ['#001a4d', '17'],
      \ 'diff_del'  : ['#4a0000', '52'],
      \ 'diff_txt'  : ['#000082', '18'],
      \ }

" The IBM DAC sixteen, with the five measured substitutions listed above.
let s:ansi = [
      \ '#000000', '#cc0000', '#00aa00', '#aa5500',
      \ '#4444ff', '#bb00bb', '#00aaaa', '#aaaaaa',
      \ '#5c5c5c', '#ff5555', '#55ff55', '#ffff55',
      \ '#6666ff', '#ff55ff', '#55ffff', '#ffffff',
      \ ]

call broadsheet#apply('vga', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
