"""Country Bloom flower art (6 types x T1/T2/T3) as SVG.

Run from repo root:  python scripts/art/flowers_gen.py
Then import:         .\\scripts\\godot-import.ps1
Rules (tier progression, rarity -> complexity): docs/04-experience/design-drafts/seeds-flowers-cd-brief.md
"""
import math
import os
import sys

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join("game", "assets", "sprites", "flowers")
os.makedirs(OUT, exist_ok=True)

SW_OUT = 5.5
SW_IN = 3.0
PLUM = "3D2B3D"
STEM = "599E52"
LEAF = "6BC261"
GOLD = "E8C44A"

PAL = {
    "clover":    {"petal": "8CD980", "center": "FFEB80", "seed": "80D173", "crystal": "BF8CF2"},
    "daisy":     {"petal": "FAFAF5", "center": "FFD133", "seed": "D9E08C", "crystal": "F2C759"},
    "buttercup": {"petal": "FFE026", "center": "F2A61A", "seed": "EBD133", "crystal": "FFB81F"},
    "tulip":     {"petal": "EB476B", "center": "8C2638", "seed": "C75973", "crystal": "D9598C"},
    "sunflower": {"petal": "FFC71F", "center": "73471F", "seed": "E0B82E", "crystal": "F29E14"},
    "pumpkin":   {"petal": "F2851F", "center": "8C5214", "seed": "E08C26", "crystal": "EB7A0D"},
}


# ---------- colour ----------

def _rgb(h):
    h = h.lstrip("#")
    return [int(h[i:i + 2], 16) for i in (0, 2, 4)]


def _hex(c):
    return "".join(f"{max(0, min(255, int(round(v)))):02X}" for v in c)


def mix(a, b, t):
    A, B = _rgb(a), _rgb(b)
    return _hex([A[i] + (B[i] - A[i]) * t for i in range(3)])


def shade(c, t):
    return mix(c, PLUM, t)


def tint(c, t):
    return mix(c, "FFFFFF", t)


def n(v):
    s = f"{v:.2f}".rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


# ---------- parts & rendering ----------
# Sticker look: every group gets one thick outline pass (outer silhouette),
# then fills with thin inner strokes so overlaps read as separate shapes.

def F(d, fill, t="", det=None, oa=0.45, ia=0.34, ow=SW_OUT):
    return {"k": "f", "d": d, "fill": fill, "t": t, "det": det or [], "oa": oa, "ia": ia, "ow": ow}


def S(d, color, w, t="", oa=0.45, ow=SW_OUT):
    return {"k": "s", "d": d, "color": color, "w": w, "t": t, "oa": oa, "ow": ow}


def DF(d, fill, op=1.0):
    return ("f", d, fill, op)


def DS(d, color, w, op=1.0):
    return ("s", d, color, w, op)


def _tr(t):
    return f' transform="{t}"' if t else ""


def _op(op):
    return f' opacity="{n(op)}"' if op < 1 else ""


def _det(det, tr):
    if det[0] == "f":
        _, d, fill, op = det
        return f'<path d="{d}" fill="#{fill}"{_op(op)}{tr}/>'
    _, d, color, w, op = det
    return (f'<path d="{d}" fill="none" stroke="#{color}" stroke-width="{n(w)}" '
            f'stroke-linecap="round" stroke-linejoin="round"{_op(op)}{tr}/>')


def render_group(parts):
    p1, p2 = [], []
    for p in parts:
        tr = _tr(p["t"])
        if p["k"] == "f":
            oc = shade(p["fill"], p["oa"])
            ic = shade(p["fill"], p["ia"])
            p1.append(f'<path d="{p["d"]}" fill="#{oc}" stroke="#{oc}" stroke-width="{n(p["ow"] * 2)}" '
                      f'stroke-linejoin="round"{tr}/>')
            p2.append(f'<path d="{p["d"]}" fill="#{p["fill"]}" stroke="#{ic}" stroke-width="{n(SW_IN)}" '
                      f'stroke-linejoin="round"{tr}/>')
            for det in p["det"]:
                p2.append(_det(det, tr))
        else:
            oc = shade(p["color"], p["oa"])
            p1.append(f'<path d="{p["d"]}" fill="none" stroke="#{oc}" stroke-width="{n(p["w"] + p["ow"] * 2)}" '
                      f'stroke-linecap="round" stroke-linejoin="round"{tr}/>')
            p2.append(f'<path d="{p["d"]}" fill="none" stroke="#{p["color"]}" stroke-width="{n(p["w"])}" '
                      f'stroke-linecap="round" stroke-linejoin="round"{tr}/>')
    return "".join(p1) + "".join(p2)


