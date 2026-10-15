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
    # visoki neharmonijski parcijali zvone malo duže — kutija „svjetluca" i na zvučniku telefona
    body = partials(f, total, [(1.0, 1.0), (2.0, 0.26), (5.4, 0.16), (8.9, 0.05)],
                    decays=[1.1, 0.55, 0.3, 0.12])
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


def waves(sec, seed=61, period=7.0, level=0.5, dark=False):
    """More: niskopropusni šum u talasima + pjena na vrhu talasa (dark = dublje, manje pjene)."""
    n = n_samples(sec)
    cycles = max(1, round(sec / period))
    body = lowpass(noise(sec, seed, "pink"), 420 if dark else 700)
    foam = highpass(noise(sec, seed + 1), 3500) if not dark else lowpass(highpass(noise(sec, seed + 1), 1800), 4000)
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


# ══ v2 (drugi ciklus): instrumenti koji pripadaju jednoj sezoni ═══════════════
# Country Bloom: harmonika, lap steel, čelična gitara, bendžo · Frost: celesta, staklena
# harmonika, harfa, gudači tremolo · Lantern: shakuhachi, koto tremolo, sho, hramsko zvono,
# taiko · Amber: tin whistle, harmonika (akordeon), buzuki, violončelo sekcija, bodhrán ·
# Moonlit: filcani klavir, muzička kutija, hor „ooh", vibrafon, kontrabas · Coral: najlon
# gitara, alt flauta, steel pan, ukulele, marimba, konge / bongo / guiro · Starfall: supersaw,
# synth bas, 808, gated hat · Ember: duduk, tanpura, oud, handpan, darbuka, riq.

LN2_12 = math.log(2.0) / 12.0


def tone(f, sec, harm, vib=(0.0, 0.0, 0.0), bend=(0.0, 0.08), trem=(0.0, 0.0), detune=0.0):
    """Tabelarni ton: vibrato (rate, depth, delay), klizanje u notu (polutonovi, s), tremolo."""
    tab = _table(_limit(f, tuple(harm)))
    n = n_samples(sec)
    out = [0.0] * n
    N = TABLE_N
    inc0 = f * (1.0 + detune) * N / SR
    ph = 0.0
    sin = math.sin
    exp = math.exp
    v_rate, v_depth, v_delay = vib
    wv = TAU * v_rate / SR
    d0 = n_samples(v_delay)
    ramp_len = 0.3 * SR
    b_semi, b_time = bend
    bN = max(1, n_samples(b_time))
    kb = b_semi * LN2_12
    t_rate, t_depth = trem
    wt = TAU * t_rate / SR
    for i in range(n):
        m = 1.0
        if b_semi and i < bN:
            m = exp(kb * (1.0 - i / bN))
        if v_depth and i > d0:
            m *= 1.0 + v_depth * min(1.0, (i - d0) / ramp_len) * sin(wv * i)
        ph += inc0 * m
        while ph >= N:
            ph -= N
        j = int(ph)
        a = tab[j]
        v = a + (tab[j + 1 if j + 1 < N else 0] - a) * (ph - j)
        if t_depth:
            v *= 1.0 - t_depth * (0.5 + 0.5 * sin(wt * i))
        out[i] = v
    return out


def fast_partials(freqs, amps, decays, sec):
    """Aditivno: sinusi s eksponencijalnim padom (rotacija, bez sin po uzorku)."""
    n = n_samples(sec)
    out = [0.0] * n
    for f, a, d in zip(freqs, amps, decays):
        if f >= SR * 0.45 or a == 0:
            continue
        w = TAU * f / SR
        cw, sw = math.cos(w), math.sin(w)
        k = math.exp(-1.0 / (d * SR)) if d > 0 else 1.0
        c, s = 1.0, 0.0
        amp = a
        for i in range(n):
            out[i] += amp * s
            c, s = c * cw - s * sw, s * cw + c * sw
            amp *= k
    return out


def _shape(sig, attack, release, dur):
    return env_note(sig, attack, 0.0, dur, release)


