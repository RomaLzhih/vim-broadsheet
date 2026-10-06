# Working notes for vim-broadsheet

Context for picking this up later. The README covers what the themes *are*;
this covers how to change them without breaking things.

Repo: `~/code/vim-broadsheet` → github.com/RomaLzhih/vim-broadsheet (public).
Loaded into vim as a **local editable checkout**, so edits are live with no
`:PlugUpdate`:

```vim
" in ~/.vimrc, between plug#begin and plug#end
if isdirectory(expand('~/code/vim-broadsheet'))
  Plug '~/code/vim-broadsheet'        " this machine
else
  Plug 'RomaLzhih/vim-broadsheet'     " anywhere else
endif
```

There are deliberately **no copies under `~/.vim/colors` or `~/.vim/autoload`**.
If any reappear they shadow the plugin and edits here stop taking effect.

## Architecture

`autoload/broadsheet.vim` holds every highlight-group assignment. A theme file
is *only* a palette that calls `broadsheet#apply(name, palette, ansi [, opts])`.

Five themes: `coffee` and `graphite` (prose); `tokyonight`, `vga` and
`phosphor` (code). Both retro themes are dark-only — each colors file sets
`background=dark` itself behind an `if &background !=# 'dark'` guard, which is
what keeps the colorscheme re-source Vim triggers on a 'background' change
from looping (verified: a light start and a mid-session `:set
background=light` both land on the dark palette, no loop).

Palette keys are **roles, not colours**: `cmd` `alert` `ref` `env` `verb` `math`
`opt` `quote`, plus the `bg`/`bg_alt`/`bg_soft`/`bg_deep` stock ladder and the
`ink`/`ink_soft`/`ink_mute`/`ink_faint` ink ladder. Full contract is documented
at the top of the core file.

- Retuning a colour → edit only the palette in `colors/*.vim`.
- Fixing a group assignment → edit the core; every theme inherits it.
- Adding a fourth theme → copy a palette, change values, call `broadsheet#apply`.
  No core change needed.

`opts` takes `profile` (`prose` default, or `code`) and `bold` (1 default, or 0
— composes as an AND with `g:broadsheet_bold`, and only ever removes weight).
The `code` block sits at the foot of `broadsheet#apply()` and swaps **four**
groups — `Delimiter`, `Identifier`, `Function`, `CocSemTypeBracket`. Nothing
else in the core is conditional on the profile, and it should stay that way: if
a fifth thing wants to be, that is a sign the core is being asked to hold two
designs rather than one.

`Operator` looks like it should be a fifth and deliberately is not. It reads the
**optional** `oper` palette key and falls back to `ink_soft` — so it is
conditional on the *palette*, not the profile, and any theme can colour its
operators without declaring itself a code theme. Prefer that shape for anything
else that comes up: an optional key beats another branch.

Three more keys now use that shape (added for the retro themes'
jellybeans-style keyword split; proven a byte-identical no-op for the earlier
themes by dump-diff): `struct` → `Structure`/`Typedef`, falls back `quote`;
`storage` → `StorageClass`, falls back `quote`; `except` → `Exception`, falls
back `cmd`. Facts worth keeping: newer c.vim routes `const` through
`cTypeQualifier → StorageClass`, so `storage` catches it; python.vim links
built-in exception *names* (`KeyError`) to `Structure`, so they ride `struct`;
`cppModifier` (`inline`/`virtual`/`explicit`) stays on `Type`/`quote`,
matching jellybeans.

`g:broadsheet_bold` (default 1) is handled in one place, `s:attr()`, which
strips `bold` from every attribute string. Don't add literal `gui=bold` anywhere
that bypasses it — the vimtex `texStyle*` groups are routed through it for
exactly this reason.

## How to verify a change

This matters more than it sounds. Several real bugs shipped past casual checks.

**Always load without `silent!`.** `silent!` hid a `W18` warning through many
verification passes. The load test must surface messages:

```vim
redir => msg | execute 'colorscheme graphite' | redir END
```

**Dump every group and audit contrast.** The method: walk highlight groups by id
until `synIDattr(i, 'name')` is empty, resolve links with `synIDtrans()`, record
`fg`/`bg`/attrs, resolve an empty `fg`/`bg` to `Normal`'s, then check every
text-bearing pair for WCAG AA (≥ 4.5:1).