def svg(body):
    # Drawn on a 256 viewBox, rasterized at 128px: in-game the plant shows at
    # ~45-70px, and 2x downscale stays crisp without mipmaps.
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 256 256">{body}</svg>'


def tr(x, y, a=0, flipx=False, flipy=False):
    s = f"translate({n(x)},{n(y)})"
    if a:
        s += f" rotate({n(a)})"
    if flipx:
        s += " scale(-1,1)"
    if flipy:
        s += " scale(1,-1)"
    return s


def facet_flip(a):
    # Light comes from upper-left; flip so the lit half of a rotated
    # symmetric shape always faces the light.
    r = math.radians(a)
    return math.cos(r) + math.sin(r) < 0


# ---------- shapes (local coords: base at origin, axis pointing up) ----------

def p_petal(r0, r1, w, bk=0.8, by=0.2, tk=1.2, ty=0.04, half=False):
    L = r1 - r0
    x1, y1 = -w * bk, -(r0 + L * by)
    x2, y2 = -w * tk, -(r1 - L * ty)
    d = f"M0,{n(-r0)} C{n(x1)},{n(y1)} {n(x2)},{n(y2)} 0,{n(-r1)}"
    if half:
        return d + "Z"
    return d + f" C{n(-x2)},{n(y2)} {n(-x1)},{n(y1)} 0,{n(-r0)}Z"


OVAL = dict(bk=0.55, by=0.25, tk=1.25, ty=0.02)
POINTED = dict(bk=1.1, by=0.18, tk=0.85, ty=0.4)
FLAME = dict(bk=1.0, by=0.0, tk=1.15, ty=0.45)
BUD = dict(bk=1.1, by=0.0, tk=0.95, ty=0.22)


def p_broad(r0, r1, w, half=False):
    L = r1 - r0
    a = (f"M0,{n(-r0)} C{n(-w * 0.95)},{n(-(r0 + L * 0.1))} {n(-w * 1.3)},{n(-(r1 - L * 0.35))} "
         f"{n(-w * 0.85)},{n(-(r1 - L * 0.08))}")
    if half:
        return a + f" Q{n(-w * 0.45)},{n(-(r1 + L * 0.035))} 0,{n(-(r1 + L * 0.01))}Z"
    return a + (f" C{n(-w * 0.5)},{n(-(r1 + L * 0.04))} {n(w * 0.5)},{n(-(r1 + L * 0.04))} "
                f"{n(w * 0.85)},{n(-(r1 - L * 0.08))} C{n(w * 1.3)},{n(-(r1 - L * 0.35))} "
                f"{n(w * 0.95)},{n(-(r0 + L * 0.1))} 0,{n(-r0)}Z")


def p_heart(W, H, half=False):
    a = (f"M0,0 C{n(-W)},{n(-H * 0.45)} {n(-W * 1.05)},{n(-H * 0.95)} {n(-W * 0.5)},{n(-H)} "
         f"C{n(-W * 0.2)},{n(-H * 1.02)} 0,{n(-H * 0.86)} 0,{n(-H * 0.76)}")
    if half:
        return a + "Z"
    return a + (f" C0,{n(-H * 0.86)} {n(W * 0.2)},{n(-H * 1.02)} {n(W * 0.5)},{n(-H)} "
                f"C{n(W * 1.05)},{n(-H * 0.95)} {n(W)},{n(-H * 0.45)} 0,0Z")


def p_crescent(W, H):
    return (f"M{n(-W * 0.42)},{n(-H * 0.18)} C{n(-W * 0.78)},{n(-H * 0.42)} {n(-W * 0.6)},{n(-H * 0.7)} "
            f"{n(-W * 0.16)},{n(-H * 0.88)} C{n(-W * 0.36)},{n(-H * 0.66)} {n(-W * 0.5)},{n(-H * 0.44)} "
            f"{n(-W * 0.3)},{n(-H * 0.2)}Z")


def p_leaf(L, W):
    return (f"M0,0 C{n(L * 0.28)},{n(-W)} {n(L * 0.72)},{n(-W)} {n(L)},0 "
            f"C{n(L * 0.72)},{n(W)} {n(L * 0.28)},{n(W)} 0,0Z")