# ── Country Bloom ─────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def harmonica(f, dur, slide=False):
    total = dur + 0.12
    reed = tone(f, total, ((1, 1.0), (2, 0.7), (3, 0.55), (4, 0.3), (5, 0.22), (6, 0.12), (7, 0.08)),
                vib=(5.4, 0.008, 0.28), bend=(-1.6 if slide else -0.3, 0.1 if slide else 0.04), trem=(5.4, 0.16))
    nasal = bandpass(reed, 1400.0, 1.1)
    body = lowpass2(reed, 3400)
    br = bandpass(noise(total, int(f) % 61 + 3), min(f * 2.5, 6000.0), 1.0)
    sig = [0.55 * b + 0.6 * n_ + 0.05 * r for b, n_, r in zip(body, nasal, br)]
    return _shape(sig, 0.03, 0.08, dur)


@lru_cache(maxsize=None)
def lap_steel(f, dur, slide=False):
    total = dur + 0.7
    sig = tone(f, total, ((1, 1.0), (2, 0.45), (3, 0.25), (4, 0.12), (5, 0.06)),
               vib=(4.2, 0.006, 0.3), bend=(-2.0 if slide else -0.5, 0.2 if slide else 0.06))
    return lowpass2(env_note(sig, 0.12, 2.2, dur, 0.6), 3000)


@lru_cache(maxsize=None)
def guitar_steel(f, dur, seed=1):
    total = dur + 0.6
    sig = pluck(f, total, 0.9975, 0.7, seed)
    body = bandpass(sig, 220.0, 1.2)
    sig = [x + 0.3 * b for x, b in zip(sig, body)]
    return lowpass2(env_note(sig, 0.001, 0.0, dur + 0.2, 0.3), 5200)


@lru_cache(maxsize=None)
def harmonium(f, dur):
    """Harmonij (orgulje na mijeh) za Country Bloom run: jezičci, mijeh „diše"."""
    total = dur + 0.6
    h = ((1, 1.0), (2, 0.55), (3, 0.4), (4, 0.22), (5, 0.16), (6, 0.08))
    a = tone(f, total, h, trem=(2.6, 0.12))
    b = tone(f, total, h, detune=0.0025)
    sig = [x + 0.6 * y for x, y in zip(a, b)]
    return lowpass2(env_note(sig, 0.25, 0.0, dur, 0.5), 2400)


@lru_cache(maxsize=None)
def bass_round(f, dur):
    """Okrugli „električni" bas (Country Bloom): prsti, malo tijela."""
    total = dur + 0.15
    sig = tone(f, total, ((1, 1.0), (2, 0.35), (3, 0.12), (4, 0.05)))
    return lowpass2(env_note(sig, 0.006, 0.9, dur, 0.1), 1100)


# ── Frost Orchard ─────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def glass_harmonica(f, dur):
    """Staklena harmonika: čist ton koji „treperi" (dva glasa 0,7 Hz razmaknuta), spor napad."""
    total = dur + 0.9
    a = tone(f, total, ((1, 1.0), (2, 0.1), (3, 0.03)))
    b = tone(f + 0.7, total, ((1, 0.7),))
    sig = [x + y for x, y in zip(a, b)]
    return lowpass(env_note(sig, 0.28, 0.0, dur, 0.8), 6000)


@lru_cache(maxsize=None)
def string_trem(f, dur):
    """Gudači tremolo (gudalom brzo naprijed-nazad) — svjetluca kao inje."""
    total = dur + 0.4
    a = tone(f, total, saw_harm(8), vib=(5.0, 0.004, 0.2), trem=(12.5, 0.5), detune=-0.003)
    b = tone(f, total, saw_harm(8), vib=(5.3, 0.004, 0.2), trem=(11.7, 0.5), detune=0.003)
    sig = [x + y for x, y in zip(a, b)]
    return lowpass2(env_note(sig, 0.15, 0.0, dur, 0.4), 3400)


@lru_cache(maxsize=None)
def icicle(f, dur=0.3):
    return lowpass2(env_exp(fm(f, 0.5, 2.0, 0.6, 0.0), 0.001, 0.07), 9000)


# ── Lantern Meadow ────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def shakuhachi(f, dur, slide=False):
    """Shakuhachi: puno daha, kasni dubok vibrato, „meri" klizanje u ton."""
    total = dur + 0.3
    sig = tone(f, total, ((1, 1.0), (2, 0.28), (3, 0.08)),
               vib=(4.6, 0.013, 0.45), bend=(-1.2 if slide else -0.35, 0.18 if slide else 0.08))
    br = bandpass(noise(total, int(f) % 73 + 5), min(f * 1.7, 7000.0), 0.8)
    hiss = highpass(noise(total, int(f) % 71 + 9), 3000)
    chiff = env_exp(bandpass(noise(0.06, int(f) % 17 + 1), min(f * 3, 7500.0), 1.5), 0.002, 0.02)
    out = add((sig, 1.0), (br, 0.24), (hiss, 0.03), (chiff, 0.45))
    return lowpass(env_note(out, 0.07, 0.0, dur, 0.22), 5200)


