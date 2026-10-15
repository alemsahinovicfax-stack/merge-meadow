"""Koliko su sezonske teme različite? — mjerenje bez sluha.

    python scripts/audio/music_report.py                 # teme iz igre (game/assets/audio/music)
    python scripts/audio/music_report.py <dir>           # probni render
    python scripts/audio/music_report.py --structure     # i strukturna sličnost iz season_songs.py
    python scripts/audio/music_report.py --melody --no-audio   # ritam i oblik melodija (iz zapisa)
    python scripts/audio/music_report.py --harmony --no-audio  # progresije i boje akorda (iz zapisa)

Za svaku temu: boja (log-energija u 20 pojaseva, bez ukupne glasnoće), svjetlina (centroid),
šumovitost (flatness), gustina napada (spectral flux), ritmički profil (autokorelacija napada,
0,1–2 s → tempo / mjera / groove) i dinamika. Pa udaljenost svaka-sa-svakom unutar nivoa
(home ↔ home …) i najbliži par po sezoni — par ispod praga zvuči „isto".
"""
import cmath
import json
import math
import os
import struct
import subprocess
import sys
import tempfile
import wave

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MUSIC_DIR = os.path.join(ROOT, "game", "assets", "audio", "music")
SR = 16000
N = 1024
HOP = 512


def decode(path):
    tmp = os.path.join(tempfile.gettempdir(), "mr_%d_%s.wav" % (os.getpid(), os.path.basename(path)))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", path, "-ac", "1", "-ar", str(SR), tmp], check=True)
    w = wave.open(tmp, "rb")
    n = w.getnframes()
    raw = w.readframes(n)
    w.close()
    os.remove(tmp)
    return [x / 32768.0 for x in struct.unpack("<%dh" % n, raw)]


# ── FFT (iterativni radix-2) ──────────────────────────────────────────────────
_BITREV = None
_TW = None


