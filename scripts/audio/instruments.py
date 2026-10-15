"""Instrumenti, udaraljke i ambijent za sezonsku muziku (music_gen.py) — sinteza u čistom Pythonu.

Svaki instrument: f(hz, dur_sec[, seed]) → mono lista (s repom poslije dur). Rezultati se keširaju
(ista nota istog trajanja se ne računa dvaput). Ambijent: f(len_sec, seed, …) → cijeli sloj.
"""
import math
import random
from functools import lru_cache

import dsp
from dsp import (SR, osc, fm, pluck, noise, lowpass, lowpass2, highpass, bandpass, env_exp, env_swell,
                 mix_into, n_samples, gain)

TAU = 2.0 * math.pi


def r3(x):
    return round(x, 3)


# ── ovojnice ──────────────────────────────────────────────────────────────────

def env_note(sig, attack, decay, gate, release):
    """Napad, eksponencijalni pad (decay 0 = drži), pa linearno puštanje poslije `gate`."""
    a = max(1, n_samples(attack))
    g = n_samples(gate)
    r = n_samples(release)
    out = [0.0] * len(sig)
    exp = math.exp
    k_dec = 1.0 / (decay * SR) if decay > 0 else 0.0
    for i, x in enumerate(sig):
        v = i / a if i < a else (exp(-(i - a) * k_dec) if k_dec else 1.0)
        if i > g:
            k = 1.0 - (i - g) / r if r > 0 else 0.0
            if k <= 0.0:
                return out
            v *= k
        out[i] = x * v
    return out


def tremolo(sig, rate, depth, phase=0.0):
    out = [0.0] * len(sig)
    w = TAU * rate / SR
    s = math.sin
    for i, x in enumerate(sig):
        out[i] = x * (1.0 - depth * (0.5 + 0.5 * s(w * i + phase)))
    return out


def add(*sigs_gains):
    n = max(len(s) for s, _ in sigs_gains)
    out = [0.0] * n
    for s, g in sigs_gains:
        for i, x in enumerate(s):
            out[i] += x * g
    return out


def partials(f, sec, amps, detune=None, decays=None):
    """Zbir sinusa f·k (k iz amps ključeva), svaki sa svojim padom (s)."""
    n = n_samples(sec)
    out = [0.0] * n
    sin = math.sin
    exp = math.exp
    for k, (mult, amp) in enumerate(amps):
        if f * mult > 10000.0:
            continue
        w = TAU * f * mult / SR
        dec = decays[k] if decays else 0.0
        kd = 1.0 / (dec * SR) if dec else 0.0
        for i in range(n):
            out[i] += amp * sin(w * i) * (exp(-i * kd) if kd else 1.0)
    return out


def breath(f, sec, seed, center=2.0, q=1.5):
    return bandpass(noise(sec, seed), min(f * center, 9000.0), q)


TABLE_N = 4096


@lru_cache(maxsize=None)
def _table(harm):
    """Jedan period talasa iz harmonika ((mult, amp), …) — čita ga table_osc."""
    t = [0.0] * TABLE_N
    sin = math.sin
    for mult, amp in harm:
        w = TAU * mult / TABLE_N
        for i in range(TABLE_N):
            t[i] += amp * sin(w * i)
    return t


def _limit(f, harm, top=14000.0):
    return tuple((m, a) for m, a in harm if m * f < top) or harm[:1]


def table_osc(f, sec, harm, rate=0.0, depth=0.0, delay=0.0, detune=0.0):
    """Oscilator iz tabele (1 čitanje po uzorku umjesto sinusa po harmoniku), vibrato koji
    kreće poslije `delay`; harmonici iznad ~14 kHz se izbace (bez aliasinga)."""
    tab = _table(_limit(f, tuple(harm)))
    n = n_samples(sec)
    out = [0.0] * n
    N = TABLE_N
    inc0 = f * (1.0 + detune) * N / SR
    ph = 0.0
    sin = math.sin
    w = TAU * rate / SR
    d0 = n_samples(delay)
    ramp_len = 0.3 * SR
    for i in range(n):
        if depth:
            ramp = 0.0 if i < d0 else min(1.0, (i - d0) / ramp_len)
            ph += inc0 * (1.0 + depth * ramp * sin(w * i))
        else:
            ph += inc0
        while ph >= N:
            ph -= N
        j = int(ph)
        fr = ph - j
        a = tab[j]
        out[i] = a + (tab[j + 1 if j + 1 < N else 0] - a) * fr
    return out


