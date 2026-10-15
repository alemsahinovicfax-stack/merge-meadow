"""Muzička teorija za music_gen.py: note (MIDI), akordi iz simbola, voicing s glatkim vođenjem
glasova, melodija zapisana po taktovima, mreža vremena (4/4, 3/4, 6/8) i provjera harmonije.

Zapis (season_songs.py):
  akord  "Gmaj7#11", "Em7", "D/F#", "Bb7sus4", "A6/9"; dva u taktu: "Em7@0 A7@2" (@ = dob)
  melodija  "A5:2 F#5:1 r:1"  — nota:trajanje u dobama mjere (6/8 → osmine), r = pauza
"""
import math

NOTE_PC = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}

# intervali od korijena (polutonovi); 14 = 9, 17 = 11, 18 = #11, 21 = 13
CHORD_TYPES = {
    "": (0, 4, 7), "m": (0, 3, 7), "5": (0, 7),
    "6": (0, 4, 7, 9), "m6": (0, 3, 7, 9), "6/9": (0, 4, 7, 9, 14),
    "7": (0, 4, 7, 10), "maj7": (0, 4, 7, 11), "m7": (0, 3, 7, 10), "mmaj7": (0, 3, 7, 11),
    "9": (0, 4, 7, 10, 14), "maj9": (0, 4, 7, 11, 14), "m9": (0, 3, 7, 10, 14),
    "add9": (0, 4, 7, 14), "madd9": (0, 3, 7, 14),
    "sus2": (0, 2, 7), "sus4": (0, 5, 7), "7sus4": (0, 5, 7, 10), "9sus4": (0, 5, 7, 10, 14),
    "maj7#11": (0, 4, 7, 11, 18), "13": (0, 4, 7, 10, 21),
    "7#11": (0, 4, 7, 10, 18),   # lidijski dominantni (tritonusna zamjena u bossi)
    "dim": (0, 3, 6), "m7b5": (0, 3, 6, 10), "aug": (0, 4, 8),
}

# boje koje melodija smije držati na jakoj dobi preko akorda (pored tonova akorda)
TENSIONS = {
    "major": {2, 9},          # 9, 13 (6)
    "minor": {2, 5},          # 9, 11
    "dominant": {2, 9},       # 9, 13
    "sus": {2, 9},
    "dim": set(),
}


def midi(name):
    """'A4' → 69, 'C#5' → 73, 'Bb3' → 58."""
    pc = NOTE_PC[name[0].upper()]
    rest = name[1:]
    while rest and rest[0] in "#b":
        pc += 1 if rest[0] == "#" else -1
        rest = rest[1:]
    return pc + 12 * (int(rest) + 1)


def pc_of(name):
    pc = NOTE_PC[name[0].upper()]
    for ch in name[1:]:
        if ch == "#":
            pc += 1
        elif ch == "b":
            pc -= 1
    return pc % 12


def hz(m):
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


