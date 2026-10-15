"""Merge Meadow — sezonska muzika (drugi ciklus): 8 sezona × 3 nivoa (home = hub, arena, run).

Cilj drugog ciklusa: da nijedna sezona ne zvuči kao druga. Svaka ima SVOJ žanr, svoje
instrumente (nijedan melodijski instrument se ne dijeli između sezona), svoj ritam, mjeru,
formu i „sobu" (miks). Tonaliteti i motivi iz prvog ciklusa ostaju — Arena i run i dalje
citiraju home motiv, pa se sezona prepozna.

  Country Bloom  country / bluegrass       harmonika, lap steel (dobro), čelična gitara, bendžo, kit
  Frost Orchard  zimski klasični valcer    celesta, staklena harmonika, harfa, gudači tremolo, praporci
  Lantern Meadow japanski festival lampi   shakuhachi, koto, sho, hramsko zvono, taiko (pentatonika)
  Amber Canopy   keltski folk (6/8, jig)   tin whistle, harmonika (akordeon), buzuki, violina, bodhrán
  Moonlit Warren uspavanka 12/8 + noćni jazz  muzička kutija, filcani klavir, hor „ooh", vibrafon, kontrabas
  Coral Tide     bossa nova + calypso      alt flauta, najlon gitara, steel pan, ukulele, konge
  Starfall Glade elektronika (lidijski)    supersaw (pumpa), arpeđo, 808, sub, sintisajzerski hor
  Ember Fen      modalni „world" (dorijski, Arena 7/8)  duduk, tanpura, handpan, oud, darbuka

Zapis (theory.py): akordi po taktu ("Em7@0 A7@2"), melodija {takt: "A5:2 ~F#5:1 B5>A5:1"}
(~ = klizanje u notu, X>Y = predudar, "E5:0.5+1" + sljedeći takt "=:1" = vezana nota preko
takta, "G4:1/3" = triola). Dijelovi (music_gen.py): block, arp, line, strum, bass, walk, pad,
drums, hits, gliss, sprinkle, drone, tanpura, amb — svaki može imati active=[(od, do)] taktove,
dyn=[(od, do, ×)], rev / echo send, fx, pump. „feel" (pjesma ili nivo): jitter / vel_spread /
lay — kvantizovano (elektronika) do labavo (folk), jazz melodija kasni iza dobe.

Treći sloj razlikovanja (ciklus 2, runde 6–8) — ne samo instrumenti nego i „rukopis":
  ritam melodije po žanru   music_report.py --melody   (country push, valcer, shakuhachi ma,
                            hemiola, bossa anticipacije, calypso 3+3+2, tresillo, duduk triole)
  harmonija po žanru        music_report.py --harmony  (country II7, klasični V/V, royal road,
                            bVII, pedal + iv, tritonusna zamjena, lidijsko I–II)
Dizajn: docs/04-experience/muzika-sezone.md
"""


def P(kind, name, db, **kw):
    d = {"kind": kind, "name": name, "db": db}
    d.update(kw)
    return d


def eighths(beats=4, strong=0.5, weak=0.3):
    return [(k * 0.5, strong if k % 2 == 0 else weak) for k in range(beats * 2)]


def arp(pattern, dur=0.5, vel=0.6, accent=(0,)):
    return [(b, i, dur, vel * (1.15 if b in accent else 1.0)) for b, i in pattern]


def shift(notes, n):
    return {int(k) + n: v for k, v in notes.items()}


def run_bars(*chords, each=2):
    out = []
    for c in chords:
        out += [c] * each
    return out


SONGS = {}

# ═══ 1 · COUNTRY BLOOM — „Sunny Pasture" · country / bluegrass ══════════════════
CB_MELODY = {
    0: "r:0.5 C5:0.5 C5:0.5 A4:0.5 C5:1 D5:0.5 C5:0.5", 1: "A4:1 G4:0.5 A4:0.5 ~C5:1 r:1",
    2: "r:0.5 F5:0.5 F5:0.5 D5:0.5 ~F5:1 D5:0.5 C5:0.5", 3: "Bb4:1 A4:0.5 Bb4:0.5 ~G4:2",
    4: "r:0.5 C5:0.5 C5:0.5 A4:0.5 C5:1 F5:0.5 E5:0.5", 5: "D5:1 C5:0.5 A4:0.5 ~C5:1 r:1",
    6: "B4:0.5 A4:0.5 G4:0.5 F4:0.5 G4:1 B4:0.5 C5:0.5+1", 7: "=:1 Bb4:0.5 G4:0.5 ~E4:1 r:1",
    12: "r:0.5 D5:0.5 D5:0.5 Bb4:0.5 D5:1 G5:0.5 F5:0.5",
    13: "D5:1 C5:0.5 A4:0.5 ~G4:1 A4:0.5 Bb4:0.5",
    14: "C5:0.5 A4:0.5 C5:0.5 A4:0.5 G4:1 F4:0.5 G4:0.5+1", 15: "=:1 E4:0.5 G4:0.5 ~Bb4:1 r:1"}
SONGS["country_bloom"] = {
    "title": "Sunny Pasture", "key": "F", "mode": "major",
    "feel": {"jitter": 1.6, "vel_spread": 1.4},   # živi bend, labavo
    "home": {
        "bpm": 100, "meter": "4/4", "swing": 0.5,
        "chords": ["F", "F", "Bb", "Bb@0 C7@2", "F", "D7", "G7", "C7",
                   "Bb", "F", "G7", "C7", "Bb", "F", "F@0 C7@2", "C7"],
        "mix": {"reverb": {"size": 0.45, "damp": 0.55, "pre": 0.012, "amount": 0.22},
                "tilt": (900, 0.0, 1.0), "drive": 0.15},
        "parts": [
            P("line", "harmonica", -21.0, inst="harmonica", vel=0.85, rev=0.5, notes=CB_MELODY),
            P("line", "steel", -21.5, inst="lap_steel", vel=0.85, rev=0.7, notes={
                8: "~D5:3 C5:0.5 Bb4:0.5", 9: "~C5:2 r:1 A4:0.5 Bb4:0.5", 10: "~B4:3 A4:0.5 G4:0.5", 11: "~E5:2 r:2"}),
            P("line", "steel_bed", -30.0, inst="lap_steel", vel=0.6, rev=0.8, notes={
                12: "~D4:4", 13: "~F4:4", 14: "~F4:2 E4:2", 15: "~E4:4"}),
            P("strum", "guitar", -24.0, inst="guitar_steel", lo=40, hi=67, rev=0.35,
              pattern=[(0, "B", 1.0, 0.8), (1, "D", 0.5, 0.55), (1.5, "U", 0.4, 0.4),
                       (2, "b5", 1.0, 0.7), (3, "D", 0.5, 0.55), (3.5, "U", 0.4, 0.4)]),
            P("bass", "bass", -27.0, inst="bass_round", rev=0.1, approach=(4, 3.5),
              pattern=[(0, "R", 1.4, 0.9), (2, "5", 0.9, 0.7)]),
            P("drums", "kit", -30.0, rev=0.15,
              pattern={"kick": [(0, 0.6), (2, 0.5)], "snare": [(1, 0.45), (3, 0.45)],
                       "chick": [(k * 0.5, 0.16 if k % 2 else 0.22) for k in range(8)]},
              fills={7: {"snare": [(3.25, 0.3), (3.5, 0.35), (3.75, 0.4)]},
                     15: {"snare": [(2.5, 0.3), (3, 0.35), (3.25, 0.35), (3.5, 0.4), (3.75, 0.45)]}}),
            P("amb", "birds", -45.0, layers=[("birds", {"count": 5, "level": 0.08})]),
        ],
    },
    "arena": {
        "bpm": 132, "meter": "4/4", "swing": 0.5,
        "chords": ["C", "C", "F", "G", "C", "G", "F", "G",
                   "C@0 F@2", "F", "C", "G", "C@0 F@2", "F", "F@0 C@2", "G7"],
        "mix": {"reverb": {"size": 0.4, "damp": 0.6, "pre": 0.01, "amount": 0.18}, "tilt": (900, 0.5, 1.0)},
        "parts": [
            P("arp", "banjo", -22.0, inst="banjo", style="spread", lo=55, hi=77, voices=5, rev=0.3,
              pattern=[(0, 0, 0.5, 0.7), (0.5, 2, 0.5, 0.5), (1, 4, 0.5, 0.55), (1.5, 1, 0.5, 0.5),
                       (2, 3, 0.5, 0.6), (2.5, 4, 0.5, 0.5), (3, 2, 0.5, 0.55), (3.5, 4, 0.5, 0.5)]),
            P("strum", "guitar", -27.0, inst="guitar_steel", lo=40, hi=67, rev=0.3,
              pattern=[(0, "B", 0.9, 0.8), (1, "D", 0.4, 0.5), (2, "b5", 0.9, 0.7), (3, "D", 0.4, 0.5)]),
            P("line", "lead", -24.0, inst="harmonica", vel=0.9, rev=0.45, notes={
                8: "E5:0.5 A5:0.5 E5:0.5 C5:0.5 A4:0.5 C5:0.5 E5:0.5 A5:0.5",
                9: "F5:0.5 E5:0.5 C5:0.5 A4:0.5 F4:1 A4:0.5 C5:0.5+1",
                10: "=:1 E5:0.5 D5:0.5 C5:0.5 E5:0.5 G5:0.5 E5:0.5", 11: "D5:1 B4:0.5 G4:0.5 A4:0.5 B4:0.5 D5:1",
                12: "E5:0.5 E5:0.5 C5:0.5 E5:0.5 A5:1 G5:0.5 E5:0.5",
                13: "F5:0.5 F5:0.5 C5:0.5 F5:0.5 A5:1 G5:0.5 F5:0.5+1", 14: "=:1 E5:0.5 D5:0.5 C5:1 A4:0.5 C5:0.5",
                15: "B4:0.5 D5:0.5 G5:0.5 F5:0.5 D5:1 B4:1"}),
            P("line", "dobro", -26.0, inst="lap_steel", vel=0.8, rev=0.55, notes={
                4: "r:0.5 E5:0.5 E5:0.5 C5:0.5 E5:1 G5:0.5 E5:0.5", 5: "B4:1 G4:0.5 E4:0.5 ~G4:1 r:1",
                6: "r:0.5 A4:0.5 A4:0.5 F4:0.5 A4:1 C5:0.5 A4:0.5", 7: "B4:1 G4:0.5 B4:0.5 ~D5:1 r:1"}),
            P("bass", "bass", -26.0, inst="bass_round", rev=0.1, approach=(2, 3.5),
              pattern=[(0, "R", 0.9, 0.9), (2, "5", 0.9, 0.75)]),
            P("drums", "kit", -28.0, rev=0.12,
              pattern={"kick": [(0, 0.6), (2, 0.55)], "snare": [(k * 0.5, 0.42 if k % 2 else 0.22) for k in range(8)],
                       "chick": [(1, 0.2), (3, 0.2)]},
              fills={7: {"snare": [(3.25, 0.4), (3.75, 0.45)]}, 15: {"snare": [(3, 0.4), (3.25, 0.45), (3.5, 0.5), (3.75, 0.55)]}}),
        ],
    },
    "run": {
        "bpm": 84, "meter": "4/4",
        "chords": run_bars("F6", "Bb", "F6", "C7", each=3),
        "mix": {"reverb": {"size": 0.62, "damp": 0.6, "pre": 0.02, "amount": 0.3}, "tilt": (900, 0.5, 0.5)},
        "parts": [
            P("strum", "walk", -26.5, inst="guitar_steel", lo=40, hi=67, rev=0.5,
              pattern=[(0, "B", 1.0, 0.6), (1, "D", 0.6, 0.4), (2, "b5", 1.0, 0.5), (3, "D", 0.6, 0.4)]),
            P("pad", "harmonium", -28.0, inst="harmonium", lo=53, hi=72, voices=4, rev=0.6),
            P("line", "steel", -29.0, inst="lap_steel", vel=0.85, rev=0.8, notes={
                0: "r:0.5 C5:0.5 C5:0.5 A4:0.5 ~C5:1 D5:0.5 C5:0.5", 3: "~D5:2 C5:0.5 D5:0.5 r:1",
                6: "r:0.5 F5:0.5 F5:0.5 D5:0.5 ~F5:1 D5:0.5 C5:0.5", 9: "~C5:2 Bb4:0.5 A4:0.5 ~G4:1"}),
            P("amb", "fields", -37.0, layers=[("birds", {"count": 7, "level": 0.08})]),
            P("amb", "wind", -45.0, layers=[("wind", {"cutoff": 650, "cycles": 3})]),
            P("amb", "bells", -34.0, layers=[("sheep_bells", {"at": 9.0}), ("sheep_bells", {"at": 25.0, "seed": 173})]),
        ],
    },
}

