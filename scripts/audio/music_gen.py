"""Merge Meadow — sezonska muzika (sinteza): 8 sezona × 3 nivoa → OGG loopovi + katalog.

Pokretanje iz roota repoa:
    python scripts/audio/music_gen.py                     # sve (paralelno)
    python scripts/audio/music_gen.py --only frost_orchard,ember_fen/run
    python scripts/audio/music_gen.py --lint              # samo provjera kompozicija (bez rendera)
    python scripts/audio/music_gen.py --out <dir>         # probni render van igre (katalog netaknut)
    python scripts/audio/music_gen.py --measure           # izmjeri postojeće OGG-ove (i prave) → db
    python scripts/audio/music_report.py [<dir>]          # koliko su sezone različite (mjerenje)
Pa import:  .\\scripts\\godot-import.ps1

Kompozicije: season_songs.py · instrumenti: instruments.py · efekti: fx.py · teorija: theory.py
Dizajn (tabela sezona): docs/04-experience/muzika-sezone.md
Ovo je PRIVREMENA muzika dok ne stigne prava (kompozitor / paket / AI) — vidi muzika-brief.
Pravi fajl istog imena + "source": "real" u katalogu → generator ga ne dira; --measure mu
izmjeri glasnoću (LUFS) i upiše db do cilja nivoa (TARGET_LUFS).

Drugi ciklus (v2): svaki nivo je „groove" — mreža (bpm, mjera), akordi po taktu, dijelovi
(svaki s rasponom taktova, dinamikom, reverb / eho sendom, efektima) i miks sezone (soba,
eho, nagib boje). Run je isti format, samo rjeđi.
"""
import json
import math
import os
import random
import re
import subprocess
import sys
import tempfile
import time
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import dsp  # noqa: E402
from dsp import SR, n_samples, mix_into, normalize, soft_clip, highpass, db, write_wav  # noqa: E402
import fx  # noqa: E402
import instruments as I  # noqa: E402
import theory as T  # noqa: E402
from season_songs import SONGS, SEASON_ORDER, LEVELS  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.join(ROOT, "game", "assets", "audio", "music")
CATALOG = os.path.join(ROOT, "game", "data", "audio", "sounds.json")
RES_DIR = "res://assets/audio/music/"

FOLD_TAIL = 3.5
LOOP_XF = 1.5
# Cilj u fajlu (mono) poslije db pomaka; bus Music na default 80 je −3,9 dB (kvadratna kriva slidera),
# a mono na oba kanala +3 dB → u igri ~−25 / −25 / −28 LUFS (stereo mjerenje snimka).
TARGET_LUFS = {"home": -24.0, "arena": -24.0, "run": -27.0}
# OGG: mono, 24 kHz (instrumenti su ispod ~10 kHz), Vorbis q3 — 24 teme u ~5 MB umjesto ~8.
ENCODE = ["-ac", "1", "-ar", "24000", "-c:a", "libvorbis", "-q:a", "3"]

SEEDED = {"harp", "koto", "guitar", "banjo", "pizz", "pizz_bass", "upright", "guitar_steel", "bouzouki",
          "nylon", "ukulele", "oud", "koto_trem"}
SLIDE = {"harmonica", "lap_steel", "shakuhachi", "tin_whistle", "alto_flute", "duduk"}

DRUMS = {
    "kick": lambda r: I.kick(1.0), "soft_kick": lambda r: I.soft_kick(), "kick808": lambda r: I.kick808(),
    "shaker": lambda r: I.shaker(r.randint(1, 6)), "brush": lambda r: I.brush(r.randint(1, 6)),
    "rim": lambda r: I.rim(), "chick": lambda r: I.chick(r.randint(1, 4)), "hat": lambda r: I.hat_gated(r.randint(1, 4)),
    "tamb": lambda r: I.tambourine(r.randint(1, 4)), "sleigh": lambda r: I.sleigh(r.randint(1, 3)),
    "triangle": lambda r: I.triangle(), "fcym": lambda r: I.finger_cymbal(),
    "conga": lambda r: I.conga(1.0, False, r.randint(1, 3)), "conga_hi": lambda r: I.conga(1.3, False, r.randint(1, 3)),
    "slap": lambda r: I.conga(1.3, True, r.randint(1, 3)), "bongo": lambda r: I.bongo(1.0, r.randint(1, 3)),
    "bongo_hi": lambda r: I.bongo(1.35, r.randint(1, 3)), "guiro": lambda r: I.guiro(r.randint(1, 3)),
    "clap": lambda r: I.clap(r.randint(1, 3)), "ride": lambda r: I.ride(r.randint(1, 3)),
    "taiko": lambda r: I.taiko(1.0, r.randint(1, 3)), "tblock": lambda r: I.temple_block(1.0),
    "tblock_hi": lambda r: I.temple_block(1.32), "bodhran": lambda r: I.bodhran("low", r.randint(1, 3)),
    "bodhran_hi": lambda r: I.bodhran("high", r.randint(1, 3)), "doum": lambda r: I.darbuka("doum", r.randint(1, 3)),
    "tek": lambda r: I.darbuka("tek", r.randint(1, 3)), "ka": lambda r: I.darbuka("ka", r.randint(1, 3)),
    "riq": lambda r: I.riq(r.randint(1, 3)), "woodblock": lambda r: I.woodblock(1.0),
    "snare": lambda r: I.snare_soft(r.randint(1, 4)),
}