def p_leaf_top(L, W):
    return f"M0,0 C{n(L * 0.28)},{n(-W)} {n(L * 0.72)},{n(-W)} {n(L)},0 Q{n(L * 0.5)},{n(-W * 0.1)} 0,0Z"


def p_midrib(L, W):
    return f"M{n(L * 0.1)},{n(-W * 0.02)} Q{n(L * 0.5)},{n(-W * 0.1)} {n(L * 0.84)},{n(-W * 0.01)}"


def p_ellipse(cx, cy, rx, ry, half=False):
    d = f"M{n(cx)},{n(cy - ry)} A{n(rx)},{n(ry)} 0 0,0 {n(cx)},{n(cy + ry)}"
    if half:
        return d + "Z"
    return d + f" A{n(rx)},{n(ry)} 0 0,0 {n(cx)},{n(cy - ry)}Z"


def p_circle(cx, cy, r, half=False):
    return p_ellipse(cx, cy, r, r, half)


def p_poly(pts):
    return "M" + " L".join(f"{n(x)},{n(y)}" for x, y in pts) + "Z"


def p_sparkle(x, y, s, k=0.16):
    return (f"M{n(x)},{n(y - s)} Q{n(x + s * k)},{n(y - s * k)} {n(x + s)},{n(y)} "
            f"Q{n(x + s * k)},{n(y + s * k)} {n(x)},{n(y + s)} Q{n(x - s * k)},{n(y + s * k)} {n(x - s)},{n(y)} "
            f"Q{n(x - s * k)},{n(y - s * k)} {n(x)},{n(y - s)}Z")


# ---------- building blocks ----------

def leaf(x, y, ang, L, W, col=LEAF, ow=SW_OUT):
    flip = math.cos(math.radians(ang)) < 0
    return F(p_leaf(L, W), col, tr(x, y, ang, flipy=flip), ow=ow,
             det=[DF(p_leaf_top(L, W), tint(col, 0.3)), DS(p_midrib(L, W), shade(col, 0.42), 2.4, 0.8)])


def cotyledons(y, L=38, W=19, ow=5.0):
    c = tint(LEAF, 0.12)
    return [leaf(128, y, -150, L, W, c, ow=ow), leaf(128, y, -30, L, W, c, ow=ow)]


def disc(cx, cy, r, col, ow=SW_OUT):
    det = [DF(p_circle(cx - r * 0.13, cy - r * 0.13, r * 0.82), col),
           DF(p_circle(cx - r * 0.38, cy - r * 0.38, r * 0.2), tint(col, 0.6))]
    return F(p_circle(cx, cy, r), shade(col, 0.16), det=det, ow=ow)


def gem(cx, cy, R, base, facets=8, ow=SW_OUT):
    angs = [math.radians(-90 + 360 * i / facets + 180 / facets) for i in range(facets)]
    outer = [(cx + R * math.cos(a), cy + R * math.sin(a)) for a in angs]
    inner = [(cx + R * 0.5 * math.cos(a), cy + R * 0.5 * math.sin(a)) for a in angs]
    det = []
    for i in range(facets):
        j = (i + 1) % facets
        mid = (angs[i] + angs[j]) / 2 if j else (angs[i] + angs[j] + 2 * math.pi) / 2
        lit = -(math.cos(mid) + math.sin(mid)) / math.sqrt(2)
        tone = tint(base, 0.4 * lit) if lit > 0 else shade(base, -0.28 * lit)
        det.append(DF(p_poly([outer[i], outer[j], inner[j], inner[i]]), tone))
    det.append(DF(p_poly(inner), tint(base, 0.55)))
    for i in range(facets):
        det.append(DS(f"M{n(outer[i][0])},{n(outer[i][1])} L{n(inner[i][0])},{n(inner[i][1])}",
                      shade(base, 0.4), 1.6, 0.7))
    det.append(DS(p_poly(inner), shade(base, 0.4), 1.6, 0.7))
    gx, gy, s = cx - R * 0.16, cy - R * 0.16, R * 0.17
    det.append(DF(p_poly([(gx - s, gy), (gx, gy - s * 1.3), (gx + s * 0.6, gy), (gx, gy + s * 0.7)]), "FFFFFF", 0.9))
    return F(p_poly(outer), base, det=det, ow=ow)