# ═══ 2 · FROST ORCHARD — „Silver Waltz" · zimski klasični valcer ════════════════
FO_MELODY = {
    0: "A5:3+1", 1: "=:1 F#5:1 A5:1", 2: "D6:3", 3: "C#6>D6:2 C#6:1", 4: "A5:3+1", 5: "=:1 F#5:1 A5:1",
    6: "B5>G#5:2 B5:1", 7: "E6:2 C#6:1", 8: "D6:3", 9: "C#6:2 A5:1", 10: "B5:1 G5:1 E5:1",
    11: "G5>F#5:2 E5:1", 12: "F#5:3+1", 13: "=:1 E5:1 C#6:1", 14: "B5:2 A5:1", 15: "D5:3"}
FO_CHORDS = ["D", "D", "G", "A7sus4@0 A7@2", "D", "D/F#", "E7", "A7",
             "G", "F#m", "Em", "A7", "D", "Gmaj7#11", "Em@0 A7@2", "D"]
SONGS["frost_orchard"] = {
    "title": "Silver Waltz", "key": "D", "mode": "major", "extra": ["G#"],
    "feel": {"jitter": 0.8, "vel_spread": 0.9},   # uredan klasični ansambl
    "home": {
        "bpm": 132, "meter": "3/4",
        "chords": FO_CHORDS + FO_CHORDS,
        "mix": {"reverb": {"size": 0.88, "damp": 0.2, "pre": 0.03, "amount": 0.42, "bright": 1.2},
                "tilt": (1500, -1.0, 3.0)},
        "parts": [
            P("line", "celesta", -21.0, inst="celesta", vel=0.85, rev=0.8, notes=FO_MELODY),
            P("line", "glass", -21.0, inst="glass_harmonica", vel=0.85, rev=0.8, notes=shift(FO_MELODY, 16)),
            P("arp", "sparkle", -30.0, inst="celesta", lo=79, hi=94, voices=3, rev=0.9, active=[(24, 32)],
              pattern=[(0, 0, 0.5, 0.55), (0.5, 1, 0.5, 0.45), (1, 2, 0.5, 0.5), (1.5, 1, 0.5, 0.45), (2, 2, 0.5, 0.5), (2.5, 0, 0.5, 0.4)]),
            P("block", "harp", -26.0, inst="harp", lo=59, hi=74, voices=3, strum=0.014, rev=0.7,
              hits=[(1, 0.8, 0.5), (2, 0.8, 0.42)]),
            P("bass", "pizz", -28.0, inst="pizz_bass", rev=0.5, pattern=[(0, "R", 1.0, 0.95)], alt_fifth=True),
            P("pad", "strings", -30.0, inst="string_trem", lo=62, hi=81, voices=3, vel=0.6, rev=0.8, active=[(16, 32)]),
            P("drums", "sleigh", -36.0, rev=0.6, sparse=True, active=[(16, 32)], pattern={"sleigh": [(0, 0.4)]}),
            P("hits", "triangle", -34.0, events=[(0, 0, "triangle", None, 0, 0.8), (8, 0, "triangle", None, 0, 0.7),
                                                  (16, 0, "triangle", None, 0, 0.8), (24, 0, "triangle", None, 0, 0.7)]),
            P("gliss", "harp_gliss", -30.0, inst="harp", rev=0.9,
              events=[(15, 1.0, "D5", "D7", 2.0, 0.6), (31, 1.0, "A6", "D5", 2.0, 0.5)]),
            P("amb", "wind", -45.0, layers=[("snow_wind", {})]),
        ],
    },
    "arena": {
        "bpm": 112, "meter": "4/4",
        "chords": ["D", "D", "A7", "D", "D", "G", "Em", "A7",
                   "G", "A", "A7", "Bm", "E7", "A7", "D@0 G@2", "A7"],
        "mix": {"reverb": {"size": 0.75, "damp": 0.25, "pre": 0.02, "amount": 0.32, "bright": 1.15},
                "tilt": (1500, -0.5, 2.0)},
        "parts": [
            P("bass", "pizz", -25.0, inst="pizz_bass", rev=0.4, pattern=[(0, "R", 0.9, 0.95), (2, "5", 0.9, 0.8)]),
            P("block", "pizz_chords", -25.0, inst="pizz", lo=60, hi=76, voices=3, rev=0.5,
              hits=[(1, 0.4, 0.6), (3, 0.4, 0.6)]),
            P("line", "lead", -23.0, inst="celesta", vel=0.9, rev=0.7, notes={
                8: "B5:0.75 A5:0.25 B5:0.5 D6:0.5 B5:1 G5:1", 9: "C#6:0.75 B5:0.25 C#6:0.5 E6:0.5 C#6:1 A5:1",
                10: "A5:0.5 F#5:0.5 A5:0.5 C#6:0.5 E6:1 C#6:1", 11: "D6:0.75 C#6:0.25 B5:1 F#5:1 r:1",
                12: "D6:0.75 B5:0.25 G#5:0.5 B5:0.5 D6:1 E6:1", 13: "E6:0.75 C#6:0.25 A5:0.5 C#6:0.5 E6:1 A5:1",
                14: "F#5:0.5 A5:0.5 D6:1 G5:0.75 B5:0.25 E6:1", 15: "C#6:0.5 E6:0.5 A5:0.5 G5:0.5 E5:1 r:1"}),
            P("line", "lead_glock", -31.0, inst="glock", vel=0.6, oct=1, rev=0.8, notes={
                8: "B5:0.75 A5:0.25 B5:0.5 D6:0.5 B5:1 G5:1", 9: "C#6:0.75 B5:0.25 C#6:0.5 E6:0.5 C#6:1 A5:1",
                12: "D6:0.75 B5:0.25 G#5:0.5 B5:0.5 D6:1 E6:1", 13: "E6:0.75 C#6:0.25 A5:0.5 C#6:0.5 E6:1 A5:1"}),
            P("line", "hook", -26.0, inst="glass_harmonica", vel=0.8, rev=0.8, notes={
                4: "A5:2 r:1 F#5:0.5 A5:0.5", 5: "D6:2 B5:1 r:1", 6: "B5:2 G5:1 E5:1", 7: "C#6:2 E6:2"}),
            P("drums", "bells", -29.0, rev=0.4,
              pattern={"sleigh": [(k * 0.5, 0.18 if k % 2 else 0.3) for k in range(8)]},
              even_bars={"triangle": [(0, 0.35)]}),
        ],
    },
    "run": {
        "bpm": 72, "meter": "3/4",
        "chords": ["Dadd9", "D/C#", "Bm7", "Bm7/A", "Gmaj7", "Gm6",
                   "D/A", "A7sus4", "A7", "Dadd9", "Gm6/D", "Dadd9"],
        "mix": {"reverb": {"size": 0.92, "damp": 0.15, "pre": 0.04, "amount": 0.5, "bright": 1.3},
                "tilt": (1500, -1.5, 3.0)},
        "parts": [
            P("arp", "twinkle", -27.0, inst="celesta", lo=74, hi=93, voices=4, rev=0.9,
              pattern=[(k * 0.25, [0, 1, 2, 3, 2, 1, 2, 3, 1, 2, 3, 2][k], 0.3, 0.5 if k % 4 else 0.62) for k in range(12)]),
            P("pad", "glass", -27.0, inst="glass_harmonica", lo=62, hi=81, voices=4, rev=0.9),
            P("pad", "strings", -33.0, inst="string_trem", lo=50, hi=66, voices=3, rev=0.8),
            P("line", "hook", -29.0, inst="celesta", vel=0.85, rev=0.9, oct=-1, notes={
                0: "A5:3", 3: "r:1 F#5:1 A5:1", 6: "D6:3", 9: "C#6>D6:2 A5:1"}),
            P("amb", "wind", -43.0, layers=[("snow_wind", {})]),
            P("amb", "ice", -38.0, layers=[("icicles", {"rate": 0.6})]),
            P("amb", "sleigh", -33.0, layers=[("sleigh_pass", {"at": 13.0, "length": 7.0})]),
        ],
    },
}

