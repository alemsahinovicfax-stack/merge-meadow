"""Merge Meadow — privremeni zvučni efekti (sinteza) + katalog za AudioManager.

Pokretanje iz roota repoa:
    python scripts/audio/sfx_gen.py              # svi "synth" efekti + katalog
    python scripts/audio/sfx_gen.py --only coin,merge
    python scripts/audio/sfx_gen.py --measure    # samo izmjeri postojeće fajlove (i prave) i upiši db
Pa import:  .\\scripts\\godot-import.ps1

Pravi zvuk: stavi WAV / OGG istog imena u game/assets/audio/sfx/, u katalogu
(game/data/audio/sounds.json) postavi "source": "real" i pokreni --measure. Generator
tada taj zvuk više ne dira. Karakter zvukova: docs/04-experience/audio-direction.md.
"""
import json
import math
import os
import random
import sys
import wave
import struct

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dsp import (SR, osc, fm, pluck, noise, lowpass, highpass, bandpass, env_exp, env_adsr,  # noqa: E402
                 env_swell, gain, db, mix, mix_into, soft_clip, fades, trim_tail, normalize,
                 echo, reverb, note_hz, semis, n_samples, write_wav, peak)

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_DIR = os.path.join(ROOT, "game", "assets", "audio", "sfx")
CATALOG = os.path.join(ROOT, "game", "data", "audio", "sounds.json")
RES_DIR = "res://assets/audio/sfx/"

# ── gradivni blokovi ──────────────────────────────────────────────────────────


def bell(f, sec=0.6, decay=0.25, ratio=3.5, index=1.4, index_end=0.15):
    """Staklasto zvono / „plink" (FM, neharmonijski odnos)."""
    return env_exp(fm(f, sec, ratio, index, index_end), 0.0015, decay)


def ep(f, sec=0.8, decay=0.45, index=0.9):
    """Mekano električno piano zvono (FM 1:1) — toplo, za akorde nagrada."""
    return env_exp(fm(f, sec, 1.0, index, 0.15), 0.004, decay)


def wood(f, sec=0.12, decay=0.035, drop=0.82):
    """Drveni „tok": dva moda drvenog bloka + kratak pad tona."""
    a = osc(f, sec, "sine", f * drop)
    b = osc(f * 2.76, sec, "sine", f * 2.76 * drop)
    return env_exp(mix((a, 0, 1.0), (b, 0, 0.35)), 0.001, decay)


def click(sec=0.012, fc=3000.0, q=1.2, seed=3):
    return env_exp(bandpass(noise(sec, seed), fc, q), 0.0005, sec * 0.35)


def pop(f0, f1, sec=0.14, decay=0.05, seed=5):
    """Mjehurić / pop: brz uspon tona pa pad, uz mali klik."""
    body = env_exp(osc(f0, sec, "sine", f1), 0.001, decay)
    over = env_exp(osc(f0 * 2.0, sec, "sine", f1 * 2.0), 0.001, decay * 0.5)
    return mix((body, 0, 1.0), (over, 0, 0.18), (click(0.008, 2500, 1.0, seed), 0, 0.25))


def thud(f0=150.0, f1=70.0, sec=0.14, decay=0.05, seed=7):
    body = env_exp(osc(f0, sec, "sine", f1), 0.001, decay)
    dust = env_exp(lowpass(noise(sec, seed), 700.0), 0.001, decay * 0.6)
    return mix((body, 0, 1.0), (dust, 0, 0.35))


def whoosh(sec=0.25, f0=600.0, f1=2400.0, q=1.4, seed=11, rise=0.4, fall=0.6):
    return env_swell(bandpass(noise(sec, seed, "pink"), f0, q, f1), rise, fall)


def sparkle(sec=0.6, count=7, fmin=2500.0, fmax=6000.0, seed=13, decay=0.08):
    rng = random.Random(seed)
    out = []
    for _ in range(count):
        f = rng.uniform(fmin, fmax)
        at = rng.uniform(0.0, sec * 0.75)
        mix_into(out, bell(f, 0.25, decay, ratio=2.0, index=0.6), at, rng.uniform(0.35, 0.8))
    return out


def grains(sec=0.5, count=20, fc=3500.0, q=2.0, seed=17, curve=1.0, glen=0.012):
    """Zrna šuma (sjemenke u vreći, lišće, mrvice)."""
    rng = random.Random(seed)
    out = [0.0] * n_samples(sec)
    for k in range(count):
        at = sec * (rng.random() ** curve) * 0.9
        g = env_exp(bandpass(noise(glen, rng.randint(1, 9999)), fc * rng.uniform(0.7, 1.4), q), 0.0005, glen * 0.4)
        mix_into(out, g, at, rng.uniform(0.4, 1.0))
    return out