def radial(cx, cy, count, d_full, d_half, col, tier, offset=0.0, t2_det=None):
    parts = []
    for i in range(count):
        a = offset + 360.0 * i / count
        if tier == 3:
            fx = facet_flip(a)
            parts.append(F(d_full, col, tr(cx, cy, a, flipx=fx),
                           det=[DF(d_half, tint(col, 0.45))]))
        else:
            parts.append(F(d_full, col, tr(cx, cy, a), det=list(t2_det or [])))
    return parts


def sparkle(x, y, s, oc):
    d = p_sparkle(x, y, s)
    return (f'<path d="{d}" fill="#{oc}" stroke="#{oc}" stroke-width="4.4" stroke-linejoin="round"/>'
            f'<path d="{d}" fill="#FFFFFF"/>')


def glint(x, y, s):
    return f'<path d="{p_sparkle(x, y, s, 0.14)}" fill="#FFFFFF" opacity="0.95"/>'


# ---------- CLOVER (★1) ----------

def clover(tier):
    p = PAL["clover"]
    if tier == 1:
        g1 = [S("M128,244 C125,222 131,178 128,138", STEM, 8, ow=5)] + cotyledons(208)
        hearts = [F(p_heart(22, 42), p["seed"], tr(128, 136, a), ow=5) for a in (0, 120, 240)]
        return svg(render_group(g1) + render_group(hearts))
    col = p["petal"] if tier == 2 else p["crystal"]
    body = render_group([S("M128,244 C123,212 134,172 128,118", STEM, 8)])
    hearts = radial(128, 114, 3, p_heart(30, 56), p_heart(30, 56, True), col, tier)
    body += render_group(hearts)
    if tier == 2:
        body += render_group([disc(128, 114, 10, p["center"])])
    else:
        body += render_group([gem(128, 114, 13, tint(col, 0.15), 6)])
        body += glint(113, 76, 8) + sparkle(190, 66, 11, shade(col, 0.5))
    return svg(body)


# ---------- DAISY (★1) ----------

def daisy(tier):
    p = PAL["daisy"]
    if tier == 1:
        g1 = [S("M128,244 C125,222 131,196 128,170", STEM, 8, ow=5)] + cotyledons(208)
        bud = F(p_petal(0, 52, 21, **BUD), p["seed"], tr(128, 176), ow=5,
                det=[DF(p_petal(29, 52.7, 12, bk=1.25, by=0.1, tk=0.95, ty=0.2), p["petal"])])
        return svg(render_group(g1) + render_group([bud]))
    col = p["petal"] if tier == 2 else p["crystal"]
    body = render_group([S("M128,244 C124,212 133,170 128,112", STEM, 8), leaf(128, 206, -35, 42, 17)])
    petals = radial(128, 108, 12, p_petal(14, 60, 11, **OVAL), p_petal(14, 60, 11, half=True, **OVAL), col, tier)
    body += render_group(petals)
    if tier == 2:
        body += render_group([disc(128, 108, 19, p["center"])])
    else:
        body += render_group([gem(128, 108, 20, tint(col, 0.1), 8)])
        body += glint(103, 60, 8) + sparkle(192, 54, 11, shade(col, 0.55))
    return svg(body)


# ---------- BUTTERCUP (★1) ----------

def buttercup(tier):
    p = PAL["buttercup"]
    if tier == 1:
        g1 = [S("M128,244 C125,222 131,190 128,164", STEM, 8, ow=5)] + cotyledons(208)
        return svg(render_group(g1) + render_group([disc(128, 152, 22, p["seed"], ow=5)]))
    col = p["petal"] if tier == 2 else p["crystal"]
    body = render_group([S("M128,244 C124,212 132,172 128,114", STEM, 7), leaf(127, 210, -148, 40, 16)])
    petals = radial(128, 110, 5, p_broad(4, 52, 24), p_broad(4, 52, 24, True), col, tier)
    body += render_group(petals)
    if tier == 2:
        body += render_group([disc(128, 110, 13, p["center"])])
    else:
        body += render_group([gem(128, 110, 15, tint(col, 0.15), 6)])
        body += glint(112, 70, 8) + sparkle(192, 66, 11, shade(col, 0.55))
    return svg(body)


# ---------- TULIP (★2) ----------