# ═══ 3 · LANTERN MEADOW — „Lantern Walk" · japanski festival lampiona ═══════════
LM_CHORDS = ["Abmaj7", "Bb", "Gm7", "Cm7", "Abmaj7", "Bb", "Gm7", "Cm7",
             "Fm7", "Bb7sus4", "Ebsus2", "Cm7", "Abmaj7", "Bb", "Gm7@0 Cm7@2", "Ebsus2"]
SONGS["lantern_meadow"] = {
    "title": "Lantern Walk", "key": "Eb", "mode": "pentatonic",
    "feel": {"jitter": 1.8, "vel_spread": 1.2},   # rubato
    "home": {
        "bpm": 68, "meter": "4/4",
        "chords": LM_CHORDS,
        "mix": {"reverb": {"size": 0.62, "damp": 0.45, "pre": 0.02, "amount": 0.3},
                "echo": {"beats": 0.75, "fb": 0.38, "lp": 2600.0, "amount": 0.3}, "tilt": (1000, 0.0, 1.0)},
        "parts": [
            P("line", "shakuhachi", -21.0, inst="shakuhachi", vel=0.9, rev=0.7, echo=0.4, notes={
                0: "~G5:3 F5:0.25 Eb5:0.75", 1: "~C5:2.5 r:1.5", 2: "r:0.5 Eb5:0.25 F5:0.25 ~G5:3",
                3: "F5:0.25 G5:0.25 F5:2.5 r:1", 4: "~Bb5:3 C6:0.25 Bb5:0.75", 5: "~G5:2.5 r:1.5",
                6: "r:0.5 F5:0.25 G5:0.25 ~Bb5:3", 7: "C6:0.25 Bb5:0.25 F5:2.5 r:1", 8: "~Eb6:3 C6:0.25 Bb5:0.75",
                9: "~C6:2.5 r:1.5", 10: "r:0.5 G5:0.25 Bb5:0.25 ~C6:3", 11: "Bb5:0.25 C6:0.25 Bb5:2.5 r:1",
                12: "~Eb5:3 F5:0.25 G5:0.75", 13: "~Bb5:2.5 r:1.5", 14: "F5:0.25 G5:0.25 ~C6:1.5 Bb5:2",
                15: "~Eb5:4"}),
            P("arp", "koto", -25.0, inst="koto", style="stack", lo=51, hi=76, voices=4, rev=0.5,
              pattern=[(0, 0, 2.0, 0.6), (0.12, 1, 2.0, 0.5), (0.24, 2, 2.0, 0.5), (0.36, 3, 2.0, 0.45),
                       (2.5, 2, 1.0, 0.4), (3.0, 1, 1.0, 0.35)]),
            P("line", "koto_trem", -30.0, inst="koto_trem", vel=0.6, rev=0.6, notes={
                8: "G4:4", 9: "Eb5:4", 10: "C5:4", 11: "F4:4"}),
            P("line", "koto_shadow", -28.0, inst="koto", vel=0.8, rev=0.5, notes={
                12: "Eb4:3 F4:0.5 G4:0.5", 13: "Bb4:2 G4:2", 14: "C5:2 Bb4:2", 15: "Eb4:4"}),
            P("pad", "sho", -29.0, inst="sho", style="stack", lo=60, hi=84, voices=4, rev=0.6),
            P("bass", "low_koto", -29.0, inst="koto", lo=39, rev=0.4, pattern=[(0, "R", 2.0, 0.8)]),
            P("drums", "taiko", -30.0, rev=0.3,
              pattern={"taiko": [(0, 0.7)], "tblock": [(2, 0.3)], "tblock_hi": [(3.5, 0.2)]},
              fills={7: {"taiko": [(3, 0.6), (3.5, 0.7)]}, 15: {"taiko": [(2.5, 0.5), (3, 0.6), (3.5, 0.75)]}}),
            P("hits", "bell", -31.0, rev=0.8, events=[(0, 0, "temple_bell", "Eb3", 0, 1.0), (8, 0, "temple_bell", "Bb2", 0, 0.9)]),
            P("hits", "cymbal", -36.0, events=[(4, 0, "fcym", None, 0, 0.8), (12, 0, "fcym", None, 0, 0.7)]),
            P("amb", "crickets", -44.0, layers=[("crickets", {"voices": 2, "level": 0.05})]),
        ],
    },
    "arena": {
        "bpm": 96, "meter": "4/4", "feel": {"jitter": 1.0},
        "chords": ["Eb", "Abmaj7", "Fm7", "Bbsus4", "Eb", "Gm7", "Abmaj7", "Bbsus4",
                   "Abmaj7", "Bb", "Gm7", "Cm7", "Abmaj7", "Bb", "Fm7", "Bbsus4"],
        "mix": {"reverb": {"size": 0.5, "damp": 0.5, "pre": 0.015, "amount": 0.22},
                "echo": {"beats": 0.75, "fb": 0.3, "lp": 2400.0, "amount": 0.2}, "tilt": (1000, 2.0, -0.5)},
        "parts": [
            P("drums", "taiko", -24.5, rev=0.25,
              pattern={"taiko": [(0, 1.0), (1.5, 0.55), (1.75, 0.5), (2, 0.85), (3, 0.5)],
                       "tblock": [(0.5, 0.25), (2.5, 0.25)], "tblock_hi": [(1, 0.3), (3, 0.3), (3.5, 0.25)]},
              fills={7: {"taiko": [(3.25, 0.5), (3.5, 0.6), (3.75, 0.7)]}, 15: {"taiko": [(3, 0.6), (3.25, 0.6), (3.5, 0.7), (3.75, 0.8)]}}),
            P("arp", "koto", -27.0, inst="koto", style="stack", lo=51, hi=75, voices=4, rev=0.4,
              pattern=[(0, 0, 1.4, 0.6), (0.1, 1, 1.4, 0.5), (0.2, 2, 1.4, 0.5), (2, 1, 1.0, 0.45), (2.1, 3, 1.0, 0.4)]),
            P("line", "call", -23.0, inst="bamboo", vel=0.9, rev=0.5, echo=0.3, notes={
                0: "Bb5:0.25 C6:0.25 Bb5:1.5 G5:0.5 Bb5:1.5", 1: "C6:0.25 Eb6:0.25 C6:2.5 r:1",
                4: "Eb6:0.25 F6:0.25 Eb6:1.5 C6:0.5 Bb5:1.5", 5: "G5:0.25 Bb5:0.25 G5:2.5 r:1",
                8: "C6:0.25 Eb6:0.25 C6:1.5 Bb5:0.5 G5:1.5", 9: "F5:0.25 G5:0.25 F5:2.5 r:1",
                12: "Eb6:0.25 F6:0.25 Eb6:1.5 C6:0.5 Bb5:1.5", 13: "Bb5:0.25 C6:0.25 Bb5:2.5 r:1"}),
            P("line", "answer", -24.0, inst="koto", vel=0.9, rev=0.4, echo=0.2, notes={
                2: "C5:0.5 C5:0.5 Eb5:1 C5:0.5 Bb4:0.5 r:1", 3: "Bb4:0.5 Bb4:0.5 F5:1 Eb5:0.5 C5:0.5 r:1",
                6: "C5:0.5 C5:0.5 F5:1 Eb5:0.5 C5:0.5 r:1", 7: "Bb4:0.5 Bb4:0.5 Eb5:1 F5:1 r:1",
                10: "G4:0.5 G4:0.5 Bb4:1 G4:0.5 F4:0.5 r:1", 11: "C5:0.5 C5:0.5 Eb5:1 G5:1 r:1",
                14: "F5:0.5 F5:0.5 Eb5:1 C5:0.5 Bb4:0.5 r:1", 15: "Bb4:0.5 C5:0.5 Eb5:0.5 F5:0.5 Bb5:1 r:1"}),
            P("line", "hook", -27.0, inst="shakuhachi", vel=0.8, rev=0.5, echo=0.3, active=[(12, 16)], notes={
                14: "~C6:3 Bb5:0.25 C6:0.75", 15: "~Bb5:4"}),
            P("bass", "low_koto", -27.0, inst="koto", lo=39, rev=0.3, pattern=[(0, "R", 1.0, 0.85), (2, "5", 1.0, 0.65)]),
        ],
    },
    "run": {
        "bpm": 52, "meter": "4/4",
        "chords": run_bars("Ebadd9", "Fm7/Eb", "Abmaj7/Eb", "Bb7sus4/Eb"),
        "mix": {"reverb": {"size": 0.88, "damp": 0.4, "pre": 0.05, "amount": 0.5},
                "echo": {"beats": 0.75, "fb": 0.45, "lp": 2200.0, "amount": 0.38}, "tilt": (1000, 0.0, 1.0)},
        "parts": [
            P("pad", "sho", -26.0, inst="sho", style="stack", lo=55, hi=82, voices=5, rev=0.7),
            P("line", "shakuhachi", -28.0, inst="shakuhachi", vel=0.85, rev=0.8, echo=0.55, notes={
                0: "~G5:3 F5:0.25 Eb5:0.75", 2: "~C5:2.5 r:1.5", 4: "r:0.5 Eb5:0.25 F5:0.25 ~G5:3",
                6: "F5:0.25 G5:0.25 F5:2.5 r:1"}),
            P("line", "koto_trem", -33.0, inst="koto_trem", vel=0.6, rev=0.7, notes={3: "r:2 G5:2", 7: "r:2 F5:2"}),
            P("hits", "bell", -30.0, rev=0.9, events=[(0, 0, "temple_bell", "Eb3", 0, 1.0), (4, 0, "temple_bell", "Ab2", 0, 0.9)]),
            P("amb", "crickets", -36.0, layers=[("crickets", {"voices": 3, "level": 0.05})]),
            P("amb", "chimes", -34.0, layers=[("chimes", {"at": 6.5, "notes": ["Eb6", "F6", "G6", "Bb6", "C7"]}),
                                               ("chimes", {"at": 24.0, "notes": ["Eb6", "F6", "G6", "Bb6", "C7"], "seed": 9})]),
        ],
    },
}