def arp(notes, step=0.07, voice="pluck", sec=0.6, g=1.0, decay=0.3):
    out = []
    for i, name in enumerate(notes):
        f = note_hz(name) if isinstance(name, str) else name
        if voice == "pluck":
            v = env_exp(pluck(f, sec, 0.997, 0.55, seed=100 + i), 0.001, decay)
        elif voice == "bell":
            v = bell(f, sec, decay)
        elif voice == "ep":
            v = ep(f, sec, decay)
        else:
            v = env_exp(osc(f, sec, "tri"), 0.002, decay)
        mix_into(out, v, i * step, g)
    return out


# ── zvukovi ───────────────────────────────────────────────────────────────────
# Svaka funkcija vraća listu (ili listu varijanti). Kratko, mekano, „pastelno": drvo, zvona,
# trzaji, mjehurići — ništa oštro ni metalno.


def s_ui_tap():
    return mix((wood(880, 0.09, 0.03), 0, 1.0), (click(0.006, 3200), 0, 0.2))


def s_ui_back():
    return wood(620, 0.09, 0.03, 0.78)


def s_ui_tab():
    return mix((wood(980, 0.08, 0.025), 0, 0.8), (bell(note_hz("G6"), 0.25, 0.07, 2.0, 0.5), 0.01, 0.35))


def s_ui_swipe():
    return whoosh(0.22, 700, 2200, 1.2, seed=21, rise=0.35, fall=0.65)


def s_ui_open():
    return mix((arp(["C6", "G6"], 0.055, "pluck", 0.35, 1.0, 0.12), 0, 1.0),
               (whoosh(0.22, 500, 1800, 1.0, seed=23), 0, 0.35))


def s_ui_close():
    return mix((arp(["G5", "C5"], 0.05, "pluck", 0.3, 1.0, 0.1), 0, 1.0),
               (whoosh(0.18, 1600, 500, 1.0, seed=25, rise=0.2, fall=0.8), 0, 0.3))


def s_ui_toggle_on():
    return mix((env_exp(osc(660, 0.08, "sine"), 0.002, 0.03), 0, 1.0),
               (env_exp(osc(990, 0.1, "sine"), 0.002, 0.04), 0.055, 1.0))


def s_ui_toggle_off():
    return mix((env_exp(osc(990, 0.08, "sine"), 0.002, 0.03), 0, 1.0),
               (env_exp(osc(660, 0.1, "sine"), 0.002, 0.04), 0.055, 1.0))


def s_ui_slider():
    return env_exp(osc(1900, 0.03, "sine"), 0.0008, 0.008)


def s_ui_denied():
    a = env_exp(lowpass(osc(240, 0.12, "tri", 190), 1200), 0.002, 0.04)
    return mix((a, 0, 1.0), (a, 0.11, 0.8))


def s_ui_toast():
    return pop(650, 1150, 0.14, 0.045, seed=27)


def s_field_open():
    """Polje sezone se otvori: mekan uzlazni whoosh + dvije note harfe."""
    return mix((whoosh(0.45, 400, 2600, 0.9, seed=131, rise=0.55, fall=0.45), 0, 0.8),
               (arp(["F5", "C6"], 0.09, "pluck", 0.6, 0.6, 0.22), 0.18, 1.0))


def s_field_close():
    return mix((whoosh(0.38, 2400, 500, 0.9, seed=133, rise=0.3, fall=0.7), 0, 0.8),
               (arp(["C6", "F5"], 0.08, "pluck", 0.5, 0.5, 0.18), 0.05, 1.0))


def s_ui_play():
    chirp = env_exp(osc(420, 0.16, "tri", 1250), 0.003, 0.08)
    return mix((chirp, 0, 0.9), (bell(note_hz("C7"), 0.4, 0.12, 2.0, 0.7), 0.1, 0.5),
               (bell(note_hz("G6"), 0.4, 0.1, 2.0, 0.7), 0.13, 0.35))


# ekonomija


def s_coin():
    """Klasičan „plink" coina: dvije note zvona (B5 → E6)."""
    a = bell(note_hz("B5"), 0.25, 0.06, 2.0, 0.9)
    b = bell(note_hz("E6"), 0.5, 0.16, 2.0, 0.9)
    return mix((a, 0, 0.8), (b, 0.045, 1.0))