@lru_cache(maxsize=None)
def koto_trem(f, dur, seed=1):
    """Koto tremolo: brzo ponavljanje trzaja (~14/s) dok traje nota."""
    out = []
    t = 0.0
    k = 0
    while t < dur:
        mix_into(out, koto(f, 0.12, (seed + k) % 4 + 1), t, 0.75 if k % 2 else 1.0)
        t += 1.0 / 14.0
        k += 1
    return out


@lru_cache(maxsize=None)
def sho(f, dur):
    """Sho (japanske usne orgulje): klaster jezičaka, dugo „disanje"."""
    total = dur + 1.4
    sig = tone(f, total, ((1, 1.0), (2, 0.42), (3, 0.3), (4, 0.16), (5, 0.1), (6, 0.05)),
               vib=(4.9, 0.0025, 0.0), trem=(0.4, 0.15))
    br = bandpass(noise(total, int(f) % 57 + 2), min(f * 2.0, 6000.0), 1.0)
    out = add((sig, 1.0), (br, 0.05))
    return lowpass(env_note(out, 0.9, 0.0, dur, 1.2), 3200)


@lru_cache(maxsize=None)
def temple_bell(f, dur=6.0):
    """Hramsko zvono: hum (½), osnovni, mala terca, kvinta, oktava — dug rep, lagano udaranje."""
    sec = max(dur, 6.0)
    ratios = (0.5, 0.503, 1.0, 1.004, 1.19, 1.5, 2.0, 2.52, 3.0)
    amps = (0.55, 0.3, 1.0, 0.5, 0.45, 0.3, 0.38, 0.16, 0.1)
    decays = (5.0, 5.0, 3.8, 3.6, 2.6, 2.2, 1.8, 1.0, 0.7)
    body = fast_partials([f * r for r in ratios], amps, decays, sec)
    strike = env_exp(lowpass(noise(0.05, int(f) % 31 + 4), 1800), 0.001, 0.012)
    return lowpass(add((body, 1.0), (strike, 0.3)), 5000)


@lru_cache(maxsize=None)
def taiko(vel=1.0, seed=1):
    tone_ = env_exp(osc(70, 0.6, "sine", 43), 0.003, 0.32)
    thump = env_exp(lowpass(noise(0.25, seed), 260), 0.002, 0.08)
    skin = env_exp(bandpass(noise(0.06, seed + 5), 1100, 1.2), 0.0006, 0.012)
    return lowpass([x * vel for x in add((tone_, 1.0), (thump, 0.6), (skin, 0.25))], 3000)


@lru_cache(maxsize=None)
def temple_block(pitch=1.0):
    imp = [0.0] * n_samples(0.12)
    imp[0] = 1.0
    ring = bandpass(imp, 820.0 * pitch, 14.0)
    ping = env_exp(osc(820.0 * pitch, 0.08, "sine"), 0.0005, 0.025)
    sig = add((ring, 6.0), (ping, 0.6))
    return env_exp(sig, 0.0005, 0.05)


# ── Amber Canopy ──────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def tin_whistle(f, dur, slide=False):
    total = dur + 0.1
    sig = tone(f, total, ((1, 1.0), (2, 0.32), (3, 0.12), (4, 0.05)),
               vib=(5.9, 0.005, 0.32), bend=(-0.9 if slide else 0.0, 0.07))
    br = bandpass(noise(total, int(f) % 67 + 3), min(f * 2.0, 8000.0), 1.4)
    out = add((sig, 1.0), (br, 0.05))
    return lowpass(env_note(out, 0.018, 0.0, dur, 0.05), 7500)


@lru_cache(maxsize=None)
def accordion(f, dur):
    """Harmonika (musette): tri jezička razdešena → živo treperenje, mijeh."""
    total = dur + 0.12
    h = ((1, 1.0), (2, 0.5), (3, 0.45), (4, 0.25), (5, 0.2), (6, 0.1), (7, 0.08))
    a = tone(f, total, h, trem=(4.0, 0.06))
    b = tone(f, total, h, detune=0.0035)
    c = tone(f, total, h, detune=-0.0035)
    sig = [x + 0.7 * y + 0.7 * z for x, y, z in zip(a, b, c)]
    return lowpass2(env_note(sig, 0.05, 0.0, dur, 0.1), 3600)