# ═══ 4 · AMBER CANOPY — „Copper Leaves" · keltski folk ══════════════════════════
SONGS["amber_canopy"] = {
    "title": "Copper Leaves", "key": "G", "mode": "major",
    "feel": {"jitter": 1.4, "vel_spread": 1.5},   # folk session, naglasci
    "home": {
        "bpm": 180, "meter": "6/8",
        "chords": ["G", "G", "D", "F", "G", "D", "C", "D", "Em", "C", "D", "D", "C", "G", "Am@0 D@3", "G"],
        "mix": {"reverb": {"size": 0.34, "damp": 0.65, "pre": 0.008, "amount": 0.16},
                "tilt": (800, 2.0, -1.5), "drive": 0.1},
        "parts": [
            P("line", "whistle", -21.0, inst="tin_whistle", vel=0.85, rev=0.4, notes={
                0: "D5>B4:3 D5:2 C5:1", 1: "B4:2 A4:1 ~G4:3", 2: "F#5>E5:3 D5:2 C5:1", 3: "D5:3 A4:3",
                4: "D5>B4:3 D5:2 G5:1", 5: "G5>F#5:3 D5:3", 6: "E5:2 D5:1 C5:2 E5:1", 7: "~D5:6",
                8: "A5>G5:3 F#5:2 E5:1", 9: "E5:3 G5:3", 10: "A5:2 G5:1 E5:3", 11: "G5>F#5:3 A5:3",
                12: "A5>G5:3 E5:2 D5:1", 13: "D5:3 B4:3", 14: "C5:3 A4:2 F#4:1", 15: "~G4:6"}),
            P("line", "fiddle", -27.0, inst="fiddle", vel=0.75, rev=0.4, notes={
                12: "E5:3 C5:2 B4:1", 13: "B4:3 G4:3", 14: "A4:3 F#4:2 D4:1", 15: "D4:6"}),
            P("arp", "guitar", -24.0, inst="guitar", lo=50, hi=67, voices=4, rev=0.3,
              pattern=[(0, 0, 1.6, 0.7), (1, 2, 1.0, 0.45), (2, 3, 1.0, 0.42), (3, 1, 1.6, 0.6), (4, 2, 1.0, 0.45), (5, 3, 1.0, 0.42)]),
            P("pad", "accordion", -29.0, inst="accordion", lo=55, hi=72, voices=3, vel=0.5, rev=0.3, active=[(8, 16)]),
            P("bass", "cello", -28.0, inst="cello", rev=0.3, pattern=[(0, "R", 2.8, 0.85), (3, "5", 2.8, 0.65)]),
            P("drums", "bodhran", -31.0, rev=0.15,
              pattern={"bodhran": [(0, 0.55), (3, 0.45)], "bodhran_hi": [(5, 0.25)]},
              fills={7: {"bodhran_hi": [(3, 0.25), (4, 0.3), (5, 0.35)]}, 15: {"bodhran_hi": [(3, 0.3), (4, 0.35), (4.5, 0.35), (5, 0.4), (5.5, 0.45)]}}),
            P("drums", "tamb", -36.0, rev=0.2, active=[(8, 16)], pattern={"tamb": [(3, 0.3)]}),
            P("amb", "leaves", -44.0, layers=[("leaves", {"gusts": 4, "level": 0.1})]),
        ],
    },
    "arena": {
        "bpm": 252, "meter": "6/8",
        "chords": ["G", "C", "G", "F", "Em", "C", "D", "D", "G", "C", "Em", "D", "C", "G", "F", "D"],
        "mix": {"reverb": {"size": 0.3, "damp": 0.6, "pre": 0.006, "amount": 0.14}, "tilt": (800, 0.5, 1.5)},
        "parts": [
            P("strum", "bouzouki", -23.0, inst="bouzouki", lo=43, hi=70, rev=0.25, dyn=[(0, 8, 0.8), (8, 16, 1.05)],
              pattern=[(0, "D", 0.9, 0.7), (2, "U", 0.6, 0.45), (3, "D", 0.9, 0.6), (5, "U", 0.6, 0.45)]),
            P("block", "accordion", -27.0, inst="accordion", lo=55, hi=71, voices=3, rev=0.25,
              hits=[(1, 0.8, 0.45), (2, 0.8, 0.4), (4, 0.8, 0.45), (5, 0.8, 0.4)]),
            P("line", "lead", -23.0, inst="fiddle", vel=0.85, rev=0.3, dyn=[(0, 8, 0.8), (8, 16, 1.05)], notes={
                0: "B4:2 D5:1 G5:2 D5:1", 1: "E5:2 C5:1 E5:1 D5:1 C5:1", 2: "B4:2 A4:1 G4:3",
                3: "A4:1 B4:1 C5:1 D5:3", 4: "E5:1 G5:1 B5:1 G5:1 E5:1 B4:1", 5: "C5:2 E5:1 G5:2 E5:1",
                6: "F#5:1 E5:1 D5:1 A4:2 D5:1", 7: "D5:3 A4:3",
                8: "D5:1 B4:1 G4:1 B4:1 D5:1 G5:1", 9: "E5:1 C5:1 E5:1 G5:2 E5:1", 10: "B5:2 A5:1 G5:1 F#5:1 E5:1",
                11: "F#5:3 A5:3", 12: "G5:1 E5:1 C5:1 E5:1 G5:1 C6:1", 13: "B5:2 A5:1 G5:3",
                14: "A5:1 G5:1 E5:1 C5:2 E5:1", 15: "D5:3 F#5:1 A5:1 C6:1"}),
            P("line", "whistle", -26.0, inst="tin_whistle", vel=0.75, rev=0.3, notes={
                8: "D5:1 B4:1 G4:1 B4:1 D5:1 G5:1", 9: "E5:1 C5:1 E5:1 G5:2 E5:1", 10: "B5:2 A5:1 G5:1 F#5:1 E5:1",
                11: "F#5:3 A5:3", 12: "G5:1 E5:1 C5:1 E5:1 G5:1 C6:1", 13: "B5:2 A5:1 G5:3",
                14: "A5:1 G5:1 E5:1 C5:2 E5:1", 15: "D5:3 F#5:1 A5:1 C6:1"}),
            P("bass", "cello", -26.0, inst="cello", rev=0.2, pattern=[(0, "R", 1.5, 0.9), (3, "5", 1.5, 0.75)]),
            P("drums", "bodhran", -27.0, rev=0.12,
              pattern={"bodhran": [(0, 0.85), (3, 0.65)], "bodhran_hi": [(1, 0.3), (2, 0.35), (4, 0.3), (5, 0.4)]},
              odd_bars={"tamb": [(3, 0.25)]},
              fills={7: {"bodhran_hi": [(4.5, 0.3), (5.5, 0.35)]}, 15: {"bodhran_hi": [(3.5, 0.3), (4.5, 0.35), (5.5, 0.45)]}}),
        ],
    },
    "run": {
        "bpm": 162, "meter": "6/8",
        "chords": run_bars("Gadd9", "F", "Cadd9", "Dsus4", each=4),
        "mix": {"reverb": {"size": 0.58, "damp": 0.68, "pre": 0.015, "amount": 0.3}, "tilt": (800, 2.0, -1.5)},
        "parts": [
            P("arp", "guitar", -28.0, inst="guitar", lo=50, hi=69, voices=4, rev=0.4,
              pattern=[(0, 0, 1.5, 0.55), (1, 2, 1.0, 0.4), (2, 3, 1.0, 0.38), (3, 1, 1.5, 0.5), (4, 2, 1.0, 0.4), (5, 3, 1.0, 0.38)]),
            P("pad", "cellos", -28.0, inst="cello_section", lo=43, hi=64, voices=3, rev=0.5),
            P("line", "whistle", -30.0, inst="tin_whistle", vel=0.8, rev=0.6, notes={
                0: "D5>B4:3 D5:2 C5:1", 4: "C5:2 A4:1 F4:3", 8: "E5:3 D5:2 C5:1", 12: "D5:3 A4:3"}),
            P("amb", "leaves", -39.0, layers=[("leaves", {"gusts": 6, "level": 0.1})]),
            P("amb", "forest", -33.0, layers=[("woodpecker", {"at": 7.5}), ("crow", {"at": 22.0})]),
        ],
    },
}

