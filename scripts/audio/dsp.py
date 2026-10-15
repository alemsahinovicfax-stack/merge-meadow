"""Mali DSP za Merge Meadow zvuk — čist Python (bez numpy), mono float liste.

Koriste ga sfx_gen.py (efekti) i music_gen.py (privremena muzika). Sve je deterministično
(seed), pa isti skript uvijek daje iste fajlove.
"""
import math
import random
import struct
import wave

SR = 44100
TAU = 2.0 * math.pi


def n_samples(sec):
    return max(1, int(round(sec * SR)))


def silence(sec):
    return [0.0] * n_samples(sec)


def semis(f, st):
    return f * (2.0 ** (st / 12.0))


def note_hz(name):
    """'A4', 'C#5', 'Bb3' → Hz."""
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    base = names[name[0].upper()]
    rest = name[1:]
    if rest.startswith("#"):
        base += 1
        rest = rest[1:]
    elif rest.startswith("b"):
        base -= 1
        rest = rest[1:]
    octave = int(rest)
    return 440.0 * (2.0 ** ((base + (octave - 4) * 12) / 12.0))


# ── oscilatori ────────────────────────────────────────────────────────────────

def osc(freq, sec, wave="sine", f_end=None, vib_rate=0.0, vib_depth=0.0, phase=0.0, sweep="exp"):
    """Oscilator s klizanjem tona (exp ili lin) i vibratom (dubina u udjelu frekvencije)."""
    n = n_samples(sec)
    out = [0.0] * n
    ph = phase
    sin = math.sin
    for i in range(n):
        t = i / n
        if f_end is None:
            f = freq
        elif sweep == "exp":
            f = freq * (f_end / freq) ** t
        else:
            f = freq + (f_end - freq) * t
        if vib_depth:
            f *= 1.0 + vib_depth * sin(TAU * vib_rate * i / SR)
        ph += TAU * f / SR
        if wave == "sine":
            s = sin(ph)
        elif wave == "tri":
            s = (2.0 / math.pi) * math.asin(sin(ph))
        elif wave == "soft_square":
            s = math.tanh(2.5 * sin(ph))
        elif wave == "saw":
            # zaobljena pila: zbir prvih harmonika (bez aliasinga na niskim tonovima)
            s = sin(ph) - 0.5 * sin(2 * ph) + 0.33 * sin(3 * ph) - 0.25 * sin(4 * ph)
            s *= 0.6
        else:
            s = sin(ph)
        out[i] = s
    return out


def fm(fc, sec, ratio=2.0, index=2.0, index_end=0.0, f_end=None, feedback=0.0):
    """FM ton (zvono, marimba, EP): indeks modulacije pada od `index` do `index_end`."""
    n = n_samples(sec)
    out = [0.0] * n
    pc = 0.0
    pm = 0.0
    prev = 0.0
    sin = math.sin
    for i in range(n):
        t = i / n
        f = fc if f_end is None else fc * (f_end / fc) ** t
        idx = index + (index_end - index) * t
        pm += TAU * f * ratio / SR
        mod = sin(pm + feedback * prev)
        prev = mod
        pc += TAU * f / SR
        out[i] = sin(pc + idx * mod)
    return out


def pluck(freq, sec, decay=0.996, bright=0.5, seed=1):
    """Karplus-Strong trzaj (harfa / gitara / pizzicato). `bright` 0..1: koliko je početni
    šum filtriran (0 = mekan, tup napad; 1 = oštar)."""
    rng = random.Random(seed)
    period = max(2, int(round(SR / freq)))
    buf = [rng.uniform(-1.0, 1.0) for _ in range(period)]
    passes = int(round(4 * (1.0 - bright)))
    for _ in range(passes):
        buf = [(buf[i] + buf[i - 1]) * 0.5 for i in range(period)]
    m = sum(buf) / period
    buf = [x - m for x in buf]
    n = n_samples(sec)
    out = [0.0] * n
    idx = 0
    for i in range(n):
        cur = buf[idx]
        nxt_i = idx + 1
        if nxt_i == period:
            nxt_i = 0
        buf[idx] = decay * 0.5 * (cur + buf[nxt_i])
        out[i] = cur
        idx = nxt_i
    return out