@lru_cache(maxsize=None)
def bouzouki(f, dur, seed=1):
    """Buzuki: dupli žičani parovi (blago razdešeni), svijetao, kratak."""
    total = dur + 0.5
    a = pluck(f, total, 0.996, 0.8, seed)
    b = pluck(f * 1.004, total, 0.996, 0.8, seed + 2)
    sig = [x + y for x, y in zip(a, b)]
    if f < 260:
        c = pluck(f * 2.0, total, 0.995, 0.8, seed + 4)
        sig = [x + 0.5 * y for x, y in zip(sig, c)]
    return lowpass2(env_note(sig, 0.001, 0.0, dur + 0.15, 0.2), 6000)


@lru_cache(maxsize=None)
def cello_section(f, dur):
    total = dur + 0.9
    parts = [tone(f, total, saw_harm(6), vib=(4.8 + k * 0.3, 0.005, 0.25), detune=d) for k, d in enumerate((-0.004, 0.0, 0.0045))]
    sig = [a + b + c for a, b, c in zip(*parts)]
    return lowpass2(env_note(sig, 0.45, 0.0, dur, 0.8), 1500)


@lru_cache(maxsize=None)
def bodhran(kind="low", seed=1):
    if kind == "low":
        t = env_exp(osc(78, 0.35, "sine", 54), 0.002, 0.2)
        s = env_exp(bandpass(noise(0.08, seed), 320, 1.0), 0.001, 0.04)
        return lowpass(add((t, 1.0), (s, 0.5)), 2000)
    t = env_exp(osc(150, 0.15, "sine", 124), 0.001, 0.07)
    s = env_exp(bandpass(noise(0.05, seed + 3), 950, 1.2), 0.0006, 0.018)
    return lowpass(add((t, 0.8), (s, 0.6)), 3500)


# ── Moonlit Warren ────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def felt_piano(f, dur):
    """Filcani klavir (tih, mekan): blago neharmonijski parcijali, filc umjesto čekića."""
    total = dur + 1.2
    B = 0.00035
    freqs, amps, decays = [], [], []
    for k in range(1, 9):
        fk = f * k * math.sqrt(1.0 + B * k * k)
        freqs.append(fk)
        amps.append(1.0 / (k ** 1.6))
        decays.append(2.8 / (k ** 0.7) if f < 500 else 1.8 / (k ** 0.7))
    body = fast_partials(freqs, amps, decays, total)
    felt = env_exp(lowpass(noise(0.05, int(f) % 29 + 6), 420), 0.002, 0.015)
    sig = add((body, 1.0), (felt, 0.35))
    return lowpass(env_note(sig, 0.008, 0.0, dur + 0.15, 0.45), 2600)


@lru_cache(maxsize=None)
def choir_ooh(f, dur):
    total = dur + 1.2
    raw = vib_osc(f, total, 4.4, 0.005, 0.0, tuple((h, 1.0 / h) for h in range(1, 12)))
    f1 = bandpass(raw, 330.0, 3.0)
    f2 = bandpass(raw, 820.0, 4.0)
    low = lowpass(raw, 360.0)
    sig = [0.9 * a + 0.35 * b + 0.4 * c for a, b, c in zip(f1, f2, low)]
    return env_note(sig, 0.7, 0.0, dur, 1.1)


# ── Coral Tide Garden ─────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def nylon(f, dur, seed=1):
    total = dur + 0.7
    sig = pluck(f, total, 0.998, 0.32, seed)
    body = bandpass(sig, 180.0, 1.3)
    sig = [x + 0.35 * b for x, b in zip(sig, body)]
    return lowpass2(env_note(sig, 0.0015, 0.0, dur + 0.3, 0.4), 3600)


@lru_cache(maxsize=None)
def ukulele(f, dur, seed=1):
    total = dur + 0.3
    sig = pluck(f, total, 0.993, 0.6, seed)
    body = bandpass(sig, 420.0, 1.5)
    sig = [x + 0.3 * b for x, b in zip(sig, body)]
    return lowpass2(env_note(sig, 0.001, 0.0, dur + 0.05, 0.08), 5200)