def s_coins_spend():
    chink = env_exp(bandpass(noise(0.05, 31), 3200, 2.0), 0.0005, 0.012)
    chord = mix((bell(note_hz("E6"), 0.7, 0.2, 2.0, 0.8), 0.03, 0.7),
                (bell(note_hz("G#6"), 0.7, 0.2, 2.0, 0.8), 0.05, 0.6),
                (bell(note_hz("B6"), 0.7, 0.22, 2.0, 0.8), 0.07, 0.6))
    drawer = thud(220, 120, 0.12, 0.03, seed=33)
    return mix((chink, 0, 0.7), (chord, 0, 1.0), (drawer, 0.02, 0.35))


def s_purchase_ok():
    body = arp(["C5", "E5", "G5", "C6"], 0.075, "ep", 1.0, 1.0, 0.45)
    return mix((echo(body, 0.11, 0.35, 0.25, 3), 0, 1.0), (sparkle(0.8, 6, 3000, 6000, seed=35), 0.25, 0.35))


def s_purchase_fail():
    return arp(["E5", "C5"], 0.13, "tri", 0.4, 1.0, 0.12)


def s_unlock():
    run = arp(["G4", "C5", "E5", "G5", "C6"], 0.06, "pluck", 0.9, 1.0, 0.35)
    chord = mix((ep(note_hz("C5"), 1.2, 0.6), 0, 0.5), (ep(note_hz("E5"), 1.2, 0.6), 0, 0.45),
                (ep(note_hz("G5"), 1.2, 0.6), 0, 0.45))
    return mix((run, 0, 1.0), (chord, 0.3, 0.8), (sparkle(0.9, 9, 3000, 7000, seed=37), 0.3, 0.4))


def s_gift():
    ribbon = whoosh(0.18, 900, 3500, 1.2, seed=39)
    return mix((ribbon, 0, 0.6), (arp(["E6", "G6", "C7"], 0.07, "bell", 0.6, 0.8, 0.14), 0.12, 1.0),
               (pop(500, 1000, 0.12, 0.04, seed=41), 0.08, 0.6))


def s_reward_tick():
    return env_exp(pluck(note_hz("A6"), 0.15, 0.995, 0.7, seed=43), 0.0005, 0.04)


def s_wear():
    swish = whoosh(0.35, 600, 4000, 1.0, seed=45, rise=0.5, fall=0.5)
    gliss = arp(["C6", "E6", "G6"], 0.06, "bell", 0.5, 0.7, 0.12)
    return mix((swish, 0, 0.5), (gliss, 0.08, 1.0))


def s_upgrade():
    return mix((arp(["C5", "D5", "E5", "G5", "C6"], 0.05, "tri", 0.4, 0.8, 0.07), 0, 1.0),
               (bell(note_hz("C7"), 0.6, 0.2, 2.0, 0.8), 0.26, 0.6))


# Arena


def s_seed_pick():
    return mix((env_exp(osc(480, 0.06, "sine", 720), 0.001, 0.02), 0, 1.0), (click(0.006, 2200), 0, 0.3))


def s_seed_drop():
    return thud(190, 115, 0.1, 0.03, seed=47)


def s_seed_wobble():
    return env_exp(osc(330, 0.32, "sine", 250, vib_rate=17, vib_depth=0.06), 0.003, 0.11)


def s_merge():
    """Sočan pop spajanja (T2); AudioManager diže ton s combom."""
    return mix((pop(380, 920, 0.18, 0.06, seed=49), 0, 1.0),
               (bell(note_hz("E6"), 0.3, 0.06, 2.0, 0.5), 0.015, 0.25))


def s_merge_t3():
    chord = mix((bell(note_hz("C6"), 1.2, 0.35, 3.0, 1.0), 0.0, 0.6),
                (bell(note_hz("E6"), 1.2, 0.35, 3.0, 1.0), 0.04, 0.55),
                (bell(note_hz("G6"), 1.2, 0.35, 3.0, 1.0), 0.08, 0.55),
                (bell(note_hz("C7"), 1.2, 0.4, 3.0, 1.0), 0.12, 0.5))
    bloom = env_exp(osc(130, 0.6, "sine", 110), 0.01, 0.2)
    shimmer = env_swell(highpass(noise(0.9, 51), 6000), 0.2, 0.8)
    return mix((chord, 0, 1.0), (bloom, 0, 0.25), (shimmer, 0.05, 0.1), (sparkle(1.0, 8, 4000, 8000, seed=53), 0.15, 0.3))


