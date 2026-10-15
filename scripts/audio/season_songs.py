"""Merge Meadow — sezonska muzika: 8 sezona × 3 nivoa (home = hub, arena, run).

Svaka sezona ima svoj identitet (tonalitet, mjera, tempo, instrumenti, ambijent), a Arena i run
nose isti motiv kao home tema, da se sezona prepozna. Zapis (theory.py):
  akordi  po taktu: "Gmaj7", "D/F#", "Em7@0 A7@2" (@ = doba)
  melodija  {takt: "A5:2 F#5:1"} — nota:trajanje u dobama mjere (6/8 → osmine), r = pauza
Dijelovi aranžmana (music_gen.py): block, arp, line, bass, walk, pad, drums, hits, drone, amb.
Dizajn i tabela: docs/04-experience/muzika-sezone.md
"""


def P(kind, name, db, **kw):
    d = {"kind": kind, "name": name, "db": db}
    d.update(kw)
    return d


def eighths(beats=4, strong=0.5, weak=0.3):
    return [(k * 0.5, strong if k % 2 == 0 else weak) for k in range(beats * 2)]


def sixteenths(beats=4, v=0.3):
    return [(k * 0.25, v * (1.0 if k % 4 == 0 else 0.6)) for k in range(beats * 4)]


ARP8 = [(0, 0), (0.5, 1), (1, 2), (1.5, 3), (2, 1), (2.5, 2), (3, 3), (3.5, 2)]


def arp(pattern, dur=0.5, vel=0.6, accent=(0,)):
    return [(b, i, dur, vel * (1.15 if b in accent else 1.0)) for b, i in pattern]


SONGS = {}

