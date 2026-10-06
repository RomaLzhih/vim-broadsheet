# vim-broadsheet

Newspaper colorschemes for Vim, built for writing **LaTeX and Markdown** rather
than for reading code — plus a code side built for the opposite.

Five themes share one core:

| | | |
|---|---|---|
| **coffee** | warm — press-red, ochre, sepia on newsprint cream | light + dark |
| **graphite** | cool — burgundy, blueprint blue, cyan, slate on grey stock | light + dark |
| **tokyonight** | the Tokyo Night palette, pitched at source code | dark + light |
| **vga** | the IBM PC's sixteen on true black — white prose, magenta keywords | dark only |
| **phosphor** | CRT terminal — P3 amber and P39 green glow on a green-black tube | dark only |

```vim
:colorscheme coffee
:colorscheme graphite
:colorscheme tokyonight
:set background=light   " day edition
:set background=dark    " late edition

:colorscheme vga        " both retro themes are dark-only — a CRT
:colorscheme phosphor   " has no day edition; each sets it itself
```

## The idea

A newspaper carries hierarchy through **weight and hue separation**, not
saturation. So the prose reads as ink on paper, and the markup around it is a
different *category* at a glance without ever shouting.

The rule that matters most: **delimiters recede, content advances.**

```
\section{Market Turbulence}          \section    crimson bold
                                     title text  ink bold  (a headline)
\begin{equation}\label{eq:cap}       \begin\end  crimson bold
  \alpha_t = \beta \cdot r_{t-1}     {equation}  verdigris bold
\end{equation}                       eq:cap      navy underline
                                     \alpha      ochre
As \citet{fama1970} shows.           fama1970    navy underline
% TODO: rerun with 2024 data         comment     mute italic
                                     { } braces  hairline, near-invisible
```

Braces and delimiters fall back to a faint gray while the prose inside `{...}`
keeps full ink. In a `.tex` file with conceal disabled — where every brace is
literally on screen — that one inversion is the difference between reading a
page and reading a pile of syntax.

`\textbf{...}` content gains weight but no color, so emphasis still reads as
prose.

## The code editions

**tokyonight**, **vga** and **phosphor** invert the premise.
There is no prose in a source file to protect, and every token on the line is
content, so four of the assignments above are swapped:

| | prose (coffee, graphite) | code (the other three) |
|---|---|---|
| `Delimiter` | hairline — braces are noise around the text | operator weight — in R `,` *is* the argument list |
| `Identifier` | secondary ink | full ink — the identifiers are the content |
| `Function` | bold | plain — open-ended and on every other line |
| `CocSemTypeBracket` | undefined | follows `Delimiter` |

`Operator` moves too, but on a different lever: it takes the optional `oper`
palette key if the theme supplies one, and the secondary ink if not. A `.tex`
file has almost no operators in it; a source file has them on every line.