def vib_osc(f, sec, rate=5.0, depth=0.006, delay=0.25, harm=((1, 1.0),)):
    """Harmonici s vibratom koji kreće poslije `delay` (flauta, violina, glas)."""
    return table_osc(f, sec, harm, rate, depth, delay)


def saw_harm(n=16):
    return tuple((h, (1.0 if h % 2 else -1.0) / h) for h in range(1, n + 1))


def saw_band(f, sec, harmonics=12, detune=0.0):
    """Pila do `harmonics` harmonika (bez aliasinga), opciono razdešena."""
    return table_osc(f, sec, saw_harm(harmonics), detune=detune)


def square_band(f, sec, harmonics=9):
    return table_osc(f, sec, tuple((h, 1.0 / h) for h in range(1, harmonics + 1, 2)))


# ── tipke i udarni tonski instrumenti ─────────────────────────────────────────

@lru_cache(maxsize=None)
def ep(f, dur):
    """Električni klavir (FM 1:1, dva blago razdešena)."""
    total = dur + 0.5
    a = fm(f, total, 1.0, 1.15, 0.25)
    b = fm(f * 1.0035, total, 1.0, 0.9, 0.2)
    sig = [x * 0.6 + y * 0.4 for x, y in zip(a, b)]
    return lowpass(env_note(sig, 0.006, 1.1, dur, 0.35), 4800)


@lru_cache(maxsize=None)
def ep_soft(f, dur):
    total = dur + 0.6
    a = fm(f, total, 1.0, 0.6, 0.12)
    b = fm(f * 1.002, total, 1.0, 0.5, 0.1)
    sig = [x * 0.55 + y * 0.45 for x, y in zip(a, b)]
    return lowpass(env_note(sig, 0.012, 1.6, dur, 0.5), 3200)


@lru_cache(maxsize=None)
def music_box(f, dur):
    """Muzička kutija: zupčić s neharmonijskim parcijalom, kratko, bez drška."""
    total = max(dur, 0.6) + 0.9
    body = partials(f, total, [(1.0, 1.0), (2.0, 0.22), (5.4, 0.14), (8.9, 0.04)],
                    decays=[1.1, 0.5, 0.16, 0.07])
    click = lowpass2(env_exp(highpass(noise(0.012, int(f) % 91), 2500), 0.0003, 0.003), 7000)
    sig = add((body, 1.0), (click, 0.08))
    return env_note(sig, 0.0015, 0.0, total, 0.05)


@lru_cache(maxsize=None)
def celesta(f, dur):
    total = max(dur, 0.5) + 1.0
    body = partials(f, total, [(1.0, 1.0), (2.0, 0.12), (4.0, 0.2), (6.0, 0.05)], decays=[0.9, 0.5, 0.12, 0.06])
    knock = env_exp(bandpass(noise(0.02, int(f) % 37 + 2), min(f * 3, 6000.0), 1.5), 0.0005, 0.006)
    sig = add((body, 1.0), (knock, 0.1))
    return lowpass2(env_note(sig, 0.002, 0.0, total, 0.05), 6500)


@lru_cache(maxsize=None)
def glock(f, dur):
    total = dur + 1.2
    return env_exp(fm(f, total, 3.5, 1.2, 0.1), 0.002, 0.5)


@lru_cache(maxsize=None)
def glass(f, dur):
    """Stakleno zvonce (arpeđo na Starfallu, svici)."""
    total = dur + 0.8
    return lowpass2(env_exp(fm(f, total, 3.5, 0.7, 0.0), 0.002, 0.32), 7500)


@lru_cache(maxsize=None)
def vibes(f, dur):
    """Vibrafon: FM 1:4 + tremolo."""
    total = max(dur, 0.5) + 1.2
    bar = fm(f, total, 4.0, 1.1, 0.0)
    fund = osc(f, total, "sine")
    sig = [0.3 * x + 0.85 * y for x, y in zip(bar, fund)]
    sig = env_note(env_exp(sig, 0.002, 1.3), 0.002, 0.0, dur + 0.25, 0.9)
    return lowpass(tremolo(sig, 5.2, 0.28), 6000)


@lru_cache(maxsize=None)
def marimba(f, dur):
    total = max(dur, 0.25) + 0.35
    bar = fm(f, total, 4.0, 2.4, 0.0)
    fund = osc(f, total, "sine")
    sig = [0.55 * x + 0.8 * y for x, y in zip(bar, fund)]
    return lowpass(env_note(sig, 0.0015, 0.22, total, 0.05), 6000)