def tulip(tier):
    p = PAL["tulip"]
    if tier == 1:
        g1 = [S("M128,244 C126,222 130,200 128,178", STEM, 8, ow=5),
              leaf(126, 243, -120, 74, 16, ow=5), leaf(130, 243, -58, 68, 15, ow=5)]
        c = p["seed"]
        bud = F(p_petal(0, 60, 20, **FLAME), c, tr(128, 182), ow=5,
                det=[DF(p_crescent(20, 60), tint(c, 0.4))])
        return svg(render_group(g1) + render_group([bud]))
    col = p["petal"] if tier == 2 else p["crystal"]
    body = render_group([S("M128,244 C126,214 131,182 128,150", STEM, 9),
                         leaf(126, 242, -118, 94, 19), leaf(130, 242, -62, 82, 17)])
    back = shade(col, 0.16)
    petals = []
    for a, W, H, c in ((-20, 28, 72, back), (20, 28, 72, back), (0, 32, 80, col)):
        d = p_petal(0, H, W, **FLAME)
        if tier == 2:
            det = []
            if a == 0:
                det = [DF(p_crescent(W, H), tint(c, 0.4)),
                       DS(f"M0,{n(-H * 0.14)} Q{n(W * 0.1)},{n(-H * 0.45)} 0,{n(-H * 0.74)}", shade(c, 0.3), 2.6, 0.55)]
            petals.append(F(d, c, tr(128, 148, a), det=det))
        else:
            petals.append(F(d, c, tr(128, 148, a, flipx=facet_flip(a)),
                            det=[DF(p_petal(0, H, W, half=True, **FLAME), tint(c, 0.42)),
                                 DS(f"M0,0 L0,{n(-H)}", shade(c, 0.3), 1.6, 0.6)]))
    body += render_group(petals)
    if tier == 3:
        body += glint(114, 100, 9) + sparkle(74, 72, 10, shade(col, 0.5)) + sparkle(186, 86, 12, shade(col, 0.5))
    return svg(body)


# ---------- SUNFLOWER (★2) ----------

def sun_disc(cx, cy, r, center):
    base = shade(center, 0.08)
    inner = tint(center, 0.14)
    det = [DF(p_circle(cx - 2, cy - 2, r * 0.8), inner)]
    for rr, cnt, off in ((r * 0.25, 5, 0), (r * 0.47, 9, 10), (r * 0.66, 13, 5)):
        for k in range(cnt):
            ang = math.radians(360 * k / cnt + off)
            det.append(DF(p_circle(cx - 2 + rr * math.cos(ang), cy - 2 + rr * math.sin(ang), 2.2), shade(center, 0.3)))
    det.append(DF(p_ellipse(cx - r * 0.4, cy - r * 0.45, r * 0.22, r * 0.13), tint(center, 0.45), 0.8))
    return F(p_circle(cx, cy, r), base, det=det, oa=0.5)


def sunflower(tier):
    p = PAL["sunflower"]
    if tier == 1:
        g1 = [S("M128,244 C125,222 131,190 128,160", STEM, 9, ow=5)] + cotyledons(214, 40, 20)
        tips = [F(p_petal(15, 36, 9, **POINTED), p["petal"], tr(128, 152, i * 60 + 30), ow=4) for i in range(6)]
        return svg(render_group(g1) + render_group(tips + [disc(128, 152, 21, p["seed"], ow=5)]))
    col = p["petal"] if tier == 2 else p["crystal"]
    body = render_group([S("M128,244 C121,208 135,164 128,112", STEM, 11),
                         leaf(129, 190, -26, 62, 26), leaf(127, 212, -154, 52, 22)])
    back_col = shade(col, 0.16)
    petals = radial(128, 104, 12, p_petal(22, 67, 12, **POINTED), p_petal(22, 67, 12, half=True, **POINTED),
                    back_col, tier, offset=15)
    petals += radial(128, 104, 12, p_petal(22, 60, 11, **POINTED), p_petal(22, 60, 11, half=True, **POINTED),
                     col, tier)
    body += render_group(petals)
    if tier == 2:
        body += render_group([sun_disc(128, 104, 31, p["center"])])
    else:
        body += render_group([gem(128, 104, 31, tint(col, 0.12), 8)])
        body += glint(104, 54, 9) + sparkle(62, 48, 11, shade(col, 0.55)) + sparkle(198, 152, 10, shade(col, 0.55))
    return svg(body)


# ---------- PUMPKIN (★3) ----------

def lobe_streak(cx, cy, rx, ry):
    return (f"M{n(cx - rx * 0.5)},{n(cy - ry * 0.62)} Q{n(cx - rx * 0.86)},{n(cy)} {n(cx - rx * 0.5)},{n(cy + ry * 0.62)} "
            f"Q{n(cx - rx * 0.64)},{n(cy)} {n(cx - rx * 0.5)},{n(cy - ry * 0.62)}Z")


