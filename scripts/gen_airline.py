#!/usr/bin/env python3
"""gen_airline.py — emit autoload/airline/themes/<name>.vim from a theme palette.

  command python3 scripts/gen_airline.py colors/swan-vga.vim

vim-airline picks a theme by name: airline#switch_matching_theme() calls
airline#switch_theme(tr(tolower(g:colors_name), '-', '_')), so a theme file
named after the colorscheme -- hyphens as underscores, since an autoload name
cannot hold one -- is found automatically.  colors/swan-vga.vim therefore
yields autoload/airline/themes/swan_vga.vim.  Without one, airline derives its own
colours and can land anywhere -- under vga it put bg_deep text on bg_alt, about
1.1:1, which made the middle statusline sections and every tab label
invisible.  Every pair emitted here is asserted at WCAG AA first.

A colors file with one palette (vga, phosphor) gets a flat theme file.  One
with a day and a late edition (budapest) gets both, inside
airline#themes#<name>#refresh() -- airline calls that on every theme load, so
the bar follows 'background' along with the page.
"""
import re
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from colorlib import contrast, luminance                        # noqa: E402

# Section -> (fg role, bg role).  A is the mode block: a bright accent with the
# stock colour laid over it, the same inversion IncSearch uses.
MODES = {
    'normal':  'ink',
    'insert':  'quote',
    'replace': 'alert',
    'visual':  'opt',
}


def read_palettes(path):
    """One dict per `let s:palette = {` block.  Two blocks are the two
    editions, returned day first -- told apart by the stock, not by their
    order in the file."""
    pals = []
    for block in open(path).read().split('let s:palette = {')[1:]:
        pal = {}
        for m in re.finditer(r"\\ '(\w+)'\s*:\s*\['(#[0-9a-f]{6})',\s*'(\d+)'\]",
                             block):
            k, hexv, ct = m.groups()
            pal[k] = (hexv, ct)
        pals.append(pal)
    return sorted(pals, key=lambda p: -luminance(p['bg'][0]))


def pair(pal, fg, bg, why, fails):
    r = contrast(pal[fg][0], pal[bg][0])
    if r < 4.5:
        fails.append(f'{why}: {fg} on {bg} = {r:.2f}')
    return f"['{pal[fg][0]}', '{pal[bg][0]}', {pal[fg][1]}, {pal[bg][1]}]", r


def body(name, pal, fails, edition=''):
    """The palette statements for one edition.  `edition` only labels a
    failure, so a two-edition theme says which page a pair is under AA on."""
    out = []
    w = out.append

    for mode, accent in MODES.items():
        a, _ = pair(pal, 'bg', accent, f'{edition}{mode} section A', fails)
        b, _ = pair(pal, 'ink', 'bg_soft', f'{edition}{mode} section B', fails)
        c, _ = pair(pal, 'ink', 'bg_alt', f'{edition}{mode} section C', fails)
        w(f'" {mode}: the mode block wears {accent}')
        w(f'let s:{mode}_a = {a}')
        w(f'let s:{mode}_b = {b}')
        w(f'let s:{mode}_c = {c}')
        w(f'let g:airline#themes#{name}#palette.{mode} = '
          f'airline#themes#generate_color_map(s:{mode}_a, s:{mode}_b, s:{mode}_c)')
        mod, _ = pair(pal, 'cmd', 'bg_alt', f'{edition}{mode} modified', fails)
        w(f"let g:airline#themes#{name}#palette.{mode}_modified = {{"
          f" 'airline_c': {mod} }}")
        w('')

    ia, _ = pair(pal, 'ink_mute', 'bg_alt', f'{edition}inactive', fails)
    w('" An inactive split recedes by going quiet, never by becoming unreadable.')
    w(f'let g:airline#themes#{name}#palette.inactive = '
      f'airline#themes#generate_color_map({ia}, {ia}, {ia})')
    w(f"let g:airline#themes#{name}#palette.inactive_modified = {{"
      f" 'airline_c': {ia} }}")
    w('')

    tab, _ = pair(pal, 'ink_soft', 'bg_alt', f'{edition}tabline tab', fails)
    tabsel, _ = pair(pal, 'ink', 'bg_deep', f'{edition}tabline selected', fails)
    tabtype, _ = pair(pal, 'bg', 'quote', f'{edition}tabline type', fails)
    tabmod, _ = pair(pal, 'bg', 'cmd', f'{edition}tabline modified', fails)
    tabhid, _ = pair(pal, 'ink_mute', 'bg_alt', f'{edition}tabline hidden', fails)
    tabfill, _ = pair(pal, 'ink_soft', 'bg_alt', f'{edition}tabline fill', fails)
    w('" The tab strip: the current tab is a paper step, the others recede one')
    w('" ink weight.  Same reasoning as the completion menu -- a filled accent')
    w('" block for the selected row is the heaviest thing on the page.')
    w(f'let g:airline#themes#{name}#palette.tabline = {{')
    w(f"      \\ 'airline_tab':     {tab},")
    w(f"      \\ 'airline_tabsel':  {tabsel},")
    w(f"      \\ 'airline_tabtype': {tabtype},")
    w(f"      \\ 'airline_tabfill': {tabfill},")
    w(f"      \\ 'airline_tabmod':  {tabmod},")
    w(f"      \\ 'airline_tabhid':  {tabhid},")
    w('      \\ }')
    w('')
    acc, _ = pair(pal, 'alert', 'bg_alt', f'{edition}accent red', fails)
    w('" Warning and error accents, used by the whitespace and diagnostics parts.')
    w(f"let g:airline#themes#{name}#palette.accents = {{ 'red': {acc} }}")
    w('')
    return out


