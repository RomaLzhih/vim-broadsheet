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
is *only* a palette that calls `broadsheet#apply(name, palette, ansi)`.

Palette keys are **roles, not colours**: `cmd` `alert` `ref` `env` `verb` `math`
`opt` `quote`, plus the `bg`/`bg_alt`/`bg_soft`/`bg_deep` stock ladder and the
`ink`/`ink_soft`/`ink_mute`/`ink_faint` ink ladder. Full contract is documented
at the top of the core file.

- Retuning a colour → edit only the palette in `colors/*.vim`.
- Fixing a group assignment → edit the core; both themes inherit it.
- Adding a third theme → copy a palette, change values, call `broadsheet#apply`.
  No core change needed.

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
until `synIDattr(i, 'name')` is empty, record `fg`/`bg`/attrs, then check every
text-bearing pair for WCAG AA (≥ 4.5:1). Current baseline is **468 text pairs
per theme per edition, 0 below AA**. `ink_faint` and delimiter/hairline groups
are the deliberate exemptions.

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
   `CocSemTypeMod<Kind><Mod>`** — confirmed from `coc.nvim/build/index.js`, not
   just its vimscript defaults. A bare `CocSemFunction` is from an older coc and
   is never consulted.

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
   `set -- $pair` silently fails in loops.

## Settled design decisions — don't re-litigate

- **Delimiters recede, content advances.** `texDelim` is hairline; the prose
  inside `{...}` keeps full ink. This is the core idea, tuned for
  `g:vimtex_syntax_conceal_disable = 1`.
- **Body text is pure black** in both light editions. A consequence: the two
  light themes share 26 identical groups (all ink-derived). That is intended,
  not an accent collision.
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

## Open items

- **vim-signify clash.** `~/.vimrc:702` `s:SignifyGitSignStyle()` hardcodes
  gruvbox lime/red on `#282828` and re-fires on `ColorScheme *`, overriding the
  theme's sign colours on cream/grey stock. One-line fix, not yet applied:
  `if get(g:, 'colors_name', '') =~# 'coffee\|graphite' | return | endif`
- **`<leader>ts` is now redundant.** `~/.vimrc:624` double-sources the vimrc to
  work around `CocSem*` links being wiped by `hi clear`. That root cause is
  fixed (`~/.vimrc:1040`, re-applied via a `ColorScheme` autocmd), so the
  mapping can go.
- **`.vimrc` does not travel.** Plain file, `$HOME` is not a git repo, no
  dotfiles repo exists. The conditional `Plug` above handles the plugin on a new
  machine, but only once the vimrc itself is there.
- **Possible improvement:** inside a math zone `texMathCmd` and `texMathZone`
  are the same colour, separated only by bold, so `\times` stands out from prose
  but not from surrounding math. A second math colour for commands would fix it.
- **Dev tooling is not in the repo.** The dump/audit scripts described above
  live only in session scratch. Worth committing under `scripts/` if this gets
  picked up again.