def note(inst, m, dur, seed=1, slide=False):
    fn = getattr(I, inst)
    f = I.r3(T.hz(m))
    d = I.r3(max(0.06, dur))
    if inst in SEEDED:
        return fn(f, d, seed % 4 + 1)
    if inst in SLIDE:
        return fn(f, d, bool(slide))
    return fn(f, d)


# ── pomoćno ───────────────────────────────────────────────────────────────────

def stem(sec):
    return [0.0] * n_samples(sec)


def rms_db(sig, n=None):
    s = sig[:n] if n else sig
    if not s:
        return -120.0
    r = math.sqrt(sum(x * x for x in s) / len(s))
    return 20.0 * math.log10(max(r, 1e-9))


# Rijetki događaji (sova, žabe, galebovi, meteori, zvona; glock / trokut u temi): glasnoća se
# mjeri dok zvuče — RMS cijelog loopa bi ih (3 kreketa u 32 s) pojačao do najglasnijeg vrha.
EVENT_AMB = {"owl", "gull", "frog", "meteor", "chimes", "sheep_bells", "sleigh_pass", "woodpecker", "crow"}


def active_rms_db(sig, n=None, win=2048, span_db=20.0):
    """RMS samo prozora koji zvuče (do `span_db` ispod najglasnijeg)."""
    s = sig[:n] if n else sig
    pw = []
    for i in range(0, max(1, len(s) - win), win):
        chunk = s[i:i + win]
        pw.append(sum(x * x for x in chunk) / len(chunk))
    if not pw or max(pw) <= 0:
        return -120.0
    th = max(pw) * 10 ** (-span_db / 10.0)
    act = [p for p in pw if p >= th]
    return 10.0 * math.log10(sum(act) / len(act))


def level_db(sig, sparse, n=None):
    return active_rms_db(sig, n) if sparse else rms_db(sig, n)


def fold(sig, loop_len):
    """Rep poslije kraja loopa (reverb, zadnje note) se doda na početak → loop bez šava."""
    L = n_samples(loop_len)
    out = list(sig[:L]) + [0.0] * max(0, L - len(sig))
    for i in range(L, len(sig)):
        out[i - L] += sig[i]
    return out


def loop_layer(sig, loop_len, xf=LOOP_XF):
    """Kontinualan sloj (vjetar, more, bordun) dužine loop+xf → loop dužine `loop` s pretapanjem
    repa u glavu (snaga konstantna) — šum se na šavu ne udvostruči."""
    L = n_samples(loop_len)
    X = n_samples(xf)
    sig = list(sig) + [0.0] * max(0, L + X - len(sig))
    out = sig[:L]
    for i in range(X):
        k = i / X
        out[i] = sig[i] * math.sqrt(k) + sig[L + i] * math.sqrt(1.0 - k)
    return out


def active(p, bar):
    rng = p.get("active")
    return rng is None or any(a <= bar < b for a, b in rng)


def dyn(p, bar):
    for a, b, g in p.get("dyn", ()):
        if a <= bar < b:
            return g
    return 1.0


def jit(rng, ctx, a):
    """Ljudsko odstupanje napada (± a sekundi) × osjećaj sezone: elektronika 0 (kvantizovano),
    folk / rubato > 1."""
    return rng.uniform(-a, a) * ctx.get("jitter", 1.0)


def hum(rng, ctx, lo, hi):
    """Raspon jačine udarca oko 1 × osjećaj sezone (elektronika ravno, folk naglašeno)."""
    return 1.0 + (rng.uniform(lo, hi) - 1.0) * ctx.get("vel_spread", 1.0)