@lru_cache(maxsize=None)
def kalimba(f, dur):
    """Kalimba: osnovni ton + jak neharmonijski parcijal koji brzo nestane."""
    total = max(dur, 0.4) + 0.8
    body = partials(f, total, [(1.0, 1.0), (5.95, 0.32), (2.0, 0.08)], decays=[0.7, 0.06, 0.25])
    sig = env_note(body, 0.002, 0.0, total, 0.05)
    return lowpass(sig, 6500)


@lru_cache(maxsize=None)
def steelpan(f, dur):
    """Steel drum: oktava i duodecima jake, mekan napad."""
    total = max(dur, 0.4) + 0.7
    a = fm(f, total, 2.0, 1.3, 0.25)
    b = partials(f, total, [(1.0, 0.6), (2.0, 0.5), (3.0, 0.18)], decays=[0.8, 0.5, 0.3])
    sig = [0.55 * x + 0.6 * y for x, y in zip(a, b)]
    return lowpass(env_note(env_exp(sig, 0.004, 0.75), 0.004, 0.0, total, 0.05), 5200)


@lru_cache(maxsize=None)
def tongue(f, dur):
    """Tongue / hang drum: topao, mekan napad, dug rep."""
    total = max(dur, 0.6) + 1.4
    body = partials(f, total, [(1.0, 1.0), (2.0, 0.28), (3.0, 0.12), (5.0, 0.04)], decays=[1.6, 0.8, 0.35, 0.12])
    sig = env_note(body, 0.007, 0.0, total, 0.05)
    return lowpass(sig, 4400)


# ── trzalice ──────────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def harp(f, dur, seed=1):
    total = dur + 0.9
    sig = pluck(f, total, 0.9982, 0.6, seed)
    return lowpass2(env_note(sig, 0.001, 0.0, dur + 0.5, 0.4), 5200)


@lru_cache(maxsize=None)
def koto(f, dur, seed=1):
    """Koto / citra: svijetao trzaj, kratak rep."""
    total = dur + 0.6
    sig = pluck(f, total, 0.9965, 0.85, seed)
    sig = add((sig, 1.0), (bandpass(sig, min(f * 3.0, 8000.0), 3.0), 0.25))
    return lowpass2(env_note(sig, 0.0008, 0.0, dur + 0.3, 0.3), 6200)


@lru_cache(maxsize=None)
def guitar(f, dur, seed=1):
    """Akustična / najlon gitara: trzaj + rezonanca tijela."""
    total = dur + 0.8
    sig = pluck(f, total, 0.9978, 0.45, seed)
    body = bandpass(sig, 190.0, 1.3)
    sig = [x + 0.35 * b for x, b in zip(sig, body)]
    return lowpass2(env_note(sig, 0.0012, 0.0, dur + 0.35, 0.45), 4200)


@lru_cache(maxsize=None)
def banjo(f, dur, seed=1):
    total = dur + 0.4
    sig = pluck(f, total, 0.993, 0.95, seed)
    sig = highpass(sig, 250.0)
    return lowpass2(env_note(sig, 0.0006, 0.0, dur + 0.2, 0.2), 6000)


@lru_cache(maxsize=None)
def pizz(f, dur, seed=1):
    """Pizzicato gudača: tup, kratak."""
    total = min(dur, 0.6) + 0.45
    sig = pluck(f, total, 0.992, 0.3, seed)
    return lowpass2(env_note(sig, 0.002, 0.0, total, 0.08), 3000)


@lru_cache(maxsize=None)
def pizz_bass(f, dur, seed=1):
    total = min(dur, 1.2) + 0.4
    sig = pluck(f, total, 0.9955, 0.25, seed)
    fund = env_exp(osc(f, total, "sine"), 0.004, 0.55)
    sig = [0.7 * x + 0.6 * y for x, y in zip(sig, fund)]
    return lowpass2(env_note(sig, 0.003, 0.0, total, 0.1), 1400)


@lru_cache(maxsize=None)
def synth_pluck(f, dur):
    """Mekan sintisajzerski trzaj: pila s filterom koji se zatvara."""
    total = dur + 0.35
    raw = saw_band(f, total, 10)
    sig = lowpass(raw, 4200.0, 520.0)
    return env_note(env_exp(sig, 0.002, 0.32), 0.002, 0.0, dur + 0.15, 0.2)