@lru_cache(maxsize=None)
def alto_flute(f, dur, slide=False):
    total = dur + 0.25
    sig = tone(f, total, ((1, 1.0), (2, 0.12), (3, 0.03)),
               vib=(4.9, 0.005, 0.35), bend=(-0.7 if slide else 0.0, 0.1))
    br = bandpass(noise(total, int(f) % 53 + 8), min(f * 2.0, 6000.0), 1.2)
    out = add((sig, 1.0), (br, 0.08))
    return lowpass(env_note(out, 0.08, 0.0, dur, 0.16), 3400)


@lru_cache(maxsize=None)
def bongo(pitch=1.0, seed=1):
    t = env_exp(osc(430 * pitch, 0.12, "sine", 360 * pitch), 0.001, 0.05)
    s = env_exp(bandpass(noise(0.03, seed), 2200, 1.4), 0.0005, 0.008)
    return add((t, 1.0), (s, 0.5))


@lru_cache(maxsize=None)
def guiro(seed=1):
    out = []
    rng = random.Random(seed)
    for k in range(16):
        tick = env_exp(bandpass(noise(0.01, rng.randint(1, 99)), 2900, 4.0), 0.0005, 0.003)
        mix_into(out, tick, k * 0.011, 0.6 + 0.4 * (k / 15))
    return out


# ── Starfall Glade ────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def supersaw(f, dur):
    total = dur + 1.0
    voices = [tone(f, total, saw_harm(10), detune=d) for d in (-0.012, -0.005, 0.0, 0.005, 0.012)]
    sig = [sum(v) for v in zip(*voices)]
    return lowpass2(env_note(sig, 0.3, 0.0, dur, 0.9), 2300)


@lru_cache(maxsize=None)
def synth_bass(f, dur):
    total = dur + 0.2
    raw = saw_band(f, total, 12)
    sig = lowpass(raw, 1300.0, 260.0)
    subw = osc(f, total, "sine")
    sig = [x + 0.6 * y for x, y in zip(sig, subw)]
    return env_note(env_exp(sig, 0.003, 0.35), 0.003, 0.0, dur, 0.06)


@lru_cache(maxsize=None)
def synth_choir(f, dur):
    total = dur + 1.0
    raw = vib_osc(f, total, 5.0, 0.004, 0.0, tuple((h, 1.0 / h) for h in range(1, 14)))
    raw2 = vib_osc(f * 1.006, total, 4.6, 0.004, 0.0, tuple((h, 1.0 / h) for h in range(1, 14)))
    mixd = [a + b for a, b in zip(raw, raw2)]
    f1 = bandpass(mixd, 760.0, 3.0)
    f2 = bandpass(mixd, 1250.0, 4.0)
    sig = [0.9 * a + 0.6 * b for a, b in zip(f1, f2)]
    return env_note(sig, 0.5, 0.0, dur, 0.9)


@lru_cache(maxsize=None)
def kick808():
    body = env_exp(osc(150, 0.45, "sine", 46), 0.002, 0.28)
    click = env_exp(highpass(noise(0.01, 3), 2000), 0.0003, 0.002)
    return lowpass(add((body, 1.0), (click, 0.25)), 2500)


@lru_cache(maxsize=None)
def hat_gated(seed=1):
    return lowpass2(env_exp(highpass(noise(0.04, seed), 8000), 0.0005, 0.011), 12000)


# ── Ember Fen ─────────────────────────────────────────────────────────────────

@lru_cache(maxsize=None)
def duduk(f, dur, slide=False):
    """Duduk: dvostruki jezičak, nazalan i topao, izražajan vibrato, klizanja."""
    total = dur + 0.25
    raw = tone(f, total, ((1, 1.0), (2, 0.75), (3, 0.6), (4, 0.35), (5, 0.25), (6, 0.15), (7, 0.1), (8, 0.06)),
               vib=(5.1, 0.011, 0.35), bend=(-1.4 if slide else -0.3, 0.17 if slide else 0.06))
    f1 = bandpass(raw, 650.0, 1.3)
    f2 = bandpass(raw, 1250.0, 2.0)
    low = lowpass(raw, 420.0)
    br = bandpass(noise(total, int(f) % 47 + 2), min(f * 3.0, 6000.0), 1.0)
    sig = [0.9 * a + 0.5 * b + 0.45 * c + 0.03 * d for a, b, c, d in zip(f1, f2, low, br)]
    return env_note(sig, 0.07, 0.0, dur, 0.15)