def sections_for(p, bar):
    for b0, b1, hits in p["sections"]:
        if b0 <= bar < b1:
            return hits
    return []


def voiced(p, ch, prev, scale_pcs):
    style = p.get("style", "close")
    if style == "spread":
        return T.spread_voicing(ch, p.get("lo", 43), p.get("hi", 72), p.get("voices", 5))
    if style == "stack":
        return T.stack_voicing(ch, scale_pcs, p.get("lo", 55), p.get("hi", 80), p.get("voices", 4))
    return T.voicing(ch, p.get("lo", 55), p.get("hi", 76), prev, p.get("voices", 4))


# ── dijelovi aranžmana ────────────────────────────────────────────────────────

def part_block(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        hits = sections_for(p, bar) if "sections" in p else p["hits"]
        for s0, s1, ch in prog.segments(bar, g.beats):
            v = voiced(p, ch, prev, ctx["scale"])
            prev = v
            for beat, dur, vel in hits:
                if not (s0 - 1e-6 <= beat < s1 - 1e-6):
                    continue
                d = min(dur, s1 - beat)
                t0 = g.at(bar, beat)
                for k, m in enumerate(v):
                    mix_into(out, note(p["inst"], m, g.sec(d), k + bar), t0 + k * p.get("strum", 0.0),
                             vel * dyn(p, bar) * hum(rng, ctx, 0.92, 1.05))
    return out


def part_arp(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    cache = {}
    pattern = p["pattern"]
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        pat = p.get("odd_pattern", pattern) if bar % 2 else pattern
        for beat, idx, dur, vel in pat:
            ch = prog.at(bar, beat)
            key = (bar, ch.symbol)
            if key not in cache:
                cache[key] = voiced(p, ch, prev, ctx["scale"])
                prev = cache[key]
            v = cache[key]
            m = v[idx % len(v)] + 12 * (idx // len(v))
            if p.get("octave_tail") and bar % 2 == 1 and beat >= g.beats - 1:
                m += 12
            mix_into(out, note(p["inst"], m, g.sec(dur), int(beat * 2) + bar), g.at(bar, beat) + jit(rng, ctx, 0.004),
                     vel * dyn(p, bar) * hum(rng, ctx, 0.9, 1.06))
    return out


def part_line(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    shift = 12 * p.get("oct", 0)
    for bar, n in T.melody_events_ex(p["notes"]):
        if not active(p, bar):
            continue
        t = g.at(bar, n["beat"]) + ctx.get("lay", 0.0) + jit(rng, ctx, 0.006)
        vel = p.get("vel", 0.8) * dyn(p, bar) * hum(rng, ctx, 0.9, 1.05)
        if n["grace"] is not None:
            mix_into(out, note(p["inst"], n["grace"] + shift, 0.07, bar), max(0.0, t - 0.065), vel * 0.75)
        mix_into(out, note(p["inst"], n["midi"] + shift, g.sec(n["dur"] + n["tie"]), bar, n["slide"]), max(0.0, t), vel)
    return out


def part_strum(g, prog, p, rng, ctx):
    """Gitara / ukulele / buzuki: B = bas žica (korijen), b5 = kvinta, D / U = trzaj dole /
    gore (razmak među žicama), P = sve žice odjednom (bossa), x = prigušen „chop"."""
    out = stem(g.length + FOLD_TAIL)
    cache = {}
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        pat = p.get("odd_pattern", p["pattern"]) if bar % 2 else p["pattern"]
        for beat, kind, dur, vel in pat:
            ch = prog.at(bar, beat)
            if ch.symbol not in cache:
                cache[ch.symbol] = T.spread_voicing(ch, p.get("lo", 40), p.get("hi", 67), p.get("voices", 5))
            v = cache[ch.symbol]
            t0 = g.at(bar, beat) + jit(rng, ctx, 0.004)
            vv = vel * dyn(p, bar) * hum(rng, ctx, 0.9, 1.06)
            d = g.sec(dur)
            if kind == "B":
                mix_into(out, note(p["inst"], v[0], d, bar), t0, vv)
            elif kind == "b5":
                f5 = T.place(ch.fifth(), v[0] - 5 if v[0] - 5 >= p.get("lo", 40) else v[0])
                mix_into(out, note(p["inst"], f5, d, bar + 1), t0, vv)
            elif kind in ("D", "U", "P", "x"):
                strings = v[1:] if len(v) > 2 else v
                if kind == "U":
                    strings = list(reversed(strings[-4:]))
                gap = {"D": 0.009, "U": 0.007, "P": 0.0, "x": 0.004}[kind]
                for k, m in enumerate(strings):
                    dd = 0.07 if kind == "x" else d
                    mix_into(out, note(p["inst"], m, dd, bar + k), t0 + k * gap, vv * (0.55 if kind == "x" else 1.0) * (0.85 + 0.15 * (k % 2)))
    return out


def _bass_pitch(ch, role, lo=36):
    root = T.bass_note(ch.bass, lo)
    if role == "R":
        return root
    if role == "5":
        return T.bass_note(ch.fifth(), lo)
    if role == "8":
        return root + 12
    if role == "3":
        return T.bass_note(ch.third(), lo)
    return root


def part_bass(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    prev_sym = None
    lo = p.get("lo", 36)
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        for beat, role, dur, vel in p["pattern"]:
            ch = prog.at(bar, beat)
            r = role
            if p.get("alt_fifth") and role == "R" and beat == 0 and ch.symbol == prev_sym:
                r = "5"
            m = _bass_pitch(ch, r, lo)
            mix_into(out, note(p["inst"], m, g.sec(dur), bar), g.at(bar, beat), vel * dyn(p, bar) * hum(rng, ctx, 0.93, 1.04))
        prev_sym = prog.at(bar, 0).symbol
        ap = p.get("approach")
        if ap and bar % ap[0] == ap[0] - 1:
            nxt = prog.at(bar + 1, 0)
            m = T.bass_note(nxt.bass, lo) - 1
            beat = ap[1]
            mix_into(out, note(p["inst"], m, g.sec(g.beats - beat), bar), g.at(bar, beat), 0.5 * dyn(p, bar))
    return out


def part_walk(g, prog, p, rng, ctx):
    """Walking bas: korijen, ton akorda, ton akorda, prilaz sljedećem korijenu (pola tona)."""
    out = stem(g.length + FOLD_TAIL)
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        segs = prog.segments(bar, g.beats)
        for k, (s0, s1, ch) in enumerate(segs):
            nxt = segs[k + 1][2] if k + 1 < len(segs) else prog.at(bar + 1, 0)
            root = T.bass_note(ch.bass, 36)
            third = T.place(ch.third(), root)
            fifth = T.place(ch.fifth(), root)
            target = T.bass_note(nxt.bass, 36)
            appr = target - 1 if abs(target - 1 - fifth) <= abs(target + 1 - fifth) else target + 1
            length = int(round(s1 - s0))
            seq = {4: [root, third, fifth, appr], 3: [root, fifth, appr], 2: [root, appr], 1: [root]}.get(length, [root])
            for j, m in enumerate(seq):
                while m > 52:
                    m -= 12
                mix_into(out, note(p["inst"], m, g.sec(0.95), bar * 4 + j), g.at(bar, s0 + j),
                         p.get("vel", 0.85) * (1.0 if j == 0 else 0.85) * dyn(p, bar) * hum(rng, ctx, 0.93, 1.04))
    return out


def part_pad(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    for bar in range(g.bars):
        if not active(p, bar):
            continue
        for s0, s1, ch in prog.segments(bar, g.beats):
            # isti akord u sljedećem taktu = jedna duga nota (pad ne „ponavlja" napad)
            if s0 > 0 or bar == 0 or prog.at(bar - 1, g.beats - 0.01).symbol != ch.symbol or not active(p, bar - 1):
                span = s1 - s0
                b2 = bar + 1
                if s1 >= g.beats:
                    while b2 < g.bars and active(p, b2) and len(prog.segments(b2, g.beats)) == 1 \
                            and prog.at(b2, 0).symbol == ch.symbol:
                        span += g.beats
                        b2 += 1
                v = voiced(p, ch, prev, ctx["scale"])
                prev = v
                for m in v:
                    mix_into(out, note(p["inst"], m, g.sec(span)), g.at(bar, s0), p.get("vel", 0.6) * dyn(p, bar))
    return out


def part_drums(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    every = p.get("every", 1)
    for bar in range(g.bars):
        if bar % every or not active(p, bar):
            continue
        pat = dict(p["pattern"])
        extra = p.get("odd_bars") if bar % 2 == 1 else p.get("even_bars")
        if extra:
            for k, v in extra.items():
                pat[k] = list(pat.get(k, [])) + list(v)
        fills = p.get("fills", {})
        if bar in fills:
            for k, v in fills[bar].items():
                pat[k] = list(pat.get(k, [])) + list(v)
        soft = bar in p.get("soft_bars", [])
        for inst, hits in pat.items():
            if soft and inst in p.get("soft_drop", []):
                continue
            for beat, vel in hits:
                sample = DRUMS[inst](rng)
                mix_into(out, sample, g.at(bar, beat) + jit(rng, ctx, 0.003),
                         vel * (0.65 if soft else 1.0) * dyn(p, bar) * hum(rng, ctx, 0.88, 1.08))
    return out


def part_hits(g, prog, p, rng, ctx):
    out = stem(g.length + FOLD_TAIL)
    for bar, beat, inst, name, dur, vel in p["events"]:
        if inst in DRUMS:
            sample = DRUMS[inst](rng)
        else:
            sample = note(inst, T.midi(name), dur or 0.5)
        mix_into(out, sample, g.at(bar, beat), vel)
    return out


def part_gliss(g, prog, p, rng, ctx):
    """Glissando harfe (Frost): note ljestvice od `from` do `to` za `beats` doba."""
    out = stem(g.length + FOLD_TAIL)
    sc = set(ctx["scale"])
    for bar, beat, a, b, beats, vel in p["events"]:
        lo, hi = T.midi(a), T.midi(b)
        step = 1 if hi >= lo else -1
        notes = [m for m in range(lo, hi + step, step) if m % 12 in sc]
        if not notes:
            continue
        t0 = g.at(bar, beat)
        span = g.sec(beats)
        for k, m in enumerate(notes):
            mix_into(out, note(p.get("inst", "harp"), m, 0.6, k), t0 + span * k / len(notes), vel * (0.7 + 0.3 * k / len(notes)))
    return out


def part_sprinkle(g, prog, p, rng, ctx):
    """Rijetke note (zvjezdice, pahulje, kapi): nasumično iz liste, samo one koje pašu uz akord."""
    out = stem(g.length + FOLD_TAIL)
    t = p.get("start", 0.6)
    lo_gap, hi_gap = p["gap"]
    while t < g.length - 0.6:
        bar = int(t // g.bar_sec)
        beat = (t - bar * g.bar_sec) / g.beat_sec
        if active(p, bar):
            ch = prog.at(bar, beat)
            ok = [n for n in p["notes"] if T.midi(n) % 12 in ch.allowed()] or p["notes"]
            m = T.midi(rng.choice(ok))
            mix_into(out, note(p["inst"], m, p.get("dur", 0.8), int(t)), t, rng.uniform(0.55, 1.0))
        t += rng.uniform(lo_gap, hi_gap)
    return out


PARTS = {"block": part_block, "arp": part_arp, "line": part_line, "strum": part_strum, "bass": part_bass,
         "walk": part_walk, "pad": part_pad, "drums": part_drums, "hits": part_hits, "gliss": part_gliss,
         "sprinkle": part_sprinkle}


AMB = {
    "wind": lambda L, kw: I.wind(L, kw.get("seed", 21), kw.get("cutoff", 650), kw.get("cycles", 3)),
    "breeze": lambda L, kw: I.wind(L, kw.get("seed", 27), kw.get("cutoff", 340), kw.get("cycles", 2)),
    "snow_wind": lambda L, kw: I.snow_wind(L, kw.get("seed", 31)),
    "birds": lambda L, kw: I.birds(L, kw.get("seed", 23), kw.get("count", 7), kw.get("level", 0.08)),
    "crickets": lambda L, kw: I.crickets(L, kw.get("seed", 41), kw.get("voices", 3), kw.get("level", 0.05)),
    "katydids": lambda L, kw: I.katydids(L, kw.get("seed", 221), kw.get("level", 0.04)),
    "owl": lambda L, kw: I.owl(L, kw["at"], kw.get("seed", 51)),
    "waves": lambda L, kw: I.waves(L, kw.get("seed", 61), kw.get("period", 7.0), kw.get("level", 0.5), kw.get("dark", False)),
    "gull": lambda L, kw: I.gull(L, kw["at"], kw.get("seed", 71)),
    "crackle": lambda L, kw: I.crackle(L, kw.get("seed", 81), kw.get("rate", 7.0), kw.get("level", 0.18)),
    "frog": lambda L, kw: I.frog(L, kw["at"], kw.get("seed", 91)),
    "leaves": lambda L, kw: I.leaves(L, kw.get("seed", 101), kw.get("gusts", 5), kw.get("level", 0.1)),
    "chimes": lambda L, kw: I.chimes(L, kw["at"], [T.hz(T.midi(n)) for n in kw["notes"]], kw.get("seed", 111)),
    "sparkles": lambda L, kw: I.sparkles(L, kw.get("seed", 121), kw.get("rate", 1.2), kw.get("lo", 2600),
                                         kw.get("hi", 5200), kw.get("level", 0.035)),
    "meteor": lambda L, kw: I.meteor(L, kw["at"], kw.get("seed", 131)),
    "bubbles": lambda L, kw: I.bubbles(L, kw.get("seed", 141), kw.get("count", 6)),
    "icicles": lambda L, kw: I.icicles(L, kw.get("seed", 181), kw.get("rate", 0.7)),
    "sleigh_pass": lambda L, kw: I.sleigh_pass(L, kw["at"], kw.get("seed", 191), kw.get("length", 6.0)),
    "sheep_bells": lambda L, kw: I.sheep_bells(L, kw["at"], kw.get("seed", 171)),
    "woodpecker": lambda L, kw: I.woodpecker(L, kw["at"], kw.get("seed", 201)),
    "crow": lambda L, kw: I.crow(L, kw["at"], kw.get("seed", 211)),
    "cosmic_hum": lambda L, kw: I.cosmic_hum(L, kw.get("seed", 231)),
    "drips": lambda L, kw: I.drips(L, kw.get("seed", 241), kw.get("rate", 0.5)),
}


def amb_layer(kind, kw, loop_len):
    """Ambijent dužine loop+xf pa pretopljen u loop (događaji poput sove ostaju gdje jesu)."""
    sig = AMB[kind](loop_len + LOOP_XF, kw)
    return loop_layer(sig, loop_len)


# ── render nivoa ──────────────────────────────────────────────────────────────

def apply_fx(sig, chain):
    for name, kw in chain:
        if name == "chorus":
            sig = fx.chorus(sig, **kw)
        elif name == "wow":
            sig = fx.wow(sig, **kw)
        elif name == "tilt":
            sig = fx.tilt(sig, **kw)
        elif name == "drive":
            sig = fx.drive(sig, **kw)
    return sig


def match_rms(sig, ref_db, amount):
    cur = rms_db(sig)
    if cur < -119:
        return sig
    g_ = db(ref_db - cur) * amount
    return [x * g_ for x in sig]


def song_scale(season):
    song = SONGS[season]
    sc = set(T.scale(song["key"], song.get("mode", "major")))
    return sc | {T.pc_of(x) for x in song.get("extra", [])}


def render_level(season, level):
    spec = SONGS[season][level]
    g = T.Grid(spec["bpm"], len(spec["chords"]), spec["meter"], spec.get("swing", 0.5))
    prog = T.Progression(spec["chords"])
    L = g.length
    n_loop = n_samples(L)
    total = L + FOLD_TAIL
    # „osjećaj" sezone (season_songs: feel na pjesmi, nivo ga može pregaziti)
    feel = dict(SONGS[season].get("feel", {}))
    feel.update(spec.get("feel", {}))
    ctx = {"scale": sorted(song_scale(season)), **feel}
    dry = stem(total)
    rev_send = stem(total)
    echo_send = stem(total)
    loops = []
    for p in spec["parts"]:
        rng = random.Random(zlib.crc32(("%s/%s/%s" % (season, level, p["name"])).encode()))
        kind = p["kind"]
        if kind == "amb":
            for kind2, kw in p["layers"]:
                loops.append((amb_layer(kind2, kw, L), p["db"], kind2 in EVENT_AMB))
            continue
        if kind == "drone":
            for name in p["notes"]:
                loops.append((loop_layer(note(p["inst"], T.midi(name), L + LOOP_XF + 0.5), L), p["db"], False))
            continue
        if kind == "tanpura":
            sig = I.tanpura(L + LOOP_XF, T.hz(T.midi(p["root"])), T.hz(T.midi(p["fifth"])), period=p.get("period", 4.4))
            loops.append((loop_layer(sig, L), p["db"], False))
            continue
        sig = PARTS[kind](g, prog, p, rng, ctx)
        # Melodije, rijetki udarci i dijelovi koji sviraju samo u dijelu teme (active) se mjere dok
        # zvuče — inače bi motiv koji svira 4 od 16 taktova ispao 6 dB glasniji od cilja.
        sparse = p.get("sparse", kind in ("hits", "gliss", "line", "sprinkle") or "active" in p)
        cur = level_db(sig, sparse, n_loop)
        if cur > -119:
            sig = [x * db(p["db"] - cur) for x in sig]
        if p.get("fx"):
            sig = apply_fx(sig, p["fx"])
        if p.get("pump"):
            sig = fx.pump(sig, g.beat_sec * p.get("pump_every", 1), p["pump"], p.get("pump_release", 0.22))
        mix_into(dry, sig, 0.0, 1.0)
        r = p.get("rev", 1.0 if p.get("wet", True) else 0.0)
        if r:
            mix_into(rev_send, sig, 0.0, r)
        e = p.get("echo", 0.0)
        if e:
            mix_into(echo_send, sig, 0.0, e)
    mix = spec.get("mix", {})
    ref = rms_db(dry, n_loop)
    out = list(dry)
    ec = mix.get("echo")
    if ec and any(echo_send):
        ret = fx.echo(echo_send, delay=g.sec(ec.get("beats", 0.75)), feedback=ec.get("fb", 0.35), lp=ec.get("lp", 3000.0))
        ret = match_rms(ret[:len(out)], ref, ec.get("amount", 0.3))
        mix_into(out, ret, 0.0, 1.0)
        mix_into(rev_send, ret, 0.0, 0.5)
    rv = mix.get("reverb", {"size": 0.8, "damp": 0.4, "amount": 0.3})
    ret = fx.reverb(rev_send, size=rv.get("size", 0.8), damp=rv.get("damp", 0.4), predelay=rv.get("pre", 0.02),
                    bright=rv.get("bright", 1.0))
    ret = match_rms(ret[:len(out)], ref, rv.get("amount", 0.3))
    mix_into(out, ret, 0.0, 1.0)
    out = fold(out, L)
    for sig, target, sparse in loops:
        cur = level_db(sig, sparse)
        if cur > -119:
            g_ = db(target - cur)
            for i in range(min(len(out), len(sig))):
                out[i] += sig[i] * g_
    return master(out, mix), g.bpm, L


def master(sig, mix):
    sig = highpass(sig, 40.0)
    t = mix.get("tilt")
    if t:
        sig = fx.tilt(sig, t[0], t[1], t[2])
    if mix.get("drive"):
        sig = fx.drive(normalize(sig, -3.0), 1.6, mix["drive"])
    sig = normalize(sig, -3.0)
    sig = soft_clip(sig, 1.25)
    return normalize(sig, -1.0)


# ── provjera kompozicija ──────────────────────────────────────────────────────

def lint_all(only=None):
    warns = []
    for season in SEASON_ORDER:
        sc = song_scale(season)
        for level in LEVELS:
            if only and (season, level) not in only:
                continue
            spec = SONGS[season][level]
            g = T.Grid(spec["bpm"], len(spec["chords"]), spec["meter"], spec.get("swing", 0.5))
            prog = T.Progression(spec["chords"])
            for p in spec["parts"]:
                if p["kind"] != "line":
                    continue
                for bar, total in T.bar_lengths_ok(p["notes"], g.beats):
                    warns.append("%s/%s %s: takt %s ima %s dobâ (treba %d)" % (season, level, p["name"], bar, total, g.beats))
                for bar in p["notes"]:
                    if int(bar) >= g.bars:
                        warns.append("%s/%s %s: takt %s van progresije (%d taktova)" % (season, level, p["name"], bar, g.bars))
                events = T.melody_events(p["notes"])
                warns += T.lint("%s/%s %s" % (season, level, p["name"]), prog, events, g, sc)
    return warns


# ── kodiranje, mjerenje, katalog ──────────────────────────────────────────────

def lufs(path):
    res = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-af", "ebur128=framelog=quiet", "-f", "null", "-"],
                         capture_output=True, text=True)
    m = re.findall(r"I:\s+(-?\d+(?:\.\d+)?) LUFS", res.stderr)
    return float(m[-1]) if m else None


def render_job(job):
    season, level, out_dir = job
    t0 = time.time()
    sig, bpm, L = render_level(season, level)
    tid = "%s_%s" % (season, level)
    tmp = os.path.join(tempfile.gettempdir(), "mm_music_%s.wav" % tid)
    write_wav(tmp, sig)
    out = os.path.join(out_dir, tid + ".ogg")
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", tmp] + ENCODE + [out], check=True)
    os.remove(tmp)
    loud = lufs(out)
    return {"id": tid, "season": season, "level": level, "sec": round(len(sig) / SR, 2), "bpm": bpm,
            "lufs": loud, "kb": os.path.getsize(out) // 1024, "render_s": round(time.time() - t0, 1)}


def load_catalog():
    if os.path.exists(CATALOG):
        with open(CATALOG, encoding="utf-8") as f:
            return json.load(f)
    return {"schema": 1, "sfx": {}, "music": {}}


def save_catalog(cat):
    with open(CATALOG, "w", encoding="utf-8", newline="\n") as f:
        json.dump(cat, f, ensure_ascii=False, indent=1)


def measure_only(music, want):
    for season, level in want:
        tid = "%s_%s" % (season, level)
        entry = music.get(tid)
        if not entry:
            print(tid, "nije u katalogu — preskočeno")
            continue
        path = os.path.join(ROOT, "game", entry["file"].replace("res://", "", 1))
        loud = lufs(path)
        if loud is None:
            print(tid, "ne mogu izmjeriti (ffmpeg?)")
            continue
        entry["lufs"] = loud
        entry["db"] = round(TARGET_LUFS[level] - loud, 1)
        print(f"{tid:24s} {entry.get('source', '?'):5s} {loud} LUFS  db {entry['db']}")


def parse_only(arg):
    want = []
    for tok in arg.split(","):
        season, _, level = tok.partition("/")
        if season not in SONGS:
            raise SystemExit("nepoznata sezona: " + season)
        for lv in ([level] if level else LEVELS):
            want.append((season, lv))
    return want


def main():
    args = sys.argv[1:]
    only = None
    out_dir = None
    jobs = max(1, min(6, (os.cpu_count() or 2) - 1))
    for i, a in enumerate(args):
        if a == "--only":
            only = parse_only(args[i + 1])
        elif a == "--out":
            out_dir = args[i + 1]
        elif a == "--jobs":
            jobs = int(args[i + 1])
    want = only or [(s, lv) for s in SEASON_ORDER for lv in LEVELS]

    warns = lint_all(set(want))
    for w in warns:
        print("LINT", w)
    if "--lint" in args:
        print("lint: %d upozorenja" % len(warns))
        return

    cat = load_catalog()
    music = cat.setdefault("music", {})
    if "--measure" in args:
        measure_only(music, want)
        save_catalog(cat)
        return

    preview = out_dir is not None
    out_dir = out_dir or OUT_DIR
    os.makedirs(out_dir, exist_ok=True)
    todo = []
    for season, level in want:
        tid = "%s_%s" % (season, level)
        if not preview and music.get(tid, {}).get("source") == "real":
            print(tid, "je pravi zvuk — preskočeno")
            continue
        todo.append((season, level, out_dir))
    # najduži prvi (bolje punjenje paralelnih procesa)
    todo.sort(key=lambda j: -len(SONGS[j[0]][j[1]]["chords"]) * SONGS[j[0]][j[1]].get("bpm", 60) ** -1)
    t0 = time.time()
    if jobs > 1 and len(todo) > 1:
        from multiprocessing import Pool
        with Pool(jobs) as pool:
            results = pool.map(render_job, todo, chunksize=1)
    else:
        results = [render_job(j) for j in todo]
    total_kb = 0
    for r in sorted(results, key=lambda r: (SEASON_ORDER.index(r["season"]), LEVELS.index(r["level"]))):
        total_kb += r["kb"]
        print(f"{r['id']:24s} {r['sec']:6.1f}s {r['kb']:5d} KB  {r['lufs']} LUFS  ({r['render_s']} s)")
        if preview:
            continue
        music[r["id"]] = {
            "file": RES_DIR + r["id"] + ".ogg", "source": "synth", "loop": True,
            "season": r["season"], "level": r["level"], "title": SONGS[r["season"]]["title"],
            "sec": r["sec"], "bpm": r["bpm"], "lufs": r["lufs"],
            "db": round(TARGET_LUFS[r["level"]] - r["lufs"], 1) if r["lufs"] is not None else -8.0,
        }
    print("ukupno %d KB, %.0f s" % (total_kb, time.time() - t0))
    if not preview:
        for old in ("meadow", "arena", "run"):
            music.pop(old, None)
        cat["music"] = {k: music[k] for k in sorted(music, key=lambda k: (
            SEASON_ORDER.index(music[k]["season"]) if music[k].get("season") in SEASON_ORDER else 99,
            LEVELS.index(music[k]["level"]) if music[k].get("level") in LEVELS else 9, k))}
        save_catalog(cat)


if __name__ == "__main__":
    main()