Three more optional keys use the same lever to split the keyword classes the
way [jellybeans](https://github.com/nanotech/jellybeans.vim) does — `struct`
for `Structure`/`Typedef` (`class`, `template`, `namespace`, `typedef`),
`storage` for `StorageClass` (`static`, `const`, `extern`), and `except` for
`Exception` (`try`, `catch`, `throw`, `raise`). Omitted, they fall back to
`quote`/`quote`/`cmd`, which is exactly what the earlier themes rendered. The
two retro themes supply all three, so a C++ buffer carries a five-way keyword
split: control flow, types, shape declarations, qualifiers, and the danger
keywords in the alarm colour. Python's built-in exception names (`KeyError`)
ride `struct` too — Vim links them to `Structure`.

**The code themes then go further: no bold anywhere.** The prose themes hang
hierarchy on two cues, weight and hue, because a `.tex` file is prose with
markup laid over it and the markup has to separate from the type. A source file
has no prose in it — every line is already markup — so weight stops being a
signal and turns into texture, and thirty bold keywords to a screen is a page
that shouts evenly. Hue carries the whole hierarchy here, which is what the
Tokyo Night palette was built to do — and in the retro themes, brightness
carries it too: DOS text mode's intensity bit was that era's bold. One law
holds across all of them: **white belongs to the variables and body text alone**
— the most frequent token owns the brightest ink — and frequent tokens ride
light colours generally, with the darker accents reserved for specific
modifiers and literals.

Italics, underlines and undercurls are untouched: comments still slant, links
still underline, misspellings still curl.

```
#include <vector>                  #include    blue1      (env)
std::vector<int> rows;             vector      full ink
                                   int         yellow     (quote)
auto n = parse(argv[1]);           parse       blue       (ref)
                                   argv        full ink
                                   =           cyan       (oper)
if (n > 0x1F) { return -1; }       if, return  magenta    (cmd)
                                   0x1F, -1    orange     (math)
                                   ( ) { } ,   secondary ink
// TODO: overflow                  comment     mute italic
```

(`parse` is blue only if something is highlighting calls — `let c_functions = 1`
or coc.nvim's semantic tokens. See [Notes](#notes).)

The palette is [Tokyo Night](https://github.com/folke/tokyonight.nvim), used as
published. On the dark edition every accent is the upstream hex; see
[Palettes](#palettes) for the two that could not be.

## Install

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'RomaLzhih/vim-broadsheet'
```

Then pick an edition and a theme:

```vim
set termguicolors
set background=light
colorscheme coffee
```

Requires a truecolor terminal (`set termguicolors`). 256-color fallbacks are
defined for every group, so it degrades rather than breaks.

A one-line toggle between editions, which also works with any other dual-background
scheme:

```vim
nnoremap <Leader>tb :let &background = (&background ==# 'dark' ? 'light' : 'dark')<CR>
```

## Options

```vim
let g:broadsheet_bold = 0    " default 1
```

Drops every bold attribute the theme sets — including the weight on
`\textbf{...}` content — while leaving italics and underlines untouched. Set it
before `:colorscheme`, or re-run `:colorscheme` after changing it.

Worth knowing what you give up: the design leans on weight as one of its two
hierarchy cues, so with bold off, headings and commands are separated by hue
alone. That reads calmer and flatter — which is the point if you dislike bold
faces, but H1 and H2 in particular become harder to tell apart at a glance, and
in LaTeX `\times` stops standing out from the math around it.

The switch only ever removes weight, never adds it, so it does nothing to
tokyonight — that theme declares `'bold': 0` for itself and already carries
none. To put weight back into it, edit the `broadsheet#apply()` call at the foot
of `colors/tokyonight.vim`.

## What it covers

- **LaTeX** — [vimtex](https://github.com/lervag/vimtex) 2.x, tuned for
  `g:vimtex_syntax_conceal_disable = 1`. Child groups are restated so
  highlighting survives a `:colorscheme` switch without reloading the buffer.
- **Markdown** — [vim-markdown](https://github.com/preservim/vim-markdown)
  (`mkd*`/`html*`) and Vim's built-in `markdown*`, with a real H1→H6 descent.
- **Prose filetypes** — reStructuredText, gitcommit, help, mail, BibTeX.
- **Source** — C/C++, shell, Python and R are covered through the standard
  groups their syntax files link to, checked token by token against real files
  in both editions. Anything else Vim ships is covered to the same degree.
- **Plugins** — coc.nvim (including the `CocSemType*` semantic tokens), fzf,
  startify, easymotion, signify, floaterm, which-key, visual-multi, signature,
  bookmarks.
- **vim-airline** — `vga` and `phosphor` ship matching airline themes, so the
  statusline and tab strip follow the colorscheme instead of being derived.
  airline resolves them by name when you switch interactively; if you make one
  of them your startup colorscheme, set `let g:airline_theme = 'vga'` to match.
- **Terminal** — a matching 16-color ANSI palette for `:terminal` and floaterm.

## Palettes

Roles, not colors. `cmd` is press-red in coffee, burgundy in graphite and
magenta in tokyonight; `math` is ochre in one and orange in another.

Each theme is listed in its own leading edition — the prose pair were drawn for
paper, Tokyo Night for a dark screen.

| role | used for | coffee (light) | graphite (light) | tokyonight (dark) |
|---|---|---|---|---|
| `cmd` | commands, headings, keywords | `#8c1c13` press-red |
| `alert` | errors, H3 | `#a52019` |
| `ref` | refs, citations, links, functions | `#1f4e79` navy |
| `env` | environment names, preproc, `$VAR` | `#2c5f5d` verdigris |
| `math` | math zones, numbers | `#7d5f0e` ochre |
| `verb` | strings, verbatim | `#4f5d16` olive |
| `opt` | `[options]`, `#params`, constants, properties | `#70386b` plum |
| `quote` | blockquotes, types, H4–H6 | `#7a5c3e` sepia |
| `oper` | operators — **optional**, falls back to secondary ink | — |

The stocks differ too: coffee's day edition is newsprint cream `#f5f2e9`,
graphite's is newspaper grey `#e3e5e6` — a dull light grey rather than an
off-white, with only a faint cool cast so it stays distinct from the cream.
Graphite's accents are pitched slightly deeper to match, since a greyer page
needs a little more ink to hold the same separation. Body text is pure black in
both.

The two are designed from different premises rather than being recolors of each
other. Coffee is weighted to the warm half of the wheel — five of its eight
accents sit between 300° and 90° — which is what makes it read as printing ink
on warm stock. Graphite commits to the cool half, with `quote` carrying its role
on low saturation instead of a hue of its own.

That also means the two don't share a role→hue assignment. The cool half of the
wheel only fits four or five well-separated hues, so graphite's assignment had
to change, not just the values.

In graphite, `math` takes the green and `verb` the teal, inverting the usual
green-for-strings convention. That is deliberate: this is a theme for writing
LaTeX, where math zones are a constant presence and `lstlisting` blocks are
rare, so math earns the more visible hue.

tokyonight takes its values from upstream rather than deriving new ones. On the
dark edition, every accent above is the published hex, and so are the stock
steps, the ink above the comment, the diff washes, the IncSearch orange and the
16 ANSI colors. Two things could not survive as published, both because this
family holds every text pair at AA:

- **`comment` `#565f89`** is 2.8:1 on the night stock and 2.5:1 in a float — the
  one upstream color that is unreadable rather than merely quiet. `ink_mute` is
  lifted along the same hue to `#828ab6` (5.1:1). Comments are still the dimmest
  text on the page.
- **`blue0` `#3d59a1`**, the Search fill, puts body ink at 4.14:1. It is taken
  one step deeper to `#395294`.

The **assignment**, though, is [Catppuccin](https://github.com/catppuccin/nvim)'s
rather than Tokyo Night's own: types on the yellow instead of in the cyan
family, constants on the teal, and operators given a hue instead of being left
on ink. That is where Catppuccin's colourfulness comes from — not from the
values being louder, but from more of the screen carrying a hue at all.

One piece of it can't be had with these values. Catppuccin separates preproc
(pink) from operators (sky), and Tokyo Night has no third violet or pink that
survives: `purple #9d7cd8` is ΔE 11 from the keyword magenta — a collision by
the ~12–14 threshold — and also fails AA on the deepest stock step, while
`magenta2 #ff007c` fails AA on two steps. Pressing either would mean giving up
an upstream hex, so preproc takes `blue1` and operators the cyan, ΔE 19 apart.

The change that matters most is types. They were `green1` before, one step from
the cyan preproc held, and `#include <vector>` over `std::vector<int>` came out
as two shades of the same colour.

The light edition is the harder one. Tokyo Night Day is low-contrast by design:
its foreground is 4.5:1 on its own stock and every accent sits between 3.0 and
4.3, so there is no room to hang a four-step ink ladder underneath. The whole
day palette is pressed deeper along its own hue lines — hue preserved to within
7° of the dark edition, chroma tracking lightness down so that pressing a color
darker doesn't also make it shout, and `cmd` capped at chroma 44, the level
graphite settled on for the same reason. The stock, the search fill and the
selection step stay upstream.

The two retro themes are era palettes on black, each with one describable idea:

| role | vga | phosphor |
|---|---|---|
| `ink` variables, body | `#ffffff` DAC white | `#d6ecd0` phosphor white |
| `cmd` keywords | `#ff55ff` DAC bright magenta | `#ffb000` P3 amber |
| `oper` operators | `#ffffff` — the body white, shared with variables | `#7fbf6f` sage |
| `ref` functions | `#55ffff` bright cyan | `#82e96e` bloom |
| `quote` types | `#ffff55` DAC bright yellow | `#56d8d8` turquoise |
| `struct` class/namespace | `#55ff55` DAC bright green | `#dc89d1` lifted 3279 pink |
| `opt` constants, properties | `#00b4ff` electric blue | `#5ce6b0` teal |
| `storage` static/const | `#dd8134` lifted brown | `#e2850f` burnt amber |
| `verb` strings | `#fe9e96` DAC red, twice lifted | `#3fdc3f` P1 green |
| `math` numbers | `#dd8134` shared with `storage` | `#e2850f` shared with `storage` |
| `env` preproc, `$VAR` | `#fe716b` lifted DAC red | `#ff8778` lifted 3279 red |
| `alert` errors | `#ff5555` bright red | `#ff6b5e` red |

**vga** — the hexes are IBM's DAC and the intensity bit does the work bold
used to do: white prose over the DAC's own grays, and the assignment of Vim's
own **koehler**, which turns out to be the same palette — koehler's keyword
yellow is ΔE 4.1 from the DAC's bright yellow, its type green ΔE 5.0, its
identifier cyan ΔE 2.5. Keywords take the bright magenta instead of
koehler's yellow, and `class`/`namespace` takes the green koehler gives to
types — so green, yellow and cyan each sit one place round from where koehler
puts them. Where the two differ further: koehler has no dim
colours at all, so vga's strings moved off the dim green onto the DAC red
driven up twice (which landed ΔE 4.5 from koehler's own salmon, arrived at
independently); koehler links `Structure` to `Type`, while this theme splits
them and gives constants on an electric blue — the terminal blue `#5555ff` is 4.13:1 and too
dark to sit among accents living at L60–97, lifting it along its own hue only
desaturates it toward lavender, and rotating it to azure leaves it soft because
it still carries red; sRGB caps blue chroma near 49 where green and magenta
reach 99, so the vividness comes from dropping the red channel to zero instead; and the DAC red runs at three intensities — errors exact,
preprocessor one step up, strings two. Operators are the one role with no hue at
all: vga puts them on the body white, so `x + y` reads as one phrase in one
colour. That is the single role allowed to share the ink — an operator is
content rather than chrome, since `+` against `-` changes what a line means —
while delimiters stay a step back at `#aaaaaa`, because a bracket is
scaffolding around content rather than content itself. It is the family's
founding rule, delimiters recede and content advances, applied inside the
expression. One deliberately darker accent
remains, the lifted amber on numbers and `static`/`const`. Blue at DAC value
never carries text: it is the Norton-panel wash behind search and diffs.
**phosphor** — a colour terminal remembered as a monochrome one: a
phosphor-tinted ink ladder over the IBM 3279's red, green, turquoise and pink,
with the VT220's P3 amber on the preprocessor and the search flash; the only
theme in the family whose audit carries zero advisories. Each file's header
documents every measured deviation from the authentic bytes — the originals it
replaces are unreadable on black (DOS blue `#0000aa` is 1.58:1).

Paper and ink are four steps each: `bg` / `bg_alt` / `bg_soft` / `bg_deep` and
`ink` / `ink_soft` / `ink_mute` / `ink_faint`.

Every text-bearing pair is **≥ 4.5:1 WCAG contrast**, audited from a live Vim
dump per theme per edition — zero below AA in every edition, and the
audit tooling now ships in `scripts/`. The exception is `ink_faint`, which is
deliberately below AA: it exists for brace glyphs, hairline rules and whitespace
markers that must be barely there, never for text. Window separators are exempt
on the same grounds.

## Adding or editing a theme

`autoload/broadsheet.vim` holds every highlight-group assignment. A theme is
just a palette that calls into it, so a fix in the core reaches every theme.

To retune a color, edit only the palette in the theme's `colors/*.vim`. To add
a fourth theme, copy one of them, change the values, and call:

```vim
call broadsheet#apply('yourname', s:palette, s:ansi)
call broadsheet#apply('yourname', s:palette, s:ansi, {'profile': 'code'})
```

No changes to the core are needed either way. `profile` swaps the four
assignments listed in [The code editions](#the-code-editions) and defaults to
`'prose'`; `bold` (default 1) lets a theme declare itself weightless. The
optional palette keys — `oper`, `struct`, `storage`, `except` — are opt-in per
theme and fall back to the roles that carried those groups before.

The full palette contract is documented at the top of `autoload/broadsheet.vim`.

## Notes

- **`@`-prefixed groups are intentionally absent.** coc.nvim asks for
  treesitter-style names (`@function`) before the classic ones, but Vim — unlike
  Neovim — allows only alphanumerics and underscore in a highlight group name,
  so defining `@function` raises `W18: Invalid character in group name` on every
  load. coc's fallback to `Function` is the correct path in Vim.
- **Selected completion rows use a paper step, not a filled accent block.** A
  solid navy bar is the heaviest thing on a light page; the fuzzy-matched
  characters keep the accent instead.
- **vim-signify** users who hardcode `SignifySign*` colors in their vimrc via a
  `ColorScheme *` autocmd will override the theme's. Guard it with
  `if get(g:, 'colors_name', '') =~# 'coffee\|graphite\|tokyonight\|vga\|phosphor' | return | endif`.
- **C and C++ function calls need `let c_functions = 1`.** Vim's `c.vim` gates
  `cFunction` behind it, so without it a call is plain text. A colorscheme has
  no business setting a syntax option, so set it yourself — or ignore it if
  coc.nvim is supplying `CocSemTypeFunction`, which the core already maps.
- **Python's `True` / `False` / `None` come out as functions,** not constants.
  Vim's `python.vim` force-links `pythonBoolean` and `pythonConstant` to
  `Function` with `hi! def link`, which overrides even a full definition made by
  a colorscheme, so this cannot be fixed from here. If it bothers you, put this
  in `~/.vim/after/syntax/python.vim`:

  ```vim
  hi! link pythonBoolean  Boolean
  hi! link pythonConstant Constant
  ```

## License

MIT — see [LICENSE](LICENSE).