@lru_cache(maxsize=None)
def oud(f, dur, seed=1):
    total = dur + 0.6
    sig = pluck(f, total, 0.9965, 0.42, seed)
    body = bandpass(sig, 300.0, 1.0)
    sig = [x + 0.4 * b for x, b in zip(sig, body)]
    return lowpass2(env_note(sig, 0.001, 0.0, dur + 0.25, 0.3), 3200)


@lru_cache(maxsize=None)
def darbuka(kind="doum", seed=1):
    if kind == "doum":
        t = env_exp(osc(132, 0.3, "sine", 96), 0.002, 0.15)
        b = env_exp(lowpass(noise(0.1, seed), 420), 0.001, 0.03)
        return add((t, 1.0), (b, 0.3))
    if kind == "tek":
        s = env_exp(bandpass(noise(0.04, seed + 2), 3600, 2.0), 0.0004, 0.022)
        t = env_exp(osc(1100, 0.04, "sine"), 0.0004, 0.016)
        return add((s, 1.0), (t, 0.35))
    s = env_exp(bandpass(noise(0.04, seed + 4), 2500, 2.0), 0.0004, 0.028)
    t = env_exp(osc(880, 0.05, "sine"), 0.0004, 0.02)
    return add((s, 0.8), (t, 0.3))


@lru_cache(maxsize=None)
def riq(seed=1):
    rng = random.Random(seed + 11)
    jing = partials(1.0, 0.15, [(rng.uniform(5000, 5400), 0.5), (rng.uniform(6700, 7100), 0.4),
                                (rng.uniform(8600, 9000), 0.25)], decays=[0.04, 0.03, 0.025])
    hiss = env_exp(highpass(noise(0.06, seed + 7), 7000), 0.0005, 0.015)
    return add((jing, 0.6), (hiss, 0.4))


@lru_cache(maxsize=None)
def chick(seed=1):
    """Zatvoren hi-hat (Country Bloom kit)."""
    hiss = env_exp(highpass(noise(0.05, seed), 7500), 0.0005, 0.018)
    metal = partials(1.0, 0.05, [(6800, 0.3), (8300, 0.2)], decays=[0.015, 0.012])
    return lowpass2(add((hiss, 1.0), (metal, 0.3)), 11000)


# ── ambijent v2 ───────────────────────────────────────────────────────────────

def tanpura(sec, root_hz, fifth_hz, seed=161, period=4.4):
    """Tanpura bordun: Pa – Sa' – Sa' – Sa, svaka žica dugo zvoni; „jawari" — pojas prizvuka
    koji se diže kroz notu (svjetlucavo zujanje)."""
    out = layer(sec)
    order = [fifth_hz, root_hz * 2, root_hz * 2, root_hz]
    t = 0.0
    k = 0
    cache = {}
    while t < sec:
        f = order[k % 4]
        if f not in cache:
            ring = 3.6
            raw = tone(f, ring, saw_harm(18))
            bloom = bandpass(raw, 900.0, 2.2, 2800.0)
            body = lowpass(raw, 600.0)
            sig = [0.5 * a + 0.7 * b for a, b in zip(body, bloom)]
            cache[f] = env_exp(sig, 0.004, 1.6)
        mix_into(out, cache[f], t, 0.9 if k % 4 else 1.0)
        t += period / 4.0
        k += 1
    return out[: n_samples(sec)]


def sheep_bells(sec, at, seed=171, level=0.08):
    out = layer(sec)
    rng = random.Random(seed)
    base = rng.uniform(900, 1250)
    clank = fast_partials([base, base * 2.32, base * 4.1, base * 5.9], [1.0, 0.6, 0.35, 0.2], [0.5, 0.3, 0.15, 0.08], 1.0)
    t = at
    for _ in range(rng.randint(2, 4)):
        mix_into(out, clank, t, level * rng.uniform(0.5, 1.0))
        t += rng.uniform(0.25, 0.6)
    return out[: n_samples(sec)]


def icicles(sec, seed=181, rate=0.7, level=0.05):
    out = layer(sec)
    rng = random.Random(seed)
    t = rng.uniform(0.2, 1.0)
    while t < sec - 0.5:
        mix_into(out, icicle(round(rng.uniform(2300, 4400), 1)), t, level * rng.uniform(0.4, 1.0))
        t += rng.expovariate(rate)
    return out[: n_samples(sec)]


