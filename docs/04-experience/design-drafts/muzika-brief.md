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
> **What I need:** the game has **8 seasons**, each with its own look and mood. Each season needs **3 instrumental loops** that share the same key and main motif:
> - **Home** — menus, home screen, shop, collection album (heard the most): the season's main theme, melody in front, calm.
> - **Arena** — the merge puzzle screen: same theme, more playful (ostinato, a bit faster).
> - **Run** — the running level: almost ambient (pad + nature sounds of the season); the home motif may appear slowly; must not fight with sound effects; no drums.
>
> | # | Season | Mood | Key / meter | Home tempo · instruments | Arena | Run ambience |
> |---|--------|------|-------------|--------------------------|-------|--------------|
> | 1 | **Country Bloom** | warm fields, sunny afternoon | F major, 4/4 swing | 84 · Rhodes, harp, glockenspiel, brushes | 100 · marimba, whistle | birds, wind |
> | 2 | **Frost Orchard** | crisp winter orchard, silver blossom | D major (Lydian sparkle), **waltz 3/4** | 88 · music box / celesta, harp, pizzicato, strings, triangle | 104 · pizzicato polka, sleigh bells | snowy wind, wind chimes |
> | 3 | **Lantern Meadow** | dusk, paper lanterns, fireflies in tall grass | Eb major **pentatonic** | 72 · bamboo flute, koto, kalimba, frame drum | 96 · kalimba ostinato, woodblock | crickets, fireflies |
> | 4 | **Amber Canopy** | late-autumn sun through high leaves | G major, **6/8** | 60 (dotted ♩) · clarinet, fingerpicked guitar, cello, tambourine | 76 · **jig**: banjo, fiddle, bodhrán | rustling leaves, wind |
> | 5 | **Moonlit Warren** | night blooms under a quiet moon, bunny burrows | Ab major, **lullaby 3/4** | 66 · vibraphone, harp, soft choir | 96 · **brush-swing**: upright bass, Rhodes, vibes | crickets, owl, stars |
> | 6 | **Coral Tide Garden** | salt breeze, seashell petals | A major, **bossa nova** | 100 · flute, nylon guitar, Rhodes, rim clicks | 112 · **calypso**: steel pan, marimba, congas | waves, gulls |
> | 7 | **Starfall Glade** | petals catching the night sky, falling stars | Bb **Lydian** | 80 · airy lead, glassy arpeggio, warm synth pad | 108 · synth arpeggio, soft pulse | sparkles, meteors |
> | 8 | **Ember Fen** | low firelight over marsh blooms — mysterious but warm, never scary | D **Dorian** | 70 · low flute, tongue drum / handpan, D–A drone, frame drum | 96 · tongue drum ostinato, clarinet | crackling embers, frogs |
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