Exempt from the audit, and nothing else: any pair whose fg is `ink_faint`; the
window-separator and fill groups (`VertSplit`, `VertSplitNC`, `WinSeparator`,
`EndOfBuffer`, `ToolbarLine`, `PmenuSbar`, `PmenuThumb`, `mkdLineBreak`,
`debugPC`); and pairs where fg equals bg, which are invisible on purpose.

Baseline as of the tokyonight change, measured that way: **446 pairs audited per
theme per edition (448 for tokyonight, whose profile moves `Delimiter` out of
`ink_faint`), 0 below AA in all six.** Tightest: coffee 4.50, graphite 4.62,
tokyonight 4.63 dark / 4.64 light.

The number is method-dependent — the older note here said 468, from a script
that no longer exists, presumably with a different rule for groups that set no
explicit fg. Do not compare the two; re-measure both sides if it matters.

**The tooling now lives in `scripts/`** (added with the retro themes):
`colorlib.py` (contrast, Lab/LCh, ΔE76, hue-line lift, xterm-nearest, and an
`audit` subcommand for palette JSONs), `dump.vim` + `audit_dump.py` (the dump
method above, with the exemption list built in), and `synwalk.vim` +
`samples/` (walk every cell of real C++/Python/Bash/R files and report which
group actually fires — the rAssign-bug-finder). The dump auditor was
validated against this file's numbers before first use: tokyonight dark
reproduces 0 bold / 46 italic / 23 underline / 12 undercurl and 0 below AA;
coffee dark reproduces 178 bold. Its pair count is *distinct colour pairs*
(≈39 per edition), not the 446 group-level figure above — method-dependent
again; both are recorded so neither gets "corrected" into the other. All nine
editions (six original + three retro) audit at 0 below AA.

**Audit against the *real emitted pairs*, not guessed ones.** An early check
required every accent to clear AA on every stock step and flagged the working
palette as broken — the theme only paints specific combinations. Dump first,
then audit what is actually there.

**Use ΔE (Lab), not hex intuition, for "are these distinct".** Threshold ~12–14.
`cmd`/`alert` are the standing exception: same hue by design in both themes
(coffee sits at 9.6).

**Use chroma (Lab) for "does this shout".** This is what diagnosed two separate
complaints. Reference points: 26 reads as *dark* rather than as a colour; ~42 is
calm but clearly coloured; 55+ is loud.

## Vim gotchas that cost real debugging time

1. **`exists('*autoload#func')` does NOT trigger autoloading.** Used as a guard
   in `colors/*.vim` it always fails and silently turns the colorscheme into a
   no-op. Probe with `globpath(&runtimepath, 'autoload/broadsheet.vim')`.

2. **Never define treesitter-style `@*` groups.** Vim (unlike Neovim) permits
   only alphanumerics and underscore in a highlight group name, so `@function`
   or `@markup.link.url` raises `W18: Invalid character in group name` on every
   load. It is a *warning*, so the group is still created and every functional
   test passes — it just spams the user. coc's fallback to the classic groups is
   the correct path in Vim.

3. **coc's semantic groups are `CocSemType<Kind>` and
   `CocSemTypeMod<Kind><Mod>`** — confirmed from `coc.nvim/build/index.js`
   (`toHighlightPart`), not just its vimscript defaults. A bare `CocSemFunction`
   is from an older coc and is never consulted. Three details from that source,
   all of which have bitten:
   - only the **first character** of each part is upper-cased, so it is
     `EnumMember` and `Readonly`, not `Enummember` / `ReadOnly`;
   - a token with modifiers is pushed **twice**, the plain kind then the
     kind+modifier, and only for `tokenModifiers[0]` — so a modifier group only
     lands when the server lists that modifier first. clangd puts `declaration`
     ahead of `readonly`, which is why a const's declaring line keeps the base
     colour while every *use* of it picks up the modifier colour;
   - the core's `'ModDeprecated'` entry therefore builds `CocSemModDeprecated`,
     which is **dead** — the live form would be `TypeMod<Kind>Deprecated`, one
     per kind. Left as-is, not yet asked for.

4. **`vim -e -s` (silent ex mode) does not source the vimrc.** Tests needing the
   real plugin set must run in normal mode: `vim -N -X -S script </dev/null`.