# ═══ 5 · MOONLIT WARREN — „Moon Lullaby" · uspavanka 12/8 + noćni jazz ═════════
SONGS["moonlit_warren"] = {
    "title": "Moon Lullaby", "key": "Ab", "mode": "major",
    "feel": {"jitter": 1.0, "vel_spread": 1.0},   # uspavanka
    "home": {
        "bpm": 138, "meter": "12/8",
        "chords": ["Abmaj7", "Dbadd9/Ab", "Dbmaj7@0 Eb7sus4@6", "Abmaj7@0 Eb7@6",
                   "Dbmaj7", "Fm7", "Dbmaj7@0 Eb7@6", "Abadd9"],
        # muzička kutija mora malo „zvoniti" i na zvučniku telefona (visoke su bile −27 dB ispod ukupnog)
        "mix": {"reverb": {"size": 0.7, "damp": 0.6, "pre": 0.02, "amount": 0.36}, "tilt": (1200, 0.5, -1.5)},
        "parts": [
            P("line", "music_box", -21.0, inst="music_box", vel=0.85, rev=0.7, notes={
                0: "C5:6 Eb5:3 Ab5:3", 1: "Ab5:3 F5:2 Eb5:1 F5:6", 2: "Db5:6 Eb5:3 F5:3", 3: "Ab5:4 G5:4 Eb5:4",
                4: "F5:6 Ab5:3 C6:3", 5: "Bb5:3 G5:2 F5:1 Ab5:6", 6: "Db6:4 C6:4 Bb5:4", 7: "Ab5:9 r:3"}),
            P("arp", "piano", -24.0, inst="felt_piano", style="spread", lo=44, hi=70, voices=4, rev=0.6,
              pattern=arp([(0, 0), (1, 1), (2, 2), (3, 3), (4, 2), (5, 1), (6, 0), (7, 1), (8, 2), (9, 3), (10, 2), (11, 1)],
                          2.0, 0.5, (0, 6))),
            P("pad", "choir", -30.0, inst="choir_ooh", lo=58, hi=74, voices=3, vel=0.6, rev=0.8, active=[(4, 8)]),
            P("bass", "upright", -29.0, inst="upright", rev=0.4, pattern=[(0, "R", 5.5, 0.8), (6, "R", 5.5, 0.7)]),
            P("amb", "breeze", -48.0, layers=[("breeze", {})]),
        ],
    },
    "arena": {
        "bpm": 88, "meter": "4/4", "swing": 0.64, "feel": {"jitter": 1.3, "lay": 0.014},
        "chords": ["Abmaj7", "Fm7", "Bbm7", "Eb7", "Abmaj7", "Fm7", "Bbm7", "Eb7",
                   "Dbmaj7", "Dbm6", "Cm7", "F7", "Bbm7", "Eb7", "Abmaj7@0 F7@2", "Bbm7@0 Eb7@2"],
        "mix": {"reverb": {"size": 0.55, "damp": 0.55, "pre": 0.015, "amount": 0.25}, "tilt": (1200, 0.5, -1.0)},
        "parts": [
            P("block", "rhodes", -25.0, inst="ep", lo=53, hi=70, strum=0.006, rev=0.4,
              fx=[("chorus", {"rate": 0.5, "depth": 0.0025, "base": 0.01, "mix": 0.45})],
              hits=[(0, 1.2, 0.55), (1.5, 0.4, 0.38), (2.5, 1.2, 0.45)]),
            P("walk", "bass", -26.0, inst="upright", vel=0.85, rev=0.2),
            P("line", "lead", -24.0, inst="vibes", vel=0.9, rev=0.5, notes={
                8: "r:0.5 Ab5:0.5 F5:0.5 Ab5:0.5 C6:1 Ab5:0.5 F5:0.5",
                9: "E5:1 r:0.5 Ab5:0.5 Bb5:1 Ab5:0.5 E5:0.5",
                10: "Eb5:0.5 G5:0.5 Bb5:0.5 C6:0.5 Eb6:1 C6:0.5 G5:0.5",
                11: "A5:1 r:0.5 C6:0.5 Eb6:1 C6:0.5 A5:0.5",
                12: "Ab5:0.5 F5:0.5 Db5:0.5 F5:0.5 Ab5:1 Bb5:0.5 G5:0.5+1", 13: "=:1 Bb5:0.5 Db6:0.5 C6:1 r:1",
                14: "C6:1 Ab5:0.5 G5:0.5 A5:1.5 C6:0.5", 15: "Bb5:1 Db6:0.5 Bb5:0.5 G5:1 Eb5:0.5 Ab5:0.5"}),
            P("line", "head", -25.0, inst="vibes", vel=0.85, rev=0.5, notes={
                0: "r:0.5 Eb5:0.5 G5:0.5 Bb5:1 G5:0.5 F5:0.5 Ab5:0.5+1", 1: "=:1 F5:0.5 C5:0.5 Eb5:1 r:1",
                2: "r:0.5 F5:0.5 Ab5:0.5 Db6:1 Bb5:0.5 Ab5:0.5 G5:0.5+1", 3: "=:1 Bb4:0.5 Db5:0.5 C5:1 r:1",
                4: "C5:1 r:0.5 Eb5:0.5 Ab5:1.5 G5:0.5+1", 5: "=:1 F5:0.5 Eb5:0.5 C5:1 r:1",
                6: "Db5:1 r:0.5 F5:0.5 Bb5:1.5 Ab5:0.5", 7: "G5:0.5 F5:0.5 Eb5:0.5 Db5:0.5 Bb4:1 r:1"}),
            P("drums", "brushes", -29.0, rev=0.2,
              pattern={"ride": [(0, 0.24), (1, 0.28), (1.5, 0.17), (2, 0.24), (3, 0.28), (3.5, 0.17)],
                       "brush": [(1, 0.4), (3, 0.4)]}),
        ],
    },
    "run": {
        "bpm": 120, "meter": "12/8",
        "chords": ["Abmaj9", "Dbmaj9/Ab", "Abmaj9", "Dbm6/Ab", "Abmaj9", "Eb9sus4/Ab"],
        "mix": {"reverb": {"size": 0.78, "damp": 0.65, "pre": 0.03, "amount": 0.42}, "tilt": (1200, 0.5, -3.0)},
        "parts": [
            P("arp", "piano", -29.0, inst="felt_piano", style="spread", lo=44, hi=72, voices=4, rev=0.6,
              pattern=[(k, [0, 1, 2, 3, 2, 1][k % 6], 1.5, 0.55 if k % 3 == 0 else 0.42) for k in range(12)]),
            P("pad", "choir", -27.0, inst="choir_ooh", lo=56, hi=75, voices=4, rev=0.8),
            P("line", "music_box", -29.0, inst="music_box", vel=0.85, rev=0.8, notes={
                0: "C5:6 Eb5:3 Ab5:3", 2: "F5:6 Ab5:3 C6:3", 4: "Ab5:4 G5:4 F5:4"}),
            P("amb", "katydids", -37.0, layers=[("katydids", {"level": 0.04})]),
            P("amb", "owl", -31.0, layers=[("owl", {"at": 21.0})]),
            P("amb", "breeze", -46.0, layers=[("breeze", {})]),
        ],
    },
}

