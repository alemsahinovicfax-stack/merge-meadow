---
type: iskustvo
status: aktivan
milestone: M8
tags: [iskustvo, audio, muzika, brief]
povezano:
  - audio-direction
  - muzika-sezone
  - zvuk-izvjestaj
ai_sažetak: "Brief za pravu muziku (kompozitor, paket ili AI): 8 sezona × 3 loopa (home, Arena, run) — raspoloženje, tonalitet, tempo, instrumenti po sezoni, format, glasnoća, licenca; prioritet (prvo 8 home tema); engleski tekst spreman za slanje."
---

# Muzika — brief za kompozitora / izvor

## Sažetak

Igra ima **24 privremene teme** (8 sezona × home / arena / run, sinteza, 2026-10-14) — rade, svaka sezona ima svoj karakter, ali zvuče „kompjuterski". Ovaj brief je za pravu muziku, koji god put izabereš:

| Put | Za | Protiv |
|-----|----|--------|
| **Kompozitor** (Fiverr, SoundBetter, r/gameDevClassifieds) | muzika samo za tvoju igru, ispravke po želji | najskuplje (24 loopa!); treba jasan ugovor (licenca, Content ID) |
| **Gotov paket** (itch.io, Humble bundle, Unity / Godot asset paketi) | jeftino, odmah | drugi ga koriste; teško naći 8 različitih „sezona" koje pašu |
| **AI** (Suno / Udio, plaćeni plan) | brzo, mnogo varijanti — 24 teme su realne | provjeri komercijalnu licencu plana; loop bez šava obično treba ručno doraditi |

**Prioritet (da trošak ima smisla):**
1. **8 home tema** — sviraju najviše (sav hub + loot ekran).
2. **8 arena tema** — kompozitor ih često može izvesti iz home teme (isti motiv, drugi aranžman, brži tempo) — jeftinije kao „varijacija".
3. **8 run tema** — skoro ambijent; mogu ostati sintetizovane najduže (zvukovi okoline + pad).