5. **Ex mode has no colour context.** `synIDattr()` must be given an explicit
   `'gui'` argument or every colour reads back empty and term attributes
   (bold/underline only) leak through instead.

6. **`hi clear` wipes vimtex's `hi def link` children** on a colorscheme switch,
   and nothing re-establishes them until the syntax script is re-sourced. The
   core restates the important ones so highlighting survives `:colorscheme`
   without reloading the buffer. Don't remove that block.

7. **vim-plug prepends plugin dirs.** A test that does `set runtimepath+=` puts
   vimtex *after* `$VIMRUNTIME`, so Vim's built-in `syntax/tex.vim` wins and you
   silently test the wrong syntax groups. Use `set runtimepath^=`.

8. Environment: `python3` is aliased to a bare directory in this user's zsh —
   use `command python3`. And zsh does not word-split unquoted variables, so
   `set -- $pair` silently fails in loops. zsh also aborts the whole command
   line on a glob that matches nothing (`rm -f dump_*.txt` in a fresh directory
   kills the `for` loop after it), so guard globs that may be empty.

9. **`hi! def link` in a syntax script beats anything a colorscheme does.** The
   `default` only protects against overwriting a group that has settings; the
   `!` overrides an existing link *and* a full definition, and syntax scripts
   are sourced after the colorscheme. `python.vim` uses it for `pythonBoolean`
   and `pythonConstant`, so `True`/`False`/`None` render as `Function` and no
   colorscheme can change that — verified by defining the group outright and
   watching it lose. Only an `after/syntax/` file wins. Plain `hi def link` (no
   bang) does *not* override, which is why the core's `rAssign` fix holds.
   Before "fixing" any upstream link from here, check which form it uses.

10. **`cFunction` is gated behind `let c_functions = 1`.** Without it no C or
    C++ call is highlighted at all, which makes a C++ file look far flatter
    than it will in a real session. Set it in test harnesses, and remember the
    user's coc/clangd supplies `CocSemTypeFunction` anyway.

## Settled design decisions — don't re-litigate

- **Delimiters recede, content advances.** `texDelim` is hairline; the prose
  inside `{...}` keeps full ink. This is the core idea, tuned for
  `g:vimtex_syntax_conceal_disable = 1`.
- **Body text is pure black** in coffee's and graphite's light editions. A
  consequence: those two share 26 identical groups (all ink-derived). That is
  intended, not an accent collision. tokyonight is not part of that — its day
  ink is `#181c30`, a blue-black, because Tokyo Night Day's ink is blue.
- **Commands must not be the loudest thing on the page** in graphite — they are
  the most frequent element in a `.tex` file. Hence burgundy `#6e1128`
  (chroma 42), not a bright red. The loud red belongs to `alert`/errors.
  **Coffee keeps its original press-red `#8c1c13`** — restraint was tried there
  and rejected.
- **graphite inverts green-for-strings**: `math` takes the green, `verb` the
  teal. Deliberate — this is a LaTeX theme, math zones are constant and
  `lstlisting` is rare, so math earns the visible hue.
- **Selected completion rows use a paper step, not a filled accent block.** A
  solid navy bar is the heaviest thing on a light page.
- **graphite's stock is newspaper grey `#e3e5e6`** — dull light grey, faint cool
  cast. `#d7dce0` was tried and rejected as too dark.

### tokyonight

- **The palette is upstream's, not a re-derivation.** On the dark edition every
  accent, every stock step, the diff washes and the ANSI 16 are the published
  hex. Exactly two things moved, both forced by the AA rule: `comment #565f89`
  (2.8:1 → `ink_mute #828ab6`, 5.1:1) and the `blue0` search fill (4.14 →
  `#395294`, 4.63). If a third thing ever "needs" to move, question it hard.
- **The values are Tokyo Night's; the assignment is Catppuccin's.** Types on the
  yellow, constants on `green1`, operators on the cyan via the optional `oper`
  key. That is where Catppuccin's colourfulness comes from — more of the screen
  carries a hue, not louder hues. Asked for explicitly, after being shown that
  keeping the hexes means it reads *more colourful* but not *more luminous*.