# ── bas ───────────────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def bass(f, dur):
    total = dur + 0.12
    a = osc(f, total, "sine")
    b = osc(f * 2, total, "sine")
    c = osc(f * 3, total, "tri")
    sig = [x + 0.22 * y + 0.06 * z for x, y, z in zip(a, b, c)]
    return lowpass(env_note(sig, 0.01, 0.7, dur, 0.1), 900)


@lru_cache(maxsize=None)
def upright(f, dur, seed=1):
    """Kontrabas (walking): trzaj + ton, malo duži."""
    total = dur + 0.25
    sig = pluck(f, total, 0.9968, 0.2, seed)
    fund = osc(f, total, "sine")
    sig = [0.55 * x + 0.5 * y for x, y in zip(sig, fund)]
    return lowpass2(env_note(sig, 0.004, 0.9, dur, 0.12), 1200)


@lru_cache(maxsize=None)
def sub(f, dur):
    total = dur + 0.3
    a = osc(f, total, "sine")
    b = osc(f * 2, total, "sine")
    sig = [x + 0.12 * y for x, y in zip(a, b)]
    return lowpass(env_note(sig, 0.03, 0.0, dur, 0.25), 500)


@lru_cache(maxsize=None)
def cello(f, dur):
    """Gudački bas (Amber): pila, spor napad, vibrato."""
    total = dur + 0.35
    raw = vib_osc(f, total, 5.0, 0.004, 0.2, ((1, 1.0), (2, 0.5), (3, 0.3), (4, 0.18), (5, 0.1)))
    return lowpass(env_note(raw, 0.09, 0.0, dur, 0.3), 1400)


# ── duvački i gudački solo ────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def flute(f, dur):
    total = dur + 0.25
    tone = vib_osc(f, total, 5.0, 0.006, 0.22, ((1, 1.0), (2, 0.16), (3, 0.05)))
    br = breath(f, total, int(f) % 97 + 3, 2.0, 1.8)
    sig = [x + 0.05 * y for x, y in zip(tone, br)]
    return lowpass(env_note(sig, 0.06, 0.0, dur, 0.16), 6500)


@lru_cache(maxsize=None)
def bamboo(f, dur):
    """Bambusova flauta: više daha, „čif" na napadu, ton se malo podigne na mjesto."""
    total = dur + 0.3
    n = n_samples(total)
    out = [0.0] * n
    ph = 0.0
    sin = math.sin
    scoop = n_samples(0.07)
    for i in range(n):
        bend = 0.982 + 0.018 * min(1.0, i / scoop)
        vib = 1.0 + 0.007 * min(1.0, max(0.0, i / SR - 0.3) / 0.3) * sin(TAU * 4.6 * i / SR)
        ph += TAU * f * bend * vib / SR
        out[i] = sin(ph) + 0.12 * sin(2 * ph) + 0.04 * sin(3 * ph)
    br = breath(f, total, int(f) % 89 + 7, 1.6, 1.2)
    chiff = env_exp(bandpass(noise(0.05, int(f) % 13 + 1), min(f * 4, 8000.0), 2.0), 0.002, 0.018)
    sig = add((out, 1.0), (br, 0.1), (chiff, 0.35))
    return lowpass(env_note(sig, 0.05, 0.0, dur, 0.2), 6000)


@lru_cache(maxsize=None)
def low_flute(f, dur):
    """Niska, tamna flauta (Ember): više daha, sporiji vibrato."""
    total = dur + 0.35
    tone = vib_osc(f, total, 4.4, 0.008, 0.3, ((1, 1.0), (2, 0.22), (3, 0.08)))
    br = breath(f, total, int(f) % 83 + 11, 3.5, 1.2)
    sig = [x + 0.1 * y for x, y in zip(tone, br)]
    return lowpass(env_note(sig, 0.08, 0.0, dur, 0.25), 3800)


@lru_cache(maxsize=None)
def reed(f, dur):
    """Klarinet / oboa (Amber): neparni harmonici, mali vibrato."""
    total = dur + 0.2
    tone = vib_osc(f, total, 5.2, 0.004, 0.25, ((1, 1.0), (2, 0.07), (3, 0.42), (5, 0.18), (7, 0.07)))
    br = breath(f, total, int(f) % 79 + 5, 3.0, 2.0)
    sig = [x + 0.025 * y for x, y in zip(tone, br)]
    return lowpass(env_note(sig, 0.045, 0.0, dur, 0.12), 3600)


