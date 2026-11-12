" =============================================================================
" swan-phosphor.vim — the CRT edition of the Broadsheet family
" =============================================================================
"
" A colour terminal remembered as a monochrome one.  The tube is a green-cast
" black (#050d07); the ink ladder is phosphor-tinted whites — the long-
" persistence glow of the IBM 5151's P39 phosphor, desaturated toward white —
" descending to a dim afterglow for line numbers.  Body text and identifiers
" wear that white and nothing else does.
"
" The licence for several hues on one tube is the IBM 3279 (1979), the colour
" terminal whose base four were green, red, blue and white, extended with
" yellow, pink and turquoise.  This theme carries the same assignment as vga
" in its own values: the loudest hue on keywords, a light purple on
" class/namespace, one darker accent on numbers and qualifiers.  Here the
" loudest hue IS the identity — P3 amber #ffb000, the VT220's amber option —
" so keywords keep it, and it also drives the IncSearch cell, which is that
" amber at full drive under black text: the inverse-video look of a real
" terminal's search hit.
"
"   role     value               used for
"   ink      #d6ecd0 P39 white   body, identifiers — the only white here
"   cmd      #ffb000 P3 amber   keywords — the VT220 amber verbatim
"                                (10.74:1), the loudest hue in the palette on
"                                the most frequent coloured token.  vga spends
"                                its shout the same way
"   struct   #dc89d1             class/template/namespace — the 3279 pink
"                                #cc7ac2 lifted one step up its own hue to
"                                L67.8 (8.01:1), a light purple, dE 107.7 from
"                                the keyword amber and dE 79.4 from the
"                                turquoise on types.  The unlifted pink
"                                survives as ANSI 5.  Under clangd every
"                                `std::` lands here too
"   env      #ff8778             preproc, $VAR — the 3279 red #ff6b5e lifted
"                                one step up its own hue (8.42:1 on the tube,
"                                5.63:1 on the deepest emitted stock); dE 14.6
"                                from the error red, and dE 21 apart in cterm
"                                (210 vs 203) so the split survives 256
"                                colours
"   alert    #ff6b5e 3279 red    errors; `except` shares it (throw/raise).
"                                The red stays exact here — env is the one
"                                that moved.  dE 21 apart in cterm too (210 vs
"                                203), so the split survives 256 colours
"   math     #e2850f burnt amber numbers, escapes; `storage` shares it
"                                (const/static are constant-machinery, the
"                                readonly logic).  Deliberately the one
"                                darker accent (L64), reserved for exactly
"                                these specific modifiers and literals
"   verb     #3fdc3f P1 green    strings — the one block token where a
"                                saturated field earns its keep
"   ref      #82e96e bloom       functions — an over-driven phosphor, carried
"                                by chroma from L84 (not lightness: body ink
"                                owns the brightest band)
"   oper     #7fbf6f sage        operators, deliberately the calm one
"   quote    #56d8d8 turquoise   types — the 3279's turquoise, this theme's
"                                flagship accent
"   opt      #5ce6b0 teal        constants, properties — the far edge of the
"                                tube's own green family, dE 26/35/51 from the
"                                three greens.  Its nearest neighbour is the
"                                turquoise on types at dE 30.1, the tightest
"                                pair in the palette: they meet in a signature
"                                (`def f(n: int = MAX)`) and are told apart by
"                                hue rather than by weight
"
" Loudness lives in the two phosphor families (amber keywords, green strings);
" the second-most-frequent token — operators — stays sage-calm, which is what
" keeps high contrast from becoming high chaos.  Weakest spot, accepted:
" Bash, where keywords and $VAR are both warm-family — dE 58.5, which is far
" wider than the dE 21 the original cut had, because $VAR moved to the red.
"
" Every text pair the core emits holds WCAG AA, and every pair one edit away
" does too — zero advisories, the only theme in the family that can say so.
" In 256-colour terminals the top three ink steps are pinned to the green cube
" (194/151/108) rather than Lab-nearest greys, so the phosphor cast survives
" quantisation.  `ink_faint` is the exception and takes grey 240: the cube's
" nearest green, 65, renders 4.88:1 against the quantised stock — above AA,
" for the one role this family holds deliberately BELOW it.  Correctness of
" the sub-AA contract beats the cast on the one step whose whole job is to be
" barely there.  No two text colours share a cell; the only overlap is
" diff_chg against bg_deep, a wash-versus-stock artefact of the 240-cell
" palette that every theme in the family has some of.
"
" No bold anywhere ('bold': 0).  One edition only — a CRT has no day side.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'swan-phosphor: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

" Dark-only.  The guard keeps the colorscheme re-source that Vim triggers on
" a 'background' change from looping.
if &background !=# 'dark'
  set background=dark
endif

let s:palette = {
      \ 'bg'        : ['#050d07', '232'],
      \ 'bg_alt'    : ['#0d1a10', '233'],
      \ 'bg_soft'   : ['#16261a', '235'],
      \ 'bg_deep'   : ['#203524', '236'],
      \ 'ink'       : ['#d6ecd0', '194'],
      \ 'ink_soft'  : ['#a2bfa0', '151'],
      \ 'ink_mute'  : ['#7fa084', '108'],
      \ 'ink_faint' : ['#3f5a44', '240'],
      \ 'cmd'       : ['#ffb000', '214'],
      \ 'alert'     : ['#ff6b5e', '203'],
      \ 'ref'       : ['#82e96e', '77'],
      \ 'env'       : ['#ff8778', '210'],
      \ 'verb'      : ['#3fdc3f', '83'],
      \ 'math'      : ['#e2850f', '172'],
      \ 'opt'       : ['#5ce6b0', '79'],
      \ 'quote'     : ['#56d8d8', '80'],
      \ 'oper'      : ['#7fbf6f', '71'],
      \ 'struct'    : ['#dc89d1', '176'],
      \ 'storage'   : ['#e2850f', '172'],
      \ 'except'    : ['#ff6b5e', '203'],
      \ 'marker'    : ['#4a3800', '58'],
      \ 'marker_hot': ['#ffb000', '214'],
      \ 'on_hot'    : ['#050d07', '232'],
      \ 'diff_add'  : ['#103a14', '22'],
      \ 'diff_chg'  : ['#0e3336', '236'],
      \ 'diff_del'  : ['#3a1210', '52'],
      \ 'diff_txt'  : ['#155054', '23'],
      \ }

" Era anchors kept: 2/10 pure P1 green, 3/11 the amber pair, 5 the 3279 pink
" unlifted, 7/15 the phosphor whites.  Slot 11 #ffd75f is also where the pale
" amber went when the warm family lost a text role — it stays in the palette,
" one edit from coming back.  Brightblack is lifted to #5f7a65 (4.18:1) so
" TUIs that put real text in it — fzf, tig, htop — stay legible.
let s:ansi = [
      \ '#0d1a10', '#cc4b3e', '#33cc33', '#ffb000',
      \ '#5f87d7', '#cc7ac2', '#33bbbb', '#a2bfa0',
      \ '#5f7a65', '#ff6b5e', '#55ff55', '#ffd75f',
      \ '#87afff', '#e29fd8', '#5ce6e6', '#d6ecd0',
      \ ]

call broadsheet#apply('swan-phosphor', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