def _prep():
    global _BITREV, _TW
    bits = int(math.log2(N))
    _BITREV = [int(format(i, "0%db" % bits)[::-1], 2) for i in range(N)]
    _TW = [cmath.exp(-2j * math.pi * k / N) for k in range(N // 2)]


def fft_mag(frame):
    a = [complex(frame[_BITREV[i]]) for i in range(N)]
    size = 2
    while size <= N:
        half = size // 2
        step = N // size
        for start in range(0, N, size):
            k = 0
            for j in range(start, start + half):
                t = _TW[k] * a[j + half]
                u = a[j]
                a[j] = u + t
                a[j + half] = u - t
                k += step
        size *= 2
    return [abs(a[i]) for i in range(N // 2)]


def band_edges(n_bands=20, lo=60.0, hi=7600.0):
    edges = [lo * (hi / lo) ** (i / n_bands) for i in range(n_bands + 1)]
    return [int(round(e * N / SR)) for e in edges]


EDGES = None


def features(path):
    global EDGES
    if _BITREV is None:
        _prep()
    if EDGES is None:
        EDGES = band_edges()
    x = decode(path)
    win = [0.5 - 0.5 * math.cos(2 * math.pi * i / (N - 1)) for i in range(N)]
    bands_acc = [0.0] * (len(EDGES) - 1)
    nb = len(EDGES) - 1
    dct = [[math.cos(math.pi * k * (j + 0.5) / nb) for j in range(nb)] for k in range(13)]
    mf_sum = [0.0] * 12
    mf_sq = [0.0] * 12
    cent, flat, rms_db, flux = [], [], [], []
    prev = None
    frames = 0
    for s in range(0, len(x) - N, HOP):
        fr = [x[s + i] * win[i] for i in range(N)]
        mag = fft_mag(fr)
        pw = [m * m for m in mag]
        tot = sum(pw) + 1e-12
        frames += 1
        fb = []
        for b in range(len(EDGES) - 1):
            e = sum(pw[EDGES[b]:max(EDGES[b] + 1, EDGES[b + 1])])
            bands_acc[b] += e
            fb.append(math.log(e + 1e-9))
        for k in range(1, 13):
            c = sum(dct[k][j] * fb[j] for j in range(nb))
            mf_sum[k - 1] += c
            mf_sq[k - 1] += c * c
        cent.append(sum(i * p for i, p in enumerate(pw)) / tot * SR / N)
        lg = sum(math.log(p + 1e-12) for p in pw[3:]) / (len(pw) - 3)
        flat.append(math.exp(lg) / (tot / len(pw)))
        rms_db.append(10 * math.log10(tot / N + 1e-12))
        if prev is not None:
            flux.append(sum(max(0.0, m - q) for m, q in zip(mag, prev)))
        prev = mag
    total = sum(bands_acc) + 1e-12
    timbre = [10 * math.log10(b / total + 1e-12) for b in bands_acc]
    # gustina napada: vrhovi fluxa iznad pokretnog prosjeka
    mean_f = sum(flux) / len(flux)
    onsets = 0
    for i in range(1, len(flux) - 1):
        lo = max(0, i - 8)
        local = sum(flux[lo:i + 8]) / (min(len(flux), i + 8) - lo)
        if flux[i] > flux[i - 1] and flux[i] >= flux[i + 1] and flux[i] > 1.5 * local and flux[i] > 0.3 * mean_f:
            onsets += 1
    dur = len(x) / SR
    # ritam: autokorelacija fluxa (bez srednje vrijednosti), lagovi 0,1–2 s
    f0 = [v - mean_f for v in flux]
    fps = SR / HOP
    lags = range(int(0.1 * fps), int(2.0 * fps))
    e0 = sum(v * v for v in f0) + 1e-12
    ac = [sum(f0[i] * f0[i + L] for i in range(len(f0) - L)) / e0 for L in lags]
    mf_mean = [v / frames for v in mf_sum]
    mf_std = [math.sqrt(max(0.0, q / frames - m * m)) for q, m in zip(mf_sq, mf_mean)]
    best_lag = max(range(len(ac)), key=lambda i: ac[i]) if ac else 0
    return {
        "timbre": timbre,
        "mfcc": mf_mean,
        "mfcc_std": mf_std,
        "tempo_lag": (best_lag + int(0.1 * fps)) / fps,
        "centroid": sum(cent) / len(cent),
        "flatness": sum(flat) / len(flat),
        "onset_rate": onsets / dur,
        "rhythm": ac,
        "dyn": (max(rms_db) - sorted(rms_db)[len(rms_db) // 10]),
    }


def dist(a, b):
    """Kombinovana udaljenost: boja (MFCC prosjek + promjena) + ritam + svjetlina + gustina + šum
    (svako ~0–1)."""
    t1 = math.sqrt(sum((x - y) ** 2 for x, y in zip(a["mfcc"], b["mfcc"])) / 12.0) / 4.0
    t2 = math.sqrt(sum((x - y) ** 2 for x, y in zip(a["mfcc_std"], b["mfcc_std"])) / 12.0) / 1.5
    t = 0.7 * t1 + 0.3 * t2
    ra, rb = a["rhythm"], b["rhythm"]
    na = math.sqrt(sum(v * v for v in ra)) + 1e-9
    nb = math.sqrt(sum(v * v for v in rb)) + 1e-9
    r = 1.0 - sum(x * y for x, y in zip(ra, rb)) / (na * nb)
    c = abs(math.log(a["centroid"] / b["centroid"])) / 1.0
    o = abs(math.log((a["onset_rate"] + 0.2) / (b["onset_rate"] + 0.2))) / 1.5
    f = abs(math.log((a["flatness"] + 1e-4) / (b["flatness"] + 1e-4))) / 3.0
    parts = {"boja": t, "ritam": r, "svjetlina": c, "gustina": o, "šum": f}
    total = 0.35 * t + 0.3 * r + 0.15 * c + 0.12 * o + 0.08 * f
    return total, parts


SEASONS = ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
           "moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
SHORT = {"country_bloom": "CB", "frost_orchard": "FO", "lantern_meadow": "LM", "amber_canopy": "AC",
         "moonlit_warren": "MW", "coral_tide": "CT", "starfall_glade": "SG", "ember_fen": "EF"}


def audio_report(d, cache_path=None):
    feats = {}
    for s in SEASONS:
        for lv in ("home", "arena", "run"):
            p = os.path.join(d, "%s_%s.ogg" % (s, lv))
            if os.path.exists(p):
                feats[(s, lv)] = features(p)
    summary = {}
    for lv in ("home", "arena", "run"):
        ids = [s for s in SEASONS if (s, lv) in feats]
        print("\n== %s ==  (udaljenost 0 = isto; najbliži par po sezoni)" % lv)
        print("      " + " ".join("%5s" % SHORT[s] for s in ids))
        nearest = {}
        for a in ids:
            row = []
            best = None
            for b in ids:
                if a == b:
                    row.append("   - ")
                    continue
                dd, parts = dist(feats[(a, lv)], feats[(b, lv)])
                row.append("%5.2f" % dd)
                if best is None or dd < best[0]:
                    best = (dd, b, parts)
            nearest[a] = best
            print("%5s " % SHORT[a] + " ".join(row))
        print("najbliži:")
        for a in ids:
            dd, b, parts = nearest[a]
            why = ", ".join("%s %.2f" % (k, v) for k, v in sorted(parts.items(), key=lambda kv: kv[1])[:2])
            print("  %-16s ↔ %-16s %.2f   (najsličnije: %s)" % (a, b, dd, why))
        vals = [nearest[a][0] for a in ids]
        summary[lv] = {"min": round(min(vals), 3), "mean_nearest": round(sum(vals) / len(vals), 3)}
        print("  min %.2f · prosjek najbližih %.2f" % (min(vals), sum(vals) / len(vals)))
        for a in ids:
            f = feats[(a, lv)]
            print("    %-16s centroid %5.0f Hz  napadi %4.1f/s  šum %.3f  dinamika %4.1f dB  puls %.2f s" % (
                a, f["centroid"], f["onset_rate"], f["flatness"], f["dyn"], f["tempo_lag"]))
    if cache_path:
        with open(cache_path, "w", encoding="utf-8") as fh:
            json.dump(summary, fh, indent=1)
    return summary


def structure_report():
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from season_songs import SONGS
    print("\n== struktura: zajednički instrumenti po nivou (Jaccard; 1 = isti set) ==")
    for lv in ("home", "arena", "run"):
        sets = {}
        for s in SEASONS:
            spec = SONGS[s][lv]
            insts = set()
            for p in spec["parts"]:
                if "inst" in p:
                    insts.add(p["inst"])
                if p["kind"] == "drums":
                    insts |= set(p["pattern"].keys())
                    for extra in ("odd_bars", "even_bars"):
                        insts |= set(p.get(extra, {}).keys())
                if p["kind"] == "amb":
                    insts |= {l[0] for l in p["layers"]}
                if p["kind"] == "hits":
                    insts |= {e[2] for e in p["events"]}
                if p["kind"] == "tanpura":
                    insts.add("tanpura")
            sets[s] = insts
        pairs = []
        for i, a in enumerate(SEASONS):
            for b in SEASONS[i + 1:]:
                j = len(sets[a] & sets[b]) / max(1, len(sets[a] | sets[b]))
                pairs.append((j, a, b, sorted(sets[a] & sets[b])))
        pairs.sort(reverse=True)
        print("-- %s: najviše zajedničkog" % lv)
        for j, a, b, common in pairs[:5]:
            print("  %.2f %-15s %-15s %s" % (j, a, b, ", ".join(common)))
        shared = {}
        for s in SEASONS:
            for inst in sets[s]:
                shared.setdefault(inst, []).append(SHORT[s])
        print("  instrumenti u 3+ sezone: " + "; ".join("%s (%s)" % (k, " ".join(v)) for k, v in sorted(shared.items()) if len(v) >= 3))


def exclusivity_report():
    """Koji instrumenti / zvukovi se dijele između sezona (svi nivoi zajedno)."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from season_songs import SONGS
    owners = {}
    for s in SEASONS:
        for lv in ("home", "arena", "run"):
            for p in SONGS[s][lv]["parts"]:
                names = []
                if "inst" in p:
                    names.append(p["inst"])
                if p["kind"] == "drums":
                    names += list(p["pattern"].keys())
                if p["kind"] == "amb":
                    names += [l[0] for l in p["layers"]]
                if p["kind"] == "hits":
                    names += [e[2] for e in p["events"]]
                for n in names:
                    owners.setdefault(n, set()).add(SHORT[s])
    shared = {k: v for k, v in owners.items() if len(v) > 1}
    print()
    print("== ekskluzivnost: %d zvukova, dijeljeno između sezona: %d ==" % (len(owners), len(shared)))
    for k, v in sorted(shared.items(), key=lambda kv: -len(kv[1])):
        print("  %-14s %s" % (k, " ".join(sorted(v))))


# ── melodije iz zapisa: da li sve sezone „pjevaju" istim ritmom? ─────────────────

# Osjećana doba po mjeri, u jedinicama generatora (četvrtina u 4/4 i 3/4, osmina u 6/8 / 12/8 /
# 7/8): ritam se poredi u dobama, pa je jig (♩♪) drugačiji od točkastog ritma (♩.♪).
PULSE = {"4/4": 1.0, "3/4": 1.0, "6/8": 3.0, "12/8": 3.0, "7/8": 2.0}


def _melody_notes(spec):
    """[(t_u_dobama, midi, trajanje_u_dobama, ukras)] svih melodijskih linija teme."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import theory as T
    pulse = PULSE[spec["meter"]]
    # napadi kako se čuju (swing pomjeri „i"), u osjećanim dobama
    g = T.Grid(spec["bpm"], len(spec["chords"]), spec["meter"], spec.get("swing", 0.5))
    lines = []
    for p in spec["parts"]:
        if p["kind"] != "line":
            continue
        notes = []
        for bar, n in T.melody_events_ex(p["notes"]):
            t = g.at(bar, n["beat"]) / g.beat_sec / pulse
            notes.append((t, n["midi"], (n["dur"] + n["tie"]) / pulse, bool(n["slide"] or n["grace"] is not None)))
        lines.append(notes)
    return lines


def melody_features(spec):
    lines = _melody_notes(spec)
    cells = {}
    n_notes = 0
    stats = {"off": 0, "sync": 0, "long": 0, "orn": 0, "rep": 0, "step": 0, "third": 0, "leap": 0}
    iois = []
    lo, hi = 999, 0
    for notes in lines:
        for k, (t, m, d, orn) in enumerate(notes):
            n_notes += 1
            lo, hi = min(lo, m), max(hi, m)
            phase = t - math.floor(t + 1e-9)
            if phase > 1e-6:
                stats["off"] += 1
                if t + d > math.floor(t) + 1 + 1e-6:
                    stats["sync"] += 1          # počne van dobe i preveže se preko sljedeće
            if d >= 2.0 - 1e-6:
                stats["long"] += 1
            if orn:
                stats["orn"] += 1
            if k + 1 < len(notes):
                ioi = notes[k + 1][0] - t
                step = abs(notes[k + 1][1] - m)
                if ioi <= 4.0:
                    iois.append(ioi)
                    stats["rep" if step == 0 else "step" if step <= 2 else "third" if step <= 4 else "leap"] += 1
                if k + 2 < len(notes):
                    ioi2 = notes[k + 2][0] - notes[k + 1][0]
                    if ioi <= 4.0 and ioi2 <= 4.0:
                        key = (round(phase * 12), round(ioi * 12), round(ioi2 * 12))
                        cells[key] = cells.get(key, 0) + 1
    tot = sum(cells.values()) or 1
    cells = {k: v / tot for k, v in cells.items()}
    nn = max(1, n_notes)
    ni = max(1, stats["rep"] + stats["step"] + stats["third"] + stats["leap"])
    return {
        "cells": cells, "notes": n_notes,
        "off": stats["off"] / nn, "sync": stats["sync"] / nn, "long": stats["long"] / nn, "orn": stats["orn"] / nn,
        "ioi": sum(iois) / max(1, len(iois)),
        "steps": [stats[k] / ni for k in ("rep", "step", "third", "leap")],
        "range": hi - lo if n_notes else 0,
    }


def cell_name(key):
    ph, a, b = key
    f = lambda x: ("%g" % (x / 12.0))
    return "%s%s→%s" % ("" if ph == 0 else "(+%s) " % f(ph), f(a), f(b))


def _cos(a, b):
    keys = set(a) | set(b)
    num = sum(a.get(k, 0) * b.get(k, 0) for k in keys)
    da = math.sqrt(sum(v * v for v in a.values()))
    db_ = math.sqrt(sum(v * v for v in b.values()))
    return num / (da * db_) if da and db_ else 0.0


def melody_report():
    """Ritam melodija po nivou: sličnost „ćelija" (dvije uzastopne razmake napada + faza u dobi),
    i ćelije koje dijeli 4+ sezone (= rukopis kompozitora umjesto žanra)."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from season_songs import SONGS
    for lv in ("home", "arena", "run"):
        feats = {s: melody_features(SONGS[s][lv]) for s in SEASONS}
        print("\n== melodije · %s ==  (ritam: 1 = isti ritmički rječnik)" % lv)
        print("       " + "".join("%6s" % SHORT[s] for s in SEASONS))
        sims = {}
        for a in SEASONS:
            row = []
            for b in SEASONS:
                if a == b:
                    row.append("    - ")
                    continue
                c = _cos(feats[a]["cells"], feats[b]["cells"])
                sims[(a, b)] = c
                row.append("%6.2f" % c)
            print("   %s " % SHORT[a] + "".join(row))
        worst = sorted(((sims[(a, b)], a, b) for i, a in enumerate(SEASONS) for b in SEASONS[i + 1:]), reverse=True)
        print("najsličniji ritam: " + ", ".join("%s↔%s %.2f" % (SHORT[a], SHORT[b], c) for c, a, b in worst[:4]))
        usage = {}
        for s in SEASONS:
            for k, v in feats[s]["cells"].items():
                if v >= 0.06:
                    usage.setdefault(k, []).append(SHORT[s])
        common = sorted(((len(v), k, v) for k, v in usage.items() if len(v) >= 4), reverse=True)
        print("ćelije u 4+ sezone (≥6 % melodije): " + ("; ".join("%s [%s]" % (cell_name(k), " ".join(v)) for _, k, v in common) or "nema"))
        for s in SEASONS:
            f = feats[s]
            top = sorted(f["cells"].items(), key=lambda kv: -kv[1])[:2]
            print("    %-15s %3d nota  van dobe %3.0f%%  sinkopa %3.0f%%  duge %3.0f%%  ukras %3.0f%%  razmak %.2f  "
                  "ponov/korak/terca/skok %s  opseg %2d  top: %s" % (
                      s, f["notes"], 100 * f["off"], 100 * f["sync"], 100 * f["long"], 100 * f["orn"], f["ioi"],
                      "/".join("%.0f" % (100 * x) for x in f["steps"]), f["range"],
                      ", ".join("%s %.0f%%" % (cell_name(k), 100 * v) for k, v in top)))


# ── harmonija iz zapisa: ista progresija + iste boje akorda = isti „osjećaj" ───────

ROMAN = ["I", "bII", "II", "bIII", "III", "IV", "#IV", "V", "bVI", "VI", "bVII", "VII"]


def _palette(q):
    if q in ("", "m", "5"):
        return "trozvuk"
    if q in ("7", "7#11"):
        return "dom7"
    if q in ("maj7", "m7", "mmaj7"):
        return "7-ice"
    if q in ("9", "maj9", "m9", "13", "maj7#11", "6/9"):
        return "9-ice"
    if "sus" in q:
        return "sus"
    if q in ("add9", "madd9", "6", "m6"):
        return "add/6"
    return "dim/aug"


def harmony_features(song, spec):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import theory as T
    tonic = T.pc_of(song["key"])
    seq = []
    pal = {}
    for bar in spec["chords"]:
        for _, ch in T.parse_bar_chords(bar):
            deg = (ch.root - tonic) % 12
            minor = ch.family in ("minor", "dim")
            seq.append(ROMAN[deg].lower() if minor else ROMAN[deg])
            k = _palette(ch.quality)
            pal[k] = pal.get(k, 0) + 1
    # uzastopni ponovljeni akord = jedan (harmonski ritam se gleda posebno)
    steps = [c for i, c in enumerate(seq) if i == 0 or c != seq[i - 1]]
    loop = steps + steps[:1]
    trans = {}
    for a, b in zip(loop, loop[1:]):
        trans[(a, b)] = trans.get((a, b), 0) + 1
    tot = sum(pal.values())
    return {"seq": steps, "trans": trans, "pal": {k: v / tot for k, v in pal.items()},
            "rate": len(steps) / max(1, len(spec["chords"]))}


def harmony_report():
    """Progresija (stupnjevi u tonalitetu, I = tonika, mala slova = mol) i boje akorda po nivou;
    sličnost = kosinus prelaza (60 %) + palete boja (40 %)."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from season_songs import SONGS
    for lv in ("home", "arena", "run"):
        feats = {s: harmony_features(SONGS[s], SONGS[s][lv]) for s in SEASONS}
        print("\n== harmonija · %s ==  (1 = ista progresija i boje)" % lv)
        print("       " + "".join("%6s" % SHORT[s] for s in SEASONS))
        sims = {}
        for a in SEASONS:
            row = []
            for b in SEASONS:
                if a == b:
                    row.append("    - ")
                    continue
                c = 0.6 * _cos(feats[a]["trans"], feats[b]["trans"]) + 0.4 * _cos(feats[a]["pal"], feats[b]["pal"])
                sims[(a, b)] = c
                row.append("%6.2f" % c)
            print("   %s " % SHORT[a] + "".join(row))
        worst = sorted(((sims[(a, b)], a, b) for i, a in enumerate(SEASONS) for b in SEASONS[i + 1:]), reverse=True)
        print("najsličnija harmonija: " + ", ".join("%s↔%s %.2f" % (SHORT[a], SHORT[b], c) for c, a, b in worst[:4]))
        for s in SEASONS:
            f = feats[s]
            pal = ", ".join("%s %.0f%%" % (k, 100 * v) for k, v in sorted(f["pal"].items(), key=lambda kv: -kv[1]))
            seq = " ".join(f["seq"][:12]) + (" …" if len(f["seq"]) > 12 else "")
            print("    %-15s %-46s  promjena/takt %.2f  boje: %s" % (s, seq, f["rate"], pal))


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    d = args[0] if args else MUSIC_DIR
    if "--structure" in sys.argv:
        structure_report()
        exclusivity_report()
    if "--melody" in sys.argv:
        melody_report()
    if "--harmony" in sys.argv:
        harmony_report()
    if "--no-audio" not in sys.argv:
        audio_report(d, os.path.join(tempfile.gettempdir(), "music_report_summary.json"))