@lru_cache(maxsize=None)
def fiddle(f, dur):
    total = dur + 0.15
    tone = vib_osc(f, total, 5.6, 0.007, 0.12, tuple((h, (1.0 if h % 2 else 0.8) / h) for h in range(1, 9)))
    return lowpass(env_note(tone, 0.03, 0.0, dur, 0.1), 3800)


@lru_cache(maxsize=None)
def whistle(f, dur):
    total = dur + 0.2
    tone = osc(f, total, "sine", vib_rate=5.2, vib_depth=0.006)
    br = bandpass(noise(total, int(f)), f * 2.0, 2.0)
    sig = [x + 0.04 * y for x, y in zip(tone, br)]
    return env_note(sig, 0.05, 0.0, dur, 0.18)


@lru_cache(maxsize=None)
def star_lead(f, dur):
    """Nebeski lead (Starfall): sinus + oktava, hor (razdešen), spor napad."""
    total = dur + 0.5
    a = vib_osc(f, total, 4.8, 0.005, 0.3, ((1, 1.0), (2, 0.18)))
    b = vib_osc(f * 1.0045, total, 5.3, 0.005, 0.35, ((1, 0.6),))
    sig = [x + y for x, y in zip(a, b)]
    return lowpass(env_note(sig, 0.07, 0.0, dur, 0.4), 5000)


# ── padovi ────────────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def pad_warm(f, dur):
    total = dur + 2.2
    a = osc(f * 0.9965, total, "sine")
    b = osc(f, total, "tri")
    c = osc(f * 1.0035, total, "sine")
    d = osc(f * 2, total, "sine")
    sig = [0.35 * w + 0.25 * x + 0.35 * y + 0.12 * z for w, x, y, z in zip(a, b, c, d)]
    return lowpass(env_note(sig, 1.6, 0.0, dur, 2.0), 2200)


@lru_cache(maxsize=None)
def strings(f, dur):
    """Gudački pad: tri razdešene pile, spor napad."""
    total = dur + 1.2
    a = saw_band(f, total, 8, -0.004)
    b = saw_band(f, total, 8, 0.0)
    c = saw_band(f, total, 8, 0.0045)
    sig = [x + y + z for x, y, z in zip(a, b, c)]
    return lowpass(env_note(sig, 0.7, 0.0, dur, 1.0), 1700)


@lru_cache(maxsize=None)
def choir(f, dur):
    """Hor „aah" / „ooh": pila kroz dva formanta, mali vibrato."""
    total = dur + 1.2
    raw = vib_osc(f, total, 4.6, 0.005, 0.0, tuple((h, 1.0 / h) for h in range(1, 12)))
    f1 = bandpass(raw, 650.0, 3.0)
    f2 = bandpass(raw, 1080.0, 4.0)
    low = lowpass(raw, 500.0)
    sig = [0.9 * a + 0.55 * b + 0.25 * c for a, b, c in zip(f1, f2, low)]
    return env_note(sig, 0.6, 0.0, dur, 1.0)


@lru_cache(maxsize=None)
def pad_icy(f, dur):
    """Ledeni pad (Frost): sinusi + oktava, svjetluca (tremolo), bez basa."""
    total = dur + 2.0
    a = osc(f, total, "sine")
    b = osc(f * 2.003, total, "sine")
    c = osc(f * 3.0, total, "sine")
    sig = [0.6 * x + 0.35 * y + 0.08 * z for x, y, z in zip(a, b, c)]
    sig = tremolo(sig, 0.35, 0.3, (f % 7) * 0.9)
    return highpass(env_note(sig, 1.4, 0.0, dur, 1.8), 180)


@lru_cache(maxsize=None)
def pad_synth(f, dur):
    """Topli sintisajzerski pad (Starfall): razdešene pile, filter zatvoren."""
    total = dur + 1.8
    a = saw_band(f, total, 6, -0.006)
    b = saw_band(f, total, 6, 0.006)
    sig = [x + y for x, y in zip(a, b)]
    return lowpass(env_note(sig, 1.2, 0.0, dur, 1.6), 1200)


@lru_cache(maxsize=None)
def drone(f, dur):
    """Bordun (Ember): korijen + kvinta + oktava, sporo „diše"."""
    total = dur + 1.5
    a = osc(f, total, "sine")
    b = osc(f * 1.5, total, "sine")
    c = osc(f * 2.004, total, "tri")
    sig = [0.7 * x + 0.3 * y + 0.18 * z for x, y, z in zip(a, b, c)]
    sig = tremolo(sig, 0.12, 0.25)
    return lowpass(env_note(sig, 1.5, 0.0, dur, 1.4), 900)


