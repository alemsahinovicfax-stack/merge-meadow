"""Efekti za sezonsku muziku (music_gen.py) — čist Python, mono.

reverb   Freeverb (8 comb + 4 all-pass, prigušenje, pre-delay) — „soba" sezone
echo     eho s povratnom spregom i filterom u petlji (Lantern flauta, Starfall arp)
chorus   modulisano kašnjenje (padovi, rhodes); `wow` = isto, sporo i puno (traka)
tilt     nagib spektra oko tačke (tamnije / svjetlije, boja sezone)
pump     sidechain „pumpanje" na svaku dobu (Starfall)
drive    blago zasićenje (toplina)
"""
import math

from dsp import SR, n_samples

TAU = 2.0 * math.pi

_COMBS = (1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617)
_APS = (556, 441, 341, 225)


def reverb(sig, size=0.8, damp=0.4, wet=1.0, predelay=0.02, tail=0.0, bright=1.0):
    """Freeverb (Jezar) mono: vraća SAMO mokri signal (send / return), dužine len+tail.
    size 0..1 (soba → hala), damp 0..1 (prigušenje visokih), bright skalira ulaz za visoke."""
    scale = SR / 44100.0
    n = len(sig) + n_samples(tail)
    pd = n_samples(predelay)
    src = [0.0] * n
    g_in = 0.015
    for i, x in enumerate(sig):
        if i + pd < n:
            src[i + pd] = x * g_in
    fb = size * 0.28 + 0.7
    d1 = damp * 0.4
    d2 = 1.0 - d1
    out = [0.0] * n
    for c in _COMBS:
        L = max(2, int(c * scale))
        buf = [0.0] * L
        idx = 0
        store = 0.0
        for i in range(n):
            y = buf[idx]
            store = y * d2 + store * d1
            buf[idx] = src[i] + store * fb
            out[i] += y
            idx += 1
            if idx == L:
                idx = 0
    for a in _APS:
        L = max(2, int(a * scale))
        buf = [0.0] * L
        idx = 0
        for i in range(n):
            b = buf[idx]
            x = out[i]
            out[i] = -x + b
            buf[idx] = x + b * 0.5
            idx += 1
            if idx == L:
                idx = 0
    w = wet * 3.0
    if bright != 1.0:
        out = tilt(out, 2500.0, 0.0, 20.0 * math.log10(max(bright, 1e-3)))
    return [x * w for x in out]


def echo(sig, delay=0.375, feedback=0.4, lp=3000.0, mix=1.0, tail=0.0):
    """Mokri eho (bez originala): kašnjenje s filtrom u petlji — svaki odjek tamniji."""
    d = max(1, n_samples(delay))
    n = len(sig) + n_samples(tail)
    buf = [0.0] * d
    out = [0.0] * n
    a = math.exp(-TAU * lp / SR)
    y = 0.0
    idx = 0
    for i in range(n):
        x = sig[i] if i < len(sig) else 0.0
        delayed = buf[idx]
        y = (1.0 - a) * delayed + a * y
        out[i] = delayed * mix
        buf[idx] = x + y * feedback
        idx += 1
        if idx == d:
            idx = 0
    return out


def chorus(sig, rate=0.6, depth=0.003, base=0.012, mix=0.5):
    """Modulisano kašnjenje (linearna interpolacija): širi pad / rhodes."""
    n = len(sig)
    out = [0.0] * n
    sin = math.sin
    w = TAU * rate / SR
    b = base * SR
    dep = depth * SR
    for i in range(n):
        dl = b + dep * sin(w * i)
        p = i - dl
        j = int(p)
        if j < 0:
            wet = 0.0
        else:
            fr = p - j
            a = sig[j]
            c = sig[j + 1] if j + 1 < n else 0.0
            wet = a + (c - a) * fr
        out[i] = sig[i] * (1.0 - mix) + wet * mix
    return out


def wow(sig, rate=0.45, depth=0.0018):
    """Traka koja malo „pliva" (pitch wobble): samo kašnjeni signal, sporo."""
    return chorus(sig, rate, depth, depth * 1.5 + 0.002, 1.0)


def tilt(sig, pivot=1200.0, low_db=0.0, high_db=0.0):
    """Nagib: niske (ispod pivota) i visoke (iznad) svaka svojim pojačanjem."""
    a = math.exp(-TAU * pivot / SR)
    gl = 10 ** (low_db / 20.0)
    gh = 10 ** (high_db / 20.0)
    y = 0.0
    out = [0.0] * len(sig)
    for i, x in enumerate(sig):
        y = (1.0 - a) * x + a * y
        out[i] = y * gl + (x - y) * gh
    return out


def pump(sig, beat_sec, depth=0.5, release=0.22, offset=0.0):
    """Sidechain: na svaku dobu glasnoća padne za `depth` pa se vrati za `release` s."""
    out = [0.0] * len(sig)
    exp = math.exp
    bs = beat_sec * SR
    rel = release * SR
    off = offset * SR
    for i, x in enumerate(sig):
        t = (i - off) % bs
        att = min(1.0, t / (0.004 * SR))
        g = 1.0 - depth * att * exp(-t / rel) if t > 0 else 1.0 - depth
        out[i] = x * g
    return out


def drive(sig, amount=1.5, mix=0.6):
    t = math.tanh
    norm = 1.0 / t(amount)
    return [x * (1.0 - mix) + t(x * amount) * norm * mix for x in sig]