def s_crystal_fly():
    return mix((whoosh(0.55, 700, 5200, 1.6, seed=55, rise=0.6, fall=0.4), 0, 0.7),
               (sparkle(0.55, 6, 4000, 8000, seed=57, decay=0.05), 0.1, 0.4))


def s_pour():
    """Sjemenke se prospu iz korpe: zrna koja se prorjeđuju + mekan „šuš"."""
    rattle = grains(0.75, 46, 3800, 2.2, seed=59, curve=1.7)
    shh = env_swell(bandpass(noise(0.6, 61, "pink"), 2500, 0.8), 0.15, 0.85)
    return lowpass(mix((rattle, 0, 1.0), (shh, 0, 0.35)), 7000)


def s_seed_land():
    out = []
    for k, (f0, f1) in enumerate([(820, 560), (900, 610), (760, 520)]):
        out.append(mix((env_exp(osc(f0, 0.05, "sine", f1), 0.0008, 0.012), 0, 1.0), (click(0.005, 2600, 1.0, 63 + k), 0, 0.25)))
    return out


def s_vacuum():
    w = env_swell(bandpass(noise(0.38, 65, "pink"), 3200, 1.3, 600), 0.85, 0.15)
    return mix((w, 0, 1.0), (pop(700, 300, 0.1, 0.03, seed=67), 0.33, 0.4))


def s_field_clear():
    notes = ["C6", "D6", "E6", "G6", "A6", "C7", "D7", "E7"]
    gliss = arp(notes, 0.06, "bell", 0.8, 0.7, 0.18)
    shimmer = env_swell(highpass(noise(1.0, 69), 5000), 0.3, 0.7)
    return mix((gliss, 0, 1.0), (shimmer, 0, 0.1), (sparkle(1.0, 10, 4000, 8000, seed=71), 0.2, 0.3))


def s_gate_open():
    return mix((ep(note_hz("G5"), 0.9, 0.4), 0, 0.8), (ep(note_hz("D6"), 0.9, 0.4), 0.09, 0.8),
               (sparkle(0.6, 5, 3500, 7000, seed=73), 0.12, 0.3))


# Muncher (Nibbs)


def s_muncher_wake():
    pop_up = env_exp(osc(190, 0.08, "sine", 620), 0.001, 0.03)
    squeak = env_exp(osc(1250, 0.16, "sine", 1800, vib_rate=24, vib_depth=0.04), 0.004, 0.06)
    dirt = grains(0.25, 12, 1400, 1.5, seed=75, curve=1.3, glen=0.015)
    return mix((pop_up, 0, 1.0), (squeak, 0.06, 0.55), (dirt, 0.02, 0.5))


def s_muncher_awake():
    trill = []
    for i, f in enumerate([660, 780, 660, 880]):
        mix_into(trill, env_exp(osc(f, 0.09, "soft_square"), 0.002, 0.04), i * 0.075, 0.6)
    nyeh = env_exp(lowpass(osc(520, 0.3, "saw", 470, vib_rate=11, vib_depth=0.05), 2200), 0.01, 0.14)
    return mix((whoosh(0.3, 400, 1600, 1.0, seed=77), 0, 0.4), (trill, 0.05, 0.8), (nyeh, 0.38, 0.6))


def s_muncher_chomp():
    out = []
    for k in range(2):
        crunch = env_exp(bandpass(noise(0.08, 79 + k), 1500 + 300 * k, 1.1), 0.0008, 0.02)
        snap = env_exp(osc(170, 0.06, "sine", 110), 0.001, 0.02)
        out.append(mix((crunch, 0, 1.0), (snap, 0, 0.6), (grains(0.12, 5, 2600, 2.0, seed=83 + k), 0.02, 0.4)))
    return out


def s_muncher_hmph():
    voice = env_adsr(bandpass(osc(310, 0.32, "saw", 190), 750, 1.4), 0.01, 0.08, 0.6, 0.14)
    puff = env_exp(lowpass(noise(0.18, 85), 1500), 0.005, 0.06)
    return mix((voice, 0, 1.0), (puff, 0.05, 0.45))


def s_muncher_freeze():
    crackle = grains(0.22, 24, 6000, 3.0, seed=87, curve=0.8, glen=0.006)
    ping = bell(2480, 0.7, 0.2, 3.7, 1.6, 0.2)
    whomp = env_exp(osc(160, 0.25, "sine", 90), 0.003, 0.07)
    return mix((crackle, 0, 0.8), (ping, 0.02, 0.6), (whomp, 0, 0.5))


