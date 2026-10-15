---
type: iskustvo
status: aktivan
milestone: M8
tags: [iskustvo, audio, muzika, sezone]
povezano:
  - audio-direction
  - zvuk-izvjestaj
  - muzika-brief
  - seasons-izvjestaj
ai_sažetak: "Muzika po sezoni: 8 sezona × 3 nivoa (home = hub, arena, run) — tonalitet, mjera, tempo, instrumenti, ambijent i motiv svake sezone; Arena i run citiraju home motiv. Privremeno sintetizovano (scripts/audio/season_songs.py)."
---

# Muzika po sezoni

> Roditelj: [[_index|04-experience]] · sistem i miks: [[audio-direction]] · brief za pravu muziku: [[design-drafts/muzika-brief|muzika-brief]] · datum: 2026-10-14

## Sažetak

Svaka sezona ima **tri teme** — po jednu za svaki nivo igre:

| Nivo | Gdje svira | Karakter |
|------|-----------|----------|
| **home** | hub (Home, Camp, Shop, Album) i loot ekran | glavna tema sezone, mirna, melodija u prvom planu |
| **arena** | stranica Arena | ista sezona, razigranije: ostinato, brži tempo, motiv home teme se vrati u taktovima 5–8 |
| **run** | run | skoro ambijent: pad na 4 akorda + zvukovi okoline sezone; home motiv se citira takt po takt preko padova |

Muzika uvijek prati **aktivnu sezonu**: kad igrač promijeni sezonu (Home, kupovina u Shopu, otključavanje u Campu), tema se pretopi za ~1 s, bez novog poziva iz koda. Kod bira nivo (`Sfx.music_level("home" | "arena" | "run")`), a `AudioManager` sezonu.

Identitet sezone nosi: **tonalitet i modus**, **mjera**, **paleta instrumenata** i **ambijent**. Sve tri teme jedne sezone dijele tonalitet i motiv, pa se sezona prepozna i u Areni i u runu.

## Sezone