# ═══ 6 · CORAL TIDE GARDEN — „Seashell Bossa" · bossa nova + calypso ═══════════
SONGS["coral_tide"] = {
    "title": "Seashell Bossa", "key": "A", "mode": "major",
    "feel": {"jitter": 1.0, "vel_spread": 1.1, "lay": -0.006},   # melodija malo gura
    "home": {
        "bpm": 128, "meter": "4/4",
        "chords": ["Amaj7", "Bm7", "D6/9", "Bb7#11", "Amaj7", "D#m7b5", "Dmaj7", "E7sus4",
                   "Dmaj7", "C#m7", "Cmaj7#11", "Bm7@0 E7@2", "Amaj7", "Dmaj9", "Bm7@0 E7@2", "A6/9"],
        "mix": {"reverb": {"size": 0.42, "damp": 0.3, "pre": 0.01, "amount": 0.2},
                "echo": {"beats": 0.25, "fb": 0.12, "lp": 5000.0, "amount": 0.12}, "tilt": (1500, -1.0, 2.5)},
        "parts": [
            P("line", "flute", -21.0, inst="alto_flute", vel=0.85, rev=0.5, echo=0.4, notes={
                0: "E5:1 C#5:0.5 E5:1 F#5:0.5 E5:0.5 C#5:0.5+1", 1: "=:1 B4:0.5 A4:1 r:1.5",
                2: "D5:1 B4:0.5 D5:1 F#5:0.5 E5:0.5 D5:0.5+1", 3: "=:1 C#5:0.5 ~E5:1 r:1.5",
                4: "E5:1 C#5:0.5 E5:1 A5:0.5 G#5:0.5 F#5:0.5+1", 5: "=:1 E5:0.5 C#5:1 r:1.5",
                6: "D5:1 C#5:0.5 D5:1 F#5:0.5 A5:0.5 B5:0.5+1", 7: "=:1 A5:0.5 E5:1 r:1.5",
                8: "r:0.5 F#5:1 E5:0.5 F#5:1 A5:1", 9: "G#5:2.5 E5:1 F#5:0.5+1", 10: "=:1 E5:0.5 D5:1 B4:1.5",
                11: "r:0.5 B4:0.5 D5:0.5 E5:0.5 G#5:1 B5:1", 12: "E5:1 C#5:0.5 E5:1 G#5:0.5 F#5:0.5 E5:0.5+1",
                13: "=:1 A5:0.5 C#6:1 r:1.5", 14: "B5:1 A5:0.5 F#5:1 G#5:0.5 E5:0.5 D5:0.5", 15: "~C#5:3 r:1"}),
            P("line", "pan", -27.0, inst="steelpan", vel=0.7, rev=0.5, notes={
                12: "r:2 G#5:0.5 B5:1 E6:0.5", 13: "C#6:2 r:0.5 A5:0.5 C#6:0.5 F#6:0.5", 14: "D6:1.5 B5:1 G#5:1.5",
                15: "C#6:2 E6:2"}),
            P("strum", "nylon", -24.0, inst="nylon", lo=43, hi=67, rev=0.35,
              pattern=[(0, "B", 0.9, 0.7), (0, "P", 0.4, 0.5), (1.5, "P", 0.4, 0.45), (2, "b5", 0.9, 0.6), (2.5, "P", 0.4, 0.45)],
              odd_pattern=[(0, "B", 0.9, 0.7), (0.5, "P", 0.4, 0.45), (2, "b5", 0.9, 0.6), (2, "P", 0.4, 0.45), (3.5, "P", 0.4, 0.4)]),
            P("bass", "marimba_bass", -28.0, inst="marimba", lo=40, rev=0.2, pattern=[(0, "R", 1.4, 0.85), (2, "5", 1.4, 0.65)]),
            P("drums", "perc", -31.0, rev=0.15,
              pattern={"shaker": [(k * 0.25, 0.1 if k % 2 else 0.16) for k in range(16)]},
              odd_bars={"rim": [(1, 0.22), (2.5, 0.22)]}, even_bars={"rim": [(0, 0.22), (1.5, 0.22), (3, 0.22)]},
              fills={7: {"rim": [(3, 0.2), (3.5, 0.24), (3.75, 0.28)]}, 15: {"rim": [(3, 0.22), (3.25, 0.24), (3.5, 0.27), (3.75, 0.3)]}}),
            P("amb", "sea", -46.0, layers=[("waves", {"period": 8.0, "level": 0.5})]),
        ],
    },
    "arena": {
        "bpm": 104, "meter": "4/4",
        "chords": ["A6", "D6", "E7", "A6", "A6@0 E7@2", "D6", "E7", "A6",
                   "D6", "E7", "A6@0 E7@2", "Bm7@0 E7@2", "A6", "E7", "A6@0 D6@2", "E7"],
        "mix": {"reverb": {"size": 0.4, "damp": 0.35, "pre": 0.01, "amount": 0.18}, "tilt": (1500, 0.0, 1.5)},
        "parts": [
            P("line", "lead", -22.0, inst="steelpan", vel=0.9, rev=0.4, notes={
                8: "F#5:0.75 A5:0.75 D6:0.5 F#6:0.75 D6:0.75 A5:0.5", 9: "E5:0.75 G#5:0.75 B5:0.5 E6:1 B5:1",
                10: "E6:0.75 E6:0.75 C#6:0.5 G#5:1 E5:1", 11: "F#5:0.75 A5:0.75 C#6:1 A5:0.5 F#5:0.5 E5:0.5+1",
                12: "=:1 D6:0.75 B5:0.75 F#5:0.5 A5:1", 13: "G#5:0.75 B5:0.75 D6:0.5 E6:2",
                14: "C#6:0.75 A5:0.75 E5:0.5 F#5:0.75 A5:0.75 D6:0.5", 15: "B5:0.75 B5:0.75 G#5:0.5 E5:2"}),
            P("line", "riff", -25.0, inst="marimba", vel=0.85, rev=0.3, notes={
                0: "E5:0.75 E5:0.75 A5:0.5 C#6:0.75 A5:0.75 E5:0.5",
                1: "F#5:0.75 F#5:0.75 A5:0.5 D6:0.75 A5:0.75 F#5:0.5",
                2: "G#5:0.75 G#5:0.75 B5:0.5 E6:0.75 D6:0.75 B5:0.5", 3: "A5:0.75 A5:0.75 C#6:0.5 A5:2"}),
            P("line", "hook", -26.0, inst="steelpan", vel=0.75, rev=0.4, notes={
                4: "C#6:1 A5:0.5 C#6:1 E6:0.5 C#6:1", 5: "r:0.5 A5:0.5 F#5:1 A5:0.5 D6:1.5",
                6: "B5:1 G#5:0.5 B5:1 D6:0.5 B5:1", 7: "A5:1.5 C#6:0.5 E6:2"}),
            P("strum", "uke", -25.0, inst="ukulele", lo=55, hi=72, voices=4, rev=0.25,
              pattern=[(0.5, "x", 0.2, 0.5), (1, "D", 0.3, 0.4), (1.5, "x", 0.2, 0.5), (2.5, "x", 0.2, 0.5),
                       (3, "D", 0.3, 0.4), (3.5, "x", 0.2, 0.5)]),
            P("bass", "marimba_bass", -25.0, inst="marimba", lo=40, rev=0.15,
              pattern=[(0, "R", 1.0, 0.9), (1.5, "5", 0.5, 0.6), (2, "R", 0.5, 0.7), (3, "8", 0.5, 0.6), (3.5, "5", 0.5, 0.6)]),
            P("drums", "perc", -26.0, rev=0.12,
              pattern={"conga": [(1.5, 0.5), (3, 0.45)], "slap": [(2.5, 0.45)], "conga_hi": [(3.5, 0.5)],
                       "bongo": [(0.5, 0.3)], "bongo_hi": [(1, 0.25)], "shaker": eighths(4, 0.18, 0.12),
                       "guiro": [(2, 0.3)]}),
        ],
    },
    "run": {
        "bpm": 66, "meter": "4/4",
        "chords": run_bars("Amaj9", "Dmaj9", "C#m7", "Cmaj7#11"),
        "mix": {"reverb": {"size": 0.55, "damp": 0.5, "pre": 0.02, "amount": 0.3}, "tilt": (1500, -1.0, 2.0)},
        "parts": [
            P("pad", "warm", -28.0, inst="pad_warm", lo=50, hi=73, voices=5, rev=0.7),
            P("arp", "pan", -28.0, inst="steelpan", lo=62, hi=81, voices=4, rev=0.6,
              pattern=[(k * 0.5, [0, 2, 1, 3, 2, 1, 3, 2][k], 0.45, 0.5 if k % 2 == 0 else 0.4) for k in range(8)]),
            P("line", "flute", -29.0, inst="alto_flute", vel=0.85, rev=0.7, notes={
                0: "E5:1 C#5:0.5 ~E5:1 F#5:0.5 E5:1", 2: "r:1 B4:0.5 A4:1 C#5:1.5",
                4: "E5:1 C#5:0.5 ~E5:1 G#5:0.5 E5:1", 6: "r:1 A4:0.5 ~E5:1 r:1.5"}),
            P("amb", "sea", -33.0, layers=[("waves", {"period": 7.3, "level": 0.5, "dark": True})]),
            P("amb", "gulls", -33.0, layers=[("gull", {"at": 5.5}), ("gull", {"at": 20.5, "seed": 77})]),
            P("amb", "bubbles", -41.0, layers=[("bubbles", {"count": 5})]),
        ],
    },
}