def s_muncher_thaw():
    rng = random.Random(89)
    tinks = []
    for _ in range(9):
        mix_into(tinks, bell(rng.uniform(2200, 5200), 0.3, 0.05, 3.3, 1.2, 0.2), rng.uniform(0.0, 0.22), rng.uniform(0.4, 0.9))
    crash = env_exp(highpass(noise(0.4, 91), 3000), 0.002, 0.09)
    return mix((tinks, 0, 1.0), (crash, 0, 0.35))


def s_muncher_yawn():
    return env_adsr(osc(880, 0.65, "sine", 440, vib_rate=6, vib_depth=0.015), 0.08, 0.1, 0.8, 0.3)


# Pip (događaji iz animations.json: sfx:land, pop, sneeze, bonk, thump, cough, blow)


def s_pip_land():
    return thud(150, 90, 0.1, 0.035, seed=93)


def s_pip_pop():
    return pop(560, 1250, 0.12, 0.04, seed=95)


def s_pip_sneeze():
    ah = env_adsr(lowpass(osc(620, 0.16, "tri", 840), 2500), 0.02, 0.05, 0.6, 0.06)
    choo = env_exp(bandpass(noise(0.16, 97), 3200, 1.0, 1500), 0.002, 0.05)
    squeak = env_exp(osc(1500, 0.07, "sine", 1100), 0.002, 0.025)
    return mix((ah, 0, 0.45), (choo, 0.17, 1.0), (squeak, 0.19, 0.35))


def s_pip_bonk():
    return mix((wood(520, 0.16, 0.05, 0.75), 0, 1.0), (thud(160, 100, 0.1, 0.03, seed=99), 0, 0.4))


def s_pip_thump():
    return thud(120, 70, 0.14, 0.05, seed=101)


def s_pip_cough():
    k = env_exp(bandpass(noise(0.06, 103), 1300, 1.2), 0.003, 0.02)
    return mix((k, 0, 1.0), (k, 0.1, 0.8))


def s_pip_blow():
    return lowpass(env_swell(bandpass(noise(0.45, 105, "pink"), 1600, 0.7), 0.25, 0.75), 5000)


# Run


def s_run_go():
    rise = env_exp(osc(500, 0.22, "tri", 1050), 0.004, 0.12)
    return mix((rise, 0, 0.8), (arp(["C5", "G5", "C6"], 0.05, "pluck", 0.5, 0.8, 0.2), 0.08, 1.0))


def s_lane():
    return whoosh(0.13, 1400, 3000, 1.3, seed=107, rise=0.3, fall=0.7)


def s_run_seed():
    return mix((env_exp(pluck(note_hz("A5"), 0.25, 0.996, 0.6, seed=109), 0.0005, 0.08), 0, 1.0),
               (pop(600, 900, 0.08, 0.025, seed=111), 0, 0.4))


def s_bush():
    rustle = grains(0.3, 26, 3000, 1.6, seed=113, curve=0.9, glen=0.02)
    return mix((rustle, 0, 0.8), (bell(note_hz("A6"), 0.4, 0.12, 2.0, 0.8), 0.12, 0.6))


def s_run_hit():
    return mix((wood(300, 0.25, 0.07, 0.7), 0, 1.0), (thud(110, 60, 0.25, 0.08, seed=115), 0, 0.8),
               (grains(0.2, 8, 1800, 1.4, seed=117), 0.02, 0.3))


def s_run_fail():
    out = []
    for i, name in enumerate(["G4", "E4", "C4"]):
        v = env_adsr(osc(note_hz(name), 0.32, "tri", vib_rate=5, vib_depth=0.012), 0.01, 0.06, 0.7, 0.18)
        mix_into(out, lowpass(v, 2400), i * 0.2, 0.9)
    return out


def s_run_finish():
    run = arp(["C5", "E5", "G5", "C6"], 0.08, "pluck", 0.9, 1.0, 0.3)
    chord = mix((ep(note_hz("C5"), 1.4, 0.7), 0, 0.5), (ep(note_hz("E5"), 1.4, 0.7), 0, 0.45),
                (ep(note_hz("G5"), 1.4, 0.7), 0, 0.45), (ep(note_hz("C6"), 1.4, 0.7), 0, 0.4))
    return mix((run, 0, 1.0), (chord, 0.32, 0.9), (sparkle(1.0, 10, 3000, 7000, seed=119), 0.35, 0.35))