# ── udaraljke ─────────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def kick(vel=1.0):
    body = env_exp(osc(108, 0.24, "sine", 46), 0.002, 0.075)
    return lowpass([x * vel for x in body], 1800)


@lru_cache(maxsize=None)
def soft_kick():
    body = env_exp(osc(80, 0.3, "sine", 42), 0.004, 0.09)
    return lowpass(body, 700)


@lru_cache(maxsize=None)
def shaker(seed=1):
    return lowpass2(env_exp(highpass(noise(0.07, seed), 6000), 0.004, 0.018), 10000)


@lru_cache(maxsize=None)
def brush(seed=1):
    return env_exp(bandpass(noise(0.2, seed), 2300, 0.6), 0.002, 0.055)


@lru_cache(maxsize=None)
def rim():
    a = osc(1650, 0.06, "sine", 1500)
    b = osc(4400, 0.06, "sine", 4100)
    return env_exp([x + 0.3 * y for x, y in zip(a, b)], 0.0008, 0.012)


@lru_cache(maxsize=None)
def frame_drum(pitch=1.0, seed=1):
    """Okvirni bubanj / bodhrán: tup ton + koža."""
    tone = env_exp(osc(92 * pitch, 0.35, "sine", 68 * pitch), 0.003, 0.14)
    skin = env_exp(bandpass(noise(0.12, seed), 420 * pitch, 1.2), 0.001, 0.035)
    return lowpass(add((tone, 1.0), (skin, 0.5)), 2400)


@lru_cache(maxsize=None)
def woodblock(pitch=1.0):
    a = env_exp(osc(1050 * pitch, 0.08, "sine", 980 * pitch), 0.0006, 0.022)
    b = env_exp(bandpass(noise(0.03, 5), 1800 * pitch, 6.0), 0.0004, 0.008)
    return add((a, 1.0), (b, 0.6))


@lru_cache(maxsize=None)
def tambourine(seed=1):
    rng = random.Random(seed)
    jing = partials(1.0, 0.25, [(rng.uniform(4100, 4600), 0.5), (rng.uniform(5800, 6400), 0.4),
                                (rng.uniform(7300, 7900), 0.3)], decays=[0.07, 0.05, 0.04])
    hiss = env_exp(highpass(noise(0.12, seed), 6000), 0.001, 0.03)
    return add((jing, 0.6), (hiss, 0.5))


@lru_cache(maxsize=None)
def sleigh(seed=1):
    """Praporci: grozd zvončića u 60 ms."""
    out = []
    rng = random.Random(seed)
    for k in range(4):
        mix_into(out, tambourine(seed * 7 + k), rng.uniform(0.0, 0.06), rng.uniform(0.4, 0.8))
    return out


@lru_cache(maxsize=None)
def triangle():
    return partials(1.0, 2.0, [(5300, 0.6), (7400, 0.25), (9100, 0.1)], decays=[1.0, 0.6, 0.4])


@lru_cache(maxsize=None)
def finger_cymbal():
    return partials(1.0, 2.5, [(2900, 0.6), (7800, 0.3), (4350, 0.2)], decays=[1.4, 0.5, 0.9])


@lru_cache(maxsize=None)
def conga(pitch=1.0, slap=False, seed=1):
    tone = env_exp(osc(330 * pitch, 0.25, "sine", 250 * pitch), 0.002, 0.09)
    hit = env_exp(bandpass(noise(0.05, seed), 1500 if slap else 800, 1.5), 0.0005, 0.012)
    return add((tone, 1.0), (hit, 0.7 if slap else 0.35))


@lru_cache(maxsize=None)
def clap(seed=1):
    out = []
    for k in range(3):
        burst = env_exp(bandpass(noise(0.05, seed + k), 1400, 0.9), 0.0005, 0.012)
        mix_into(out, burst, k * 0.011, 0.8 if k < 2 else 1.0)
    tail = env_exp(bandpass(noise(0.15, seed + 9), 1200, 0.8), 0.001, 0.05)
    mix_into(out, tail, 0.022, 0.4)
    return lowpass(out, 5000)


# ── ambijent (cijeli slojevi, dužina loopa) ───────────────────────────────────

def layer(sec):
    return [0.0] * n_samples(sec)


