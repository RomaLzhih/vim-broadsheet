# vim-broadsheet

Newspaper colorschemes for Vim, built for writing **LaTeX and Markdown** rather
than for reading code.

Two themes share one core:

| | | |
|---|---|---|
| **coffee** | warm — press-red, ochre, sepia on newsprint cream | light + dark |
| **graphite** | cool — blueprint blue, cyan, teal, slate on grey stock | light + dark |

```vim
:colorscheme coffee
:colorscheme graphite
:set background=light   " day edition
:set background=dark    " late edition
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
faces, but H1 and H2 in particular become harder to tell apart at a glance.

## What it covers

- **LaTeX** — [vimtex](https://github.com/lervag/vimtex) 2.x, tuned for
  `g:vimtex_syntax_conceal_disable = 1`. Child groups are restated so
  highlighting survives a `:colorscheme` switch without reloading the buffer.
- **Markdown** — [vim-markdown](https://github.com/preservim/vim-markdown)
  (`mkd*`/`html*`) and Vim's built-in `markdown*`, with a real H1→H6 descent.
- **Prose filetypes** — reStructuredText, gitcommit, help, mail, BibTeX.
- **Plugins** — coc.nvim (including the `CocSemType*` semantic tokens), fzf,
  startify, easymotion, signify, floaterm, which-key, visual-multi, signature,
  bookmarks.
- **Terminal** — a matching 16-color ANSI palette for `:terminal` and floaterm.

## Palettes

Roles, not colors. `cmd` is press-red in coffee and drafting red in graphite;
`math` is ochre in one and teal in the other.

| role | used for | coffee (light) | graphite (light) |
|---|---|---|---|
| `cmd` | commands, headings | `#8c1c13` press-red | `#a3123a` drafting red |
| `alert` | errors, H3 | `#a52019` | `#bd2b46` |
| `ref` | refs, citations, links | `#1f4e79` navy | `#1d4f9c` blueprint blue |
| `env` | environment names | `#2c5f5d` verdigris | `#0b5a6b` cyan |
| `math` | math zones, numbers | `#7d5f0e` ochre | `#1a6350` teal |
| `verb` | strings, verbatim | `#4f5d16` olive | `#2d7033` green |
| `opt` | `[options]`, `#params` | `#70386b` plum | `#6b3d96` violet |
| `quote` | blockquotes, types, H4–H6 | `#7a5c3e` sepia | `#4d5a66` slate |

The two are designed from different premises rather than being recolors of each
other. Coffee is weighted to the warm half of the wheel — five of its eight
accents sit between 300° and 90° — which is what makes it read as printing ink
on warm stock. Graphite commits to the cool half, with commands as the single
warm exception because they have to pop hardest, and `quote` carrying its role
on low saturation instead of a hue of its own.

That also means the two don't share a role→hue assignment. In graphite, green
goes to strings (the universal convention) and math takes the calmer teal,
because a math zone is a large band of text and wants the quieter color. The
cool half of the wheel only fits four or five well-separated hues, so the
assignment had to change, not just the values.

Paper and ink are four steps each: `bg` / `bg_alt` / `bg_soft` / `bg_deep` and
`ink` / `ink_soft` / `ink_mute` / `ink_faint`.

Every text-bearing pair is **≥ 4.5:1 WCAG contrast** — 468 pairs per theme per
edition, verified. The single exception is `ink_faint`, which is deliberately
below AA: it exists for brace glyphs, hairline rules and whitespace markers that
must be barely there, never for text.

## Adding or editing a theme

`autoload/broadsheet.vim` holds every highlight-group assignment. A theme is
just a palette that calls into it, so a fix in the core reaches both themes.

To retune a color, edit only the palette in `colors/coffee.vim` or
`colors/graphite.vim`. To add a third theme, copy one of them, change the
values, and call `broadsheet#apply('yourname', s:palette, s:ansi)` — no changes
to the core needed.

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
  `if get(g:, 'colors_name', '') =~# 'coffee\|graphite' | return | endif`.

## License

MIT — see [LICENSE](LICENSE).