def s_revive():
    gliss = arp(["C5", "E5", "G5", "C6", "E6", "G6"], 0.05, "bell", 0.6, 0.6, 0.15)
    shimmer = env_swell(highpass(noise(0.9, 121), 4500), 0.6, 0.4)
    return mix((gliss, 0, 1.0), (shimmer, 0, 0.15), (sparkle(0.9, 8, 3000, 7000, seed=123), 0.2, 0.35))


# Loot / Journal


def s_loot_reveal():
    return mix((pop(500, 1000, 0.12, 0.04, seed=125), 0, 0.8), (bell(note_hz("C6"), 0.4, 0.1, 2.0, 0.7), 0.02, 0.6))


def s_loot_double():
    return mix((arp(["G5", "C6", "E6", "G6"], 0.05, "bell", 0.7, 0.7, 0.16), 0, 1.0),
               (sparkle(0.8, 9, 3500, 7500, seed=127), 0.1, 0.4))


def s_discover():
    return mix((arp(["A5", "C6", "E6"], 0.08, "bell", 0.7, 0.8, 0.2), 0, 1.0),
               (sparkle(0.7, 6, 3500, 7000, seed=129), 0.15, 0.35))


# ── katalog ───────────────────────────────────────────────────────────────────
# cat → ciljna kratkoročna glasnoća (najglasnijih 150 ms, K-ponderisano, dBFS). UI je tih, nagrade najglasnije.
TARGET = {"ui": -23.0, "soft": -21.0, "game": -18.0, "reward": -16.0, "big": -15.0}
# Ručne korekcije poslije slušanja / mjerenja pravog miksa (dB): šum sipanja i led su
# u miksu iz igre bili najglasniji trenuci (audio_smoke + snimak Master busa, 2026-10-14).
TRIM = {"pour": -3.0, "muncher_thaw": -2.5, "muncher_freeze": -1.0, "seed_land": -2.0,
        "muncher_chomp": -5.0, "run_seed": -3.0}
MAX_DB = -0.5


def target_db(sound_id, kind, loud):
    return round(min(MAX_DB, TARGET[kind] - loud + TRIM.get(sound_id, 0.0)), 1)