Može se mijenjati **sezona po sezona**: fajl `game/assets/audio/music/<sezona>_<nivo>.ogg`, u katalogu `"source": "real"`, pa `python scripts/audio/music_gen.py --measure` ([[../audio-direction#Zamjena pravim zvukom|audio-direction § Zamjena]]). Prave i sintetizovane teme rade zajedno. Privremene teme mogu ići uz brief kao referenca za tempo, tonalitet i raspoloženje.

**Za AI:** opis sezone iz tabele niže + „seamless loop, no intro, no ending, instrumental, <tempo> BPM, <key>" kao prompt; generiši više verzija, izaberi, pa loop dotjeraj u Audacityju (rez na početak takta, crossfade na šavu).

## Brief (engleski — za slanje)

> **Project:** *Merge Meadow* — a cozy mobile game (Android first). You merge seeds into flowers in a small arena, then run through seasonal meadows as Pip, a little bunny, collecting seeds. Pastel, flat-cartoon art; soft, friendly, never stressful. Sessions are short and often played on a phone speaker, sometimes on public transport.
>
> **What I need:** the game has **8 seasons**, each with its own look, mood **and musical genre** — no two seasons should sound alike (different instruments, tempo, meter and groove). Each season needs **3 instrumental loops** that share the same key and main motif:
> - **Home** — menus, home screen, shop, collection album (heard the most): the season's main theme, melody in front, calm.
> - **Arena** — the merge puzzle screen: same theme, more playful (ostinato, a bit faster).
> - **Run** — the running level: almost ambient (pad + nature sounds of the season); the home motif may appear slowly; must not fight with sound effects; no drums.
>
> | # | Season | Mood | Key / meter | Home tempo · instruments | Arena | Run ambience |
> |---|--------|------|-------------|--------------------------|-------|--------------|
> | 1 | **Country Bloom** | warm fields, sunny afternoon — country / bluegrass | F major, 4/4 straight eighths | 100 · harmonica, lap steel, steel-string guitar boom-chick, light kit | 132 · **bluegrass**: banjo rolls, whistle | walking strum, harmonium, birds, sheep bells |
> | 2 | **Frost Orchard** | crisp winter orchard, silver blossom — classical | D major (Lydian sparkle), **waltz 3/4** | 132 · celesta then glass harmonica, harp oom-pah-pah, string tremolo, sleigh bells | 112 · **polka**: pizzicato, celesta + glockenspiel | twinkling celesta, glass pad, icicles, distant sleigh |
> | 3 | **Lantern Meadow** | dusk lantern festival in tall grass — Japanese | Eb major **pentatonic** | 68 · shakuhachi (bends, echo), koto, sho, taiko, temple bell | 96 · **festival drums**: taiko, flute call – koto answer | very slow: sho, temple bell, crickets, wind chimes |
> | 4 | **Amber Canopy** | late-autumn sun through high leaves — Celtic folk | G major, **6/8** | 60 (dotted ♩) · tin whistle (cuts), fiddle harmony, fingerpicked guitar, accordion, bodhrán | 84 · **jig** (A + B part): fiddle, whistle, bouzouki | 6/8 fingerpicking, cellos, leaves, woodpecker, crow |
> | 5 | **Moonlit Warren** | night blooms under a quiet moon, bunny burrows — lullaby + night jazz | Ab major, **12/8 lullaby** | 46 (dotted ♩) · music box, felt piano, soft choir, upright bass | 88 · **brush swing**: vibes head, Rhodes, walking bass | broken chords on felt piano, choir, katydids, owl |
> | 6 | **Coral Tide Garden** | salt breeze, seashell petals — Brazil + Caribbean | A major, **bossa nova** | 128 · alto flute, nylon guitar, steel pan counter-line, marimba bass | 104 · **calypso**: marimba riff, steel pan, ukulele chops, congas | steel pan ostinato, deep waves, gulls |
> | 7 | **Starfall Glade** | petals catching the night sky, falling stars — electronic | Bb **Lydian** | 108 · airy lead, pumping supersaw, 16th arpeggio, 808, sub | 118 · **build-up then drop** | pumping pulse, sparkles, meteors |
> | 8 | **Ember Fen** | low firelight over marsh blooms — modal world, mysterious but warm | D **Dorian** | 62 · duduk, handpan, tanpura drone, oud, darbuka | **7/8** (2+2+3) · darbuka, oud melody, duduk | heartbeat darbuka, tanpura, embers, frogs |
>
> **Write in each genre's own language, not one style for all.** The placeholders share no instruments, but an earlier version still sounded alike because every melody used the same rhythms and every season the same I–vi–IV–V chords. Please make each season idiomatic:
> - **Country Bloom:** eighth-note pickups, repeated notes, a few "push" anticipations; triads and dominant 7ths (I–VI7–II7–V7).
> - **Frost Orchard:** long notes tied over the bar, appoggiaturas; classical harmony (V/V, inversions), a minor iv for winter.
> - **Lantern Meadow:** long tones, quick ornaments, silence (*ma*); the "royal road" IV–V–iii–vi, sus2 chords, pedal.
> - **Amber Canopy:** jig rhythms; mixolydian bVII (F in G major).
> - **Moonlit Warren:** lullaby with hemiola over a tonic pedal; the Arena is real swing (laid back, ii–V).
> - **Coral Tide:** bossa anticipations and tritone substitutions; calypso with 3+3+2 sixteenths and sixth chords.
> - **Starfall Glade:** tresillo (3+3+2) toplines, Lydian I–II; tight, quantized.
> - **Ember Fen:** duduk melismas (triplet turns), Dorian i–IV over a drone; 7/8 phrased 2+2+3.
>
> **References for the feel** (not to copy): Animal Crossing (New Horizons) hourly music, Stardew Valley seasons, A Short Hike, Unpacking.
>
> **Technical:**
> - Seamless loops: no intro, no ending, no fade; the last bar flows into the first. Home 30–60 s, Arena 25–45 s, Run 30–40 s.
> - Phone-speaker friendly: the melody and harmony must be clear without bass; nothing important below ~200 Hz; no harsh highs above ~8 kHz.
> - Leave room for sound effects: no busy lead in the 2–4 kHz range for the Run loops; keep dynamics gentle.
> - Delivery: WAV, 48 kHz (or 44.1 kHz), 24-bit, stereo; integrated loudness around −16 LUFS, true peak ≤ −1 dBTP (I set the in-game level myself). Stems welcome but optional.
> - The 3 loops of a season share key and motif, so a 1 s crossfade between them (home ↔ arena) feels natural.
>
> **License:** perpetual, worldwide, commercial use in the game, its trailers, store pages and social videos; I may edit / loop / shorten it. **No Content ID / YouTube claim registration.** Credit name of your choice in the game credits. Exclusive license preferred — please quote both exclusive and non-exclusive, and per season or for all 8.
>
> **Process:** first the Home theme of season 1 (short sketch, 20–30 s); after approval the remaining Home themes, then the Arena and Run versions. One round of revisions per track.
>
> **Attached:** placeholder versions of all 24 loops (tempo, key and mood reference only).

## Šta provjeriti kad stigne

- [ ] Loop bez šava (slušaj prelaz kraj → početak 5×; u Audacityju bez klika)
- [ ] Na zvučniku telefona: melodija se čuje, ništa ne „pucketa" od basa
- [ ] Uz efekte: `merge`, `coin`, `pour` se jasno čuju preko muzike (Settings 80 / 100)
- [ ] Home ↔ Arena iste sezone: prelaz od 1 s ne „škripi" (isti tonalitet)
- [ ] Licenca napisana (email / ugovor), Credits u Settingsu ažurirani
- [ ] `--measure` upisao `db`, `audio_smoke` prolazi, veličina u budžetu (`AUDIO_BUDGET_KB` 8192; sintetizovane teme su OGG mono 24 kHz q3 ≈ 6 KB/s; pravi stereo OGG q4 ≈ 16 KB/s — 24 × 40 s ≈ 15 MB → prave teme kodirati mono / 32 kHz ili svjesno dići budžet)

## Povezano

- [[../_index|← Iskustvo]]
- [[../muzika-sezone|muzika-sezone]]
- [[../audio-direction|audio-direction]]
- [[../zvuk-izvjestaj|zvuk-izvjestaj]]