- **Types must not be in the cyan family.** They were `green1` at first, one
  step from the cyan `PreProc` held, and `#include <vector>` over
  `std::vector<int>` came out as two shades of one colour. This is the thing
  that looked wrong; yellow fixes it (ΔE 90).
- **Read-only symbols take the `Number` colour** (`math`, the orange), via
  `CocSemTypeMod<Kind>Readonly` for Variable/Parameter/Property/EnumMember.
  Asked for directly. It also happens to be Catppuccin's logic — constants,
  numbers and read-only bindings all read as one category.
  Defined in **two places on purpose**: here, so the themes are self-sufficient
  for anyone else, and in `~/.vimrc:1116` (`s:cocSemModMap`), so it also holds
  under this user's other 31 colorschemes — `hi clear` wipes the theme's copy
  the moment they switch away. Both point at `Number`, so they cannot disagree.
  Verified across all 34 installed schemes: 34 match, 0 miss.
- **`Property` is on `opt`, not `ref`.** `obj.field` and `obj.method()` sit side
  by side all day and were the same blue. Catppuccin puts properties on its teal
  for exactly this reason. It shares `opt` with `Constant`, which is fine — both
  are leaf values, and they rarely need telling apart at a glance.
- **There is no third violet available.** Catppuccin splits preproc (pink) from
  operators (sky); Tokyo Night cannot. `purple #9d7cd8` is ΔE 11.3 from the
  keyword magenta *and* fails AA on `bg_deep` (3.67); `magenta2 #ff007c` fails
  AA on two steps. Both were measured, not guessed — an earlier eyeball estimate
  put purple/magenta at 16, which would have passed. Preproc takes `blue1` and
  operators the cyan, ΔE 19 dark / 15 light.
- **The day edition is pressed, and had to be.** Tokyo Night Day's own fg is
  4.52:1 on its own stock and every accent is 3.0–4.3, so a four-step ink ladder
  will not fit underneath it. Everything is pushed down its own hue line, with
  chroma scaled by the lightness ratio — holding chroma while dropping lightness
  is what turned magenta into an electric violet at chroma 90 on the first pass.
  `cmd` is capped at chroma 44, graphite's number, for graphite's reason.
- **No bold anywhere**, declared by the theme itself (`'bold': 0`), not by the
  reader's `g:broadsheet_bold`. The prose themes need two cues because a `.tex`
  file is prose with markup over it and the markup must separate from the type;
  a source file is *all* markup, so weight stops being a signal and becomes
  texture. Hue carries the hierarchy alone. Italics/underlines/undercurls are
  untouched — verified as 0 bold, 46 italic, 23 underline, 12 undercurl, with
  coffee and graphite unchanged at 178 bold each.
- The two switches compose as an AND and only ever *remove* weight: setting
  `g:broadsheet_bold = 1` cannot put bold back into tokyonight. `s:bold` is
  re-derived on every `apply()`, so it is not sticky across `:colorscheme`
  switches — that was tested in both directions.
- Consequences accepted: markdown H1 and H2 are now identical in this theme,
  and `texMathCmd` no longer separates from `texMathZone` (the open item below).
  Both are prose problems, and this is not a prose theme.

### the retro themes (vga / phosphor, 2026-08-13)

**breadbin (C64/ZX) was designed, built and then removed at the user's request
on 2026-08-14.** Don't resurrect it without being asked. It is not in git
history (it was never committed), so it is gone from the repo entirely.

Designed by a three-direction adversarial workflow, every value measured; the
candidate comparison lives in the "The Fourth Broadsheet" artifact.

- **Both: dark-only, `{'profile': 'code', 'bold': 0}`, and all four
  optional keys set.** `except` = the theme's `alert` in both (danger
  keywords wear the alarm colour); `storage` shares `math` in both — numbers
  and qualifiers as one category, the readonly logic again. Every deviation from authentic era bytes is documented in the
  colors-file header with before/after contrast; do not "restore" the
  originals (DOS blue `#0000aa` is 1.58:1 on black).