# ═══ 7 · STARFALL GLADE — „Falling Stars" · elektronika (lidijski) ══════════════
SG_ARP16 = [(k * 0.25, [0, 1, 2, 3, 2, 1, 3, 2, 0, 1, 2, 3, 2, 3, 1, 2][k], 0.25, 0.5 if k % 4 else 0.62) for k in range(16)]
SONGS["starfall_glade"] = {
    "title": "Falling Stars", "key": "Bb", "mode": "lydian", "extra": ["Eb"],
    "feel": {"jitter": 0.0, "vel_spread": 0.35},   # kvantizovano — mašina
    "home": {
        "bpm": 108, "meter": "4/4",
        "chords": ["Bbmaj7", "C/Bb", "Bbmaj7", "C/Bb", "Gm9", "Am7", "Dm7", "F",
                   "Gm7", "C/E", "Ebmaj7", "F7sus4", "Bbmaj7", "C/Bb", "Gm9@0 F@2", "Bbmaj9"],
        "mix": {"reverb": {"size": 0.93, "damp": 0.2, "pre": 0.04, "amount": 0.5, "bright": 1.1},
                "echo": {"beats": 0.75, "fb": 0.45, "lp": 4000.0, "amount": 0.3}, "tilt": (1000, 2.0, 2.0)},
        "parts": [
            P("line", "lead", -21.0, inst="star_lead", vel=0.85, rev=0.7, echo=0.4, notes={
                0: "D5:1.5 F5:1.5 A5:1", 1: "G5:1.5 E5:1.5 C5:1", 2: "D5:1.5 F5:1.5 Bb5:0.5 A5:0.5", 3: "E5:4",
                4: "Bb5:1.5 A5:1.5 G5:1", 5: "C6:1.5 A5:1.5 E5:1", 6: "F5:1.5 D5:1.5 A5:0.5 F5:0.5", 7: "C5:3 r:1",
                8: "D6:1.5 Bb5:1.5 G5:1", 9: "E6:1.5 C6:1.5 G5:1", 10: "D6:1.5 Bb5:1.5 G5:0.25 A5:0.25 Bb5:0.5",
                11: "C6:4", 12: "A5:1.5 F5:1.5 D5:1", 13: "E5:1.5 G5:1.5 C6:1", 14: "D6:1.5 C6:1.5 A5:1",
                15: "D5:4"}),
            P("pad", "saw", -25.0, inst="supersaw", lo=53, hi=74, voices=4, vel=0.6, rev=0.6, pump=0.45),
            P("arp", "arp", -27.0, inst="synth_pluck", lo=65, hi=86, voices=4, rev=0.5, echo=0.3, pump=0.35,
              pattern=SG_ARP16),
            P("pad", "choir", -30.0, inst="synth_choir", lo=62, hi=77, voices=3, vel=0.6, rev=0.8, active=[(8, 16)]),
            P("bass", "sub", -27.0, inst="sub", rev=0.0, pattern=[(0, "R", 3.8, 0.9)]),
            P("drums", "beat", -29.0, rev=0.1, active=[(4, 16)],
              pattern={"kick808": [(0, 0.6), (2, 0.5)], "clap": [(3, 0.25)],
                       "hat": [(k * 0.25, 0.15 if k % 2 else 0.22) for k in range(16)]}),
            P("hits", "riser", -33.0, events=[(14, 0, "riser", "C4", 4.2, 1.0)]),
            P("sprinkle", "glass", -34.0, inst="glass", notes=["Bb6", "C7", "D7", "F7", "A6"], gap=(1.5, 3.0), dur=0.5, rev=0.9),
            P("amb", "stars", -44.0, layers=[("sparkles", {"rate": 0.8, "level": 0.03})]),
        ],
    },
    "arena": {
        "bpm": 118, "meter": "4/4",
        "chords": ["Bbmaj7", "C", "Dm7", "C", "Bbmaj7", "C", "Am7", "F",
                   "Gm7", "Ebmaj7", "Bbmaj7", "F", "Gm7", "Ebmaj7", "C", "Fsus4"],
        "mix": {"reverb": {"size": 0.85, "damp": 0.25, "pre": 0.03, "amount": 0.32},
                "echo": {"beats": 0.75, "fb": 0.4, "lp": 4000.0, "amount": 0.22}, "tilt": (1000, 3.0, 3.0)},
        "parts": [
            P("drums", "kick", -27.0, rev=0.08, active=[(4, 16)],
              pattern={"kick808": [(0, 0.7), (1, 0.6), (2, 0.7), (3, 0.6)]}),
            P("drums", "hats", -31.0, rev=0.08, active=[(6, 16)],
              pattern={"hat": [(0.5, 0.3), (1.5, 0.3), (2.5, 0.3), (3.5, 0.3)]}),
            P("drums", "claps", -30.0, rev=0.15, active=[(8, 16)], pattern={"clap": [(1, 0.35), (3, 0.35)]},
              fills={7: {"clap": [(2, 0.2), (2.5, 0.25), (3, 0.3), (3.25, 0.35), (3.5, 0.4), (3.75, 0.45)]}}),
            P("hits", "riser", -30.0, events=[(6, 0, "riser", "C4", 3.8, 1.0)]),
            P("bass", "bass", -25.0, inst="synth_bass", rev=0.0, pump=0.3,
              pattern=[(k * 0.5, "8" if k % 2 else "R", 0.45, 0.85 if k % 2 == 0 else 0.7) for k in range(8)]),
            P("arp", "arp", -24.0, inst="synth_pluck", lo=60, hi=84, voices=4, rev=0.4, echo=0.25, pump=0.4, pattern=SG_ARP16,
              dyn=[(0, 4, 0.8), (4, 8, 0.9), (8, 16, 1.0)]),
            # gradnja nije prazna: supersaw tiho od prvog takta (uvod je bio 6 dB tiši od ostalih Arena u igri)
            P("pad", "saw", -29.0, inst="supersaw", lo=58, hi=74, voices=3, vel=0.6, rev=0.5, pump=0.55,
              dyn=[(0, 8, 0.55), (8, 16, 1.0)]),
            P("line", "lead", -22.0, inst="star_lead", vel=0.9, rev=0.6, echo=0.3, notes={
                8: "Bb5:1.5 D6:1.5 G5:1", 9: "G5:1.5 Bb5:1.5 D6:1", 10: "F5:1.5 A5:1.5 D6:1", 11: "C6:3 r:1",
                12: "D6:1.5 Bb5:1.5 G5:1", 13: "Bb5:1.5 G5:1.5 Eb5:1", 14: "E6:1.5 D6:1.5 C6:1", 15: "C6:2 Bb5:2"}),
            P("line", "hook", -26.0, inst="star_lead", vel=0.75, rev=0.6, echo=0.3, notes={
                4: "D5:1.5 F5:1.5 A5:1", 5: "G5:1.5 E5:1.5 C5:1", 6: "C6:1.5 A5:1.5 E5:1", 7: "C5:3 r:1"}),
        ],
    },
    "run": {
        "bpm": 90, "meter": "4/4",
        "chords": run_bars("Bbmaj7#11", "C/Bb", "Bbmaj7#11", "C/Bb", each=3),
        "mix": {"reverb": {"size": 0.94, "damp": 0.15, "pre": 0.05, "amount": 0.55, "bright": 1.2},
                "echo": {"beats": 0.75, "fb": 0.5, "lp": 3500.0, "amount": 0.35}, "tilt": (1000, 2.0, 2.0)},
        "parts": [
            P("arp", "pulse", -27.5, inst="synth_pluck", lo=62, hi=86, voices=4, rev=0.6, echo=0.4, pump=0.4, pattern=SG_ARP16),
            P("pad", "saw", -27.0, inst="supersaw", lo=50, hi=74, voices=5, rev=0.7, pump=0.4),
            P("pad", "choir", -32.0, inst="synth_choir", lo=62, hi=77, voices=3, rev=0.8),
            P("bass", "sub", -31.0, inst="sub", pattern=[(0, "R", 3.8, 0.8)]),
            P("drums", "beat", -31.0, rev=0.2, pattern={"kick808": [(0, 0.5), (2.5, 0.3)]}),
            P("line", "lead", -29.0, inst="star_lead", vel=0.85, rev=0.8, echo=0.4, notes={
                0: "D5:1.5 F5:1.5 A5:1", 3: "Bb5:1.5 A5:1.5 G5:1", 6: "D6:1.5 Bb5:1.5 G5:1", 9: "C6:4"}),
            P("amb", "sparkles", -37.0, layers=[("sparkles", {"rate": 1.6, "level": 0.035})]),
            P("amb", "meteors", -32.0, layers=[("meteor", {"at": 4.5}), ("meteor", {"at": 18.0, "seed": 137}),
                                                ("meteor", {"at": 27.0, "seed": 139})]),
            P("amb", "hum", -40.0, layers=[("cosmic_hum", {})]),
        ],
    },
}