# id: (funkcija, kategorija, {pitch: [min,max], cooldown_ms, max, group, chain})
SOUNDS = {
    "ui_tap": (s_ui_tap, "ui", {"pitch": [0.96, 1.05], "cooldown_ms": 40, "max": 3}),
    "ui_back": (s_ui_back, "ui", {"pitch": [0.97, 1.03], "cooldown_ms": 60}),
    "ui_tab": (s_ui_tab, "ui", {"pitch": [0.98, 1.02], "cooldown_ms": 120, "group": "nav"}),
    "ui_swipe": (s_ui_swipe, "ui", {"pitch": [0.92, 1.08], "cooldown_ms": 150, "group": "nav"}),
    "ui_open": (s_ui_open, "ui", {"cooldown_ms": 150}),
    "ui_close": (s_ui_close, "ui", {"cooldown_ms": 150}),
    "ui_toggle_on": (s_ui_toggle_on, "ui", {"cooldown_ms": 60}),
    "ui_toggle_off": (s_ui_toggle_off, "ui", {"cooldown_ms": 60}),
    "ui_slider": (s_ui_slider, "ui", {"pitch": [0.9, 1.1], "cooldown_ms": 55}),
    "ui_denied": (s_ui_denied, "soft", {"cooldown_ms": 250}),
    "ui_toast": (s_ui_toast, "ui", {"pitch": [0.95, 1.05], "cooldown_ms": 200}),
    "ui_play": (s_ui_play, "game", {"cooldown_ms": 300}),
    "field_open": (s_field_open, "soft", {"cooldown_ms": 300}),
    "field_close": (s_field_close, "soft", {"cooldown_ms": 300}),
    "coin": (s_coin, "game", {"pitch": [0.99, 1.01], "cooldown_ms": 35, "max": 4, "chain": {"window_ms": 700, "step": 1, "max_steps": 7}}),
    "coins_spend": (s_coins_spend, "reward", {"cooldown_ms": 200}),
    "purchase_ok": (s_purchase_ok, "reward", {"cooldown_ms": 500, "duck": [-8.0, 1.2]}),
    "purchase_fail": (s_purchase_fail, "soft", {"cooldown_ms": 400}),
    "unlock": (s_unlock, "big", {"cooldown_ms": 600, "duck": [-9.0, 1.4]}),
    "gift": (s_gift, "reward", {"cooldown_ms": 400}),
    "reward_tick": (s_reward_tick, "ui", {"cooldown_ms": 30, "max": 3, "chain": {"window_ms": 300, "step": 1, "max_steps": 12}}),
    "wear": (s_wear, "reward", {"cooldown_ms": 250}),
    "upgrade": (s_upgrade, "reward", {"cooldown_ms": 300}),
    "seed_pick": (s_seed_pick, "ui", {"pitch": [0.93, 1.08], "cooldown_ms": 50}),
    "seed_drop": (s_seed_drop, "soft", {"pitch": [0.92, 1.08], "cooldown_ms": 50}),
    "seed_wobble": (s_seed_wobble, "soft", {"pitch": [0.95, 1.05], "cooldown_ms": 120}),
    "merge": (s_merge, "game", {"pitch": [0.98, 1.02], "cooldown_ms": 40, "max": 3, "chain": {"window_ms": 2500, "step": 1, "max_steps": 9}}),
    "merge_t3": (s_merge_t3, "big", {"cooldown_ms": 200, "duck": [-7.0, 1.0]}),
    "crystal_fly": (s_crystal_fly, "soft", {"cooldown_ms": 200}),
    "pour": (s_pour, "game", {"pitch": [0.95, 1.05], "cooldown_ms": 400}),
    "seed_land": (s_seed_land, "ui", {"pitch": [0.9, 1.15], "cooldown_ms": 30, "max": 3}),
    "vacuum": (s_vacuum, "soft", {"pitch": [0.93, 1.07], "cooldown_ms": 90, "max": 2}),
    "field_clear": (s_field_clear, "big", {"cooldown_ms": 800, "duck": [-6.0, 1.0]}),
    "gate_open": (s_gate_open, "reward", {"cooldown_ms": 800}),
    "muncher_wake": (s_muncher_wake, "game", {"cooldown_ms": 300}),
    "muncher_awake": (s_muncher_awake, "game", {"cooldown_ms": 800}),
    "muncher_chomp": (s_muncher_chomp, "game", {"pitch": [0.92, 1.08], "cooldown_ms": 120, "max": 2}),
    "muncher_hmph": (s_muncher_hmph, "game", {"pitch": [0.95, 1.05], "cooldown_ms": 500}),
    "muncher_freeze": (s_muncher_freeze, "game", {"cooldown_ms": 300}),
    "muncher_thaw": (s_muncher_thaw, "game", {"cooldown_ms": 300}),
    "muncher_yawn": (s_muncher_yawn, "soft", {"cooldown_ms": 1500}),
    "pip_land": (s_pip_land, "soft", {"pitch": [0.93, 1.07], "cooldown_ms": 150}),
    "pip_pop": (s_pip_pop, "soft", {"pitch": [0.95, 1.08], "cooldown_ms": 150}),
    "pip_sneeze": (s_pip_sneeze, "soft", {"pitch": [0.96, 1.06], "cooldown_ms": 600}),
    "pip_bonk": (s_pip_bonk, "soft", {"pitch": [0.95, 1.05], "cooldown_ms": 300}),
    "pip_thump": (s_pip_thump, "soft", {"pitch": [0.95, 1.05], "cooldown_ms": 200}),
    "pip_cough": (s_pip_cough, "soft", {"cooldown_ms": 600}),
    "pip_blow": (s_pip_blow, "soft", {"cooldown_ms": 600}),
    "run_go": (s_run_go, "game", {"cooldown_ms": 500}),
    "lane": (s_lane, "ui", {"pitch": [0.92, 1.08], "cooldown_ms": 70}),
    "run_seed": (s_run_seed, "game", {"pitch": [0.97, 1.03], "cooldown_ms": 40, "max": 3, "chain": {"window_ms": 900, "step": 2, "max_steps": 5}}),
    "bush": (s_bush, "game", {"cooldown_ms": 200}),
    "run_hit": (s_run_hit, "game", {"cooldown_ms": 300}),
    "run_fail": (s_run_fail, "reward", {"cooldown_ms": 800, "duck": [-10.0, 1.4]}),
    "run_finish": (s_run_finish, "big", {"cooldown_ms": 800, "duck": [-10.0, 1.6]}),
    "revive": (s_revive, "reward", {"cooldown_ms": 600, "duck": [-6.0, 1.0]}),
    "loot_reveal": (s_loot_reveal, "game", {"cooldown_ms": 60, "chain": {"window_ms": 600, "step": 2, "max_steps": 6}}),
    "loot_double": (s_loot_double, "reward", {"cooldown_ms": 500}),
    "discover": (s_discover, "reward", {"cooldown_ms": 300}),
}