- **vga's one idea: the hexes are IBM's DAC, the intensity bit does the work
  bold used to do.** The palette settled early; the *assignment* moved six
  times under user direction, so read the file header for the current one and
  treat the list below as the reasoning behind it, not a second source of
  truth.
  - **The assignment is Vim's own `koehler`**, which the user pointed at and
    which turns out to BE this palette: keyword yellow `#ffff60` is ΔE 4.1
    from the DAC bright yellow, type green `#60ff60` ΔE 5.0, identifier cyan
    `#40ffff` ΔE 2.5, and every koehler accent sits at L 73-97 with no dim
    colours at all. Departures, each with a reason: keywords take the DAC
    bright magenta (asked for directly; koehler's yellow moved to constants),
    strings are their own colour rather than sharing numbers', `Structure` is
    split from `Type` (koehler links them, and that split is what `struct`
    exists for), and comments stay on the ink ladder rather than koehler's
    blue, because ink_mute is a ladder step here, not an accent. NB koehler's
    own keywords are yellow and its white is `Normal` — the user recalled it
    as white keywords, but the file says `hi Statement guifg=#ffff60`; either
    way white-on-keywords is barred by law 1.
  - **The DAC red runs at three intensities** — errors exact `#ff5555`,
    preproc one step up `#fe716b`, strings two `#fe9e96`. The last was the
    koehler correction: strings had been on the dim green `#00aa00` (L60.6),
    the darkest frequent token on the page, and the lift landed ΔE 4.5 from
    koehler's own Constant salmon without being copied from it — independent
    evidence that koehler is the DAC set lifted.
  - **struct is DAC bright green** `#55ff55` (2026-08-14, asked for twice —
    once early, once after the blue exploration). Types moved to the bright
    yellow and constants took the blue, so green/yellow/cyan each sit one
    place round from koehler's assignment.
  - **opt is an electric blue** `#00b4ff` (2026-08-14) — the only accent in
    vga that is not a DAC byte, arrived at after four instructive failures:
      * `#5555ff`, the terminal blue the user named, is 4.13:1 and L46.5 —
        sub-AA and "too dark" among accents living at L60-97;
      * lifted along its own hue it desaturates into lavender (`#a996ff`),
        rejected twice as purple — **RGB blue is violet-leaning in Lab**, pure
        `#0000ff` measures hue 306;
      * lifted and rotated to azure (`#77aaff`) it is legible and blue but
        reads SOFT, because it still carries a red channel: HSV saturation 53%
        where every DAC bright is 66.7%.
    **The general lesson: for blues, vividness is a saturation problem, not a
    chroma problem.** sRGB caps blue chroma near 49 at L69 (measured across
    h240-290) where green and magenta reach 99, so no blue can ever match them
    on chroma. Dropping the red channel to zero gives the same L69.4 and
    8.97:1 with saturation 100%. Also measured and rejected: royal blue
    `#4169e1` (4.33:1, L47.8 — darker than the value already called too dark;
    lifting it lands ΔE 11.6 from the lavender, under the collision bar).
  - **oper is the body white `#ffffff`** (2026-08-14, asked for after trying
    the dim cyan, `#8a8a8a` and `#aaaaaa` in turn). This is the ONE role
    permitted to be byte-identical to `ink`, and the reasoning matters because
    it looks like a law-1 breach and is not: law 1 exists to stop a
    HUE-carrying role stealing the brightest ink (white keywords, white
    function names). An operator carries no hue and is *content* — `+` against
    `-` changes what a line means — so it joins the prose rather than stealing
    from it. Delimiters stay back at `#aaaaaa`: a bracket is scaffolding, not
    content. That is the family's founding rule applied inside an expression.
    Encoded as `INK_SHAREABLE = {'oper'}` in `scripts/colorlib.py`; near-white
    is still a violation for every role including `oper`, since a colour that
    is *almost* the ink competes with it where one that IS the ink simply is
    it. Verified the law still fires if `cmd` takes the ink.
  - **cmd at chroma 97.7 on the most frequent coloured token is a deliberate
    departure** from the frequency discipline the rest of the family keeps.
    Asked for, measured, passes both laws — do not "correct" it.
  - **Watch the cterm cells whenever two accents share a hue family.** The
    three reds pin to 203/210/217 because nearest-Lab put two of them on 203,
    which would have merged them in any 256-colour terminal. `check_cterm()`
    now catches this class automatically.
  - Rejected cuts, for the record: white keywords over a lightgray body (Turbo
    Pascal style) and a `#7a6dff` dark violet on struct. Everything else that
    moved was superseded rather than rejected, and each displaced value found
    a new role — see the reassignment corollary below.

- **Namespaces follow `struct` when the key exists** (core, 2026-08-14).
  `CocSemTypeNamespace` used to link to `Include`, so under clangd every
  `std::` wore the preprocessor's colour — in vga that was the bright magenta,
  which the user read as "purple on namespaces". A namespace is one of the
  things `struct` covers, so with the key present it now links to `Structure`
  and `namespace demo {` matches every `std::` after it. Also defines a
  `Namespace` group, which is NOT a Vim group but IS probed first by resolver
  chains — coc's own and the one at `~/.vim/vimrc.d/60-coc-semantic.vim:57`
  (`['Namespace', '@module', 'Include', 'PreProc', '#PLAIN']`) — so the user's
  resolver lands on the same colour instead of on Include. Conditional on the
  palette, so coffee/graphite/tokyonight are byte-identical: verified by
  dump-diff across all six editions.
- **phosphor's one idea: a colour terminal remembered as a monochrome one.**
  The era anchor is the IBM 3279 (1979) plus the 5151's P39 glow — NOT a
  dual-phosphor tube; that framing was tried and struck as fantasy. ref is
  chroma-carried from L84 (`#82e96e`), pressed below ink's lightness band on
  purpose. The only theme whose audit has zero advisories. Its cterm ink
  ladder is pinned to the green cube (194/151/108) — but `ink_faint` takes
  grey 240, because the cube's nearest green (65) renders 4.88:1 against the
  quantised stock, above AA for the one role held deliberately below it.
  **It carries vga's assignment in its own values** (2026-08-14): the loudest
  hue on keywords — which here is the P3 amber `#ffb000`, so the theme's
  identity survives the alignment intact — class/namespace on the 3279 pink
  lifted to a light purple `#dc89d1`, preproc on the 3279 red lifted
  `#ff8778`, constants on the teal, numbers+qualifiers on the burnt amber as
  the one darker accent. Two adversarial critics rejected an intermediate cut
  that put the lifted red on *keywords* and the teal on struct: the teal sat
  ΔE 30.1 / Δh 33.9° from the turquoise on types (class and type are the two
  largest coloured roles in C++), and keywords-vs-`catch` in one red family
  co-occur constantly where class-vs-error does not. The rotation that
  followed vga's fixed both and handed the amber back.
- **Design laws from the user, stated twice and now absolute (2026-08-13) —
  do not re-litigate:**
  1. **White is for variables/body text ONLY.** Never on any other highlight
     group — not functions (a rejected cut of the since-removed breadbin),
     not keywords (vga's first cut; no "Turbo Pascal identity" exemption). The most frequent token
     owns the brightest ink. (:terminal ANSI slot 15 is not a highlight
     group and keeps white.)
  2. **Frequent tokens ride light colours.** A dark accent mixed frequently
     among light ones reads as uncomfortable (the `#7a6dff` struct was
     rejected for this). Darker accents are allowed only on *specific*
     modifiers/keyword classes — vga's `#dd8134` on static/const/literals is
     the sanctioned shape.
  Applied: vga ink `#ffffff` / cmd → DAC bright green `#55ff55` / struct →
  lifted DAC red `#fe716b` / opt → light purple `#a996ff`. phosphor conformed
  to both laws already (its near-white IS the body ink, every accent clears
  the L floor) — its assignment update is the outstanding piece.
  **The laws are now encoded as tests** in `scripts/colorlib.py`
  (`check_laws()`, run automatically by `audit`), so a violating palette fails
  the audit rather than needing a human to notice. So is the 256-colour check
  (`check_cterm()`): two TEXT colours quantising to one xterm cell fails the
  audit — vga nearly shipped with keywords and errors both on 203 — while a
  wash meeting a stock step is reported as cosmetic, since the 240-cell
  palette makes those unavoidable and every theme here has one or four.

  Corollary the user has now exercised three times: **a displaced colour is
  usually reassignable, not discardable.** The periwinkle rejected as a
  keyword became the constant purple; the DOS brown displaced from constants
  became the numbers/qualifier amber; the lifted red displaced from keywords
  became preproc; koehler's keyword yellow became constants. Six rounds of
  reassignment on vga and not one value was invented to fill a gap. Try moving a measured value to a rarer role
  before deriving a new one — it keeps the palette's provenance intact.

## Airline

`autoload/airline/themes/vga.vim` and `phosphor.vim` ship with the themes,
generated by `scripts/gen_airline.py` from the palette (which refuses to write
a file if any pair is under AA).  They exist because without one airline
derives its own colours: under vga it put `bg_deep` text on `bg_alt`, ~1.1:1,
which made every middle statusline section and every tab label invisible —
that is what the user reported as "hard to read", and it was not the core's
TabLine groups, which measured fine.

`airline#switch_matching_theme()` resolves a theme by `tolower(g:colors_name)`,
so these are picked up on any interactive `:colorscheme`.  Caveat worth
knowing: `~/.vimrc.d/40-colorscheme.vim:72` guards that call with
`v:vim_did_enter`, so a theme set at *startup* keeps the pinned
`g:airline_theme` instead.  Making vga the startup theme means setting
`g:airline_theme = 'vga'` too.

Regenerate after any palette edit:

```
command python3 scripts/gen_airline.py colors/vga.vim colors/phosphor.vim
```

## Open items

- **vim-signify clash.** `~/.vimrc:702` `s:SignifyGitSignStyle()` hardcodes
  gruvbox lime/red on `#282828` and re-fires on `ColorScheme *`, overriding the
  theme's sign colours on cream/grey stock. One-line fix, not yet applied
  (regex needs all five names):
  `if get(g:, 'colors_name', '') =~# 'coffee\|graphite\|tokyonight\|vga\|phosphor' | return | endif`
- **graphite has one real 256-colour bug**, found when `check_cterm()` was
  added and not yet fixed because graphite is settled and the user has not
  asked: `ink_soft #a8aeb3` and `quote #9fb0bd` both quantise to xterm 145
  (gui ΔE 5.7, already under the family's 12 bar as a gui advisory), so in a
  256-colour terminal its types, blockquotes and H4-H6 render identical to its
  delimiters. Truecolor is unaffected. Fix would be to press `quote` a step or
  pick a distinct cell; both change a shipped look, so ask first.
- **`<leader>ts` is now redundant.** `~/.vimrc:635` double-sources the vimrc to
  work around `CocSem*` links being wiped by `hi clear`. That root cause is
  fixed (`~/.vimrc:1050`, re-applied via a `ColorScheme` autocmd), so the
  mapping can go.
- **The vimrc's `CocSem*` map is the user's own, forced, and stays that way**
  (`~/.vimrc:1050`, 2026-08-04). It wins over whatever the colorscheme sets.
  Asked for explicitly, twice — do not "correct" it again. Two properties of it
  are deliberate and must not be tidied: the bare keys (`'Keyword'`, `'Operator'`
  …) build `CocSemKeyword`, which coc never reads, so those entries are inert;
  and `Parameter`/`Variable`/`Class` are not Vim groups, so variables and
  parameters render as plain text, which is the intended look.
- **Consequence: only 12 of coc's kinds are actually driven by that map.** The
  rest — keyword, string, number, boolean, operator, comment, modifier, enum,
  struct, enumMember, bracket — fall through to the theme, so the palette here
  still decides most of what a C++ buffer looks like. When the user says the
  semantic colours look bad, the fix is usually in `broadsheet#apply()`, not in
  the vimrc. Get the token name from `:Inspect` first.
- **`.vimrc` does not travel.** Plain file, `$HOME` is not a git repo, no
  dotfiles repo exists. The conditional `Plug` above handles the plugin on a new
  machine, but only once the vimrc itself is there.
- **Possible improvement:** inside a math zone `texMathCmd` and `texMathZone`
  are the same colour, separated only by bold, so `\times` stands out from prose
  but not from surrounding math. A second math colour for commands would fix it.
- ~~Dev tooling is still not in the repo~~ **Resolved with the retro themes:**
  the whole set now lives in `scripts/` (see "How to verify a change" above)
  and was validated against this file's recorded numbers before first use.
  Not yet committed to git — the working tree holds it.
- **Coverage of the four languages was checked against real sample files**, not
  against the group lists in the syntax scripts. Both are worth doing: the
  dumps tell you what `hi def link` says, the walk tells you what actually
  paints. `shCase`/`shCaseEsac` look unlinked in the grep but resolve to
  `shConditional` in practice.