def sleigh_pass(sec, at, seed=191, length=6.0, level=0.07):
    """Saonice prolaze u daljini: praporci 8/s, priđu pa odu (glasnoća + tama)."""
    out = layer(sec)
    rng = random.Random(seed)
    t = 0.0
    while t < length:
        x = t / length
        g = math.sin(math.pi * x) ** 2
        mix_into(out, sleigh(rng.randint(1, 3)), at + t, level * g)
        t += 0.125 + rng.uniform(-0.01, 0.01)
    return lowpass2(out[: n_samples(sec)], 6500)


def woodpecker(sec, at, seed=201, level=0.1):
    out = layer(sec)
    rng = random.Random(seed)
    tap = temple_block(1.9)
    n = rng.randint(10, 16)
    for k in range(n):
        mix_into(out, tap, at + k * 0.062, level * (1.0 - 0.04 * k))
    return out[: n_samples(sec)]


def crow(sec, at, seed=211, level=0.07):
    out = layer(sec)
    rng = random.Random(seed)
    for k in range(rng.randint(1, 3)):
        d = 0.33
        f0 = rng.uniform(560, 650)
        raw = saw_band(f0, d, 10)
        rough = [x * (0.6 + 0.4 * math.sin(TAU * 38 * i / SR)) for i, x in enumerate(raw)]
        caw = env_swell(bandpass(rough, 1250.0, 1.6, 1000.0), 0.15, 0.85)
        mix_into(out, caw, at + k * 0.5, level)
    return out[: n_samples(sec)]


def katydids(sec, seed=221, level=0.04):
    """Noćni skakavci (Moonlit): niže, „ch-ch-ch" grupe — drugačije od cvrčaka (Lantern)."""
    out = layer(sec)
    rng = random.Random(seed)
    for v in range(2):
        f = rng.uniform(2700, 3300)
        burst = env_exp(bandpass(noise(0.05, seed + v), f, 3.0), 0.003, 0.012)
        t = rng.uniform(0.0, 1.0)
        while t < sec - 0.5:
            for p in range(rng.randint(2, 3)):
                mix_into(out, burst, t + p * 0.09, level * rng.uniform(0.6, 1.0))
            t += rng.uniform(0.9, 1.6)
    return out[: n_samples(sec)]


def cosmic_hum(sec, seed=231):
    n = n_samples(sec)
    a = osc(55.0, sec, "sine")
    b = osc(82.6, sec, "sine")
    c = osc(110.3, sec, "sine")
    air = bandpass(noise(sec, seed, "pink"), 1800.0, 0.7)
    s = math.sin
    return [0.5 * x + 0.3 * y + 0.2 * z + 0.15 * w * (0.5 + 0.5 * s(TAU * 2 * i / n)) for i, (x, y, z, w) in enumerate(zip(a, b, c, air))]


def drips(sec, seed=241, rate=0.5, level=0.06):
    out = layer(sec)
    rng = random.Random(seed)
    t = rng.uniform(0.3, 1.5)
    while t < sec - 0.3:
        f = rng.uniform(700, 1100)
        plip = env_exp(osc(f, 0.06, "sine", f * 2.0), 0.002, 0.018)
        mix_into(out, plip, t, level * rng.uniform(0.5, 1.0))
        t += rng.expovariate(rate)
    return out[: n_samples(sec)]


@lru_cache(maxsize=None)
def snare_soft(seed=1):
    """Mekani doboš (Country Bloom kit): kratak ton tijela + šum žica, bez oštrine."""
    body = env_exp(osc(196, 0.12, "sine", 168), 0.001, 0.05)
    wires = env_exp(bandpass(noise(0.2, seed), 2600, 0.8), 0.001, 0.07)
    return lowpass2(add((body, 0.7), (wires, 0.8)), 7000)


@lru_cache(maxsize=None)
def riser(f, dur):
    """Uzlazni šum (Starfall Arena prije „dropa"): pojas klizi 400 → 6000 Hz, glasnoća raste."""
    sec = max(dur, 0.5)
    sig = bandpass(noise(sec, 251, "pink"), 400.0, 1.6, 6000.0)
    n = len(sig)
    return [x * (i / n) ** 2 for i, x in enumerate(sig)]
