" =============================================================================
" tokyonight.vim — the code edition of the Broadsheet family
" =============================================================================
"
" Coffee and graphite are typesetting themes: they are pitched for a .tex file,
" where markup surrounds prose.  This one inverts the premise.  It is for
" source — C++, shell, Python and R — where there is no prose to protect and
" every token on the line is content.
"
" The palette is Tokyo Night (folke/tokyonight.nvim), used as published rather
" than re-derived.  The assignment is Catppuccin's, which puts more of the
" screen in colour than Tokyo Night's own does — types on the yellow rather than
" in the cyan family, and operators on a hue instead of on ink.  On the late
" edition every accent below is the upstream hex:
"
"   role    hue   late edition               catppuccin        used for
"   cmd     306°  #bb9af7  magenta           mauve             keywords
"   alert    12°  #f7768e  red               red               errors, H3
"   ref     282°  #7aa2f7  blue              blue              functions, refs
"   quote    77°  #e0af68  yellow            yellow            types
"   verb    126°  #9ece6a  green             green             strings, verbatim
"   math     56°  #ff9e64  orange            peach             numbers, escapes
"   oper    249°  #7dcfff  cyan              sky               operators
"   env     220°  #2ac3de  blue1             (pink)            preproc, $VAR
"   opt     182°  #73daca  green1            teal              constants, params
"
" Catppuccin's own separation of preproc (pink) from operators (sky) cannot be
" had here: Tokyo Night's only other violet, purple #9d7cd8, is dE 11 from the
" keyword magenta — a collision by this family's ~12-14 threshold — and also
" fails AA on the deepest stock step; its pink, magenta2 #ff007c, fails AA on
" two steps.  Pressing either would have meant giving up an upstream hex, so
" preproc takes blue1 and operators the cyan, dE 19 apart.  Those two share far
" less of a line than types and preproc did.
"
" Types on the yellow is the change that matters most.  It was green1 before,
" one step from the cyan preproc held, and `#include <vector>` over
" `std::vector<int>` came out in two shades of the same colour.
"
" Two upstream values could not be carried over as-is, both for the same
" reason — this family holds every text pair at WCAG AA:
"
"   comment  #565f89 is 2.8:1 on the night stock, and 2.5:1 in a float.  It is
"            the one upstream colour that is genuinely unreadable rather than
"            merely quiet, so ink_mute is lifted along the same hue to #828ab6
"            (5.1:1).  Comments stay the dimmest text on the page; they stop
"            being a thing you squint at.
"
"   blue0    #3d59a1 is the Search fill.  Body ink over it lands at 4.14:1, so
"            the fill is taken one step deeper to #395294 (4.63:1).
"
" Everything else — the four stock steps, both ink weights above the comment,
" the diff washes, IncSearch orange, the 16 ANSI colours — is upstream.
"
" The day edition is the harder one.  Tokyo Night Day is a low-contrast theme:
" its own foreground is 4.5:1 on its own stock, and every accent sits between
" 3.0 and 4.3 — under AA before anything is asked of it.  There is no room to
" hang a four-step ink ladder under a 4.5:1 body text, so the whole day palette
" is pressed deeper along its own hue lines.  Hue is preserved to within 7° of
" the late edition; chroma tracks lightness down so that pressing a colour
" darker does not also make it shout (holding chroma while dropping lightness
" is what turns a violet into an electric one — magenta would have landed at
" chroma 90).  Keywords are the most frequent coloured token in a source file,
" so cmd is capped at chroma 44, the level graphite settled on for the same
" reason.  The stock, the search fill and the selection step stay upstream.
"
" Nothing in this theme is bold.  Coffee and graphite carry hierarchy on two
" cues, weight and hue, because a .tex file is prose with markup laid over it
" and the markup has to separate from the type.  A source file has no prose in
" it — every line is already markup — so weight stops being a signal and turns
" into texture: thirty bold keywords to a screen is a page that shouts evenly.
" Hue carries the whole hierarchy here, which is what this palette was built to
" do in the first place.
"
" g:broadsheet_bold only ever removes weight, so it cannot put this back; the
" 'bold' key in the call at the foot of this file is the switch.
"
"   :set background=dark      late edition   (Tokyo Night, night)
"   :set background=light     day edition    (Tokyo Night Day, pressed)
"
" Group assignments live in autoload/broadsheet.vim.  This theme asks for the
" 'code' profile, which trades four prose defaults for source-file ones — see
" broadsheet-profile in the help file.
" =============================================================================