| # | Sezona | Tema | Tonalitet | Home | Arena | Run (ambijent) |
|---|--------|------|-----------|------|-------|----------------|
| 1 | Country Bloom | Sunny Pasture | F-dur (Arena C-dur) | 4/4 swing 84 · el. klavir, harfa, glockenspiel, četke | 100 · marimba, zviždaljka | pad, harfa · ptice, vjetar |
| 2 | Frost Orchard | Silver Waltz | D-dur, lidijska iskra (#11, G#) | **valcer 3/4** 88 · muzička kutija, harfa, pizzicato bas, gudači, trokut, praporci | 104 · pizzicato polka, celesta, praporci | ledeni pad + hor, muzička kutija · snježni vjetar s fijukom, zvona na vjetru |
| 3 | Lantern Meadow | Lantern Walk | Eb-dur **pentatonika** | 72 · bambusova flauta, koto, kalimba, rhodes, okvirni bubanj, činelice | 96 · kalimba ostinato, woodblock, konge | topli pad, kalimba · cvrčci, svici |
| 4 | Amber Canopy | Copper Leaves | G-dur | **6/8** 60 · klarinet, gitara prstima, gudački bas, tamburin | **jig 6/8** 76 · bendžo, violina, bodhrán | gudači, gitara · šuštanje lišća, vjetar, rijetke ptice |
| 5 | Moonlit Warren | Moon Lullaby | Ab-dur | **uspavanka 3/4** 66 · vibrafon, harfa, hor, pizzicato bas | noćni **swing** 96 · kontrabas (walking), rhodes, vibrafon, ride, četke | pad + hor, vibrafon · cvrčci, sova, zvijezde |
| 6 | Coral Tide Garden | Seashell Bossa | A-dur | **bossa nova** 100 · flauta, najlon gitara, rhodes, rim klik | **calypso** 112 · steel pan, marimba, konge | topli pad, steel pan · talasi, galebovi, mjehurići |
| 7 | Starfall Glade | Falling Stars | Bb **lidijski** (E♮) | 80 · nebeski lead, stakleni arpeđo, sintisajzerski pad, sub bas | 108 · synth arp, stakleni 16-tinke, puls | sintisajzerski pad + hor, staklo · iskre, meteori |
| 8 | Ember Fen | Firelight Marsh | D **dorijski** (toplo-tajanstveno) | 70 · niska flauta, tongue drum, bordun D–A, okvirni bubanj | 96 · tongue drum ostinato, klarinet, pljesak | bordun + pad, tongue drum · pucketanje žara, žabe, nizak vjetar |

Tempo u 6/8 je dotted-četvrtina (60 / 76); u generatoru je zapisan kao osmine (180 / 228).

### Kako zvuče (namjera)

- **Country Bloom** — sunčano popodne na pašnjaku; originalne teme (prve u igri), sad prebačene u novi sistem.
- **Frost Orchard** — klizanje po zaleđenom voćnjaku: valcer na muzičkoj kutiji. G# u E9 i C# u Gmaj7#11 daju „mraz" — svjetlucavu, malo neočekivanu boju.
- **Lantern Meadow** — šetnja s lampama u sumrak: pentatonika (bez polutonova) i bambusova flauta, sve je meko i široko; u runu se čuju samo cvrčci, svici i pad.
- **Amber Canopy** — jesenja šuma: valovito 6/8 („ljuljanje") kao folk pjesma uz gitaru. Arena je irski jig — najživlja Arena u igri.
- **Moonlit Warren** — uspavanka za zečeve u jazbini (3/4, sporo); Arena je tihi noćni jazz s četkama.
- **Coral Tide Garden** — bossa nova na plaži: sinkope, najlon gitara, flauta; Arena je calypso sa steel panom.
- **Starfall Glade** — zvjezdana čistina: lidijski modus (povišena kvarta) je klasična „čarobna / svemirska" boja; stakleni arpeđo kao zvjezdice.
- **Ember Fen** — vatra nad močvarom: dorijski modus je mol sa svijetlom sekstom (B♮) — tajanstveno, ali toplo; bordun i tongue drum, bez ičega strašnog.

## Pravila (za sve teme)

- **Loop bez šava:** rep reverba i zadnjih nota se presavije na početak; ambijent (vjetar, more, žar) se pretapa 1,5 s.
- **Harmonija provjerena:** `music_gen.py --lint` — svaka nota na jakoj dobi je ton akorda ili dozvoljena boja (9, 11, 13), ništa van ljestvice, nema dugih sudara (mala sekunda); motiv u runu ne prelazi preko promjene akorda.
- **Glasnoća:** home i arena −24 LUFS u fajlu, run −27 (u igri na default sliderima ~−25 / −28, efekti stoje iznad).
- **Telefon:** melodija i harmonija su iznad ~200 Hz; bas samo podržava.
- **Dužine:** 25–55 s po temi (16 taktova; run 32 s). OGG mono 24 kHz q3 — svih 24 tema ~4–5 MB.

## Zamjena pravom muzikom

Isto kao za jednu temu ([[audio-direction#Zamjena pravim zvukom|audio-direction § Zamjena]]): fajl `game/assets/audio/music/<sezona>_<nivo>.ogg`, `"source": "real"` u katalogu, `python scripts/audio/music_gen.py --measure`. Može se mijenjati sezona po sezona — prave i sintetizovane teme rade zajedno. Za kompozitora: tabela gore je specifikacija (tonalitet, tempo, instrumenti, ambijent), [[design-drafts/muzika-brief|muzika-brief]] je tekst za slanje.

## Povezano

- [[_index|← Iskustvo]]
- [[audio-direction|audio-direction]]
- [[zvuk-izvjestaj|zvuk-izvjestaj]]
- [[design-drafts/muzika-brief|muzika-brief]]
- [[design-drafts/seasons-izvjestaj|seasons-izvjestaj]]