# ═══ 8 · EMBER FEN — „Firelight Marsh" · modalni world (dorijski; Arena 7/8) ════
SONGS["ember_fen"] = {
    "title": "Firelight Marsh", "key": "D", "mode": "dorian",
    "feel": {"jitter": 1.5, "vel_spread": 1.3},   # slobodno, melizmatično
    "home": {
        "bpm": 62, "meter": "4/4",
        "chords": ["Dm9", "G/D", "Dm9", "Cadd9", "Dm9", "Fmaj7", "Em7", "Am7",
                   "Fmaj7", "G6", "Am7", "C", "Dm9", "G/D", "Em7@0 Am7@2", "Dm9"],
        "mix": {"reverb": {"size": 0.85, "damp": 0.6, "pre": 0.045, "amount": 0.4}, "tilt": (900, 2.0, -2.0)},
        "parts": [
            P("line", "duduk", -21.0, inst="duduk", vel=0.9, rev=0.6, notes={
                0: "~A4:3 G4:1/3 A4:1/3 G4:1/3", 1: "~B4:3 A4:1/3 B4:1/3 A4:1/3", 2: "~C5:2 A4:1 G4:0.5 F4:0.5",
                3: "~E4:3.5 D4:0.5", 4: "~A4:3 B4:1/3 C5:1/3 B4:1/3", 5: "~C5:2 ~E5:2",
                6: "~D5:3 C5:1/3 B4:1/3 A4:1/3", 7: "~B4:2 A4:1 r:1", 8: "A4:1/3 C5:1/3 E5:1/3 ~F5:2.5 E5:0.5",
                9: "~D5:3 E5:1/3 D5:1/3 B4:1/3", 10: "~C5:2 E5:1 G5:1", 11: "~E5:3 D5:1/3 E5:1/3 D5:1/3",
                12: "~F5:3 E5:0.5 D5:0.5", 13: "~B4:2 D5:1 B4:1", 14: "G4:1/3 A4:1/3 B4:1/3 ~G4:1 ~A4:2",
                15: "~D4:4"}),
            P("arp", "handpan", -25.0, inst="tongue", lo=57, hi=76, voices=4, rev=0.6,
              pattern=[(0, 0, 1.0, 0.6), (1.5, 2, 1.0, 0.45), (2.5, 1, 1.0, 0.45), (3, 3, 1.0, 0.4)]),
            P("tanpura", "tanpura", -30.0, root="D3", fifth="A2", period=4.4),
            P("line", "oud", -28.0, inst="oud", vel=0.8, rev=0.5, notes={7: "r:3 C5:0.5 A4:0.5", 15: "r:3 F4:0.5 E4:0.5"}),
            P("drums", "darbuka", -31.0, rev=0.3, active=[(8, 16)],
              pattern={"doum": [(0, 0.6), (2.5, 0.45)], "tek": [(1.5, 0.3), (2, 0.25), (3.5, 0.3)], "ka": [(3.75, 0.15)]},
              fills={11: {"tek": [(3.25, 0.25), (3.75, 0.3)]}, 15: {"tek": [(3, 0.3), (3.25, 0.32), (3.5, 0.36), (3.75, 0.4)]}}),
            P("drums", "riq", -37.0, rev=0.3, active=[(8, 16)], pattern={"riq": [(1, 0.2), (3, 0.2)]}),
            P("amb", "embers", -44.0, layers=[("crackle", {"rate": 4.0, "level": 0.15})]),
        ],
    },
    "arena": {
        "bpm": 150, "meter": "7/8",
        "chords": ["Dm", "C", "Dm", "G", "Dm", "C", "F", "G", "Dm", "Am", "C", "G", "F", "G", "Am", "C"],
        "mix": {"reverb": {"size": 0.55, "damp": 0.6, "pre": 0.02, "amount": 0.22}, "tilt": (900, 1.0, 0.0)},
        "parts": [
            P("drums", "darbuka", -25.0, rev=0.2,
              pattern={"doum": [(0, 1.0), (4, 0.8)], "tek": [(2, 0.7), (5, 0.5), (6, 0.6)], "ka": [(1, 0.35), (3, 0.35)]}),
            P("drums", "riq", -33.0, rev=0.2, pattern={"riq": [(0, 0.3), (2, 0.25), (4, 0.3)]}),
            P("arp", "handpan", -23.0, inst="tongue", lo=57, hi=77, voices=4, rev=0.4,
              pattern=[(0, 0, 1.5, 0.65), (2, 2, 1.5, 0.5), (4, 1, 1.0, 0.55), (5, 3, 1.0, 0.45), (6, 2, 1.0, 0.45)]),
            P("line", "lead", -22.0, inst="oud", vel=0.9, rev=0.35, notes={
                8: "A4:0.5 B4:0.5 A4:1 F4:2 E4:0.5 F4:0.5 D4:2", 9: "E4:2 C5:2 B4:0.5 C5:0.5 A4:2",
                10: "G4:0.5 A4:0.5 G4:1 E4:2 C4:0.5 D4:0.5 E4:2", 11: "D5:2 B4:2 A4:0.5 B4:0.5 G4:2",
                12: "C5:0.5 D5:0.5 C5:1 A4:2 G4:0.5 A4:0.5 F4:2", 13: "B4:2 D5:2 C5:0.5 B4:0.5 G4:2",
                14: "C5:0.5 D5:0.5 C5:1 E5:2 D5:0.5 C5:0.5 B4:2", 15: "E5:2 D5:1 C5:1 G4:3"}),
            P("line", "hook", -25.0, inst="duduk", vel=0.85, rev=0.4, notes={
                4: "~A4:4 G4:1 A4:1 G4:1", 5: "~E4:4 G4:3", 6: "~C5:4 A4:1 G4:1 F4:1", 7: "~B4:4 D5:3"}),
            P("bass", "low_oud", -27.0, inst="oud", lo=38, rev=0.2, pattern=[(0, "R", 2.0, 0.8), (4, "R", 2.0, 0.6)]),
        ],
    },
    "run": {
        "bpm": 60, "meter": "4/4",
        "chords": run_bars("Dm9", "G/D", "Fmaj7", "Cadd9"),
        "mix": {"reverb": {"size": 0.86, "damp": 0.55, "pre": 0.05, "amount": 0.45}, "tilt": (900, 1.0, -0.5)},
        "parts": [
            P("tanpura", "tanpura", -27.0, root="D3", fifth="A2", period=4.0),
            P("drone", "drone", -33.0, inst="drone", notes=["D2"]),
            P("line", "duduk", -28.0, inst="duduk", vel=0.85, rev=0.7, notes={
                0: "~A4:3 G4:1/3 A4:1/3 G4:1/3", 2: "~B4:3 A4:1/3 B4:1/3 A4:1/3", 4: "~C5:2 ~E5:2", 6: "~E4:3 r:1"}),
            P("drums", "heart", -30.0, rev=0.4, pattern={"doum": [(0, 0.6), (0.4, 0.4)]}),
            P("sprinkle", "oud", -33.0, inst="oud", notes=["D4", "F4", "A4", "C5", "E4"], gap=(2.5, 4.0), rev=0.6),
            P("amb", "embers", -39.0, layers=[("crackle", {"rate": 6.0, "level": 0.18})]),
            P("amb", "frogs", -33.0, layers=[("frog", {"at": 7.0}), ("frog", {"at": 21.5, "seed": 97})]),
            P("amb", "drips", -40.0, layers=[("drips", {"rate": 0.4})]),
        ],
    },
}

SEASON_ORDER = ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
                "moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
LEVELS = ["home", "arena", "run"]
