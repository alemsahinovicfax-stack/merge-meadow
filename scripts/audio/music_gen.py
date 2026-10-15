"""Merge Meadow — sezonska muzika (sinteza): 8 sezona × 3 nivoa → OGG loopovi + katalog.

Pokretanje iz roota repoa:
    python scripts/audio/music_gen.py                     # sve (paralelno)
    python scripts/audio/music_gen.py --only frost_orchard,ember_fen/run
    python scripts/audio/music_gen.py --lint              # samo provjera kompozicija (bez rendera)
    python scripts/audio/music_gen.py --out <dir>         # probni render van igre (katalog netaknut)
    python scripts/audio/music_gen.py --measure           # izmjeri postojeće OGG-ove (i prave) → db
Pa import:  .\\scripts\\godot-import.ps1

Kompozicije: season_songs.py · instrumenti: instruments.py · teorija: theory.py
Dizajn (tabela sezona): docs/04-experience/muzika-sezone.md
Ovo je PRIVREMENA muzika dok ne stigne prava (kompozitor / paket / AI) — vidi muzika-brief.
Pravi fajl istog imena + "source": "real" u katalogu → generator ga ne dira; --measure mu
izmjeri glasnoću (LUFS) i upiše db do cilja nivoa (TARGET_LUFS).
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
from dsp import SR, n_samples, mix_into, reverb, normalize, soft_clip, highpass, db, write_wav  # noqa: E402
import instruments as I  # noqa: E402
import theory as T  # noqa: E402
from season_songs import SONGS, SEASON_ORDER, LEVELS  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.join(ROOT, "game", "assets", "audio", "music")
CATALOG = os.path.join(ROOT, "game", "data", "audio", "sounds.json")
RES_DIR = "res://assets/audio/music/"

FOLD_TAIL = 3.0
LOOP_XF = 1.5
# Cilj u fajlu (mono) poslije db pomaka; bus Music na default 80 je −3,9 dB (kvadratna kriva slidera),
# a mono na oba kanala +3 dB → u igri ~−25 / −25 / −28 LUFS (stereo mjerenje snimka).
TARGET_LUFS = {"home": -24.0, "arena": -24.0, "run": -27.0}
# OGG: mono, 24 kHz (instrumenti su ispod ~10 kHz), Vorbis q3 — 24 teme u ~5 MB umjesto ~8.
ENCODE = ["-ac", "1", "-ar", "24000", "-c:a", "libvorbis", "-q:a", "3"]

SEEDED = {"harp", "koto", "guitar", "banjo", "pizz", "pizz_bass", "upright"}

DRUMS = {
    "kick": lambda r: I.kick(1.0), "soft_kick": lambda r: I.soft_kick(),
    "shaker": lambda r: I.shaker(r.randint(1, 6)), "brush": lambda r: I.brush(r.randint(1, 6)),
    "rim": lambda r: I.rim(), "frame": lambda r: I.frame_drum(1.0, r.randint(1, 4)),
    "frame_hi": lambda r: I.frame_drum(1.35, r.randint(1, 4)), "wood": lambda r: I.woodblock(1.0),
    "wood_hi": lambda r: I.woodblock(1.3), "tamb": lambda r: I.tambourine(r.randint(1, 4)),
    "sleigh": lambda r: I.sleigh(r.randint(1, 3)), "triangle": lambda r: I.triangle(),
    "fcym": lambda r: I.finger_cymbal(), "conga": lambda r: I.conga(1.0, False, r.randint(1, 3)),
    "conga_hi": lambda r: I.conga(1.3, False, r.randint(1, 3)), "slap": lambda r: I.conga(1.3, True, r.randint(1, 3)),
    "clap": lambda r: I.clap(r.randint(1, 3)), "ride": lambda r: I.ride(r.randint(1, 3)),
}


def note(inst, m, dur, seed=1):
    fn = getattr(I, inst)
    f = I.r3(T.hz(m))
    d = I.r3(max(0.06, dur))
    if inst in SEEDED:
        return fn(f, d, seed % 4 + 1)
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
EVENT_AMB = {"owl", "gull", "frog", "meteor", "chimes"}


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


def sections_for(p, bar):
    for b0, b1, hits in p["sections"]:
        if b0 <= bar < b1:
            return hits
    return []


# ── dijelovi aranžmana ────────────────────────────────────────────────────────

def part_block(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    for bar in range(g.bars):
        hits = sections_for(p, bar)
        for s0, s1, ch in prog.segments(bar, g.beats):
            v = T.voicing(ch, p["lo"], p["hi"], prev, p.get("voices", 4))
            prev = v
            for beat, dur, vel in hits:
                if not (s0 - 1e-6 <= beat < s1 - 1e-6):
                    continue
                d = min(dur, s1 - beat)
                t0 = g.at(bar, beat)
                for k, m in enumerate(v):
                    mix_into(out, note(p["inst"], m, g.sec(d), k + bar), t0 + k * p.get("strum", 0.0),
                             vel * rng.uniform(0.92, 1.05))
    return out


def part_arp(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    cache = {}
    for bar in range(g.bars):
        for beat, idx, dur, vel in p["pattern"]:
            ch = prog.at(bar, beat)
            key = (bar, ch.symbol)
            if key not in cache:
                cache[key] = T.voicing(ch, p["lo"], p["hi"], prev, p.get("voices", 4))
                prev = cache[key]
            v = cache[key]
            m = v[idx % len(v)] + 12 * (idx // len(v))
            if p.get("octave_tail") and bar % 2 == 1 and beat >= g.beats - 1:
                m += 12
            mix_into(out, note(p["inst"], m, g.sec(dur), int(beat * 2) + bar), g.at(bar, beat) + rng.uniform(-0.004, 0.004),
                     vel * rng.uniform(0.9, 1.06))
    return out


def part_line(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    shift = 12 * p.get("oct", 0)
    for bar, beat, m, dur in T.melody_events(p["notes"]):
        t = g.at(bar, beat) + rng.uniform(-0.006, 0.006)
        mix_into(out, note(p["inst"], m + shift, g.sec(dur), bar), max(0.0, t), p.get("vel", 0.8) * rng.uniform(0.9, 1.05))
    return out


def _bass_pitch(ch, role, nxt=None):
    root = T.bass_note(ch.bass, 36)
    if role == "R":
        return root
    if role == "5":
        return T.bass_note(ch.fifth(), 36)
    if role == "8":
        return root + 12
    if role == "3":
        return T.bass_note(ch.third(), 36)
    if role == "A" and nxt is not None:
        return T.bass_note(nxt.bass, 36) - 1
    return root


def part_bass(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    prev_sym = None
    for bar in range(g.bars):
        for beat, role, dur, vel in p["pattern"]:
            ch = prog.at(bar, beat)
            r = role
            if p.get("alt_fifth") and role == "R" and beat == 0 and ch.symbol == prev_sym:
                r = "5"
            m = _bass_pitch(ch, r)
            mix_into(out, note(p["inst"], m, g.sec(dur), bar), g.at(bar, beat), vel * rng.uniform(0.93, 1.04))
        prev_sym = prog.at(bar, 0).symbol
        ap = p.get("approach")
        if ap and bar % ap[0] == ap[0] - 1:
            nxt = prog.at(bar + 1, 0)
            m = T.bass_note(nxt.bass, 36) - 1
            beat = ap[1]
            mix_into(out, note(p["inst"], m, g.sec(g.beats - beat), bar), g.at(bar, beat), 0.5)
    return out


def part_walk(g, prog, p, rng):
    """Walking bas: korijen, ton akorda, ton akorda, prilaz sljedećem korijenu (pola tona)."""
    out = stem(g.length + FOLD_TAIL)
    for bar in range(g.bars):
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
                         p.get("vel", 0.85) * (1.0 if j == 0 else 0.85) * rng.uniform(0.93, 1.04))
    return out


def part_pad(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    prev = None
    for bar in range(g.bars):
        for s0, s1, ch in prog.segments(bar, g.beats):
            v = T.voicing(ch, p["lo"], p["hi"], prev, p.get("voices", 4))
            prev = v
            for k, m in enumerate(v):
                mix_into(out, note(p["inst"], m, g.sec(s1 - s0)), g.at(bar, s0), p.get("vel", 0.6))
    return out


def part_drums(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    every = p.get("every", 1)
    for bar in range(g.bars):
        if bar % every:
            continue
        pat = dict(p["pattern"])
        extra = p.get("odd_bars") if bar % 2 == 1 else p.get("even_bars")
        if extra:
            for k, v in extra.items():
                pat[k] = list(pat.get(k, [])) + list(v)
        soft = bar in p.get("soft_bars", [])
        for inst, hits in pat.items():
            if soft and inst in p.get("soft_drop", []):
                continue
            for beat, vel in hits:
                sample = DRUMS[inst](rng)
                mix_into(out, sample, g.at(bar, beat) + rng.uniform(-0.003, 0.003),
                         vel * (0.65 if soft else 1.0) * rng.uniform(0.88, 1.08))
    return out


def part_hits(g, prog, p, rng):
    out = stem(g.length + FOLD_TAIL)
    for bar, beat, inst, name, dur, vel in p["events"]:
        if inst in DRUMS:
            sample = DRUMS[inst](rng)
        else:
            sample = note(inst, T.midi(name), dur or 0.5)
        mix_into(out, sample, g.at(bar, beat), vel)
    return out


AMB = {
    "wind": lambda L, kw: I.wind(L, kw.get("seed", 21), kw.get("cutoff", 650), kw.get("cycles", 3)),
    "snow_wind": lambda L, kw: I.snow_wind(L, kw.get("seed", 31)),
    "birds": lambda L, kw: I.birds(L, kw.get("seed", 23), kw.get("count", 7), kw.get("level", 0.08)),
    "crickets": lambda L, kw: I.crickets(L, kw.get("seed", 41), kw.get("voices", 3), kw.get("level", 0.05)),
    "owl": lambda L, kw: I.owl(L, kw["at"], kw.get("seed", 51)),
    "waves": lambda L, kw: I.waves(L, kw.get("seed", 61), kw.get("period", 7.0), kw.get("level", 0.5)),
    "gull": lambda L, kw: I.gull(L, kw["at"], kw.get("seed", 71)),
    "crackle": lambda L, kw: I.crackle(L, kw.get("seed", 81), kw.get("rate", 7.0), kw.get("level", 0.18)),
    "frog": lambda L, kw: I.frog(L, kw["at"], kw.get("seed", 91)),
    "leaves": lambda L, kw: I.leaves(L, kw.get("seed", 101), kw.get("gusts", 5), kw.get("level", 0.1)),
    "chimes": lambda L, kw: I.chimes(L, kw["at"], [T.hz(T.midi(n)) for n in kw["notes"]], kw.get("seed", 111)),
    "sparkles": lambda L, kw: I.sparkles(L, kw.get("seed", 121), kw.get("rate", 1.2), kw.get("lo", 2600),
                                         kw.get("hi", 5200), kw.get("level", 0.035)),
    "meteor": lambda L, kw: I.meteor(L, kw["at"], kw.get("seed", 131)),
    "bubbles": lambda L, kw: I.bubbles(L, kw.get("seed", 141), kw.get("count", 6)),
}


def amb_layer(kind, kw, loop_len):
    """Ambijent dužine loop+xf pa pretopljen u loop (događaji poput sove ostaju gdje jesu)."""
    sig = AMB[kind](loop_len + LOOP_XF, kw)
    return loop_layer(sig, loop_len)


PARTS = {"block": part_block, "arp": part_arp, "line": part_line, "bass": part_bass, "walk": part_walk,
         "pad": part_pad, "drums": part_drums, "hits": part_hits}


# ── render nivoa ──────────────────────────────────────────────────────────────

def master(sig):
    sig = highpass(sig, 45.0)
    sig = normalize(sig, -3.0)
    sig = soft_clip(sig, 1.25)
    return normalize(sig, -1.0)


def render_groove(season, level):
    spec = SONGS[season][level]
    g = T.Grid(spec["bpm"], len(spec["chords"]), spec["meter"], spec.get("swing", 0.5))
    prog = T.Progression(spec["chords"])
    L = g.length
    n_loop = n_samples(L)
    wet_bus = stem(L + FOLD_TAIL)
    dry_bus = stem(L + FOLD_TAIL)
    loops = []
    for k, p in enumerate(spec["parts"]):
        rng = random.Random(zlib.crc32(("%s/%s/%s" % (season, level, p["name"])).encode()))
        if p["kind"] == "amb":
            for kind, kw in p["layers"]:
                sig = amb_layer(kind, kw, L)
                loops.append((sig, p["db"], kind in EVENT_AMB))
            continue
        if p["kind"] == "drone":
            for name in p["notes"]:
                sig = loop_layer(note(p["inst"], T.midi(name), L + LOOP_XF + 0.5), L)
                loops.append((sig, p["db"], False))
            continue
        sig = PARTS[p["kind"]](g, prog, p, rng)
        cur = level_db(sig, p.get("sparse", p["kind"] == "hits"), n_loop)
        if cur > -119:
            sig = [x * db(p["db"] - cur) for x in sig]
        mix_into(wet_bus if p.get("wet", True) else dry_bus, sig, 0.0, 1.0)
    wet, room, damp = spec.get("reverb", (0.28, 0.84, 0.4))
    rev = reverb(wet_bus, wet=wet, room=room, damp=damp, tail=0.0)
    out = fold([a + b for a, b in zip(rev, dry_bus)], L)
    for sig, target, sparse in loops:
        cur = level_db(sig, sparse)
        if cur > -119:
            g_ = db(target - cur)
            for i in range(min(len(out), len(sig))):
                out[i] += sig[i] * g_
    return master(out), g.bpm, L


def render_run(season):
    spec = SONGS[season]["run"]
    L = spec["loop"]
    chords = [T.Chord(s) for s in spec["chords"]]
    seg = L / len(chords)
    total = L + FOLD_TAIL
    wet_bus = stem(total)
    loops = []
    rng = random.Random(zlib.crc32(("%s/run" % season).encode()))

    def pad_stem(pspec):
        out = stem(total)
        prev = None
        for k, ch in enumerate(chords):
            v = T.voicing(ch, pspec["lo"], pspec["hi"], prev, pspec.get("voices", 4))
            prev = v
            for m in v:
                mix_into(out, note(pspec["inst"], m, seg - 0.4), k * seg, 0.6)
        return out

    def add_balanced(sig, target, bus):
        cur = rms_db(sig, n_samples(L))
        if cur > -119:
            mix_into(bus, [x * db(target - cur) for x in sig], 0.0, 1.0)

    add_balanced(pad_stem(spec["pad"]), spec["pad"]["db"], wet_bus)
    if "pad2" in spec:
        add_balanced(pad_stem(spec["pad2"]), spec["pad2"]["db"], wet_bus)
    # motiv home teme: takt k preko pada k (isti akordi kao prvi taktovi teme)
    hk = spec["hook"]
    hook = stem(total)
    busy = []
    for k, text in enumerate(hk["bars"]):
        if not text:
            continue
        t0 = k * seg + hk["offset"]
        length = 0.0
        for beat, m, dur in T.parse_line(text):
            length = max(length, (beat + dur) * hk["beat_sec"])
            if m is None:
                continue
            mix_into(hook, note(hk["inst"], m, dur * hk["beat_sec"], int(beat) + k),
                     t0 + beat * hk["beat_sec"] + rng.uniform(-0.01, 0.01), 0.85 * rng.uniform(0.92, 1.05))
        busy.append((t0 - 0.6, t0 + length + 0.6))
    add_balanced(hook, hk["db"], wet_bus)
    # fragmenti: note iz liste koje pašu uz akord u tom trenutku, van prozora motiva
    fr = spec["frag"]
    frag = stem(total)
    t = 0.8
    while t < L - 1.5:
        if not any(a <= t <= b for a, b in busy):
            ch = chords[min(len(chords) - 1, int(t // seg))]
            ok = [n for n in fr["notes"] if T.midi(n) % 12 in ch.allowed()] or fr["notes"]
            m = T.midi(rng.choice(ok))
            mix_into(frag, note(fr["inst"], m, 0.8, int(t)), t, rng.uniform(0.6, 1.0))
        t += rng.uniform(*fr["gap"])
    add_balanced(frag, fr["db"], wet_bus)
    if "drone" in spec:
        d = spec["drone"]
        for name in d["notes"]:
            loops.append((loop_layer(note(d["inst"], T.midi(name), L + LOOP_XF + 0.5), L), d["db"], False))
    for kind, kw, target in spec["amb"]:
        loops.append((amb_layer(kind, kw, L), target, kind in EVENT_AMB))
    wet, room, damp = spec.get("reverb", (0.45, 0.88, 0.3))
    out = fold(reverb(wet_bus, wet=wet, room=room, damp=damp, tail=0.0), L)
    for sig, target, sparse in loops:
        cur = level_db(sig, sparse)
        if cur > -119:
            g_ = db(target - cur)
            for i in range(min(len(out), len(sig))):
                out[i] += sig[i] * g_
    return master(out), 60, L


# ── provjera kompozicija ──────────────────────────────────────────────────────

def lint_all(only=None):
    warns = []
    for season in SEASON_ORDER:
        song = SONGS[season]
        sc = set(T.scale(song["key"], song.get("mode", "major")))
        sc |= {T.pc_of(x) for x in song.get("extra", [])}
        for level in ("home", "arena"):
            if only and (season, level) not in only:
                continue
            spec = song[level]
            g = T.Grid(spec["bpm"], len(spec["chords"]), spec["meter"], spec.get("swing", 0.5))
            prog = T.Progression(spec["chords"])
            for p in spec["parts"]:
                if p["kind"] == "line":
                    for bar, total in T.bar_lengths_ok(p["notes"], g.beats):
                        warns.append("%s/%s %s: takt %s ima %s dobâ (treba %d)" % (season, level, p["name"], bar, total, g.beats))
                    events = T.melody_events(p["notes"])
                    warns += T.lint("%s/%s %s" % (season, level, p["name"]), prog, events, g, sc)
        if only and (season, "run") not in only:
            continue
        run = song["run"]
        chords = [T.Chord(s) for s in run["chords"]]
        seg = run["loop"] / len(chords)
        hk = run["hook"]
        for k, text in enumerate(hk["bars"]):
            ch = chords[k % len(chords)]
            for beat, m, dur in T.parse_line(text):
                if m is None:
                    continue
                if m % 12 not in ch.allowed() and dur * hk["beat_sec"] >= 0.5:
                    warns.append("%s/run hook takt %d %s nije u %s" % (season, k, T.name_of(m), ch.symbol))
                if m % 12 not in sc and m % 12 not in ch.pcs:
                    warns.append("%s/run hook takt %d %s van ljestvice" % (season, k, T.name_of(m)))
                if hk["offset"] + (beat + dur) * hk["beat_sec"] > seg:
                    warns.append("%s/run hook takt %d prelazi u sljedeći akord" % (season, k))
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
    if level == "run":
        sig, bpm, L = render_run(season)
    else:
        sig, bpm, L = render_groove(season, level)
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
    t0 = time.time()
    if jobs > 1 and len(todo) > 1:
        from multiprocessing import Pool
        with Pool(jobs) as pool:
            results = pool.map(render_job, todo, chunksize=1)
    else:
        results = [render_job(j) for j in todo]
    total_kb = 0
    for r in results:
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