def load_catalog():
    if os.path.exists(CATALOG):
        with open(CATALOG, encoding="utf-8") as f:
            return json.load(f)
    return {"schema": 1, "sfx": {}, "music": {}}


def k_weight(sig):
    """Približno K-ponderisanje (EBU R128): bez tutnjave ispod ~60 Hz, +4 dB iznad ~1,5 kHz —
    uho šum i visoke tonove čuje glasnije nego čist RMS."""
    hp = highpass(sig, 60.0)
    shelf = highpass(hp, 1500.0)
    return [a + 0.585 * b for a, b in zip(hp, shelf)]


def short_term_db(sig):
    """Najglasnijih 150 ms (K-ponderisan RMS) u dBFS — mjera za izjednačavanje glasnoće
    (kratki zvukovi: cijela dužina)."""
    sig = k_weight(sig)
    w = n_samples(0.15)
    if len(sig) <= w:
        r = math.sqrt(sum(x * x for x in sig) / max(1, len(sig)))
    else:
        acc = sum(x * x for x in sig[:w])
        best = acc
        for i in range(w, len(sig)):
            acc += sig[i] * sig[i] - sig[i - w] * sig[i - w]
            best = max(best, acc)
        r = math.sqrt(best / w)
    return 20.0 * math.log10(max(r, 1e-9))


def read_wav(path):
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        ch = w.getnchannels()
        sw = w.getsampwidth()
        raw = w.readframes(n)
    if sw != 2:
        return []
    vals = struct.unpack("<%dh" % (len(raw) // 2), raw)
    if ch == 2:
        vals = [(vals[i] + vals[i + 1]) * 0.5 for i in range(0, len(vals), 2)]
    return [v / 32768.0 for v in vals]


def render(sound_id, fn):
    res = fn()
    variants = res if (isinstance(res, list) and res and isinstance(res[0], list)) else [res]
    files = []
    loud = []
    for k, sig in enumerate(variants):
        # Pastelno: bez tutnjave ispod 45 Hz i bez oštrog „zraka" iznad ~11 kHz.
        sig = lowpass(highpass(sig, 45.0), 11000.0)
        sig = fades(trim_tail(sig, -66.0), 0.0015, 0.012)
        sig = normalize(sig, -1.0)
        name = sound_id + (f"_{k + 1}" if len(variants) > 1 else "") + ".wav"
        write_wav(os.path.join(OUT_DIR, name), sig)
        files.append(RES_DIR + name)
        loud.append(short_term_db(sig))
    return files, sum(loud) / len(loud), max(len(v) for v in variants) / SR


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    args = sys.argv[1:]
    only = None
    measure = "--measure" in args
    if "--only" in args:
        only = set(args[args.index("--only") + 1].split(","))
    cat = load_catalog()
    sfx = cat.setdefault("sfx", {})
    for sid, (fn, kind, opts) in SOUNDS.items():
        entry = sfx.get(sid, {})
        real = entry.get("source") == "real"
        if real or measure or (only is not None and sid not in only):
            files = entry.get("files", [])
            if not files:
                continue
            lv = []
            for f in files:
                p = os.path.join(ROOT, "game", f.replace("res://", ""))
                if p.endswith(".wav") and os.path.exists(p):
                    lv.append(short_term_db(read_wav(p)))
            if lv and (measure or real):
                entry["db"] = target_db(sid, kind, sum(lv) / len(lv))
            sfx[sid] = entry
            continue
        files, loud, sec = render(sid, fn)
        new = {"files": files, "source": "synth", "cat": kind, "db": target_db(sid, kind, loud), "sec": round(sec, 2)}
        for k in ("pitch", "cooldown_ms", "max", "group", "chain", "duck"):
            if k in opts:
                new[k] = opts[k]
        sfx[sid] = new
        print(f"{sid:16s} {sec:5.2f}s  loud {loud:6.1f} dBFS  db {new['db']:+.1f}  {len(files)} file(s)")
    cat["schema"] = 1
    cat["note"] = ("Generisano: scripts/audio/sfx_gen.py (efekti) i music_gen.py (muzika). db = pomak do ciljne "
                   "glasnoće kategorije; source real = pravi zvuk, generator ga ne dira.")
    os.makedirs(os.path.dirname(CATALOG), exist_ok=True)
    with open(CATALOG, "w", encoding="utf-8", newline="\n") as f:
        json.dump(cat, f, ensure_ascii=False, indent=1)
    print("catalog:", CATALOG, len(sfx), "sfx")


if __name__ == "__main__":
    main()