def name_of(m):
    names = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    return "%s%d" % (names[m % 12], m // 12 - 1)


class Chord:
    def __init__(self, symbol):
        self.symbol = symbol
        main, _, bass = symbol.partition("/")
        if bass and not bass[0].isalpha():
            # "6/9" nije slash akord
            main, bass = symbol, ""
        root_len = 1
        while root_len < len(main) and main[root_len] in "#b":
            root_len += 1
        self.root = pc_of(main[:root_len])
        quality = main[root_len:]
        if quality not in CHORD_TYPES:
            raise ValueError("nepoznat akord: %s (%s)" % (symbol, quality))
        self.quality = quality
        self.intervals = CHORD_TYPES[quality]
        self.bass = pc_of(bass) if bass else self.root
        self.pcs = {(self.root + i) % 12 for i in self.intervals}
        if bass:
            self.pcs.add(self.bass)

    @property
    def family(self):
        q = self.quality
        if q in ("dim", "m7b5"):
            return "dim"
        if "sus" in q:
            return "sus"
        if q.startswith("m") and not q.startswith("maj"):
            return "minor"
        if q in ("7", "9", "13", "7#11"):
            return "dominant"
        return "major"

    def allowed(self):
        """Tonovi akorda + boje koje mogu stajati na jakoj dobi."""
        ok = set(self.pcs)
        for t in TENSIONS[self.family]:
            ok.add((self.root + t) % 12)
        if "#11" in self.quality:
            ok.add((self.root + 6) % 12)
        return ok

    def fifth(self):
        if 7 in self.intervals:
            return (self.root + 7) % 12
        if 6 in self.intervals:
            return (self.root + 6) % 12
        if 8 in self.intervals:
            return (self.root + 8) % 12
        return self.root

    def third(self):
        for i in (4, 3, 5, 2):
            if i in self.intervals:
                return (self.root + i) % 12
        return self.root

    def voice_pcs(self, voices=4):
        """Tonovi za voicing: bez kvinte kad ih ima previše (9 / 11 / 13 akordi)."""
        ivs = []
        for i in self.intervals:
            if i % 12 not in ivs:
                ivs.append(i % 12)
        if len(ivs) > voices and 7 in ivs:
            ivs.remove(7)
        if len(ivs) > voices and 0 in ivs:
            ivs.remove(0)  # bez korijena — bas ga svira
        while len(ivs) > voices:
            ivs.pop()
        return [(self.root + i) % 12 for i in ivs]


def place(pc, lo):
    """Najniži MIDI ≥ lo s tom klasom tona."""
    m = lo + ((pc - lo) % 12)
    return m


def voicing(chord, lo=55, hi=76, prev=None, voices=4):
    """Akord u bliskom položaju između lo i hi; od svih inverzija ona najbliža prethodnom
    voicingu (glatko vođenje glasova)."""
    pcs = chord.voice_pcs(voices)
    best, best_cost = None, None
    for rot in range(len(pcs)):
        order = pcs[rot:] + pcs[:rot]
        for base in range(lo, lo + 12):
            notes = []
            cur = place(order[0], base)
            notes.append(cur)
            for pc in order[1:]:
                cur = place(pc, cur + 1)
                notes.append(cur)
            if notes[0] < lo or notes[-1] > hi:
                continue
            if prev:
                cost = sum(abs(a - b) for a, b in zip(sorted(notes), sorted(prev)))
                cost += abs(len(notes) - len(prev)) * 3
            else:
                center = (lo + hi) / 2.0
                cost = abs(sum(notes) / len(notes) - center)
            if best_cost is None or cost < best_cost:
                best, best_cost = notes, cost
            break
    if best is None:
        best = sorted(place(pc, lo) for pc in pcs)
    return best


def spread_voicing(chord, lo=43, hi=72, voices=5):
    """Otvoren položaj (gitara, klavir): korijen dolje, ostali tonovi akorda iznad kvinte."""
    root = place(chord.bass, lo)
    upper = voicing(chord, root + 7, hi, None, voices - 1)
    return [root] + [m for m in upper if m > root]


def stack_voicing(chord, scale_pcs, lo=55, hi=80, voices=4):
    """Kvartalno / pentatonsko slaganje (Lantern): od korijena svaki drugi ton ljestvice —
    otvoren, „istočni" zvuk umjesto terci. Korijen van ljestvice → blizak položaj."""
    sc = sorted(set(scale_pcs))
    if chord.root not in sc:
        return voicing(chord, lo, hi, None, voices)
    k = sc.index(chord.root)
    out = []
    cur = place(chord.root, lo)
    out.append(cur)
    while len(out) < voices:
        k = (k + 2) % len(sc)
        cur = place(sc[k], cur + 1)
        if cur > hi:
            break
        out.append(cur)
    return out


def bass_note(pc, lo=36):
    """Bas u oktavi 2 (C2..B2 = 36..47)."""
    return place(pc, lo)


# ── mjera i vrijeme ───────────────────────────────────────────────────────────

METERS = {
    "4/4": {"beats": 4, "strong": (0, 2), "unit": "q"},
    "3/4": {"beats": 3, "strong": (0,), "unit": "q"},
    "6/8": {"beats": 6, "strong": (0, 3), "unit": "e"},
    # 12/8: četiri „ljuljajuće" dobe po tri osmine (uspavanka); jake 0 i 6
    "12/8": {"beats": 12, "strong": (0, 6), "unit": "e"},
    # 7/8: 2+2+3 (balkanski / bliskoistočni ples); naglasci 0, 2, 4
    "7/8": {"beats": 7, "strong": (0,), "unit": "e"},
}


class Grid:
    """`bpm` broji jedinicu mjere (četvrtina u 4/4 i 3/4, osmina u 6/8). Swing pomjera
    „i" (pola dobe) samo u 4/4 i 3/4."""

    def __init__(self, bpm, bars, meter="4/4", swing=0.5):
        self.bpm = bpm
        self.bars = bars
        self.meter = meter
        self.beats = METERS[meter]["beats"]
        self.strong = METERS[meter]["strong"]
        self.swing = swing if METERS[meter]["unit"] == "q" else 0.5
        self.unit = METERS[meter]["unit"]
        self.beat_sec = 60.0 / bpm
        self.bar_sec = self.beats * self.beat_sec
        self.length = bars * self.bar_sec

    def at(self, bar, beat):
        whole = math.floor(beat + 1e-9)
        frac = beat - whole
        if abs(frac - 0.5) < 1e-6:
            frac = self.swing
        elif abs(frac - 0.25) < 1e-6 and self.swing != 0.5:
            frac = self.swing * 0.5
        elif abs(frac - 0.75) < 1e-6 and self.swing != 0.5:
            frac = self.swing + (1 - self.swing) * 0.5
        return bar * self.bar_sec + (whole + frac) * self.beat_sec

    def sec(self, beats):
        return beats * self.beat_sec


# ── progresija i melodija ─────────────────────────────────────────────────────

def parse_bar_chords(spec):
    """"Em7@0 A7@2" → [(0.0, Chord), (2.0, Chord)]; "Dmaj7" → [(0.0, Chord)]."""
    out = []
    for tok in spec.split():
        sym, _, at = tok.partition("@")
        out.append((float(at) if at else 0.0, Chord(sym)))
    out.sort(key=lambda x: x[0])
    return out


class Progression:
    def __init__(self, bars):
        self.bars = [parse_bar_chords(b) for b in bars]

    def __len__(self):
        return len(self.bars)

    def at(self, bar, beat=0.0):
        bar %= len(self.bars)
        cur = self.bars[bar][0][1]
        for at, ch in self.bars[bar]:
            if at <= beat + 1e-6:
                cur = ch
        return cur

    def segments(self, bar, beats):
        """[(beat_od, beat_do, Chord)] za takt."""
        segs = self.bars[bar % len(self.bars)]
        out = []
        for k, (at, ch) in enumerate(segs):
            end = segs[k + 1][0] if k + 1 < len(segs) else beats
            out.append((at, end, ch))
        return out


def _beats(x):
    """"0.5" ili razlomak "1/3" (triola)."""
    num, _, den = x.partition("/")
    return float(num) / float(den) if den else float(num)


def parse_line_ex(text):
    """Zapis s ukrasima → [{beat, midi|None, dur, tie, grace, slide}].
    "~A5:1"    = klizanje u notu odozdo (flauta, harmonika, lap steel, duduk)
    "B5>A5:1"  = predudar B5 (kratko, prije dobe) pa A5
    "E5:0.5+1" = vezana nota: zauzme 0,5 dobe ovog takta i zvuči još 1 dobu u sljedećem
                 (anticipacija — bossa, country „push"); sljedeći takt počinje sa "=:1"
    "=:1"      = nastavak vezane note (broji se u takt, ne svira)
    "G4:1/3"   = trajanje kao razlomak (triole: melizmi duduka)"""
    notes = []
    t = 0.0
    for tok in text.split():
        name, _, dur = tok.partition(":")
        tie = 0.0
        if "+" in dur:
            dur, _, extra = dur.partition("+")
            tie = _beats(extra)
        d = _beats(dur) if dur else 1.0
        slide = name.startswith("~")
        name = name.lstrip("~")
        grace = None
        if ">" in name:
            g, _, name = name.partition(">")
            grace = midi(g)
        m = None if name in ("r", "-", "=") else midi(name)
        notes.append({"beat": t, "midi": m, "dur": d, "tie": tie, "grace": grace, "slide": slide})
        t += d
    return notes


def parse_line(text):
    """"A5:2 F#5:1 r:1" → [(beat, midi|None, dur)] (ukrasi se ignorišu; dur = dio u ovom taktu)."""
    return [(n["beat"], n["midi"], n["dur"]) for n in parse_line_ex(text)]


def melody_events_ex(bars):
    """{takt: "zapis"} → [(bar, nota-dict)] bez pauza, s ukrasima."""
    items = bars.items() if isinstance(bars, dict) else enumerate(bars)
    out = []
    for bar, text in items:
        if not text:
            continue
        for n in parse_line_ex(text):
            if n["midi"] is not None:
                out.append((int(bar), n))
    out.sort(key=lambda x: (x[0], x[1]["beat"]))
    return out


def melody_events(bars):
    """{takt: "zapis"} ili lista zapisa → [(bar, beat, midi, dur)] bez pauza. Vezana nota
    (anticipacija) se provjerava i kao nota na prvoj dobi sljedećeg takta — mora pripadati
    sljedećem akordu."""
    out = []
    for bar, n in melody_events_ex(bars):
        out.append((bar, n["beat"], n["midi"], n["dur"]))
        if n["tie"]:
            out.append((bar + 1, 0.0, n["midi"], n["tie"]))
    out.sort()
    return out


def bar_lengths_ok(bars, beats):
    """Takt čiji zbir trajanja nije tačna mjera (greška u zapisu)."""
    bad = []
    items = bars.items() if isinstance(bars, dict) else enumerate(bars)
    for bar, text in items:
        if not text:
            continue
        total = sum(d for _, _, d in parse_line(text))
        if abs(total - beats) > 1e-6:
            bad.append((bar, total))
    return bad


def lint(name, prog, events, grid, scale_pcs):
    """Note na jakim dobama moraju biti ton akorda (ili dozvoljena boja); sve note u ljestvici
    ili akordu; duga nota pola tona iznad tona akorda = sudar. Vraća listu upozorenja."""
    warns = []
    for bar, beat, m, dur in events:
        ch = prog.at(bar, beat)
        pc = m % 12
        strong = any(abs(beat - s) < 1e-6 for s in grid.strong)
        where = "%s takt %d doba %s %s (%s)" % (name, bar, beat, name_of(m), ch.symbol)
        if pc not in scale_pcs and pc not in ch.pcs:
            warns.append("van ljestvice: " + where)
        if strong and pc not in ch.allowed():
            warns.append("jaka doba, nije ton akorda: " + where)
        long_dur = 2.0 if grid.unit == "e" else 1.0   # duga nota = bar četvrtina
        if dur >= long_dur and pc not in ch.pcs and pc not in ch.allowed():
            for cpc in ch.pcs:
                if (pc - cpc) % 12 == 1:
                    warns.append("sudar (mala sekunda iznad %s): %s" % (name_of(60 + cpc)[:-1], where))
                    break
                if (cpc - pc) % 12 == 1:
                    warns.append("sudar (mala sekunda ispod %s): %s" % (name_of(60 + cpc)[:-1], where))
                    break
        # nota koja se drži preko promjene akorda u taktu mora pristajati i novom akordu
        for s0, _, ch2 in prog.segments(bar, grid.beats):
            if beat + 1e-6 < s0 < beat + dur - 1e-6 and pc not in ch2.allowed():
                warns.append("držana preko promjene u %s: %s" % (ch2.symbol, where))
    return warns


def scale(tonic, mode):
    steps = {
        "major": (0, 2, 4, 5, 7, 9, 11), "minor": (0, 2, 3, 5, 7, 8, 10),
        "dorian": (0, 2, 3, 5, 7, 9, 10), "lydian": (0, 2, 4, 6, 7, 9, 11),
        "mixolydian": (0, 2, 4, 5, 7, 9, 10), "pentatonic": (0, 2, 4, 7, 9),
        "minor_pentatonic": (0, 3, 5, 7, 10),
    }[mode]
    t = pc_of(tonic)
    return [(t + s) % 12 for s in steps]