def noise(sec, seed=1, color="white"):
    rng = random.Random(seed)
    n = n_samples(sec)
    if color == "white":
        return [rng.uniform(-1.0, 1.0) for _ in range(n)]
    # „pink-ish": zbir tri niskopropusna sloja
    out = [0.0] * n
    b0 = b1 = b2 = 0.0
    for i in range(n):
        w = rng.uniform(-1.0, 1.0)
        b0 = 0.99765 * b0 + w * 0.0990460
        b1 = 0.96300 * b1 + w * 0.2965164
        b2 = 0.57000 * b2 + w * 1.0526913
        out[i] = (b0 + b1 + b2 + w * 0.1848) * 0.25
    return out


# ── filteri ───────────────────────────────────────────────────────────────────

def lowpass(sig, fc, fc_end=None):
    out = [0.0] * len(sig)
    y = 0.0
    n = len(sig)
    exp = math.exp
    if fc_end is None:
        # konstantan filter: koeficijent jednom (isti rezultat, ~3× brže)
        a = exp(-TAU * fc / SR)
        b = 1.0 - a
        for i, x in enumerate(sig):
            y = b * x + a * y
            out[i] = y
        return out
    for i, x in enumerate(sig):
        f = fc * (fc_end / fc) ** (i / n)
        a = exp(-TAU * f / SR)
        y = (1.0 - a) * x + a * y
        out[i] = y
    return out


def lowpass2(sig, fc, q=0.707):
    """RBJ biquad low-pass, 12 dB/okt — oštrije od lowpass() (napadi trzalica, FM bočni pojasevi)."""
    f = min(fc, SR * 0.45)
    w0 = TAU * f / SR
    cs = math.cos(w0)
    alpha = math.sin(w0) / (2.0 * q)
    a0 = 1.0 + alpha
    b0 = (1.0 - cs) * 0.5 / a0
    b1 = (1.0 - cs) / a0
    b2 = b0
    a1 = -2.0 * cs / a0
    a2 = (1.0 - alpha) / a0
    out = [0.0] * len(sig)
    x1 = x2 = y1 = y2 = 0.0
    for i, x in enumerate(sig):
        y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, x
        y2, y1 = y1, y
        out[i] = y
    return out


def highpass(sig, fc):
    lp = lowpass(sig, fc)
    return [x - l for x, l in zip(sig, lp)]


def bandpass(sig, fc, q=1.0, fc_end=None):
    """RBJ biquad band-pass (konstantan vrh 0 dB), opciono klizanje centra."""
    out = [0.0] * len(sig)
    x1 = x2 = y1 = y2 = 0.0
    n = len(sig)
    cos = math.cos
    sin = math.sin
    if fc_end is None:
        f = min(fc, SR * 0.45)
        w0 = TAU * f / SR
        alpha = sin(w0) / (2.0 * q)
        a0 = 1.0 + alpha
        b0 = alpha / a0
        b2 = -alpha / a0
        a1 = -2.0 * cos(w0) / a0
        a2 = (1.0 - alpha) / a0
        for i, x in enumerate(sig):
            y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2
            x2, x1 = x1, x
            y2, y1 = y1, y
            out[i] = y
        return out
    for i, x in enumerate(sig):
        f = fc * (fc_end / fc) ** (i / n)
        f = min(f, SR * 0.45)
        w0 = TAU * f / SR
        alpha = sin(w0) / (2.0 * q)
        a0 = 1.0 + alpha
        b0 = alpha / a0
        b2 = -alpha / a0
        a1 = -2.0 * cos(w0) / a0
        a2 = (1.0 - alpha) / a0
        y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, x
        y2, y1 = y1, y
        out[i] = y
    return out


# ── ovojnice i obrada ─────────────────────────────────────────────────────────

def env_exp(sig, attack=0.003, decay=0.2, hold=0.0):
    """Brz napad, pa eksponencijalni pad s vremenskom konstantom `decay`."""
    a = n_samples(attack)
    h = n_samples(hold) if hold > 0 else 0
    out = [0.0] * len(sig)
    exp = math.exp
    for i, x in enumerate(sig):
        if i < a:
            g = i / a
        elif i < a + h:
            g = 1.0
        else:
            g = exp(-(i - a - h) / (decay * SR))
        out[i] = x * g
    return out


def env_adsr(sig, a=0.01, d=0.1, s=0.7, r=0.2):
    n = len(sig)
    na, nd, nr = n_samples(a), n_samples(d), n_samples(r)
    ns = max(0, n - na - nd - nr)
    out = [0.0] * n
    for i, x in enumerate(sig):
        if i < na:
            g = i / na
        elif i < na + nd:
            g = 1.0 - (1.0 - s) * (i - na) / nd
        elif i < na + nd + ns:
            g = s
        else:
            g = s * max(0.0, 1.0 - (i - na - nd - ns) / max(1, nr))
        out[i] = x * g
    return out