# ═══ 1 · COUNTRY BLOOM — „Sunny Pasture" ═══════════════════════════════════════
# Topla polja i pašnjaci: F-dur, swing, el. klavir + harfa, Arena marimba + zviždaljka (C-dur).
SONGS["country_bloom"] = {
    "title": "Sunny Pasture", "key": "F", "mode": "major",
    "home": {
        "bpm": 84, "meter": "4/4", "swing": 0.58, "reverb": (0.3, 0.84, 0.4),
        "chords": ["Fmaj7", "Am7", "Bbmaj7", "C7sus4", "Fmaj7", "Am7", "Gm7", "C7",
                   "Dm7", "Am7", "Bbmaj7", "Fmaj7/A", "Gm7", "C7sus4", "Fmaj7", "C7"],
        "parts": [
            P("block", "keys", -24.0, inst="ep", lo=53, hi=72, strum=0.008, sections=[
                (0, 8, [(0, 1.4, 0.72), (1.5, 0.5, 0.5), (3, 0.9, 0.42)]),
                (8, 16, [(0, 2.4, 0.7), (2.5, 1.3, 0.45)])]),
            P("line", "melody", -21.0, inst="harp", vel=0.8, notes={
                0: "C5:1 r:0.5 A4:0.5 C5:1 D5:1", 1: "C5:1.5 A4:0.5 G4:1 A4:1",
                2: "F5:1 D5:0.5 C5:0.5 D5:2", 3: "C5:1 A4:1 G4:2",
                4: "C5:1 r:0.5 A4:0.5 C5:1 F5:1", 5: "E5:1.5 D5:0.5 C5:1 A4:1",
                6: "Bb4:1 A4:0.5 G4:0.5 F4:1 G4:1", 7: "A4:2 G4:1 E4:1",
                8: "D5:2 r:0.5 C5:0.5 A4:1", 9: "C5:3 E5:1", 10: "D5:1 F5:1 D5:1 C5:1", 11: "A4:3 C5:1",
                12: "Bb4:1 D5:1 G5:1.5 F5:0.5", 13: "F5:2 C5:2", 14: "A4:1 C5:0.5 A4:0.5 G4:1 F4:1",
                15: "G4:2 E4:1 G4:1"}),
            P("hits", "glock", -31.0, events=[(0, 0, "glock", "F6", 0.5, 1.0), (4, 0, "glock", "C6", 0.5, 1.0),
                                              (8, 0, "glock", "D6", 0.5, 1.0), (12, 0, "glock", "G6", 0.5, 1.0)]),
            P("bass", "bass", -27.0, inst="bass", approach=(4, 3.5),
              pattern=[(0, "R", 1.4, 0.9), (2, "5", 0.9, 0.65)]),
            P("drums", "drums", -30.0, wet=False, soft_bars=[8, 9, 10, 11], soft_drop=["kick"],
              pattern={"shaker": eighths(4, 0.11, 0.18), "kick": [(0, 0.55), (2.5, 0.4)],
                       "brush": [(1, 0.32), (3, 0.32)]}),
            P("amb", "birds", -44.0, wet=False, layers=[("birds", {"count": 5, "level": 0.08})]),
        ],
    },
    "arena": {
        "bpm": 100, "meter": "4/4", "swing": 0.54, "reverb": (0.22, 0.78, 0.45),
        "chords": ["C", "Am", "F", "G", "C", "Em", "F", "G", "Am", "F", "C", "G", "Am", "F", "Dm7", "G7"],
        "parts": [
            P("arp", "marimba", -22.0, inst="marimba", lo=55, hi=74, voices=4, octave_tail=True,
              pattern=arp([(0, 0), (0.5, 1), (1, 2), (1.5, 3), (2, 2), (2.5, 1), (3, 2), (3.5, 1)], 0.5, 0.55, (0, 2))),
            P("line", "lead", -26.0, inst="whistle", vel=0.9, notes={
                8: "E5:1 C5:1 A4:2", 9: "F5:1.5 E5:0.5 C5:2", 10: "G5:1 E5:1 C5:1 E5:1", 11: "D5:3 r:1",
                12: "E5:1 C5:1 A4:1 C5:1", 13: "A5:2 G5:1 F5:1", 14: "F5:1 E5:1 D5:2", 15: "B4:2 D5:1 G5:1"}),
            P("line", "echo", -30.0, inst="harp", vel=0.7, notes={
                4: "E5:1 r:0.5 C5:0.5 E5:1 G5:1", 5: "E5:1.5 B4:0.5 G4:2", 6: "A4:1 r:0.5 F4:0.5 A4:1 C5:1", 7: "B4:2 D5:2"}),
            P("bass", "bass", -27.0, inst="bass",
              pattern=[(0, "R", 1.0, 0.9), (1.5, "8", 0.4, 0.55), (2, "5", 0.8, 0.65), (3.5, "8", 0.4, 0.5)]),
            P("drums", "drums", -28.0, wet=False,
              pattern={"shaker": eighths(4, 0.11, 0.18), "kick": [(0, 0.6), (2, 0.5)], "brush": [(1, 0.38), (3, 0.38)]},
              odd_bars={"rim": [(3.5, 0.18)]}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.45, 0.88, 0.3),
        "chords": ["Fmaj9", "Dm9", "Bbmaj9", "C9sus4"],
        "pad": {"inst": "pad_warm", "lo": 48, "hi": 72, "voices": 5, "db": -26.0},
        "frag": {"inst": "harp", "notes": ["F5", "G5", "A5", "C6", "D6", "F6"], "gap": (2.2, 3.4), "db": -32.0},
        "hook": {"inst": "harp", "bars": ["C5:1 r:0.5 A4:0.5 C5:1 D5:1", "C5:1.5 A4:0.5 G4:1 A4:1", "F5:1 D5:0.5 C5:0.5 D5:2", "C5:1 A4:1 G4:2"], "beat_sec": 0.78, "offset": 1.6, "db": -31.0},
        "amb": [("wind", {"cutoff": 650, "cycles": 3}, -36.0), ("birds", {"count": 7, "level": 0.08}, -37.0)],
    },
}

# ═══ 2 · FROST ORCHARD — „Silver Waltz" ════════════════════════════════════════
# Hrskav zimski voćnjak, srebrni cvat: D-dur valcer 3/4, muzička kutija + harfa + pizzicato,
# lidijska iskra (#11, G#) za „mraz". Arena: polka pizzicato + praporci. Run: ledeni pad, fijuk.
SONGS["frost_orchard"] = {
    "title": "Silver Waltz", "key": "D", "mode": "major", "extra": ["G#"],
    "home": {
        "bpm": 88, "meter": "3/4", "reverb": (0.36, 0.88, 0.25),
        "chords": ["Dmaj7", "Bm7", "Gmaj7", "A7sus4", "Dmaj7", "F#m7", "E9", "A7",
                   "Gmaj7", "F#m7", "Em7", "A7", "Dmaj7", "Gmaj7#11", "Em7@0 A7@2", "Dadd9"],
        "parts": [
            P("line", "melody", -21.0, inst="music_box", vel=0.85, notes={
                0: "A5:2 F#5:1", 1: "D5:1.5 E5:0.5 F#5:1", 2: "B5:2 A5:1", 3: "G5:1 E5:1 D5:1",
                4: "A5:2 F#5:1", 5: "A5:1.5 B5:0.5 C#6:1", 6: "B5:1 G#5:1 E5:1", 7: "C#5:2 E5:1",
                8: "D6:2 B5:1", 9: "C#6:2 A5:1", 10: "B5:1 A5:1 G5:1", 11: "G5:1 F#5:1 E5:1",
                12: "F#5:2 A5:1", 13: "C#6:1 B5:1 D6:1", 14: "E5:1 G5:1 C#5:1", 15: "D5:3"}),
            P("block", "waltz", -26.0, inst="harp", lo=57, hi=74, voices=3, strum=0.012,
              sections=[(0, 16, [(1, 0.8, 0.5), (2, 0.8, 0.42)])]),
            P("bass", "bass", -28.0, inst="pizz_bass", pattern=[(0, "R", 1.0, 0.95)], alt_fifth=True),
            P("pad", "strings", -31.0, inst="strings", lo=62, hi=81, voices=3, vel=0.6),
            P("hits", "triangle", -34.0, wet=True, events=[(0, 0, "triangle", None, 0, 0.8), (8, 0, "triangle", None, 0, 0.7)]),
            P("drums", "sleigh", -35.0, wet=True, sparse=True, pattern={"sleigh": [(0, 0.4)]}, every=2),
            P("amb", "wind", -43.0, wet=False, layers=[("snow_wind", {})]),
        ],
    },
    "arena": {
        "bpm": 104, "meter": "4/4", "reverb": (0.25, 0.82, 0.3),
        "chords": ["D", "Bm", "G", "A", "D", "Bm", "Em7", "A7", "Gmaj7", "A", "F#m7", "Bm7", "G", "A", "D/F#@0 Em7@2", "A7"],
        "parts": [
            P("arp", "pizz", -22.0, inst="pizz", lo=57, hi=76, voices=3,
              pattern=arp([(0, 0), (0.5, 2), (1, 1), (1.5, 2), (2, 0), (2.5, 2), (3, 1), (3.5, 2)], 0.45, 0.6, (0, 2))),
            P("line", "lead", -25.0, inst="celesta", vel=0.9, notes={
                8: "B5:1 A5:0.5 B5:0.5 D6:2", 9: "C#6:1 B5:0.5 C#6:0.5 E6:2", 10: "A5:1 F#5:1 A5:1 C#6:1",
                11: "B5:3 r:1", 12: "D6:1 B5:1 G5:1 B5:1", 13: "C#6:1 A5:1 E5:1 A5:1",
                14: "F#5:1 A5:1 G5:1 B5:1", 15: "A5:2 C#6:1 E6:1"}),
            P("line", "hook", -28.0, inst="music_box", vel=0.8, notes={
                4: "A5:2 F#5:2", 5: "D5:2 F#5:2", 6: "G5:2 E5:2", 7: "C#5:2 E5:2"}),
            P("bass", "bass", -27.0, inst="pizz_bass", pattern=[(0, "R", 0.9, 0.95), (2, "5", 0.9, 0.8)]),
            P("drums", "drums", -29.0, wet=False,
              pattern={"sleigh": [(0, 0.22), (1, 0.32), (2, 0.22), (3, 0.32)], "kick": [(0, 0.5), (2, 0.45)],
                       "brush": [(1, 0.35), (3, 0.35)], "shaker": eighths(4, 0.08, 0.14)}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.5, 0.9, 0.2),
        "chords": ["Dmaj9", "Bm9", "Gmaj7#11", "A7sus4"],
        "pad": {"inst": "pad_icy", "lo": 57, "hi": 79, "voices": 5, "db": -27.0},
        "pad2": {"inst": "choir", "lo": 62, "hi": 76, "voices": 3, "db": -33.0},
        "frag": {"inst": "music_box", "notes": ["D5", "E5", "F#5", "A5", "B5", "D6"], "gap": (2.6, 4.0), "db": -33.0},
        "hook": {"inst": "music_box", "bars": ["A5:2 F#5:1", "D5:1.5 E5:0.5 F#5:1", "B5:2 A5:1", "G5:1 E5:1 D5:1"], "beat_sec": 0.8, "offset": 2.0, "db": -30.0},
        "amb": [("snow_wind", {}, -35.0), ("chimes", {"at": 5.5, "notes": ["D6", "F#6", "A6", "B6", "E6"]}, -33.0),
                ("chimes", {"at": 21.0, "notes": ["D6", "F#6", "A6", "B6", "E6"], "seed": 7}, -34.0)],
    },
}

# ═══ 3 · LANTERN MEADOW — „Lantern Walk" ═══════════════════════════════════════
# Sumrak, svici, papirne lampe u visokoj travi: Eb-dur pentatonika, bambusova flauta, koto,
# kalimba, okvirni bubanj. Arena: kalimba ostinato + woodblock. Run: cvrčci + svici.
SONGS["lantern_meadow"] = {
    "title": "Lantern Walk", "key": "Eb", "mode": "major", "melody_scale": "pentatonic",
    "home": {
        "bpm": 72, "meter": "4/4", "reverb": (0.34, 0.86, 0.35),
        "chords": ["Ebadd9", "Cm7", "Abmaj7", "Bb7sus4", "Ebadd9", "Gm7", "Abmaj7", "Bb7sus4",
                   "Cm7", "Abmaj7", "Fm7", "Bb7sus4", "Abmaj7", "Gm7", "Fm7@0 Bb7sus4@2", "Ebadd9"],
        "parts": [
            P("line", "melody", -21.0, inst="bamboo", vel=0.85, notes={
                0: "G5:1.5 F5:0.5 Eb5:1 Bb4:1", 1: "C5:2 Eb5:1 F5:1", 2: "G5:2.5 F5:0.5 Eb5:1", 3: "F5:3 r:1",
                4: "G5:1.5 F5:0.5 G5:1 Bb5:1", 5: "Bb5:2 G5:1 F5:1", 6: "C6:2 Bb5:1 G5:1", 7: "F5:2 Eb5:1 F5:1",
                8: "Eb6:2 C6:1 Bb5:1", 9: "C6:1.5 Bb5:0.5 G5:2", 10: "F5:1 G5:1 C6:2", 11: "Bb5:3 r:1",
                12: "G5:1.5 F5:0.5 Eb5:2", 13: "F5:1 G5:1 Bb5:2", 14: "C6:2 Bb5:1 F5:1", 15: "Eb5:4"}),
            P("arp", "koto", -25.0, inst="koto", lo=51, hi=70, voices=4,
              pattern=arp(ARP8, 0.5, 0.5, (0, 2))),
            P("arp", "kalimba", -32.0, inst="kalimba", lo=67, hi=84, voices=3,
              pattern=[(1.5, 2, 0.5, 0.6), (3.5, 1, 0.5, 0.5)]),
            P("pad", "rhodes", -31.0, inst="ep_soft", lo=55, hi=72, voices=4, vel=0.5),
            P("bass", "bass", -28.0, inst="bass", pattern=[(0, "R", 1.6, 0.85), (2, "5", 1.6, 0.6)]),
            P("drums", "drums", -31.0, wet=False,
              pattern={"frame": [(0, 0.8), (2.5, 0.45), (3, 0.3)], "shaker": eighths(4, 0.08, 0.13)}),
            P("hits", "cymbal", -34.0, wet=True, events=[(0, 0, "fcym", None, 0, 0.8), (8, 0, "fcym", None, 0, 0.7)]),
            P("amb", "crickets", -42.0, wet=False, layers=[("crickets", {"voices": 2, "level": 0.05})]),
        ],
    },
    "arena": {
        "bpm": 96, "meter": "4/4", "reverb": (0.26, 0.8, 0.4),
        "chords": ["Eb", "Cm7", "Abmaj7", "Bb7sus4", "Eb", "Cm7", "Fm7", "Bb7sus4",
                   "Abmaj7", "Bb", "Gm7", "Cm7", "Abmaj7", "Bb", "Fm7", "Bb7sus4"],
        "parts": [
            P("arp", "kalimba", -22.0, inst="kalimba", lo=63, hi=82, voices=4,
              pattern=arp([(0, 0), (0.5, 2), (1, 1), (1.5, 3), (2, 2), (2.5, 1), (3, 3), (3.5, 2)], 0.45, 0.6, (0, 2))),
            P("line", "lead", -25.0, inst="bamboo", vel=0.9, notes={
                8: "C6:1 Bb5:0.5 G5:0.5 Eb5:1 G5:1", 9: "F5:1 G5:0.5 F5:0.5 Bb5:2", 10: "G5:1 Bb5:1 C6:1 Bb5:1",
                11: "G5:3 r:1", 12: "Eb6:1 C6:1 Bb5:1 G5:1", 13: "F5:1 Bb5:1 C6:1 Bb5:1", 14: "C6:2 Eb6:1 C6:1",
                15: "Bb5:2 F5:2"}),
            P("line", "hook", -28.0, inst="koto", vel=0.8, notes={
                4: "G5:1.5 F5:0.5 Eb5:2", 5: "C5:2 Eb5:2", 6: "F5:2 C5:2", 7: "Bb4:2 F5:2"}),
            P("bass", "bass", -27.0, inst="upright",
              pattern=[(0, "R", 1.0, 0.9), (1.5, "5", 0.5, 0.55), (2, "R", 1.0, 0.75), (3.5, "8", 0.5, 0.5)]),
            P("drums", "drums", -28.0, wet=False,
              pattern={"frame": [(0, 0.85), (2, 0.7)], "wood": [(1.5, 0.35), (3.5, 0.35)],
                       "shaker": eighths(4, 0.1, 0.16), "conga": [(3, 0.35)], "conga_hi": [(3.5, 0.3)]}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.45, 0.88, 0.32),
        "chords": ["Ebmaj9", "Cm9", "Abmaj9", "Bb9sus4"],
        "pad": {"inst": "pad_warm", "lo": 48, "hi": 72, "voices": 5, "db": -26.5},
        "frag": {"inst": "kalimba", "notes": ["Eb5", "F5", "G5", "Bb5", "C6", "Eb6"], "gap": (2.4, 3.6), "db": -33.0},
        "hook": {"inst": "bamboo", "bars": ["G5:1.5 F5:0.5 Eb5:1 Bb4:1", "C5:2 Eb5:1 F5:1", "G5:2.5 F5:0.5 Eb5:1", "F5:3 r:1"], "beat_sec": 0.9, "offset": 1.4, "db": -31.0},
        "amb": [("crickets", {"voices": 3, "level": 0.05}, -37.0),
                ("sparkles", {"rate": 0.6, "lo": 2200, "hi": 3600, "level": 0.03}, -41.0)],
    },
}

# ═══ 4 · AMBER CANOPY — „Copper Leaves" ════════════════════════════════════════
# Kasno-jesenje sunce kroz krošnje: G-dur u 6/8, gitara prstima, klarinet, gudački bas,
# tamburin. Arena: jig (bendžo + violina + bodhrán). Run: šuštanje lišća, vjetar.
SONGS["amber_canopy"] = {
    "title": "Copper Leaves", "key": "G", "mode": "major",
    "home": {
        "bpm": 180, "meter": "6/8", "reverb": (0.26, 0.8, 0.45),
        "chords": ["G", "Em", "C", "D", "G", "Bm", "C", "D", "Em", "C", "Am7", "D", "C", "G/B", "Am7@0 D@3", "G"],
        "parts": [
            P("line", "melody", -21.0, inst="reed", vel=0.85, notes={
                0: "B4:3 D5:2 C5:1", 1: "B4:2 A4:1 G4:3", 2: "E5:3 D5:2 C5:1", 3: "D5:3 A4:3",
                4: "B4:3 D5:2 G5:1", 5: "F#5:3 D5:3", 6: "E5:2 D5:1 C5:2 E5:1", 7: "D5:6",
                8: "G5:3 F#5:2 E5:1", 9: "E5:3 G5:3", 10: "A5:2 G5:1 E5:3", 11: "F#5:3 A5:3",
                12: "G5:3 E5:2 D5:1", 13: "D5:3 B4:3", 14: "C5:3 A4:2 F#4:1", 15: "G4:6"}),
            P("arp", "guitar", -24.0, inst="guitar", lo=50, hi=67, voices=4,
              pattern=[(0, 0, 1.6, 0.7), (1, 2, 1.0, 0.45), (2, 3, 1.0, 0.42), (3, 1, 1.6, 0.6), (4, 2, 1.0, 0.45), (5, 3, 1.0, 0.42)]),
            P("bass", "cello", -28.0, inst="cello", pattern=[(0, "R", 2.8, 0.85), (3, "5", 2.8, 0.65)]),
            P("drums", "drums", -32.0, wet=False, soft_bars=[8, 9, 10, 11],
              pattern={"tamb": [(3, 0.35)], "shaker": [(1, 0.12), (2, 0.1), (4, 0.12), (5, 0.1)], "frame": [(0, 0.45)]}),
            P("amb", "leaves", -43.0, wet=False, layers=[("leaves", {"gusts": 4, "level": 0.1})]),
        ],
    },
    "arena": {
        "bpm": 228, "meter": "6/8", "reverb": (0.2, 0.78, 0.5),
        "chords": ["G", "C", "G", "D", "Em", "C", "D", "D", "G", "C", "Em", "D", "C", "G", "Am7", "D"],
        "parts": [
            P("arp", "banjo", -22.0, inst="banjo", lo=55, hi=74, voices=4,
              pattern=[(0, 0, 0.9, 0.7), (1, 2, 0.9, 0.5), (2, 1, 0.9, 0.5), (3, 0, 0.9, 0.62), (4, 2, 0.9, 0.5), (5, 3, 0.9, 0.5)]),
            P("line", "lead", -25.0, inst="fiddle", vel=0.85, notes={
                8: "D5:1 B4:1 G4:1 B4:1 D5:1 G5:1", 9: "E5:1 C5:1 E5:1 G5:2 E5:1", 10: "B5:2 A5:1 G5:1 F#5:1 E5:1",
                11: "F#5:3 A5:3", 12: "G5:1 E5:1 C5:1 E5:1 G5:1 C6:1", 13: "B5:2 A5:1 G5:3",
                14: "A5:1 G5:1 E5:1 C5:2 E5:1", 15: "D5:3 F#5:1 A5:1 C6:1"}),
            P("line", "hook", -28.0, inst="reed", vel=0.8, notes={
                4: "B4:3 G4:3", 5: "E5:3 C5:3", 6: "D5:3 A4:3", 7: "F#4:3 A4:3"}),
            P("bass", "bass", -27.0, inst="upright", pattern=[(0, "R", 2.0, 0.9), (3, "5", 2.0, 0.75)]),
            P("drums", "drums", -28.0, wet=False,
              pattern={"frame": [(0, 0.9), (3, 0.65), (5, 0.35)], "shaker": [(1, 0.15), (2, 0.12), (4, 0.15)]},
              odd_bars={"tamb": [(3, 0.3)]}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.38, 0.84, 0.42),
        "chords": ["Gadd9", "Em9", "Cmaj7", "D9sus4"],
        "pad": {"inst": "strings", "lo": 50, "hi": 72, "voices": 4, "db": -27.0},
        "frag": {"inst": "guitar", "notes": ["G4", "A4", "B4", "D5", "E5", "G5"], "gap": (2.3, 3.5), "db": -32.0},
        "hook": {"inst": "reed", "bars": ["B4:3 D5:2 C5:1", "B4:2 A4:1 G4:3", "E5:3 D5:2 C5:1", "D5:3 A4:3"], "beat_sec": 0.42, "offset": 2.0, "db": -31.0},
        "amb": [("leaves", {"gusts": 6, "level": 0.1}, -37.0), ("wind", {"cutoff": 520, "cycles": 2}, -38.0),
                ("birds", {"count": 3, "level": 0.06, "seed": 29}, -41.0)],
    },
}

# ═══ 5 · MOONLIT WARREN — „Moon Lullaby" ═══════════════════════════════════════
# Noć pod tihim mjesecom, jazbine: Ab-dur uspavanka 3/4, vibrafon + harfa + hor. Arena: noćni
# swing (kontrabas, četke, rhodes, vibrafon). Run: cvrčci, sova, zvijezde.
SONGS["moonlit_warren"] = {
    "title": "Moon Lullaby", "key": "Ab", "mode": "major",
    "home": {
        "bpm": 66, "meter": "3/4", "reverb": (0.38, 0.88, 0.35),
        "chords": ["Abmaj7", "Fm7", "Dbmaj7", "Eb7sus4", "Abmaj7", "Cm7", "Dbmaj7", "Eb7",
                   "Fm7", "Dbmaj7", "Bbm7", "Eb7", "Abmaj7", "Dbmaj7", "Bbm7@0 Eb7@2", "Abadd9"],
        "parts": [
            P("line", "melody", -21.0, inst="vibes", vel=0.85, notes={
                0: "C5:2 Eb5:1", 1: "Ab4:2 C5:1", 2: "F5:1.5 Eb5:0.5 Db5:1", 3: "Bb4:3",
                4: "C5:2 Eb5:1", 5: "G5:2 Eb5:1", 6: "F5:1 Eb5:1 Db5:1", 7: "Db5:2 Bb4:1",
                8: "Ab5:2 F5:1", 9: "F5:1.5 Eb5:0.5 C5:1", 10: "Db5:2 F5:1", 11: "Eb5:2 G4:1",
                12: "Eb5:2 C5:1", 13: "Ab5:2 F5:1", 14: "Db5:2 Bb4:1", 15: "Ab4:3"}),
            P("arp", "harp", -26.0, inst="harp", lo=51, hi=70, voices=4,
              pattern=arp([(0, 0), (0.5, 1), (1, 2), (1.5, 3), (2, 2), (2.5, 1)], 0.6, 0.5, (0,))),
            P("pad", "choir", -31.0, inst="choir", lo=56, hi=72, voices=3, vel=0.55),
            P("bass", "bass", -29.0, inst="pizz_bass", pattern=[(0, "R", 2.0, 0.85)]),
            P("amb", "night", -44.0, wet=False, layers=[("crickets", {"voices": 2, "level": 0.035, "seed": 47}),
                                                         ("sparkles", {"rate": 0.4, "level": 0.025})]),
        ],
    },
    "arena": {
        "bpm": 96, "meter": "4/4", "swing": 0.63, "reverb": (0.24, 0.82, 0.4),
        "chords": ["Abmaj7", "Fm7", "Bbm7", "Eb7", "Abmaj7", "Fm7", "Bbm7", "Eb7",
                   "Dbmaj7", "Dbm6", "Cm7", "F7", "Bbm7", "Eb7", "Abmaj7@0 F7@2", "Bbm7@0 Eb7@2"],
        "parts": [
            P("block", "rhodes", -25.0, inst="ep", lo=53, hi=70, strum=0.006,
              sections=[(0, 16, [(0, 1.2, 0.55), (1.5, 0.4, 0.38), (2.5, 1.2, 0.45)])]),
            P("walk", "bass", -26.0, inst="upright", vel=0.85),
            P("line", "lead", -24.0, inst="vibes", vel=0.9, notes={
                8: "F5:1 Ab5:1 C6:1.5 Ab5:0.5", 9: "Ab5:2 Bb5:1 Ab5:1", 10: "G5:1 Eb5:1 G5:1 Bb5:1",
                11: "A5:2 C6:1 Eb6:1", 12: "Db6:1.5 C6:0.5 Bb5:1 Ab5:1", 13: "G5:2 Bb5:1 Db6:1",
                14: "C6:2 A5:2", 15: "Bb5:1 Db6:1 G5:2"}),
            P("line", "hook", -28.0, inst="vibes", vel=0.75, notes={
                4: "C5:2 Eb5:2", 5: "Ab4:2 C5:2", 6: "F5:2 Db5:2", 7: "Bb4:4"}),
            P("drums", "drums", -29.0, wet=False,
              pattern={"ride": [(0, 0.24), (1, 0.28), (1.5, 0.17), (2, 0.24), (3, 0.28), (3.5, 0.17)],
                       "brush": [(1, 0.4), (3, 0.4)], "soft_kick": [(0, 0.35), (2.5, 0.25)]}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.5, 0.9, 0.3),
        "chords": ["Abmaj9", "Fm9", "Dbmaj9", "Eb9sus4"],
        "pad": {"inst": "pad_warm", "lo": 48, "hi": 70, "voices": 5, "db": -27.0},
        "pad2": {"inst": "choir", "lo": 60, "hi": 75, "voices": 3, "db": -32.0},
        "frag": {"inst": "vibes", "notes": ["Ab4", "C5", "Eb5", "F5", "Ab5", "C6"], "gap": (2.6, 3.8), "db": -32.0},
        "hook": {"inst": "vibes", "bars": ["C5:2 Eb5:1", "Ab4:2 C5:1", "F5:1.5 Eb5:0.5 Db5:1", "Bb4:3"], "beat_sec": 0.95, "offset": 2.0, "db": -30.0},
        "amb": [("crickets", {"voices": 3, "level": 0.04, "seed": 43}, -38.0), ("owl", {"at": 21.5}, -31.0),
                ("sparkles", {"rate": 0.7, "level": 0.03}, -40.0)],
    },
}

# ═══ 6 · CORAL TIDE GARDEN — „Seashell Bossa" ══════════════════════════════════
# Morska bašta, slani povjetarac: A-dur bossa nova, najlon gitara, flauta, rhodes, rim klik.
# Arena: calypso (steel pan, marimba, konge). Run: talasi, galebovi, mjehurići.
SONGS["coral_tide"] = {
    "title": "Seashell Bossa", "key": "A", "mode": "major",
    "home": {
        "bpm": 100, "meter": "4/4", "reverb": (0.26, 0.8, 0.45),
        "chords": ["Amaj7", "F#m7", "Bm7", "E7", "Amaj7", "F#m7", "Bm9", "E7sus4",
                   "Dmaj7", "C#m7", "Bm7", "E7", "C#m7", "F#m7", "Bm7@0 E7@2", "A6/9"],
        "parts": [
            P("line", "melody", -21.0, inst="flute", vel=0.85, notes={
                0: "E5:1.5 C#5:0.5 E5:1 F#5:1", 1: "C#5:2 B4:1 A4:1", 2: "D5:1.5 C#5:0.5 D5:1 F#5:1", 3: "E5:3 r:1",
                4: "E5:1.5 C#5:0.5 E5:1 A5:1", 5: "G#5:1.5 F#5:0.5 E5:2", 6: "D5:1 C#5:1 B4:1 D5:1", 7: "B4:3 r:1",
                8: "F#5:1.5 E5:0.5 F#5:1 A5:1", 9: "G#5:2 E5:2", 10: "F#5:1.5 E5:0.5 D5:2", 11: "B4:1 D5:1 E5:1 G#5:1",
                12: "E5:2 C#5:2", 13: "A5:1.5 G#5:0.5 F#5:2", 14: "D5:2 B4:1 G#4:1", 15: "A4:4"}),
            P("block", "guitar", -24.0, inst="guitar", lo=55, hi=71, voices=4, strum=0.01,
              sections=[(0, 16, [(0, 0.5, 0.55), (1.5, 0.5, 0.45), (2.5, 0.5, 0.45), (3.5, 0.4, 0.38)])]),
            P("pad", "rhodes", -31.0, inst="ep_soft", lo=57, hi=74, voices=4, vel=0.45),
            P("bass", "bass", -27.0, inst="upright",
              pattern=[(0, "R", 1.4, 0.9), (2, "5", 1.4, 0.72)], approach=(2, 3.5)),
            P("drums", "drums", -31.0, wet=False,
              pattern={"shaker": eighths(4, 0.1, 0.16), "soft_kick": [(0, 0.45), (2, 0.35)]},
              odd_bars={"rim": [(1, 0.22), (2.5, 0.22)]}, even_bars={"rim": [(0, 0.22), (1.5, 0.22), (3, 0.22)]}),
            P("amb", "sea", -45.0, wet=False, layers=[("waves", {"period": 8.0, "level": 0.5})]),
        ],
    },
    "arena": {
        "bpm": 112, "meter": "4/4", "reverb": (0.22, 0.78, 0.45),
        "chords": ["A", "D", "E7", "A", "F#m7", "D", "E7", "A", "D", "E", "C#m7", "F#m7", "Bm7", "E7", "A@0 D@2", "E7"],
        "parts": [
            P("arp", "marimba", -23.0, inst="marimba", lo=57, hi=76, voices=4,
              pattern=arp([(0, 0), (0.5, 2), (1, 1), (1.5, 2), (2, 3), (2.5, 2), (3, 1), (3.5, 2)], 0.45, 0.55, (0, 2))),
            P("line", "lead", -23.0, inst="steelpan", vel=0.9, notes={
                8: "F#5:1 A5:1 D6:1.5 A5:0.5", 9: "G#5:1 B5:1 E6:2", 10: "E6:1.5 C#6:0.5 G#5:1 E5:1",
                11: "F#5:3 r:1", 12: "D6:1 B5:1 A5:1 F#5:1", 13: "G#5:1 B5:1 D6:2", 14: "C#6:2 A5:2",
                15: "B5:1 G#5:1 E5:2"}),
            P("line", "hook", -27.0, inst="steelpan", vel=0.75, notes={
                4: "C#6:1.5 A5:0.5 C#6:2", 5: "D6:1.5 A5:0.5 F#5:2", 6: "E6:1.5 B5:0.5 G#5:2", 7: "A5:4"}),
            P("bass", "bass", -26.0, inst="bass",
              pattern=[(0, "R", 1.0, 0.9), (1.5, "5", 0.5, 0.6), (2, "R", 0.5, 0.7), (3, "8", 0.5, 0.6), (3.5, "5", 0.5, 0.6)]),
            P("drums", "drums", -27.0, wet=False,
              pattern={"conga": [(1.5, 0.5), (3, 0.45)], "slap": [(2.5, 0.45)], "conga_hi": [(3.5, 0.5)],
                       "shaker": eighths(4, 0.12, 0.18), "soft_kick": [(0, 0.5), (2, 0.45)]}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.4, 0.86, 0.4),
        "chords": ["Amaj9", "F#m9", "Dmaj9", "E9sus4"],
        "pad": {"inst": "pad_warm", "lo": 50, "hi": 73, "voices": 5, "db": -27.0},
        "frag": {"inst": "steelpan", "notes": ["A4", "B4", "C#5", "E5", "F#5", "A5"], "gap": (2.6, 3.8), "db": -32.0},
        "hook": {"inst": "flute", "bars": ["E5:1.5 C#5:0.5 E5:1 F#5:1", "C#5:2 B4:1 A4:1", "D5:1.5 C#5:0.5 D5:1 F#5:1", "E5:3 r:1"], "beat_sec": 0.7, "offset": 1.8, "db": -30.5},
        "amb": [("waves", {"period": 8.0, "level": 0.5}, -33.0), ("gull", {"at": 6.0}, -33.0),
                ("gull", {"at": 23.5, "seed": 77}, -34.0), ("bubbles", {"count": 5}, -41.0)],
    },
}

# ═══ 7 · STARFALL GLADE — „Falling Stars" ══════════════════════════════════════
# Latice koje hvataju noćno nebo, meteori: Bb lidijski (E♮), topli sintisajzerski pad, stakleni
# arpeđo, nebeski lead, sub bas. Arena: arp + puls. Run: iskre, meteori.
SONGS["starfall_glade"] = {
    "title": "Falling Stars", "key": "Bb", "mode": "lydian", "extra": ["Eb"],
    "home": {
        "bpm": 80, "meter": "4/4", "reverb": (0.4, 0.9, 0.25),
        "chords": ["Bbmaj7", "C/Bb", "Bbmaj7", "C/Bb", "Gm9", "Am7", "Dm7", "F",
                   "Gm7", "C/E", "Ebmaj7", "F7sus4", "Bbmaj7", "C/Bb", "Gm9@0 Fsus4@2", "Bbmaj9"],
        "parts": [
            P("line", "melody", -21.0, inst="star_lead", vel=0.85, notes={
                0: "D5:2 F5:1 A5:1", 1: "G5:2 E5:2", 2: "F5:1.5 D5:0.5 C5:1 D5:1", 3: "E5:4",
                4: "Bb5:2 A5:1 G5:1", 5: "C6:2 E5:2", 6: "A5:1.5 F5:0.5 D5:2", 7: "C5:3 r:1",
                8: "D6:2 Bb5:1 G5:1", 9: "E6:2 C6:2", 10: "D6:1.5 Bb5:0.5 G5:2", 11: "C6:2 Bb5:2",
                12: "A5:2 F5:1 D5:1", 13: "E5:2 G5:2", 14: "A5:2 Bb5:1 C6:1", 15: "D5:4"}),
            P("arp", "glass", -29.0, inst="glass", lo=70, hi=89, voices=4,
              pattern=[(k * 0.5, [0, 1, 2, 3, 2, 3, 1, 2][k], 0.5, 0.5 if k % 2 else 0.65) for k in range(8)]),
            P("pad", "synth", -27.0, inst="pad_synth", lo=53, hi=72, voices=4, vel=0.6),
            P("bass", "sub", -28.0, inst="sub", pattern=[(0, "R", 3.8, 0.9)]),
            P("drums", "drums", -33.0, wet=False, soft_bars=[0, 1, 2, 3],
              pattern={"soft_kick": [(0, 0.5), (2, 0.4)], "shaker": eighths(4, 0.06, 0.1)}),
            P("amb", "stars", -42.0, wet=True, layers=[("sparkles", {"rate": 0.8, "level": 0.03})]),
        ],
    },
    "arena": {
        "bpm": 108, "meter": "4/4", "reverb": (0.28, 0.85, 0.3),
        "chords": ["Bbmaj7", "C", "Dm7", "C", "Bbmaj7", "C", "Am7", "F",
                   "Gm7", "Ebmaj7", "Bbmaj7", "F", "Gm7", "Ebmaj7", "C", "Fsus4"],
        "parts": [
            P("arp", "pluck", -22.0, inst="synth_pluck", lo=58, hi=79, voices=4,
              pattern=arp([(0, 0), (0.5, 1), (1, 2), (1.5, 3), (2, 2), (2.5, 3), (3, 1), (3.5, 2)], 0.45, 0.55, (0, 2))),
            P("arp", "glass", -31.0, inst="glass", lo=74, hi=93, voices=3,
              pattern=[(k * 0.25, [0, 1, 2, 1][k % 4], 0.3, 0.45) for k in range(16)]),
            P("line", "lead", -24.0, inst="star_lead", vel=0.9, notes={
                8: "Bb5:1 D6:1 F6:1 D6:1", 9: "G5:1.5 Bb5:0.5 D6:2", 10: "F5:1 A5:1 C6:1 A5:1", 11: "C6:3 r:1",
                12: "D6:1 Bb5:1 G5:1 Bb5:1", 13: "D6:2 Bb5:2", 14: "E6:1.5 D6:0.5 C6:2", 15: "Bb5:2 C6:2"}),
            P("line", "hook", -28.0, inst="star_lead", vel=0.75, notes={
                4: "D5:2 F5:2", 5: "G5:2 E5:2", 6: "C6:2 A5:2", 7: "C5:4"}),
            P("bass", "bass", -26.0, inst="bass",
              pattern=[(k * 0.5, "8" if k == 7 else "R", 0.42, 0.85 if k % 2 == 0 else 0.6) for k in range(8)]),
            P("drums", "drums", -28.0, wet=False,
              pattern={"soft_kick": [(0, 0.55), (1, 0.4), (2, 0.55), (3, 0.4)], "clap": [(1, 0.3), (3, 0.3)],
                       "shaker": eighths(4, 0.1, 0.16)}),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.55, 0.92, 0.2),
        "chords": ["Bbmaj7#11", "Gm9", "Ebmaj7#11", "F9sus4"],
        "pad": {"inst": "pad_synth", "lo": 50, "hi": 72, "voices": 5, "db": -26.5},
        "pad2": {"inst": "choir", "lo": 62, "hi": 77, "voices": 3, "db": -33.0},
        "frag": {"inst": "glass", "notes": ["Bb5", "C6", "D6", "F6", "G6", "A6"], "gap": (2.0, 3.2), "db": -33.0},
        "hook": {"inst": "star_lead", "bars": ["D5:2 F5:1 A5:1", "Bb5:2 A5:1 G5:1", "D6:1.5 Bb5:0.5 G5:2", "C6:2 Bb5:2"], "beat_sec": 0.85, "offset": 1.6, "db": -30.0},
        "amb": [("sparkles", {"rate": 1.6, "level": 0.035}, -37.0), ("meteor", {"at": 4.5}, -32.0),
                ("meteor", {"at": 18.0, "seed": 137}, -32.0), ("meteor", {"at": 27.0, "seed": 139}, -33.0)],
    },
}

# ═══ 8 · EMBER FEN — „Firelight Marsh" ═════════════════════════════════════════
# Niska vatra nad močvarnim cvijećem: D dorijski (toplo-tajanstveno, ne strašno), tongue drum,
# niska flauta, bordun D–A, okvirni bubanj. Arena: ples oko vatre. Run: pucketanje, žabe.
SONGS["ember_fen"] = {
    "title": "Firelight Marsh", "key": "D", "mode": "dorian",
    "home": {
        "bpm": 70, "meter": "4/4", "reverb": (0.3, 0.84, 0.45),
        "chords": ["Dm9", "G/D", "Dm9", "Cadd9", "Dm9", "Fmaj7", "Em7", "Am7",
                   "Fmaj7", "G6", "Am7", "C", "Dm9", "G/D", "Em7@0 Am7@2", "Dm9"],
        "parts": [
            P("line", "melody", -21.0, inst="low_flute", vel=0.9, notes={
                0: "A4:1.5 G4:0.5 F4:1 E4:1", 1: "D4:2 B4:2", 2: "C5:2 A4:1 G4:1", 3: "G4:2 E4:2",
                4: "A4:1.5 G4:0.5 F4:1 A4:1", 5: "C5:2 E5:2", 6: "D5:1.5 B4:0.5 G4:2", 7: "A4:3 r:1",
                8: "A4:1 C5:1 F5:2", 9: "E5:1.5 D5:0.5 B4:2", 10: "C5:1 E5:1 G5:2", 11: "E5:2 D5:1 C5:1",
                12: "F5:2 E5:1 D5:1", 13: "B4:2 D5:2", 14: "G4:1 B4:1 C5:1 A4:1", 15: "D4:4"}),
            P("arp", "tongue", -25.0, inst="tongue", lo=57, hi=76, voices=4,
              pattern=arp([(0, 0), (0.5, 2), (1, 1), (1.5, 3), (2, 0), (2.5, 2), (3, 1), (3.5, 3)], 0.5, 0.5, (0, 2))),
            P("drone", "drone", -30.0, inst="drone", notes=["D2"]),
            P("bass", "bass", -29.0, inst="sub", pattern=[(0, "R", 3.6, 0.8)]),
            P("drums", "drums", -30.0, wet=False,
              pattern={"frame": [(0, 0.8), (1.5, 0.4), (2, 0.6)], "shaker": [(1, 0.12), (3, 0.12)]}),
            P("amb", "embers", -44.0, wet=False, layers=[("crackle", {"rate": 4.0, "level": 0.15})]),
            P("amb", "sparks", -41.0, wet=True, layers=[("sparkles", {"rate": 0.7, "lo": 1700, "hi": 3300, "level": 0.03, "seed": 151})]),
        ],
    },
    "arena": {
        "bpm": 96, "meter": "4/4", "reverb": (0.24, 0.8, 0.45),
        "chords": ["Dm", "G", "Dm", "C", "Dm", "G", "Am", "C", "F", "G", "Em", "Am", "F", "G", "Am", "C"],
        "parts": [
            P("arp", "tongue", -22.0, inst="tongue", lo=57, hi=77, voices=4,
              pattern=arp([(0, 0), (0.5, 2), (1, 1), (1.5, 2), (2, 0), (2.5, 3), (3, 1), (3.5, 2)], 0.45, 0.6, (0, 2))),
            P("line", "lead", -24.0, inst="low_flute", vel=0.95, oct=0, notes={
                8: "A4:1 C5:1 F5:1.5 E5:0.5", 9: "D5:1 B4:1 G4:2", 10: "B4:1.5 A4:0.5 G4:1 E4:1", 11: "A4:3 r:1",
                12: "C5:1 A4:1 F4:1 A4:1", 13: "B4:2 D5:2", 14: "E5:1.5 D5:0.5 C5:2", 15: "G4:2 E4:2"}),
            P("line", "hook", -28.0, inst="reed", vel=0.7, notes={
                4: "A4:1.5 G4:0.5 F4:2", 5: "D4:2 B4:2", 6: "C5:2 A4:2", 7: "G4:2 E4:2"}),
            P("bass", "bass", -26.0, inst="pizz_bass",
              pattern=[(0, "R", 1.0, 0.9), (1.5, "R", 0.5, 0.5), (2, "5", 1.0, 0.7), (3.5, "8", 0.5, 0.5)]),
            P("drums", "drums", -27.0, wet=False,
              pattern={"frame": [(0, 0.95), (2, 0.8), (2.5, 0.45)], "clap": [(1, 0.3), (3, 0.3)],
                       "shaker": eighths(4, 0.1, 0.16)}),
            P("amb", "sparks", -42.0, wet=True, layers=[("sparkles", {"rate": 0.9, "lo": 1700, "hi": 3300, "level": 0.03, "seed": 153})]),
        ],
    },
    "run": {
        "loop": 32.0, "reverb": (0.42, 0.86, 0.45),
        "chords": ["Dm9", "G/D", "Fmaj7", "Cadd9"],
        "pad": {"inst": "pad_warm", "lo": 48, "hi": 69, "voices": 4, "db": -27.5},
        "drone": {"inst": "drone", "notes": ["D2"], "db": -30.0},
        "frag": {"inst": "tongue", "notes": ["D4", "E4", "F4", "A4", "C5", "D5"], "gap": (2.6, 3.8), "db": -32.0},
        "hook": {"inst": "low_flute", "bars": ["A4:1.5 G4:0.5 F4:1 E4:1", "D4:2 B4:2", "C5:2 E5:2", "G4:2 E4:2"], "beat_sec": 0.95, "offset": 1.6, "db": -30.0},
        "amb": [("crackle", {"rate": 6.0, "level": 0.18}, -39.0), ("frog", {"at": 7.0}, -33.0),
                ("frog", {"at": 16.5, "seed": 97}, -34.0), ("frog", {"at": 26.0, "seed": 99}, -33.0),
                ("wind", {"cutoff": 380, "cycles": 2, "seed": 33}, -42.0)],
    },
}

SEASON_ORDER = ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
                "moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
LEVELS = ["home", "arena", "run"]
