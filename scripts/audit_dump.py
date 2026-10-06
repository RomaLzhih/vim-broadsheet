#!/usr/bin/env python3
"""audit_dump.py — WCAG audit of a scripts/dump.vim dump.

Usage: command python3 scripts/audit_dump.py DUMP.tsv INK_FAINT_HEX

Applies the house rules from CLAUDE.md "How to verify a change":
  - resolve an empty fg/bg to Normal's,
  - audit every text-bearing (fg, bg) pair for WCAG AA (>= 4.5:1),
  - exempt: any pair whose fg is ink_faint; the window-separator and fill
    groups; and pairs where fg equals bg (invisible on purpose).
Also prints the attribute census (bold/italic/underline/undercurl counts).
"""
import sys

EXEMPT_GROUPS = {'VertSplit', 'VertSplitNC', 'WinSeparator', 'EndOfBuffer',
                 'ToolbarLine', 'PmenuSbar', 'PmenuThumb', 'mkdLineBreak',
                 'debugPC'}


# Vim built-in defaults may carry colour NAMES (e.g. PmenuShadow's
# "DarkGrey on Black" in Vim 9.2+); resolve the ones that occur.
NAMES = {'black': '#000000', 'darkgrey': '#a9a9a9', 'darkgray': '#a9a9a9',
         'grey': '#bebebe', 'gray': '#bebebe', 'white': '#ffffff',
         'lightgrey': '#d3d3d3', 'lightgray': '#d3d3d3'}


def lum(h):
    def lin(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    h = NAMES.get(h.lower(), h)
    n = int(h.lstrip('#'), 16)
    return (0.2126 * lin(n >> 16) + 0.7152 * lin((n >> 8) & 255)
            + 0.0722 * lin(n & 255))


def contrast(a, b):
    x, y = sorted((lum(a), lum(b)), reverse=True)
    return (x + 0.05) / (y + 0.05)


def main(path, ink_faint):
    rows = []
    for line in open(path):
        name, target, fg, bg, attrs = (line.rstrip('\n').split('\t') + [''])[:5]
        rows.append((name, target, fg.lower(), bg.lower(), attrs))
    normal = next(r for r in rows if r[0] == 'Normal')
    nfg, nbg = normal[2], normal[3]

    census = {'bold': 0, 'italic': 0, 'underline': 0, 'undercurl': 0,
              'strikethrough': 0}
    pairs = {}          # (fg, bg) -> [group, ...]
    exempt_pairs = 0
    for name, target, fg, bg, attrs in rows:
        for a in census:
            if a in attrs.split(','):
                census[a] += 1
        rfg = fg or nfg
        rbg = bg or nbg
        if (name in EXEMPT_GROUPS or target in EXEMPT_GROUPS
                or rfg == ink_faint.lower() or rfg == rbg):
            exempt_pairs += 1
            continue
        pairs.setdefault((rfg, rbg), []).append(name)

    failures = [(fg, bg, contrast(fg, bg), gs) for (fg, bg), gs in pairs.items()
                if contrast(fg, bg) < 4.5]
    print(f'{len(rows)} groups; {len(pairs)} distinct text-bearing pairs '
          f'audited ({exempt_pairs} group entries exempt)')
    print('attributes:', ', '.join(f'{k} {v}' for k, v in census.items()))
    if failures:
        print(f'{len(failures)} PAIRS BELOW AA:')
        for fg, bg, r, gs in sorted(failures, key=lambda x: x[2]):
            print(f'  {fg} on {bg}  {r:4.2f}:1  '
                  f'({", ".join(gs[:6])}{"..." if len(gs) > 6 else ""})')
        return 1
    print('0 pairs below AA')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2]))
