---
type: iskustvo
status: aktivan
milestone: M8
tags: [iskustvo, audio, zvuk, muzika, izvjestaj, performanse]
povezano:
  - audio-direction
  - muzika-brief
  - performanse
  - CHECKPOINT
  - changelog
ai_sažetak: "Zvuk cijele igre (2026-10-14): AudioManager + katalog, 59 efekata i 24 sezonske teme sintetizovane skriptom (privremeno; drugi ciklus 2026-10-15 — svaka sezona svoj žanr: instrumenti, ritam melodije, harmonija), spojeno na svaki događaj; provjereno mjerenjem (snimak miksa iz igre, LUFS, vrh −0,7 dBTP), FPS bez razlike u A/B; tura za slušanje i šta je sljedeće (pravi zvuk)."
---

# Zvuk cijele igre — izvještaj

> Roditelj: [[_index|04-experience]] · mapa zvukova i pravila: [[audio-direction]] · muzika: [[design-drafts/muzika-brief|muzika-brief]] · datum: 2026-10-14

## Ukratko

1. **Igra ima zvuk svuda.** 59 efekata (62 fajla — neki imaju varijante) i **24 muzičke teme: svaka od 8 sezona ima svoju home (hub + loot), arena i run temu** (dopuna istog dana, § Muzika po sezoni niže). Svako dugme, tab i swipe, Home, Shop, kupovine, Ormar, Settings, Camp, Arena, muncher Nibbs, Pip, run, loot i Album.
2. **Svi zvukovi su privremeni.** Napravio sam ih sintezom: Python skripte računaju talase (zvona, trzaji žice, šum, filteri, odjek). Ne mogu preuzimati ni snimati zvuk, ali ovo radi odmah i nema nikakvu licencu. Pravi zvuk ide fajl po fajl, **bez izmjene koda** ([[audio-direction#Zamjena pravim zvukom|§ Zamjena]]).
3. **Ne čujem ih.** Sve sam provjerio mjerenjem: spektar svakog zvuka, glasnoća po kategoriji, snimak pravog miksa iz igre, vrh signala. Da li je *lijepo*, odlučuje tvoje uho — tura za slušanje je niže.
4. **FPS: bez razlike.** Prva verzija je kočila start huba (učitavala je zvukove na glavnom threadu). Popravljeno: učitavanje je sad u pozadini. Naizmjenično mjerenje sa zvukom i bez njega daje isti broj kasnih frejmova (u šumu laptopa).
5. **Dvije sitnice usput.**
   - Vibration iz Settingsa na Androidu nije radio, jer je dozvola bila isključena (#38). Sad je uključena, a haptika ide uz velike trenutke.
   - Slider glasnoće ima kvadratnu krivu: ranije je na 50 % zvučalo skoro kao na punoj.

## Tura za slušanje (5 min, slušalice pa zvučnik telefona)

| # | Gdje | Šta da čuješ | Pitanje za tebe |
|---|------|--------------|-----------------|
| 1 | Start igre | home tema aktivne sezone uđe za ~1 s | Da li je muzika pretiha / preglasna uz tvoj default? |
| 2 | Tapni tabove, swipe stranice | drveni „tik" + zvonce (tab), mekan whoosh (swipe) | Iritira li tap posle 50 klikova? |
| 3 | Home → otvori polje, Play | whoosh + harfa, uzlazni zvižduk | — |
| 4 | Run | „go", whoosh na promjenu trake, coini penju ton dok ih kupiš zaredom, grm + tikovi kad komadi ulete u brojač, udarac (vibracija), cilj (fanfara, muzika se utiša) | Da li coini postaju dosadni? Je li udarac pregrub? |
| 5 | Loot ekran | svaki chip „pop" redom, viši ton; ×2 | — |
| 6 | Hub → Arena | tema se pretopi u arena temu sezone (vrati se na home gdje je stala) | Da li prelaz smeta? |
| 7 | Arena: tap na korpu, spajaj | sipanje zrna + slijetanje, spajanja penju ton s combom, T3 veliko zvono + led munchera | Je li combo lanac zadovoljavajući? |
| 8 | Muncher | buđenje „!", hrskanje (2 zalogaja), „hmph" kad mu pobjegne, zijev kad je polje prazno | Je li Nibbs simpatičan ili dosadan? |
| 9 | Shop, Ormar | coini kupovina, „šuš" kad obučeš | — |
| 10 | Settings | prekidači gore / dolje, slider tik na svakih 5 (ton prati vrijednost) | Da li 0–100 sad prati sluh? |

Šta god je pre-glasno, pre-tiho ili iritantno — reci koji zvuk; to je jedan broj u katalogu (`db`, `cooldown_ms`, `pitch`) ili jedna linija u generatoru.

## Muzika po sezoni (dopuna 2026-10-14)

Na zahtjev „za svaku sezonu posebno muziku na sva tri nivoa": **24 teme**, svaka sezona sa svojim identitetom — dizajn i tabela: [[muzika-sezone]].

| Sezona | Home | Arena | Run |
|--------|------|-------|-----|
| Country Bloom | originalna tema (F-dur swing) | marimba + zviždaljka | ptice, vjetar |
| Frost Orchard | **valcer** na muzičkoj kutiji, D-dur s „mraznim" #11 | pizzicato polka + praporci | ledeni pad, snježni vjetar, zvona |
| Lantern Meadow | pentatonika, bambusova flauta, koto | kalimba ostinato | cvrčci, svici |
| Amber Canopy | **6/8** folk: klarinet + gitara | **jig**: bendžo + violina | lišće, vjetar |
| Moonlit Warren | **uspavanka** 3/4: vibrafon + harfa + hor | noćni **swing** (walking bas, četke) | cvrčci, sova, zvijezde |
| Coral Tide Garden | **bossa nova**: flauta + najlon gitara | **calypso**: steel pan + konge | talasi, galebovi |
| Starfall Glade | lidijski: nebeski lead + stakleni arpeđo | synth arp + puls | iskre, meteori |
| Ember Fen | dorijski: niska flauta + tongue drum + bordun | ples oko vatre | pucketanje žara, žabe |

- **Jedan motiv po sezoni:** Arena ga vrati u taktovima 5–8, run ga citira takt po takt (svaki takt preko „svog" akorda), pa se sezona prepozna i bez gledanja.
- **Muzika prati aktivnu sezonu:** otvoriš polje druge sezone (ili je kupiš / otključaš) → za ~1 s pretopi se na njene teme. Listanje kartica ne mijenja muziku (samo fokus).
- **Novi generator** (`scripts/audio/`): teorija (akordi iz simbola, vođenje glasova, 4/4 · 3/4 · 6/8), 35 instrumenata, 14 udaraljki, 14 ambijenata, `--lint` harmonije (0 upozorenja), paralelni render (24 teme ≈ 10 min).
- **Provjereno bez sluha:**
  - spektar svake sezone (popravljeni klikovi trzalica i FM bočni pojasevi — filter 12 dB/okt);
  - šav svakog loopa (bez skoka);
  - glasnoća u fajlu −12 … −18 LUFS, svaka svedena na cilj nivoa.
  - Rijetki događaji (sova, žabe, galebovi, meteori) mjere se dok zvuče — ranije su tri kreketa digla vrh Ember runa.
- **Veličina:** OGG mono 24 kHz q3 — 24 teme ≈ 4,6 MB (bilo bi ~8 MB na 44,1 kHz q4); Android paket 7,75 → 11,65 MB.
- **U igri** (snimak Master busa, sve sezone, default slideri): home −24,4 … −27,3 LUFS, arena −26,2 … −28,4, run −26,2 … −27,7 — sezone ujednačene unutar ~3 dB; vrhovi −11 … −20 dBFS (efekti imaju prostora).
- **Tonalni balans:** sredina (250 Hz–2 kHz) dominira u svim temama; Ember Fen je bio „mutan" (visoke −27 … −33 dB) → niska flauta i tongue drum otvoreni, dodane tople iskre (žeravice) → −23,5 dB.
- **Testovi:** suita 72 / 72 (save bez promjene, 0 grešaka parsiranja), GUT 42 / 42; `audio_smoke` provjerava svih 24 tema, praćenje sezone, tišinu poslije `play_music("")` i keš ≤ 4.

### Dopuna ture za slušanje

| Gdje | Šta da čuješ |
|------|--------------|
| Home → otvori polje Frost Orcharda | pretopi se u valcer; Arena = polka s praporcima; run = snježni vjetar i muzička kutija |
| Lantern / Moonlit / Starfall | tri noćne sezone moraju zvučati različito: sumrak (pentatonika, cvrčci) / uspavanka (vibrafon, sova) / zvjezdana (lidijski sintisajzer, meteori) |
| Amber Arena | jig u 6/8 — najživlja Arena; javi ako je prebrza |
| Ember Fen run | žar i žabe ispod muzike — ne smiju biti „strašni" |

## Drugi ciklus muzike (2026-10-15)

Na zahtjev „radi na unikatnosti, nemoj da zvuči slično kao druge sezone": svih 24 tema napravljeno ponovo, u 10 rundi, s mjerenjem poslije svake. Dizajn i tabele po sezoni: [[muzika-sezone]].

### Šta je bio problem (izmjereno)

1. **Isti zvučni pribor.** Iste FM zvona, trzalice i reverb u svim sezonama. Na primjer, shaker je svirao u 7 sezona, a topli pad u 5.
2. **Isti ritam melodija.** Ritmičku ćeliju ♩♩ koristilo je svih 8 sezona, a još tri ćelije po 5–7 sezona. Nijedna melodija nije imala sinkopu.
3. **Ista harmonija.** 5 od 8 run tema je imalo *identičnu* progresiju (I–vi–IV–V s maj9 akordima). Home teme pet sezona su sve bile I–vi–ii–V.

Prve runde (novi instrumenti po žanru) riješile su (1), ali mjera melodija je tada pokazala da su (2) i (3) ostali isti — ritam melodija je čak bio sličniji nego u prvom ciklusu. Zato su runde 6–10 prepisale melodije i akorde u jeziku svakog žanra.

### Šta je urađeno

| Sloj | Prvi ciklus | Drugi ciklus |
|------|-------------|--------------|
| Instrumenti | zajednički FM / trzaj „pribor" | 101 zvuk, svaki samo u jednoj sezoni |
| Ritam melodije | iste ćelije svuda | po žanru: country „push", valcer s vezanim notama, shakuhachi *ma*, hemiola uspavanke, bossa anticipacije, calypso 3+3+2, tresillo, duduk triole |
| Harmonija | I–vi–IV–V / ii–V svuda | po žanru: country II7, klasični V/V i silazni bas, „royal road", keltski bVII, pedal + molska iv, tritonusna zamjena, lidijsko I–II |
| Izvedba | isti „ljudski" šum za sve | kvantizovano (elektronika) … labavo (folk); jazz melodija kasni iza dobe |
| Soba | sličan reverb | reverb, eho, nagib boje, zasićenje i sidechain po sezoni |
| Tempo / mjera (doba = ♩ ili ♩.) | home 60–100, Arene 76–112; 4/4, 3/4, 6/8; svi runovi isti predložak bez tempa | home 46–132, Arene 84–132 (+ Ember 7/8 ♪ 150); 4/4, 3/4, 6/8, 12/8, 7/8; svaki run svoj tempo i ritamski potpis |

Usput u generatoru:
- `fx.py` — soba sezone;
- zapis vezanih nota i triola;
- „feel" izvođenja;
- dijelovi se balansiraju dok sviraju (motiv od 4 takta više ne ispada glasniji);
- stroži `--lint` (anticipacija prema sljedećem akordu, nota pola tona ispod akorda, nota držana preko promjene akorda) — našao je 4 sudara, ispravljeni; valcer dobio pravu 4–3 zadržicu (A7sus4 → A7);
- Moonlit home je dobio svjetliju muzičku kutiju: na zvučniku telefona je bio pretaman (visoke −27 → −24 dB ispod ukupnog).

### Mjere — prije i poslije

`music_report.py` (zvuk iz OGG fajlova; melodija i harmonija iz zapisa). **Zvuk: udaljenost** — veće = različitije. **Melodija i harmonija: sličnost** — manje = različitije.

| Mjera | Prvi ciklus | Ciklus 2 prije runde 6 | Ciklus 2 završno |
|-------|-------------|------------------------|------------------|
| Zvuk home — najbliži par / prosjek | 0,55 / 0,74 | 0,67 / 0,76 | **0,69 / 0,78** |
| Zvuk arena | 0,42 / 0,72 | 0,52 / 0,73 | **0,62 / 0,76** |
| Zvuk run | 0,50 / 0,69 | 0,61 / 0,70 | **0,65 / 0,77** |
| Ritam melodije home — najsličniji par / prosjek najbližeg | 0,93 / 0,84 | 0,94 / 0,93 | **0,68 / 0,41** |
| Ritam melodije arena | 0,99 / 0,88 | 0,92 / 0,76 | **0,65 / 0,43** |
| Ćelije koje dijeli 4+ sezone (home + arena) | 4 + 6 | 4 + 5 | **0 + 1** |
| Harmonija home — najsličniji par / prosjek | 0,90 / 0,72 | 0,88 / 0,71 | **0,75 / 0,62** |
| Harmonija arena | 0,88 / 0,68 | 0,88 / 0,68 | **0,68 / 0,59** |
| Harmonija run | 1,00 / 0,89 | 1,00 / 0,86 | **0,57 / 0,47** |
| Parovi sličnosti ≥ 0,8 (melodija + harmonija, sva 3 nivoa) | 53 | 49 | **0** |
| Instrumenti dijeljeni između sezona | npr. shaker u 7, pad u 5 | 0 | **0** |

Šta mjere ne vide:
- **Preostali najbliži parovi po zvuku** (≈ 0,6–0,7) su bliski samo po gruboj svjetlini i gustini. Po boji i ritmu su daleko (boja ≥ 0,67, ritam ≥ 0,5).
- **Srodni žanrovi ostaju srodni.** Bluegrass i keltski jig dijele porijeklo, polka i calypso su obje plesne I–IV–V7. Razlikuje ih instrument, ritam i tempo, ne akordi.
- **Mjera ne zna da li je lijepo** — to odlučuje tvoje uho.

### Provjereno

- **U igri** (snimak Master busa, sve sezone × 3 nivoa, default slideri):
  - home −24,7 … −26,0 LUFS, run −26,8 … −28,8 — sezone ujednačene unutar ~2 dB;
  - Arene −24,4 … −27,2; jedino Starfall Arena počinje na −29,3, jer je njen početak „gradnja" pa „drop". Uvod je podignut 2 dB da Arena ne zvuči prazno.
  - Vrhovi −12 … −20 dBFS — efekti imaju prostora.
- **Loopovi:** šav bez skoka i klika na svih 24. Razlika glasnoće na šavu je prirodna: kraj fraze → prvi takt.
- **Testovi:**
  - `--lint` 0 upozorenja;
  - suita 72 / 72, exit 0, save nijednom nije promijenjen;
  - GUT 42 / 42;
  - `audio_smoke`: 24 teme, budžet 7,6 / 8 MB.
- **Android pck** 12,4 → 12,8 MB; svih 24 tema u paketu, Python skripte nisu.
- **Veličina:** teme 5,1 MB (bilo 4,6); render svih 24 ≈ 9–10 min (3 procesa).

### Tura za slušanje (drugi ciklus)

Najbrže: Settings → Dev → otključaj sezone, pa otvaraj polja jednu po jednu (home), Arena, run.

| Sezona | Home | Arena | Run |
|--------|------|-------|-----|
| Country Bloom | harmonika s ponovljenim notama, lap steel u B dijelu, „ragtime" akordi | bluegrass: bendžo + harmonika u osminama, dobro citira motiv | šetnja: gitara + harmonij, ovčja zvona |
| Frost Orchard | valcer: celesta, pa staklena harmonika; duge note preko takta | polka: pizzicato + celesta | celesta treperi nad silaznim basom, molski akord „zime" |
| Lantern Meadow | shakuhachi: duga nota, brzi ukras, tišina | festival: taiko, flauta zove – koto odgovara | sho na jednom basu, hramsko zvono |
| Amber Canopy | 6/8 tin whistle s predudarima, bodhrán, F-dur akord (keltski) | jig: violina + whistle, buzuki | gitara prstima, violončela |
| Moonlit Warren | uspavanka: muzička kutija, „tri note preko četiri dobe" | swing: vibrafon kasni iza dobe, walking bas | lomljeni akordi filcanog klavira, sova |
| Coral Tide | bossa: flauta ulazi „na i", kromatski akordi | calypso: marimba 3+3+2, ukulele chop | steel pan ostinato, tamni talasi |
| Starfall Glade | elektronika tačna kao mašina, supersaw „diše" | gradnja pa drop | puls nad jednim basom, meteori |
| Ember Fen | duduk s melizmima, tanpura, darbuka od polovine | 7/8 (2+2+3), oud | otkucaj srca, žabe |

**Pitanja za tebe:**
1. Da li te ijedna sezona još podsjeća na drugu? Koje dvije?
2. Koji žanr najbolje „sjeda" na sezonu, a koji najlošije?
3. Je li Starfall previše mašinski, a Moonlit pretaman na telefonu?

## Kako radi

- **`AudioManager`** (autoload): pool od 12 playera za efekte i 2 za muziku.
  - Po zvuku vrijede: cooldown, najviše glasova (npr. `seed_land` 3), grupa (tab i swipe dijele jednu), slučajan pitch (manje „mašinski"), lanac tona (coini, combo, chipovi).
  - Muzika: crossfade 0,9 s, svaka tema pamti mjesto. Duck (utiša se) na T3, kupovinu, otključavanje, čisto polje i kraj runa. Pauza dok traje reklama i dok je app u pozadini.
- **`Sfx.play("id")`** iz bilo koje klase. Dugmad imaju `tap_sfx` (default `ui_tap`), pa svako novo dugme samo dobije zvuk.
- **Katalog** `game/data/audio/sounds.json` — sve postavke zvuka su ovdje, ne u kodu.
- **Generatori** `scripts/audio/`:
  - `dsp.py` — gradivni blokovi: FM zvona, Karplus-Strong trzaj, filteri, reverb, loop bez šava;
  - `sfx_gen.py` — 59 efekata + katalog;
  - muzika: `theory.py` (akordi, zapis, `--lint`), `instruments.py`, `fx.py` (soba), `season_songs.py` (kompozicije), `music_gen.py` (aranžman, miks, render) — 24 teme;
  - `music_report.py` — koliko su sezone različite (zvuk, `--structure`, `--melody`, `--harmony`);
  - `--measure` — glasnoća pravih fajlova.

## Provjera bez sluha

**Svaki efekat:** high-pass 45 Hz, low-pass 11 kHz, fade-in / out bez klika, normalizacija pa izjednačavanje glasnoće po kategoriji (K-ponderisano, najglasnijih 150 ms). Kategorije: UI −23, mekano −21, igra −18, nagrada −16, veliko −15.

Poslije snimka iz igre ručne korekcije (`TRIM`):

| Zvuk | Korekcija |
|------|-----------|
| sipanje (`pour`) | −3 dB |
| odmrzavanje | −2,5 dB |
| led | −1 dB |
| slijetanje | −2 dB |
| hrskanje | −5 dB |
| sjemenka u runu | −3 dB |

Svi su bili šiljci u miksu.

**Muzika:**
- tri stema po temi, izbalansirana (melodija mora nadjačati bas);
- loop bez šava (rep se „presavije" na početak);
- spektar provjeren slikom (`ffmpeg showspectrumpic`);
- OGG mono q4.

**Snimak pravog miksa iz igre** (`AudioEffectRecord` na Master busu, Settings default Music 80 / SFX 100). Kratkoročna glasnoća (400 ms) događaja naspram muzike prije njega:

| Trenutak | Glasnoća (LUFS, momentary max) | Muzika ispod |
|----------|-------------------------------|--------------|
| `ui_tap` / `ui_tab` | −19,8 / −18,1 | −22 … −23 |
| `coin` | −17,9 | −20 |
| `merge` (combo 0) | −17,8 | −21 |
| `pour` | −14,8 | −24 |
| `merge_t3` | −12,7 | −20 |
| `run_hit` | −18,2 (vrh −1,0 dBFS, limiter) | −18 |
| `reward_tick` × 5 | −16,1 | −19 |
| `run_finish` / `unlock` / `purchase_ok` | −14,3 / −14,0 / −14,6 | −17 … −20 |
| muzika sama | hub −23 … −24, Arena −26,5, run −26 (integrisano, kratki isječci) | — |

- Cijeli snimak: −20,3 LUFS, true peak **−0,7 dBTP** — nijedan zvuk ne klipuje (limiter −1 dB na Masteru).
- Mono fajl svira na oba kanala (+3 dB u stereo mjerenju) — isto za muziku i efekte, odnos ostaje.

## FPS i memorija

Detalji i tabele: [[../05-technical/performanse#Rezultati 2026-10-14 (2) — zvuk cijele igre|performanse § zvuk]].

- `load()` efekta ~3 ms, teme ~13 ms → sve u pozadinskom threadu, po jedan fajl (#37). Svih 62 efekta i prva tema su učitani ~0,4 s od starta bez huba (test); uz hub čekaju u redu iza stranica (~1–2 s), a efekat koji zatreba ranije se učita odmah (~3 ms, jednom).
- `play()` efekta 0,15 ms. Dekodiranje muzike radi audio thread.
- A/B (zvuk isključen preko `override.cfg`):
  - start huba: 16–24 kasna sa zvukom, 21–27 bez;
  - run u 4 varijante × 3 i Arena: bez razlike koja prati zvuk.
- Android paket: +1,55 MB (efekti 549 KB, teme 1 038 KB). U paketu provjereno: katalog, 62 efekta, 3 teme, AudioManager, busovi s limiterom.

## Testovi

- **Novi `audio_smoke`:**
  - katalog i budžet (4 MB);
  - svaki zvuk iz kataloga se negdje u kodu pušta;
  - svi se učitaju u pozadini bez `play()`;
  - svaki efekat svira;
  - cooldown, grupa `nav`, najviše glasova, lanac tona;
  - muzika: crossfade, ista tema, duck, pauza za reklamu, tišina, brzo tamo-nazad prije nego nova tema stigne (mjesto teme ostaje njeno — test pada na prvoj verziji koda);
  - kuke u igri: tap, Pip `sfx:` (poziran Pip je tih), sipanje + slijetanje, led munchera, Settings prekidač, coin kupovina, start runa + tema run.
- `settings_screen_smoke` prati novu krivu slidera.
- Cijela suita + GUT: [[#Rezultat suite|niže]].

## Rezultat suite

- **72 smoke testa: svi exit 0, save nijednom nije promijenjen** (kumulativno, bez vraćanja između testova); `audio_smoke` OK (pozadinsko učitavanje 0,4 s).
- **GUT 42 / 42.**
- Android pck izvezen i pregledan: katalog, 62 efekta, 3 teme, `AudioManager`, `Sfx`, busovi s limiterom su u paketu.
- Poznato, nije od zvuka: `meta_hub_smoke` poslije „OK" ispiše parse grešku `shop_screen.tscn` dok se test gasi usred pozadinskog učitavanja Shop stranice (postoji od 2026-10-10, exit 0).

## Šta je privremeno i šta ostaje otvoreno

- **Zvuk je sintetizovan** — čist, mekan, ali „elektronski"; nema snimljenih instrumenata ni pravih glasova. Za launch: pravi efekti (Kenney CC0 je besplatan prvi korak) i prava muzika ([[design-drafts/muzika-brief|brief]] — kompozitor, paket ili AI, tvoj izbor).
- **Mono** fajlovi (manje mjesta; zvučnik telefona je ionako skoro mono). Prava muzika može biti stereo — budžet se onda svjesno diže.
- **Glasnoća cijele igre** je na tišoj strani (−20 LUFS u gustom snimku, muzika ~−25). Ako je na telefonu pretiho: svi ciljevi + isti broj dB i oba `--measure` (§ Miks u [[audio-direction]]).
- **Tuđa muzika:** kad igrač sluša Spotify, naša muzika svira preko — mnoge igre tada utišaju svoju. Za Android i iOS (Faza 4) treba odluka; Godot postavke iOS audio sesije provjeriti tada.
- **Haptika** radi samo na telefonu (desktop i emulator ništa).

## Šta trebaš ti

1. **Tura za slušanje** (gore) — na slušalicama i na zvučniku telefona; javi šta smeta.
2. **Muzika:** izaberi put (kompozitor / paket / AI) — brief je spreman za slanje.
3. **Efekti:** ako želiš Kenney CC0 pakete, preuzmi ih (ili mi daj dozvolu da ih preuzmem) — ugradim ih preko kataloga i izmjerim glasnoću.

## Povezano

- [[_index|← Iskustvo]]
- [[audio-direction|audio-direction]]
- [[design-drafts/muzika-brief|muzika-brief]]
- [[../05-technical/performanse|performanse]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