def pumpkin_body(cx, cy, s, col, tier, ow=SW_OUT):
    lobes = [(-44, 2, 28, 38, 0.18), (44, 2, 28, 38, 0.18), (-22, 1, 32, 44, 0.08), (22, 1, 32, 44, 0.08),
             (0, 0, 30, 46, 0.0)]
    parts = []
    for dx, dy, rx, ry, sh in lobes:
        x, y, rx, ry = cx + dx * s, cy + dy * s, rx * s, ry * s
        c = shade(col, sh) if sh else col
        if tier == 3:
            lit = [(x - rx * 0.62, y - ry * 0.18), (x - rx * 0.12, y - ry * 0.82),
                   (x + rx * 0.18, y - ry * 0.3), (x - rx * 0.2, y + ry * 0.45)]
            dark = [(x + rx * 0.3, y - ry * 0.55), (x + rx * 0.78, y - ry * 0.05),
                    (x + rx * 0.5, y + ry * 0.6), (x + rx * 0.22, y + ry * 0.05)]
            det = [DF(p_poly(lit), tint(c, 0.38)), DF(p_poly(dark), shade(c, 0.14)),
                   DS(p_poly(lit), shade(c, 0.32), 1.6, 0.55), DS(p_poly(dark), shade(c, 0.32), 1.6, 0.45)]
        else:
            det = [DF(lobe_streak(x, y, rx, ry), tint(c, 0.35))] if sh < 0.1 else []
        parts.append(F(p_ellipse(x, y, rx, ry), c, det=det, ow=ow))
    return parts


def pumpkin(tier):
    p = PAL["pumpkin"]
    stem_col = mix(STEM, p["center"], 0.45)
    if tier == 1:
        g1 = [S("M128,244 C126,230 130,208 128,186", STEM, 8, ow=5)] + cotyledons(220)
        body = pumpkin_body(128, 162, 0.52, p["seed"], 2, ow=5)
        top = [S("M128,142 C127,136 129,129 134,124", stem_col, 7, ow=4),
               S("M136,132 C150,128 160,118 155,108 C151,101 143,105 146,112", STEM, 3.4, ow=3.2)]
        return svg(render_group(g1) + render_group(body) + render_group(top))
    col = p["petal"] if tier == 2 else p["crystal"]
    gold = tier == 3
    leaves = [leaf(118, 124, -162, 64, 28), leaf(142, 128, -18, 46, 20)]
    body = pumpkin_body(128, 176, 1.0, col, tier)
    vine_c = GOLD if gold else STEM
    top = [S("M124,130 C110,118 94,110 80,107", vine_c, 3.6),
           S("M128,136 C126,122 131,110 141,100", GOLD if gold else stem_col, 12),
           S("M138,112 C154,112 166,100 162,88 C159,79 148,82 151,91 C153,97 160,96 162,92", vine_c, 3.6)]
    bx, by = 72, 104
    bcol = "FFD24A" if tier == 2 else tint(col, 0.35)
    blossom = radial(bx, by, 5, p_petal(3, 21, 8.5, **POINTED), p_petal(3, 21, 8.5, half=True, **POINTED),
                     bcol, tier)
    for part in blossom:
        part["ow"] = 4.0
    blossom.append(disc(bx, by, 5.5, "F2A61A", ow=3.5) if tier == 2 else gem(bx, by, 6.5, tint(col, 0.4), 6, ow=3.5))
    out = render_group(leaves) + render_group(body) + render_group(top) + render_group(blossom)
    if gold:
        oc = shade(col, 0.5)
        out += (glint(114, 150, 10) + glint(150, 164, 7) + sparkle(44, 156, 11, oc) + sparkle(212, 150, 12, oc)
                + sparkle(192, 64, 9, oc) + sparkle(100, 58, 8, oc))
    return svg(out)


BUILDERS = {"clover": clover, "daisy": daisy, "buttercup": buttercup,
            "tulip": tulip, "sunflower": sunflower, "pumpkin": pumpkin}

for type_id, fn in BUILDERS.items():
    for tier in (1, 2, 3):
        with open(os.path.join(OUT, f"{type_id}_t{tier}.svg"), "w", encoding="utf-8") as fh:
            fh.write(fn(tier))
print("generated", len(BUILDERS) * 3, "svgs ->", OUT)
