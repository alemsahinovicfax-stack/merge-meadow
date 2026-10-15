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
ai_sažetak: "Muzika po sezoni (drugi ciklus): 8 sezona × 3 nivoa (home, arena, run); svaka sezona je žanr — svoji instrumenti (101 zvuk, 0 dijeljenih), svoj ritam melodije, svoja harmonija, svoj tempo / mjera / soba i „osjećaj" izvođenja; Arena i run citiraju home motiv. Mjerenje: scripts/audio/music_report.py (zvuk, --structure, --melody, --harmony)."
---

# Muzika po sezoni

> Roditelj: [[_index|04-experience]] · sistem i miks: [[audio-direction]] · brief za pravu muziku: [[design-drafts/muzika-brief|muzika-brief]] · prvi ciklus i drugi ciklus: 2026-10-14 / 2026-10-15

## Sažetak

Svaka sezona ima **tri teme** — po jednu za svaki nivo igre:

| Nivo | Gdje svira | Karakter |
|------|-----------|----------|
| **home** | hub (Home, Camp, Shop, Album) i loot ekran | glavna tema sezone, melodija u prvom planu |
| **arena** | stranica Arena | ista sezona, razigranije — forma po žanru (jig, pitanje–odgovor, „drop"…) |
| **run** | run | skoro ambijent s **vlastitim tempom i ritamskim potpisom** + zvukovi okoline sezone; home motiv se citira |

Muzika prati **aktivnu sezonu** (otvoriš polje druge sezone, kupiš je ili otključaš → za ~1 s pretopi se). Kod bira nivo (`Sfx.music_level("home" | "arena" | "run")`), `AudioManager` sezonu.

### Drugi ciklus (2026-10-15): „da nijedna sezona ne zvuči kao druga"

Prvi ciklus je imao isti zvučni „pribor" za sve sezone: iste FM zvona i trzalice, isti reverb, slična tempa. Ali mjerenje je pokazalo i dublji uzrok, koji promjena instrumenata ne rješava — **isti „rukopis kompozitora"**:

- **Isti ritam melodija.** Skoro sve melodije su građene od istih ćelija (♩♩, 𝅗𝅥♩, ♩.♪); ćeliju ♩♩ je koristilo svih 8 sezona. Nijedna melodija nije imala sinkopu.
- **Ista harmonija.** 5 od 8 run tema je imalo *identičnu* progresiju (I–vi–IV–V s maj9 akordima). Home teme pet sezona su sve bile I–vi–ii–V u maj7 bojama.

Zato drugi ciklus mijenja četiri sloja:

1. **Instrumenti.** Svaka sezona je žanr sa svojim instrumentima. Nijedan instrument, udaraljka ni zvuk okoline se ne dijeli između sezona (101 zvuk, 0 dijeljenih; `music_report.py --structure`).
2. **Ritam melodije po žanru** (§ Rukopis niže).
3. **Harmonija po žanru** (§ Rukopis niže).
4. **Izvedba.**
   - Različita tempa i mjere (4/4, 3/4, 6/8, 12/8, 7/8; Arene 88–132 BPM uz jig ♩. 84 i 7/8 ♪ 150, runovi 52–90).
   - Svaki run ima svoj ritamski potpis.
   - „Soba" sezone: reverb, eho, nagib boje, zasićenje, sidechain.
   - „Osjećaj": elektronika je kvantizovana, folk labav, jazz melodija kasni iza dobe.
   - Klizanja, predudari, vezane note preko takta, triole; prelazi bubnjeva na krajevima fraza.

## Sezone

| # | Sezona | Žanr | Home | Arena | Run (potpis) | Soba |
|---|--------|------|------|-------|--------------|------|
| 1 | Country Bloom · *Sunny Pasture* | country / bluegrass | 4/4 100, ravne osmine · **harmonika**, **lap steel** (B dio), čelična gitara „boom-chick", okrugli bas, kit (kick, mekani doboš, hi-hat) | **bluegrass** 132 · bendžo roll, gitara, harmonika „break", dobro (lap steel) citira motiv | **šetnja** 84: strum + harmonij (F6), lap steel motiv · ptice, ovčja zvona | mala soba, toplo zasićenje |
| 2 | Frost Orchard · *Silver Waltz* | zimski klasični valcer | 3/4 132, 32 takta · **celesta** → **staklena harmonika**, harfa oom-pah-pah, pizzicato bas, gudači tremolo, praporci, trokut, glissando harfe | **polka** 112 · pizzicato, celesta + glockenspiel | **treperenje** 3/4 72: celesta u 16-tinkama nad silaznim basom · ledenice, saonice u daljini | svijetla velika hala |
| 3 | Lantern Meadow · *Lantern Walk* | japanski festival lampiona (pentatonika) | 68 · **shakuhachi** (klizanja, eho), koto akordi + tremolo + heterofonija, **sho** (kvartalno slaganje), taiko, hramski blok, **hramsko zvono** | **festival** 96 · taiko ansambl, flauta zove – koto odgovara | **vrlo sporo** 52: sho na pedalu Eb, hramsko zvono, shakuhachi s ehom · cvrčci, zvona na vjetru | drvena soba + eho |
| 4 | Amber Canopy · *Copper Leaves* | keltski folk | 6/8 (♩. 60) · **tin whistle** (predudari), violina tercu ispod u završnici, gitara prstima, harmonika (B), violončelo, **bodhrán** | **jig** ♩. 84 (A i B dio) · violina + whistle, **buzuki**, harmonika na „pah" | **fingerpick** 6/8 ♩. 54 + violončela · lišće, djetlić, vrana | suha bliska soba |
| 5 | Moonlit Warren · *Moon Lullaby* | uspavanka + noćni jazz | **12/8** (♩. 46) · **muzička kutija**, **filcani klavir** (ljuljanje), hor „ooh", kontrabas | **swing** 88 · vibrafon tema od prvog takta, rhodes (chorus), walking kontrabas, ride + četke | **lomljeni akordi** 12/8 ♩. 40: filcani klavir, hor, muzička kutija · skakavci, sova | mekana tamna soba |
| 6 | Coral Tide Garden · *Seashell Bossa* | bossa nova + calypso | **bossa** 128 · **alt flauta**, **najlon gitara**, steel pan kontra, marimba bas, shaker 16-tinke, rim klave | **calypso** 104 · marimba riff, steel pan, **ukulele** chop, konge / bongo / guiro | **ostinato** 66: steel pan, topli pad, alt flauta · tamni talasi, galebovi, mjehurići | kratka svijetla soba + slapback |
| 7 | Starfall Glade · *Falling Stars* | elektronika (lidijski) | 108 · nebeski lead, **supersaw** (pumpa), 16-tinski arp, sub, **808**, hat, sintisajzerski hor, riser | 118 · **gradnja** (taktovi 1–8) pa **drop** | **puls** 90: pumpani 16-tinski arp, supersaw · iskre, meteori, kosmički hum | ogromna svijetla hala + eho |
| 8 | Ember Fen · *Firelight Marsh* | modalni „world" (dorijski) | 62 · **duduk** (klizanja, melizmi), **handpan**, **tanpura**, oud odgovori, **darbuka**, riq | **7/8** (2+2+3, ♪ 150) · darbuka, **oud** melodija, duduk motiv, handpan | **otkucaj srca** 60: tanpura + bordun, duduk, darbuka · žar, žabe, kapi | tamna pećina |

Tempo u 6/8 i 12/8 je točkasta četvrtina (♩.); u generatoru je zapisan kao osmine.

### Rukopis po sezoni (runde 6–8)

| Sezona | Ritam melodije | Harmonija | Osjećaj |
|--------|----------------|-----------|---------|
| Country Bloom | osmine „na i" s ponovljenim notama (pickup), „push" preko takta na krajevima fraza; bluegrass „break" u neprekidnim osminama | trozvuci + dominantni 7: I–VI7–II7–V7 („ragtime" krug), u Areni I–IV–V | labavo, živi bend |
| Frost Orchard | duge note preko takta (A5 drži 4 dobe), predudari (klasika); polka u točkastoj osmini + šesnaestini | klasična funkcija: I–IV–V7, V/V (E7), I6; run: silazni bas D–C#–B–A i molska iv (Gm6) | uredno |
| Lantern Meadow | duga nota, brzi ukras u šesnaestinama, tišina (*ma*); festival: flauta „zove" ukrasom, koto odgovara ponovljenim notama | „royal road" IV–V–iii–vi (japanski pop); sus2; run na pedalu Eb | rubato; taiko precizan |
| Amber Canopy | jig: ♩♪ i neprekidne osmine u 6/8 | miksolidijski **bVII** (F u G-duru) — home, jig (2×), run | folk session, naglasci |
| Moonlit Warren | uspavanka: duge note u 12/8 + **hemiola** (3 note preko 4 dobe); swing Arena: osmine s „push" vezama | home: pedal na Ab, I–IV/I–V (bez ii–V); Arena: jazz ii–V; run: molska iv (Dbm6/Ab) | Arena: melodija kasni iza dobe (lay back) |
| Coral Tide | bossa: ulazi „na i", anticipacije vezane preko takta; calypso: 3+3+2 u šesnaestinama | bossa: tritonusna zamjena (Bb7), #ivø (D#m7b5), kromatski silazak C#m7–Cmaj7#11–Bm7; calypso: sekste (A6, D6) + ii–V | melodija malo gura |
| Starfall Glade | elektronski tresillo (3+3+2 osmine), duge držane note | lidijsko I–II/I; drop vi–IV–I–V; run ljulja I ↔ II/I nad Bb | kvantizovano (mašina) |
| Ember Fen | duduk: duge note + **melizmi u triolama**; Arena: oud artikuliše 2+2+3 sa šesnaestinskim okretima | dorijski i–IV, bVII, tanpura bordun | slobodno |