" Probe the file on 'runtimepath' rather than exists('*broadsheet#apply') —
" exists() does NOT trigger autoloading, so that test always fails here and
" would silently turn this colorscheme into a no-op.
if empty(globpath(&runtimepath, 'autoload/broadsheet.vim'))
  echohl ErrorMsg
  echomsg 'tokyonight: autoload/broadsheet.vim not found on runtimepath'
  echohl NONE
  finish
endif

if &background ==# 'light'
  " Day edition — Tokyo Night Day stock, inks pressed to newspaper depth.
  let s:palette = {
        \ 'bg'        : ['#e1e2e7', '254'],
        \ 'bg_alt'    : ['#d4d6e1', '188'],
        \ 'bg_soft'   : ['#c4c8da', '251'],
        \ 'bg_deep'   : ['#b7c1e3', '146'],
        \ 'ink'       : ['#181c30', '234'],
        \ 'ink_soft'  : ['#343b57', '238'],
        \ 'ink_mute'  : ['#555a73', '60'],
        \ 'ink_faint' : ['#9398b1', '103'],
        \ 'cmd'       : ['#5f3f84', '97'],
        \ 'alert'     : ['#aa2949', '125'],
        \ 'ref'       : ['#2c5aa5', '25'],
        \ 'env'       : ['#1c5560', '23'],
        \ 'math'      : ['#8d4a08', '130'],
        \ 'verb'      : ['#4b6331', '65'],
        \ 'opt'       : ['#366c64', '23'],
        \ 'quote'     : ['#7a5e37', '137'],
        \ 'oper'      : ['#0d6384', '24'],
        \ 'marker'    : ['#a7b5e2', '146'],
        \ 'marker_hot': ['#fbb085', '216'],
        \ 'on_hot'    : ['#181c30', '234'],
        \ 'diff_add'  : ['#bbe1e8', '152'],
        \ 'diff_chg'  : ['#d9dcef', '253'],
        \ 'diff_del'  : ['#f4ced1', '224'],
        \ 'diff_txt'  : ['#c4caee', '189'],
        \ }
  " Day's own ANSI set, with the halves that fall under 4:1 on this stock taken
  " deeper — terminal output has to stay legible on paper.
  let s:ansi = [
        \ '#b4b5b9', '#c43557', '#587439', '#85673b',
        \ '#2e6ac4', '#8356b9', '#007197', '#5a69a2',
        \ '#a1a6c5', '#bf3a59', '#537622', '#8a6525',
        \ '#326ac1', '#8256ba', '#0b749a', '#3760bf',
        \ ]
else
  " Late edition — Tokyo Night (night), upstream but for comment and blue0.
  let s:palette = {
        \ 'bg'        : ['#1a1b26', '234'],
        \ 'bg_alt'    : ['#1f2335', '235'],
        \ 'bg_soft'   : ['#292e42', '236'],
        \ 'bg_deep'   : ['#283457', '237'],
        \ 'ink'       : ['#c0caf5', '189'],
        \ 'ink_soft'  : ['#a9b1d6', '146'],
        \ 'ink_mute'  : ['#828ab6', '103'],
        \ 'ink_faint' : ['#545c7e', '60'],
        \ 'cmd'       : ['#bb9af7', '140'],
        \ 'alert'     : ['#f7768e', '211'],
        \ 'ref'       : ['#7aa2f7', '111'],
        \ 'env'       : ['#2ac3de', '45'],
        \ 'math'      : ['#ff9e64', '215'],
        \ 'verb'      : ['#9ece6a', '149'],
        \ 'opt'       : ['#73daca', '80'],
        \ 'quote'     : ['#e0af68', '179'],
        \ 'oper'      : ['#7dcfff', '117'],
        \ 'marker'    : ['#395294', '25'],
        \ 'marker_hot': ['#ff9e64', '215'],
        \ 'on_hot'    : ['#1a1b26', '234'],
        \ 'diff_add'  : ['#20303b', '236'],
        \ 'diff_chg'  : ['#1f2231', '235'],
        \ 'diff_del'  : ['#37222c', '235'],
        \ 'diff_txt'  : ['#394b70', '60'],
        \ }
  " Upstream's terminal palette, unchanged.
  let s:ansi = [
        \ '#15161e', '#f7768e', '#9ece6a', '#e0af68',
        \ '#7aa2f7', '#bb9af7', '#7dcfff', '#a9b1d6',
        \ '#414868', '#ff899d', '#9fe044', '#faba4a',
        \ '#8db0ff', '#c7a9ff', '#a4daff', '#c0caf5',
        \ ]
endif

call broadsheet#apply('tokyonight', s:palette, s:ansi,
      \ {'profile': 'code', 'bold': 0})
unlet s:palette s:ansi

" vim: set ft=vim ts=2 sw=2 et:
