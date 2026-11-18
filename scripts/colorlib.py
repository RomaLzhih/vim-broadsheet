#!/usr/bin/env python3
"""Colour tooling for the broadsheet family — WCAG contrast, Lab/LCh, dE76,
lift/press along a hue line, xterm-256 nearest, and a palette auditor that
encodes the emitted-pair rules from CLAUDE.md.

CLI:
  colorlib.py info HEX [HEX...] [--bg HEX ...]     L/C/h, xterm, contrast vs bgs
  colorlib.py de HEX HEX                           dE76 between two colours
  colorlib.py lift HEX --target T --bg HEX [--bg HEX ...] [--max-chroma C]
  colorlib.py press HEX --target T --bg HEX [--bg HEX ...] [--max-chroma C]
  colorlib.py audit FILE.json                      full palette audit
Audit input JSON: {"palette": {"bg": "#000000", ...}, "ansi": ["#...", x16]}
Palette keys: bg bg_alt bg_soft bg_deep ink ink_soft ink_mute ink_faint
cmd alert ref env verb math opt quote oper marker marker_hot on_hot
diff_add diff_chg diff_del diff_txt
"""
import json, math, sys

# ---------------------------------------------------------------- conversions
def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16) / 255.0 for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return '#%02x%02x%02x' % tuple(max(0, min(255, round(c * 255))) for c in rgb)

def _lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def _delin(c):
    return c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055

def luminance(h):
    r, g, b = (_lin(c) for c in hex_to_rgb(h))
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def contrast(fg, bg):
    a, b = luminance(fg), luminance(bg)
    if a < b:
        a, b = b, a
    return (a + 0.05) / (b + 0.05)

_WP = (0.95047, 1.0, 1.08883)  # D65

def rgb_to_xyz(rgb):
    r, g, b = (_lin(c) for c in rgb)
    return (0.4124564 * r + 0.3575761 * g + 0.1804375 * b,
            0.2126729 * r + 0.7151522 * g + 0.0721750 * b,
            0.0193339 * r + 0.1191920 * g + 0.9503041 * b)

def xyz_to_rgb(xyz):
    x, y, z = xyz
    r = 3.2404542 * x - 1.5371385 * y - 0.4985314 * z
    g = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z
    b = 0.0556434 * x - 0.2040259 * y + 1.0572252 * z
    return tuple(_delin(c) for c in (r, g, b))

def _f(t):
    return t ** (1 / 3) if t > (6 / 29) ** 3 else t / (3 * (6 / 29) ** 2) + 4 / 29

def _finv(t):
    return t ** 3 if t > 6 / 29 else 3 * (6 / 29) ** 2 * (t - 4 / 29)

def hex_to_lab(h):
    x, y, z = rgb_to_xyz(hex_to_rgb(h))
    fx, fy, fz = _f(x / _WP[0]), _f(y / _WP[1]), _f(z / _WP[2])
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))

def lab_to_hex(lab):
    L, a, b = lab
    fy = (L + 16) / 116
    fx, fz = fy + a / 500, fy - b / 200
    xyz = (_finv(fx) * _WP[0], _finv(fy) * _WP[1], _finv(fz) * _WP[2])
    return xyz_to_rgb(xyz)  # raw rgb tuple, may be out of gamut

def lab_in_gamut(lab, tol=1e-4):
    return all(-tol <= c <= 1 + tol for c in lab_to_hex(lab))

def lab_to_lch(lab):
    L, a, b = lab
    return (L, math.hypot(a, b), math.degrees(math.atan2(b, a)) % 360)

def lch_to_lab(lch):
    L, C, h = lch
    return (L, C * math.cos(math.radians(h)), C * math.sin(math.radians(h)))

def lch_hex(lch):
    return rgb_to_hex(lab_to_hex(lch_to_lab(lch)))

def de76(h1, h2):
    a, b = hex_to_lab(h1), hex_to_lab(h2)
    return math.dist(a, b)

def chroma(h):
    return lab_to_lch(hex_to_lab(h))[1]

# ------------------------------------------------------------------ xterm 256
_CUBE = [0, 95, 135, 175, 215, 255]

def _x256():
    pal = {}
    for i in range(216):
        r, g, b = _CUBE[i // 36], _CUBE[i // 6 % 6], _CUBE[i % 6]
        pal[16 + i] = '#%02x%02x%02x' % (r, g, b)
    for i in range(24):
        v = 8 + 10 * i
        pal[232 + i] = '#%02x%02x%02x' % (v, v, v)
    return pal

_X256 = _x256()

def xterm(h):
    lab = hex_to_lab(h)
    return min(_X256, key=lambda i: math.dist(lab, hex_to_lab(_X256[i])))

# ---------------------------------------------------------------- lift/press
def _fit_chroma(L, C, h):
    while C > 0 and not lab_in_gamut(lch_to_lab((L, C, h))):
        C -= 0.5
    return max(C, 0)

def walk(h_in, bgs, target=4.5, up=True, max_chroma=None):
    """Walk L up (lift) or down (press) at constant hue until contrast vs every
    bg clears target.  Chroma is held at min(original, max_chroma), refit to
    gamut at each step."""
    L, C, hue = lab_to_lch(hex_to_lab(h_in))
    if max_chroma is not None:
        C = min(C, max_chroma)
    step = 0.25 if up else -0.25
    for _ in range(500):
        c_fit = _fit_chroma(L, C, hue)
        cand = lch_hex((L, c_fit, hue))
        if all(contrast(cand, bg) >= target for bg in bgs):
            return cand
        L += step
        if not (0 <= L <= 100):
            break
    return None

# --------------------------------------------------------------------- audit
# The optional keys are audited too when a palette supplies them; identical
# pairs (storage == math, except == alert) come back tagged shared-by-design.
ACCENTS = ['cmd', 'alert', 'ref', 'env', 'verb', 'math', 'opt', 'quote', 'oper',
           'struct', 'storage', 'except', 'ns']


def accents(p):
    return [a for a in ACCENTS if a in p]


STOCKS = ['bg', 'bg_alt', 'bg_soft', 'bg_deep']

# Roles that paint a large share of a source file.  The family's second design
# law — frequent tokens ride light colours, dark accents are reserved for
# specific modifiers and literals — is checked against these.  `math`/`storage`
# are deliberately excluded: numbers and qualifiers are where a darker accent
# is allowed to live.
FREQUENT = ['cmd', 'oper', 'ref', 'verb', 'quote', 'struct', 'opt', 'env']
L_FLOOR = 60.0          # a rejected accent measured L 54.3; vga's floor is 60.6


def hard_pairs(p):
    """(fg, bg) pairs the core actually emits with text on them — hard AA."""
    acc = accents(p)
    return (
        [(a, s) for a in acc for s in ('bg', 'bg_alt')]
        + [('cmd', 'bg_soft'), ('cmd', 'bg_deep'), ('env', 'bg_deep')]
        + [('ink', s) for s in STOCKS]
        + [('ink', 'marker'), ('ink', 'diff_add'), ('ink', 'diff_chg'),
           ('ink', 'diff_txt')]
        + [('ink_soft', 'bg'), ('ink_soft', 'bg_alt'), ('ink_soft', 'bg_deep')]
        + [('ink_mute', 'bg'), ('ink_mute', 'bg_alt')]
        + [('on_hot', 'marker_hot'), ('alert', 'diff_del')]
    )


def soft_pairs(p):
    """Not emitted today, but one palette edit away — advisory."""
    acc = accents(p)
    return (
        [(a, s) for a in acc for s in ('bg_soft', 'bg_deep')]
        + [('ink_mute', 'bg_soft'), ('ink_mute', 'bg_deep')]
        + [(a, w) for a in acc for w in ('diff_add', 'diff_chg')]
    )


# Roles that paint TEXT.  Two of these landing on one xterm cell means two
# kinds of token are the same colour in a 256-colour terminal -- the failure
# that nearly shipped in vga, where keywords and errors both quantised to 203.
TEXT_ROLES = set(ACCENTS) | {'ink', 'ink_soft', 'ink_mute', 'ink_faint'}


def check_cterm(p, pins=None):
    """Distinct gui colours that quantise to one xterm-256 cell render
    identically on a 256-colour terminal, and nothing else in this file can
    see it -- the rest measures truecolor.  Returns (serious, cosmetic):
    serious is two TEXT colours merging; cosmetic is a wash or stock step
    merging with another, which is a real but minor artefact of the 240-cell
    palette (every theme in this family has some, tokyonight included)."""
    pins = pins or {}
    seen, serious, cosmetic = {}, [], []
    for role in [k for k in p if k not in ('on_hot',)]:
        idx = int(pins.get(role, xterm(p[role])))
        prev = seen.get(idx)
        if prev is not None and p[prev].lower() != p[role].lower():
            msg = (f'cterm {idx}: {prev} {p[prev]} and {role} {p[role]} '
                   f'(gui dE {de76(p[prev], p[role]):.1f}) render identically')
            (serious if {prev, role} <= TEXT_ROLES else cosmetic).append(msg)
        else:
            seen.setdefault(idx, role)
    return serious, cosmetic


# A role allowed to be BYTE-IDENTICAL to the body ink.  `oper` is the only
# one: an operator is content rather than chrome -- `+` against `-` changes
# what a line means -- so a theme may decide operators join the prose instead
# of carrying an accent.  That is the opposite of the failure LAW 1 exists to
# catch, which is a HUE-carrying role stealing the brightest ink (white
# keywords, white function names).  Near-white is still a violation for
# everything including `oper`: a colour that is almost the ink competes with
# it, where one that IS the ink simply is it.
INK_SHAREABLE = {'oper'}


def check_laws(p, exceptions=None):
    """The two design laws, as testable rules.  Returns a list of violations.

    `exceptions` is a list of role names the palette declares as deliberate
    departures.  They are still measured and still printed -- an exception is
    a decision on the record, not a silencer -- but they do not fail the audit.
    """
    exceptions = set(exceptions or ())
    bad = []
    # 1. White (the brightest ink) is for variables and body text ONLY.
    for role in accents(p):
        d = de76(p[role], p['ink'])
        if d == 0 and role in INK_SHAREABLE:
            continue
        if d < 10:
            bad.append((role, f'LAW 1: {role} {p[role]} is within dE 10 of '
                              f'ink {p["ink"]} — only the body ink may wear it'))
    # 2. Frequent roles ride light colours.
    for role in FREQUENT:
        if role not in p:
            continue
        L = lab_to_lch(hex_to_lab(p[role]))[0]
        if L < L_FLOOR:
            bad.append((role, f'LAW 2: {role} {p[role]} is L{L:.1f}, under '
                              f'the {L_FLOOR:.0f} floor for a frequent role'))
    return [f'{m}   [DECLARED EXCEPTION]' if r in exceptions else m
            for r, m in bad], [m for r, m in bad if r not in exceptions]

def loudness(c):
    if c < 26: return 'dark'
    if c < 42: return 'quiet'
    if c < 55: return 'calm-coloured'
    return 'LOUD'

def audit(doc):
    p, ansi = doc['palette'], doc.get('ansi', [])
    hard_fail, notes = [], []
    print('== hard pairs (emitted, must be >= 4.5) ==')
    for fg, bg in hard_pairs(p):
        r = contrast(p[fg], p[bg])
        flag = 'FAIL' if r < 4.5 else 'ok  '
        if r < 4.5:
            hard_fail.append((fg, bg, r))
        print(f'  {flag} {fg:>10} on {bg:<10} {r:5.2f}')
    print('== advisory pairs (>= 4.5 keeps future edits free) ==')
    for fg, bg in soft_pairs(p):
        r = contrast(p[fg], p[bg])
        if r < 4.5:
            notes.append(f'advisory: {fg} on {bg} = {r:.2f}')
    print('   ' + (';  '.join(n for n in notes if n.startswith('advisory'))
                   or 'all clear'))
    print('== accents: L / chroma / hue / xterm / contrast on bg ==')
    for a in accents(p) + ['ink', 'ink_soft', 'ink_mute', 'ink_faint']:
        L, C, hu = lab_to_lch(hex_to_lab(p[a]))
        print(f'  {a:>10} {p[a]}  L{L:5.1f} C{C:5.1f} h{hu:5.1f}'
              f'  x{xterm(p[a]):3d}  {contrast(p[a], p["bg"]):5.2f}:1'
              f'  [{loudness(C)}]')
    print('== pairwise dE76 among accents (< 12 flagged) ==')
    coll = []
    acc = accents(p)
    for i, a in enumerate(acc):
        for b in acc[i + 1:]:
            d = de76(p[a], p[b])
            if d < 12:
                # A byte-identical pair is a declared sharing decision (the
                # Constant/Property precedent), never an accidental near-miss;
                # only dE in (0, 12) is the bug this check exists to catch.
                if p[a].lower() == p[b].lower():
                    tag = 'shared-by-design'
                elif {a, b} == {'cmd', 'alert'}:
                    tag = 'allowed-exception'
                else:
                    tag = 'COLLISION'
                coll.append((a, b, d, tag))
                print(f'  {tag:>17}: {a} vs {b} dE {d:.1f}')
    if not coll:
        print('   all pairs >= 12')
    print('== accents vs inks dE76 (< 12 flagged, advisory) ==')
    ok = True
    for a in accents(p):
        for k in ('ink', 'ink_soft', 'ink_mute'):
            d = de76(p[a], p[k])
            if d < 12:
                ok = False
                tag = ('shared-by-design' if p[a].lower() == p[k].lower()
                       else 'advisory')
                print(f'  {tag}: {a} vs {k} dE {d:.1f}')
    if ok:
        print('   all clear')
    print('== ladders ==')
    sL = [lab_to_lch(hex_to_lab(p[s]))[0] for s in STOCKS]
    iL = [lab_to_lch(hex_to_lab(p[k]))[0]
          for k in ('ink', 'ink_soft', 'ink_mute', 'ink_faint')]
    print(f'  stock L: {["%.1f" % v for v in sL]}  (adjacent dL >= 2.5 wanted)')
    print(f'  ink   L: {["%.1f" % v for v in iL]}  (must descend on dark)')
    ladder_bad = any(abs(sL[i + 1] - sL[i]) < 2.5 for i in range(3))
    ink_bad = not (iL[0] > iL[1] > iL[2] > iL[3])
    print(f'  ink_faint on bg: {contrast(p["ink_faint"], p["bg"]):.2f}'
          ' (target ~2.2-3.6, sub-AA by design)')
    if ansi:
        print('== ansi (fg 1-15 on bg, >= 3.0 advisory) ==')
        bad = [f'{i}:{c} {contrast(c, p["bg"]):.2f}'
               for i, c in enumerate(ansi) if i > 0
               and contrast(c, p['bg']) < 3.0]
        print('   ' + ('; '.join(bad) if bad else 'all clear'))
    print('== cterm-256 collisions (distinct colours quantising to one cell) ==')
    cterm_bad, cterm_soft = check_cterm(p, doc.get('cterm'))
    print('   ' + ('\n   '.join(cterm_bad) if cterm_bad
                   else 'no two text colours share a cell'))
    for m in cterm_soft:
        print('   (cosmetic) ' + m)
    print('== design laws ==')
    shown, laws = check_laws(p, doc.get('law_exceptions'))
    print('   ' + ('\n   '.join(shown) if shown else
                   'white is ink-only; every frequent role clears the L floor'))
    real_coll = [c for c in coll if c[3] == 'COLLISION']
    verdict = ('PASS' if not hard_fail and not real_coll and not laws
               and not cterm_bad else 'FAIL')
    print(f'AUDIT: {verdict}  ({len(hard_fail)} hard contrast failures,'
          f' {len(real_coll)} accent collisions, {len(laws)} law violations,'
          f' {len(cterm_bad)} cterm collisions,'
          f' ladder {"BAD" if ladder_bad or ink_bad else "ok"},'
          f' {len(notes)} advisories)')
    return verdict == 'PASS'

# ----------------------------------------------------------------------- cli
def main(argv):
    if not argv:
        print(__doc__); return 2
    cmd, rest = argv[0], argv[1:]
    bgs = [rest[i + 1] for i, a in enumerate(rest) if a == '--bg']
    pos = [a for i, a in enumerate(rest)
           if not a.startswith('--') and (i == 0 or rest[i - 1] not in
               ('--bg', '--target', '--max-chroma'))]
    def opt(name, default=None, cast=float):
        return cast(rest[rest.index(name) + 1]) if name in rest else default
    if cmd == 'info':
        for h in pos:
            L, C, hu = lab_to_lch(hex_to_lab(h))
            line = f'{h}  L{L:5.1f} C{C:5.1f} h{hu:5.1f}  xterm {xterm(h)}'
            for bg in bgs:
                line += f'  vs{bg} {contrast(h, bg):.2f}:1'
            print(line)
    elif cmd == 'de':
        print(f'{de76(pos[0], pos[1]):.1f}')
    elif cmd in ('lift', 'press'):
        r = walk(pos[0], bgs, opt('--target', 4.5), cmd == 'lift',
                 opt('--max-chroma'))
        if r is None:
            print('UNREACHABLE'); return 1
        L, C, hu = lab_to_lch(hex_to_lab(r))
        print(f'{r}  L{L:5.1f} C{C:5.1f} h{hu:5.1f}  xterm {xterm(r)}')
    elif cmd == 'audit':
        with open(pos[0]) as f:
            return 0 if audit(json.load(f)) else 1
    else:
        print(__doc__); return 2
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