def env_swell(sig, rise=0.5, fall=0.5):
    """Mekan uspon i pad (vjetar, šum, whoosh) — sinusni oblik."""
    n = len(sig)
    out = [0.0] * n
    peak = rise / (rise + fall) if rise + fall > 0 else 0.5
    for i, x in enumerate(sig):
        t = i / n
        if t < peak:
            g = math.sin(0.5 * math.pi * t / peak)
        else:
            g = math.cos(0.5 * math.pi * (t - peak) / (1.0 - peak))
        out[i] = x * g * g
    return out


def gain(sig, g):
    return [x * g for x in sig]


def db(x):
    return 10.0 ** (x / 20.0)


def mix_into(dst, src, at_sec=0.0, g=1.0):
    """Doda `src` u `dst` od `at_sec`; produži dst ako treba."""
    start = int(round(at_sec * SR))
    end = start + len(src)
    if end > len(dst):
        dst.extend([0.0] * (end - len(dst)))
    for i, x in enumerate(src):
        dst[start + i] += x * g
    return dst


def mix(*layers):
    """layers: (signal, at_sec, gain)."""
    out = []
    for sig, at, g in layers:
        mix_into(out, sig, at, g)
    return out


def soft_clip(sig, drive=1.0):
    t = math.tanh
    return [t(x * drive) for x in sig]


def fades(sig, fade_in=0.002, fade_out=0.008):
    n = len(sig)
    fi = min(n, n_samples(fade_in))
    fo = min(n, n_samples(fade_out))
    out = list(sig)
    for i in range(fi):
        out[i] *= i / fi
    for i in range(fo):
        out[n - 1 - i] *= i / fo
    return out


def trim_tail(sig, threshold_db=-60.0):
    th = db(threshold_db)
    end = len(sig)
    while end > 1 and abs(sig[end - 1]) < th:
        end -= 1
    return sig[: min(len(sig), end + n_samples(0.01))]


def peak(sig):
    return max((abs(x) for x in sig), default=0.0)


def rms(sig):
    if not sig:
        return 0.0
    return math.sqrt(sum(x * x for x in sig) / len(sig))


def normalize(sig, peak_db=-3.0):
    p = peak(sig)
    if p <= 1e-9:
        return sig
    return gain(sig, db(peak_db) / p)


def echo(sig, delay=0.12, feedback=0.3, wet=0.3, taps=4):
    d = n_samples(delay)
    out = list(sig) + [0.0] * (d * taps)
    for k in range(1, taps + 1):
        g = wet * (feedback ** (k - 1))
        off = d * k
        for i, x in enumerate(sig):
            out[i + off] += x * g
    return out


def reverb(sig, wet=0.25, room=0.82, damp=0.35, tail=1.2):
    """Schroeder / Freeverb-lite: 4 comb + 2 all-pass, mono."""
    n = len(sig) + n_samples(tail)
    src = list(sig) + [0.0] * (n - len(sig))
    combs = [1116, 1188, 1277, 1356]
    out = [0.0] * n
    for c in combs:
        buf = [0.0] * c
        idx = 0
        store = 0.0
        for i in range(n):
            y = buf[idx]
            store = y * (1.0 - damp) + store * damp
            buf[idx] = src[i] + store * room
            out[i] += y
            idx += 1
            if idx == c:
                idx = 0
    for ap in (556, 441):
        buf = [0.0] * ap
        idx = 0
        for i in range(n):
            b = buf[idx]
            x = out[i]
            y = -x + b
            buf[idx] = x + b * 0.5
            out[i] = y
            idx += 1
            if idx == ap:
                idx = 0
    w = wet / len(combs)
    return [src[i] * (1.0 - wet) + out[i] * w for i in range(n)]


def resample_pitch(sig, ratio):
    """Grubo pomjeranje tona (linearna interpolacija) — za varijacije zrna."""
    n = int(len(sig) / ratio)
    out = [0.0] * n
    for i in range(n):
        p = i * ratio
        j = int(p)
        f = p - j
        a = sig[j] if j < len(sig) else 0.0
        b = sig[j + 1] if j + 1 < len(sig) else 0.0
        out[i] = a + (b - a) * f
    return out


# ── snimanje ──────────────────────────────────────────────────────────────────

def write_wav(path, sig, sr=SR):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        frames = bytearray()
        for x in sig:
            v = int(max(-1.0, min(1.0, x)) * 32767.0)
            frames += struct.pack("<h", v)
        w.writeframes(bytes(frames))