def wind(sec, seed=21, cutoff=650, cycles=3):
    raw = lowpass(noise(sec, seed, "pink"), cutoff)
    n = len(raw)
    s = math.sin
    return [x * (0.35 + 0.65 * (0.5 + 0.5 * s(TAU * cycles * i / n + 0.6))) * 0.5 for i, x in enumerate(raw)]


def snow_wind(sec, seed=31):
    """Zimski vjetar + tihi fijuk kroz granje."""
    base = wind(sec, seed, 900, 2)
    whistle_l = bandpass(noise(sec, seed + 1, "pink"), 1150.0, 7.0, 1500.0)
    n = len(base)
    s = math.sin
    return [b + 0.6 * w * (0.5 + 0.5 * s(TAU * 2.0 * i / n)) for i, (b, w) in enumerate(zip(base, whistle_l))]


def birds(sec, seed=23, count=7, level=0.08):
    out = layer(sec)
    rng = random.Random(seed)
    for _ in range(count):
        at = rng.uniform(0.5, sec - 1.5)
        base = rng.uniform(2600, 3600)
        for r in range(rng.randint(2, 4)):
            chirp = env_exp(fm(base, 0.09, 2.0, 0.3, 0.0, f_end=base * rng.uniform(1.25, 1.5)), 0.004, 0.03)
            mix_into(out, chirp, at + r * rng.uniform(0.1, 0.15), level)
    return out[: n_samples(sec)]


def crickets(sec, seed=41, voices=3, level=0.05):
    """Cvrčci: svaki ima svoj ton i ritam cvrkuta (3–4 impulsa po cvrkutu)."""
    out = layer(sec)
    rng = random.Random(seed)
    for v in range(voices):
        f = rng.uniform(4200, 5100)
        period = rng.uniform(0.55, 0.95)
        pulses = rng.randint(3, 4)
        amp = level * rng.uniform(0.5, 1.0)
        pulse = env_exp(osc(f, 0.03, "sine"), 0.002, 0.008)
        t = rng.uniform(0.0, period)
        while t < sec - 0.2:
            if rng.random() < 0.85:
                for p in range(pulses):
                    mix_into(out, pulse, t + p * 0.032, amp)
            t += period * rng.uniform(0.95, 1.05)
    return lowpass(out[: n_samples(sec)], 7500)


def owl(sec, at, seed=51, level=0.12):
    out = layer(sec)
    for k, (f0, f1, d) in enumerate([(410, 380, 0.32), (395, 360, 0.55)]):
        hoot = env_swell(osc(f0, d, "sine", f1), 0.25, 0.75)
        hoot = add((hoot, 1.0), (bandpass(noise(d, seed + k), 800, 2.0), 0.04))
        mix_into(out, hoot, at + k * 0.5, level)
    return out[: n_samples(sec)]


def waves(sec, seed=61, period=7.0, level=0.5):
    """More: niskopropusni šum u talasima + pjena na vrhu talasa."""
    n = n_samples(sec)
    cycles = max(1, round(sec / period))
    body = lowpass(noise(sec, seed, "pink"), 700)
    foam = highpass(noise(sec, seed + 1), 3500)
    out = [0.0] * n
    s = math.sin
    for i in range(n):
        ph = (cycles * i / n) % 1.0
        swell = s(math.pi * ph) ** 2
        crest = max(0.0, s(math.pi * min(1.0, ph * 1.25))) ** 8
        out[i] = level * (body[i] * (0.25 + 0.75 * swell) + 0.25 * foam[i] * crest)
    return out


def gull(sec, at, seed=71, level=0.06):
    out = layer(sec)
    rng = random.Random(seed)
    for k in range(rng.randint(2, 3)):
        f0 = rng.uniform(1700, 2000)
        call = env_swell(fm(f0, 0.28, 1.0, 1.4, 0.6, f_end=f0 * 0.78), 0.2, 0.8)
        mix_into(out, lowpass(call, 4500), at + k * 0.36, level)
    return out[: n_samples(sec)]


def crackle(sec, seed=81, rate=7.0, level=0.18):
    """Žeravica: nasumični pucketi (oštri i tupi) + tiho tutnjanje."""
    out = layer(sec)
    rng = random.Random(seed)
    t = 0.0
    snap = env_exp(bandpass(noise(0.02, seed), 2800, 1.5), 0.0003, 0.003)
    pop = env_exp(bandpass(noise(0.04, seed + 1), 900, 1.2), 0.0005, 0.009)
    while t < sec - 0.1:
        t += rng.expovariate(rate)
        if rng.random() < 0.82:
            mix_into(out, snap, t, level * rng.uniform(0.2, 0.8))
        else:
            mix_into(out, pop, t, level * rng.uniform(0.35, 0.7))
    rumble = lowpass(noise(sec, seed + 2, "pink"), 180)
    out = out[: n_samples(sec)]
    return [x + 0.25 * level * r for x, r in zip(out, rumble)]