## Kako se mjeri „ne zvuči slično"

`python scripts/audio/music_report.py [<dir>] [--structure] [--melody] [--harmony] [--no-audio]`:

- **Struktura** (`--structure`): koji instrumenti / zvukovi se dijele između sezona (cilj: 0).
- **Zvuk** (svaka tema prema svakoj na istom nivou):
  - boja: MFCC prosjek i promjena kroz vrijeme;
  - ritam: autokorelacija napada;
  - svjetlina, gustina napada, šumovitost.
- **Melodija** (`--melody`, iz zapisa): ritmičke „ćelije" (dva uzastopna razmaka napada + mjesto u dobi, kako se čuje sa swingom), sinkope, duge note, ukrasi, skokovi. Upozori na ćeliju koju dijeli 4+ sezone — to je „rukopis", ne žanr.
- **Harmonija** (`--harmony`, iz zapisa): progresija u stupnjevima tonaliteta (I, vi, bVII…) i paleta boja akorda (trozvuk, dom7, 7-ice, 9-ice, sus, add / 6, dim).

Za svaku sezonu se traži najbliži par: manji broj znači da su teme različitije (zvuk), odnosno veći broj da su sličnije (melodija, harmonija).

Rezultati ciklusa: [[zvuk-izvjestaj#Drugi ciklus muzike (2026-10-15)|zvuk-izvjestaj § Drugi ciklus]].

## Pravila (za sve teme)

- **Loop bez šava:** rep reverba i zadnjih nota se presavije na početak; ambijent (vjetar, more, žar, tanpura) se pretapa 1,5 s.
- **Harmonija provjerena:** `music_gen.py --lint`:
  - svaka nota na jakoj dobi je ton akorda ili dozvoljena boja;
  - vezana nota (anticipacija) mora pripadati *sljedećem* akordu;
  - ništa van ljestvice (osim tonova samog akorda — npr. B u II7 country, G# u V/V polke);
  - nema dugih sudara;
  - ukrasi (klizanja, predudari) se ne broje.
- **Balans dijelova:** melodije, rijetki udarci i dijelovi koji sviraju samo u dijelu teme se mjere *dok zvuče* (inače bi motiv od 4 takta ispao glasniji od cilja).
- **Glasnoća:** home i arena −24 LUFS u fajlu, run −27 (u igri na default sliderima ~−25 / −28).
- **Telefon:** melodija i harmonija iznad ~200 Hz; bas samo podržava.
- **Dužine:** 23–62 s po temi; OGG mono 24 kHz q3 — svih 24 tema ~5 MB.

## Zamjena pravom muzikom

Fajl `game/assets/audio/music/<sezona>_<nivo>.ogg`, `"source": "real"` u katalogu, `python scripts/audio/music_gen.py --measure` ([[audio-direction#Zamjena pravim zvukom|audio-direction § Zamjena]]). Može sezona po sezona. Za kompozitora: tabele gore su specifikacija (i „rukopis" — ritam i harmonija žanra), [[design-drafts/muzika-brief|muzika-brief]] je tekst za slanje.

## Povezano

- [[_index|← Iskustvo]]
- [[audio-direction|audio-direction]]
- [[zvuk-izvjestaj|zvuk-izvjestaj]]
- [[design-drafts/muzika-brief|muzika-brief]]
- [[design-drafts/seasons-izvjestaj|seasons-izvjestaj]]