def indent(lines, by='    '):
    """Nest one edition's statements inside refresh(), minus the trailing gap."""
    while lines and not lines[-1]:
        lines = lines[:-1]
    return [by + line if line else '' for line in lines]


def generate(path):
    name = os.path.basename(path)[:-4]
    # The colorscheme keeps its hyphen; the airline theme, its file and every
    # autoload name in it take an underscore -- see the module docstring.
    aname = name.replace('-', '_')
    pals = read_palettes(path)
    if len(pals) not in (1, 2):
        print(f'{name}: expected one palette or two editions, found {len(pals)}')
        return None
    fails, out = [], []
    w = out.append

    w('" =============================================================================')
    w(f'" airline/themes/{aname}.vim — the folio line for the {name} colorscheme')
    w('" =============================================================================')
    w('"')
    w('" Generated by scripts/gen_airline.py from the palette in')
    w(f'" colors/{name}.vim; every pair below is asserted at WCAG AA.')
    w('"')
    w('" airline#switch_matching_theme() resolves an airline theme by the')
    w('" colorscheme name, so this file is picked up automatically.  Without it')
    w('" airline derives its own colours and can land far outside the palette --')
    w('" it put bg_deep text on bg_alt here, about 1.1:1, which is what made the')
    w('" statusline and tab labels unreadable.')
    w('"')
    w('" The mode block follows the family\'s inverted-cell logic: a bright accent')
    w('" with the paper stock laid over it, the same shape as IncSearch.')
    w('" =============================================================================')
    w('')
    w(f'let g:airline#themes#{aname}#palette = {{}}')
    w('')

    if len(pals) == 1:
        out.extend(body(aname, pals[0], fails))
    else:
        day, late = pals
        w('" Two editions.  airline calls refresh() on every theme load, and Vim')
        w('" re-sources the colorscheme when \'background\' changes, so the bar turns')
        w('" with the page.')
        w(f'function! airline#themes#{aname}#refresh() abort')
        w("  if &background ==# 'light'")
        out.extend(indent(body(aname, day, fails, 'day edition, ')))
        w('  else')
        out.extend(indent(body(aname, late, fails, 'late edition, ')))
        w('  endif')
        w('endfunction')
        w('')
        w(f'call airline#themes#{aname}#refresh()')
        w('')
    w('" vim: set ft=vim ts=2 sw=2 et:')

    if fails:
        print(f'{name}: REFUSING to write, {len(fails)} pairs under AA:')
        for f in fails:
            print('   ', f)
        return None
    return aname, '\n'.join(out) + '\n'


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        res = generate(arg)
        if not res:
            sys.exit(1)
        name, body_text = res
        root = os.path.dirname(os.path.dirname(os.path.abspath(arg)))
        outdir = os.path.join(root, 'autoload', 'airline', 'themes')
        os.makedirs(outdir, exist_ok=True)
        dest = os.path.join(outdir, name + '.vim')
        with open(dest, 'w') as f:
            f.write(body_text)
        print(f'wrote {dest}')