def frog(sec, at, seed=91, level=0.1):
    """Krek: niski impulsi (~22/s) kroz rezonanciju, ponekad dva."""
    out = layer(sec)
    rng = random.Random(seed)
    for k in range(rng.randint(1, 2)):
        d = rng.uniform(0.22, 0.32)
        f = rng.uniform(170, 240)
        body = saw_band(f, d, 8)
        pulses = [x * (0.5 + 0.5 * math.sin(TAU * 22.0 * i / SR)) ** 3 for i, x in enumerate(body)]
        croak = env_swell(bandpass(pulses, 520.0, 2.0), 0.15, 0.85)
        mix_into(out, croak, at + k * 0.42, level)
    return out[: n_samples(sec)]


def leaves(sec, seed=101, gusts=5, level=0.1):
    """Šuštanje lišća: grozdovi zrna šuma u naletima vjetra."""
    out = layer(sec)
    rng = random.Random(seed)
    for g in range(gusts):
        start = rng.uniform(0.0, sec - 2.5)
        length = rng.uniform(1.2, 2.4)
        t = start
        while t < start + length:
            grain = env_exp(highpass(noise(0.03, rng.randint(1, 999)), 2200), 0.001, 0.008)
            env = math.sin(math.pi * (t - start) / length)
            mix_into(out, grain, t, level * env * rng.uniform(0.3, 1.0))
            t += rng.uniform(0.006, 0.03)
    return lowpass(out[: n_samples(sec)], 7000)


def chimes(sec, at, notes, seed=111, level=0.07):
    """Zvona na vjetru: 3–6 nota iz `notes` (Hz) brzo jedna za drugom."""
    out = layer(sec)
    rng = random.Random(seed)
    t = at
    for _ in range(rng.randint(3, 6)):
        f = rng.choice(notes)
        mix_into(out, glass(r3(f), 0.6), t, level * rng.uniform(0.5, 1.0))
        t += rng.uniform(0.08, 0.3)
    return out[: n_samples(sec)]


def sparkles(sec, seed=121, rate=1.2, lo=2600, hi=5200, level=0.035):
    out = layer(sec)
    rng = random.Random(seed)
    t = rng.uniform(0.0, 1.0)
    while t < sec - 0.6:
        f = rng.uniform(lo, hi)
        ping = env_exp(fm(f, 0.4, 2.0, 0.5, 0.0), 0.001, 0.08)
        mix_into(out, ping, t, level * rng.uniform(0.4, 1.0))
        t += rng.expovariate(rate)
    return out[: n_samples(sec)]


def meteor(sec, at, seed=131, level=0.12):
    """Meteor: šum koji klizi s visokog na nisko + tanak ton."""
    out = layer(sec)
    d = 1.3
    sweep = env_swell(bandpass(noise(d, seed), 7000.0, 2.5, 900.0), 0.3, 0.7)
    tail = env_exp(fm(2400, d, 2.0, 0.4, 0.0, f_end=1400), 0.05, 0.4)
    mix_into(out, sweep, at, level)
    mix_into(out, tail, at + 0.2, level * 0.15)
    return out[: n_samples(sec)]


def bubbles(sec, seed=141, count=6, level=0.05):
    out = layer(sec)
    rng = random.Random(seed)
    for _ in range(count):
        at = rng.uniform(0.3, sec - 0.5)
        for k in range(rng.randint(1, 3)):
            f = rng.uniform(380, 700)
            b = env_exp(osc(f, 0.09, "sine", f * 2.2), 0.003, 0.03)
            mix_into(out, b, at + k * rng.uniform(0.06, 0.12), level)
    return out[: n_samples(sec)]


@lru_cache(maxsize=None)
def ride(seed=1):
    """Ride činela (jazz u Moonlit Areni): metalni parcijali + šum."""
    ping = partials(1.0, 0.9, [(3150, 0.5), (4870, 0.35), (6230, 0.3), (8100, 0.2)],
                    decays=[0.45, 0.35, 0.3, 0.25])
    hiss = env_exp(highpass(noise(0.3, seed), 7000), 0.001, 0.08)
    return add((ping, 0.5), (hiss, 0.25))
