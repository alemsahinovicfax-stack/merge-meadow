---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, run, endless, level-path, pojasevi, performanse, izvjestaj, claude-design]
povezano:
  - leveli-endless-cd-brief
  - balans-ciklus-1-izvjestaj
  - performanse
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "Prenos paketa design_handoff_leveli_endless: težina se sad vidi — 4 pojasa (Stroll / Jog / Dash / Sprint) na kamenovima, zastavicama i u LevelChipu, najava levela, nalet na svaku stepenicu brzine, par prepreka kao jedan predmet, cilj na kraju levela koji Pip presiječe tačno na kraju; Endless dugme (zaključano s prstenom napretka, trenutak otključavanja, rekord), Endless HUD (sat · Pace · Best), nova stepenica, novi rekord, pauza i kraj „All yours"; spreman sanduk bez „Claim". Brojevi igre nepromijenjeni. FPS: run jeftiniji nego prije (2 čitanja konfiguracije manje po frejmu), efekti samo dok traju."
---

# Leveli koji rastu + Endless · izvještaj prenosa

> Paket: `design_handoff_leveli_endless/` (zip `Merge Meadow level path 1.zip`, 2026-10-22) · brief [[leveli-endless-cd-brief|leveli-endless-cd-brief]] · brojevi [[../../02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]].

## Sažetak

| Dio | Stanje | Kako je provjereno |
|---|---|---|
| A1 · 4 pojasa (Stroll 1–5 · Jog 6–10 · Dash 11–15 · Sprint 16–20) na kamenovima, zastavice uz 1 / 6 / 11 / 16, pločica u LevelChipu | ✅ | `levels_endless_smoke` (svih 20 pločica, 4 zastavice × 8 sezona ne pokrivaju sanduke), `run_hud_v2_smoke` (L12 Dash, L20 Sprint ★ ≤ 464), snimke |
| A2 · najava levela na startu (≤ 1,2 s, ne blokira swipe), replay „Replay · 2:00" | ✅ | smoke: „Level 6" / „Jog · 1:16", nestane do 1,2 s, čip se vrati na 1 |
| A3 · nalet na svaku stepenicu brzine (15 s; Endless 20 s) | ✅ | smoke: 1 nalet na 15 s, ≤ 5 linija, trzaj ≤ 10 px, sve se vrati za 0,5 s |
| A4 · par = jedan predmet preko dvije staze (3 varijante × 8 livada), sudar ostaje 2 × 64 × 64 | ✅ | smoke: lijevo+sredina široki, sredina+desno zrcaljen, lijevo+desno dva bočna |
| A6 · cilj na kraju levela (8 sezona), traka pređe Pipa tačno na kraju, prolaz (traka pukne, luk, konfete, „Time!") | ✅ | smoke: vrijeme pojave = CD tabela ±0,02 s za svih 20 levela; u runu cilj na y −80 i na Pipu kad istekne vrijeme; ≤ 16 sprite-ova |
| B1 · zaključan Endless (krem, prsten „N / 15", katanac) + tres i toast „Beat Level 15 to unlock Endless" | ✅ | `season_sync_smoke` korak 11, smoke |
| B2 · trenutak otključavanja poslije skoka 15 → 16 (jednom po sezoni) + oblačić „Endless unlocked!" | ✅ | smoke: signal jednom, drugi skok ništa, animacija završi otvoreno s jednim oblačićem |
| B3 · Endless HUD (sat · Pace · Best) u LevelChipu, bez trake | ✅ | smoke + 3 stara testa prepravljena (čip ≤ 464 × 128 i na 59:59) |
| B4 · nova stepenica: pilula „Pace N" + nalet | ✅ | smoke: na 20 s „Pace 1" i nalet, nestane za 0,92 s |
| B5 · novi rekord u runu (jednom), red čipa → „New best!" | ✅ | smoke: jednom po runu, ≤ 12 sprite-ova |
| B6 · kraj Endlessa (R5): „Endless" / „New best!", vrijeme, Pace, „Best" / „Was", CIJELI plijen „All yours" | ✅ | smoke: 7:00 preko 4:25 → „New best!", „Pace 21", „Was 4:25", bez precrtavanja; Retry primarno |
| B7 · pauza u Endlessu: „If you quit · all yours", Quit nosi korpu u mint disku | ✅ | smoke (level pauza ostaje ½) |
| B8 · rekord sezone na Endless dugmetu (polje i put) | ✅ | smoke: „3:12" |
| C · spreman sanduk bez „Claim": frejmovi closed / peek, sjena, pločica sadržaja, reduce motion miran | ✅ | smoke: peek jednom po ciklusu, reduce motion: zatvoren, iskre stoje |
| D · formacije po pojasu | — | CD nije radio (opciono) |
| FPS | ✅ | § Performanse — run jeftiniji nego prije, efekti samo dok traju |

> **Pažnja za playtest:** u tvojim Settings je uključen **Reduce motion** (`settings.cfg`). Tada se sanduk ne pomjera, nema naleta ni animacije otključavanja (dugme se odmah otvori). Za playtest animacija isključi ga u Settings.

## Šta je u igri

### A1 · Pojasevi težine

- `UiLevels` (`scripts/visual/ui_levels.gd`): pojas = ⌈level / 5⌉, kraj pojasa (5 / 10 / 15 / 20) = pločica sa zvjezdicom (isto mjesto kao sanduk). Boja **i** broj strelica (1–4), nikad samo boja.
- **Kamen:** pločica 72 × 30 (kraj pojasa 86 × 30) na donjem rubu kamena u sva tri stanja. Crta se u istom `_draw` kao kamen i broj, pa ne dodaje nijedan čvor.
- **Zastavica pojasa** (180 × 214 + krem pločica „Stroll 1–5") uz kamen 1 / 6 / 11 / 16. Strana se bira kao u CD mocku (desno +96, lijevo −286, pa dalje) tako da ne dira sanduk ni kamen. Za svih 8 sezona provjereno testom.
- **LevelChip:** `[zastavica] Level 14 [pločica 40 h]`, i dalje ≤ 464.

![[leveli-endless-izvjestaj-ref/l14_path_bands_country.jpg]]
![[leveli-endless-izvjestaj-ref/l03_level20_pair_lantern.jpg]]

### A2 · Najava levela

Krem ploča „Level 14 + pločica" (h 180) i pilula „Dash · 1:42". Za 1,12 s uleti u LevelChip, koji se na kraju trzne 1,08. Ne hvata dodir, pa swipe radi od prve sekunde. Na replayu levela 20 piše „Replay · 2:00". U Endlessu i Practiceu je nema.

![[leveli-endless-izvjestaj-ref/l01_intro_level14_frost.jpg]]
![[leveli-endless-izvjestaj-ref/l02_intro_fly_level14_frost.jpg]]

### A3 · Nalet

Svaki put kad brzina pređe na sljedeću stepenicu (svakih 15 s u levelu, na novu stepenicu u Endlessu):

- 5 krem linija niz šavove i ivice staza;
- Pip se spljošti;
- svijet trzne 10 px.

Traje 0,42 s, bez teksta. Bazen od 5 sprite-ova pravi se jednom.

### A4 · Par prepreka

Jedan predmet preko dvije staze, s mint zastavicom na strani prolaza:

- lijevo + sredina i sredina + desno su isti široki sprite (drugi je zrcaljen);
- lijevo + desno su dva bočna dijela okrenuta ka sredini.

Ovratnik i sjena su zajednički. U kodu su i dalje dvije prepreke 64 × 64 (`obstacle.set_pair`). Široki sprite crta lijeva prepreka, a druga ne crta ništa.

**Ispravka paketa:** mint zastavica u svih 16 SVG-ova parova izlazi van okvira slike (desno do x 490 / 271, gore do y −5). U pregledaču i u Godotu bila je odsječena (vidi se i u CD mocku). Pri kopiranju okvir je proširen (`viewBox 0 −8 496 228` / `0 −8 276 228`), crtež je isti, a sidro je 8 px niže (`UiLevels.PAIR_*_ANCHOR`). Katalog #50.

### A6 · Cilj na kraju levela

- **Izgled:** dva stuba, sezonski luk i mint traka preko sve 3 staze (8 sezona). Nema ovratnika ni sjene, nije prepreka.
- **Kad se pojavi:** na liniji spawna, kad preostali put do kraja padne na 1654 px. Put se računa sa stepenicama brzine (`RunController.remaining_distance()`), kako CD traži, a ne kao „1654 / brzina". Isto pravilo sad zatvara i spawn: prazna dionica pred kraj **jeste** dolazak cilja.
- **Vožnja:** cilj se kreće sa svijetom, pa traka pređe Pipa kad istekne vrijeme. Test: unutar jednog frejma.
- **Prolaz:**
  - traka pukne na dvije polovine (78°, pa 3 prigušena zamaha);
  - luk poskoči;
  - 10 konfeta iz Pipa;
  - „Time!" stiže 0,12 s kasnije, a zastavica na traci i usporavanje ostaju kao prije.

![[leveli-endless-izvjestaj-ref/l04_gate_riding_frost.jpg]]
![[leveli-endless-izvjestaj-ref/l05_gate_pass_frost.jpg]]

### B · Endless

- **Dugme** (`EndlessButtonFace`, isto mjesto 236 × 124 u polju i na putu):
  - zaključano: krem, prsten napretka „pređeno / 15" (mint), zlatni katanac, „Endless / 8 / 15";
  - otključano: lavanda + prstenovi;
  - rekord sezone: krem pločica „🏆 3:12" na dnu dugmeta.
  Prigušenje (`modulate.a 0,55`) je izbačeno.
- **Tap na zaključano:** dugme se strese (8 px, 0,3 s) i pojavi se toast „Beat Level 15 to unlock Endless" sa zlatnim katancem (y 1310, 1,6 s).
- **Otključavanje:** poslije skoka 15 → 16 na putu, jednom po sezoni (save `season_endless_seen`). Redoslijed:
  1. katanac zadrhti, karika ode gore, tijelo iskoči i nestane;
  2. krem pređe u lavandu, prstenovi uskoče, prsten fx;
  3. oblačić „Endless unlocked!" drži 2,2 s.
- **HUD:** LevelChip u dva reda, bez trake napretka:
  - prvi red: prstenovi, sat (tabular) i pilula „Pace N" u boji toplote (0–2 mint · 3–5 žuta · 6–8 narandžasta · 9+ roza);
  - drugi red: trofej + „Best 4:25".
  Crta se kad se promijeni sekunda, stepenica ili rekord.
- **Nova stepenica:** pilula „⇈ Pace 9" ispod čipa (0,92 s), nalet i trzaj pilule u čipu.
- **Novi rekord:** jednom po runu, oko čipa (nikad preko staze ispred Pipa): prsten, trofej i 8 konfeta, a red čipa postane mint „New best!".
- **Pauza:** zaglavlje (prstenovi · sat · Pace), pečat „If you quit · all yours" i „Quit to camp" s korpom u mint disku. Pauza u levelu ostaje s ½.
- **Kraj (R5):**
  - ploča: „Endless" (lavanda, prstenovi) ili „New best!" (zlatna, trofej) + zlatni pečat;
  - vrijeme 180/900, pilula „Pace N" i „Best 5:28" / „Was 4:25";
  - plijen je cijeli, s mint pečatom „All yours";
  - Retry je primarno dugme, Revive nastavlja Endless.

![[leveli-endless-izvjestaj-ref/l12_field_endless_locked.jpg]]
![[leveli-endless-izvjestaj-ref/l13_field_endless_locked_toast.jpg]]
![[leveli-endless-izvjestaj-ref/l17_unlock_flip_lantern.jpg]]
![[leveli-endless-izvjestaj-ref/l18_unlock_bubble_lantern.jpg]]
![[leveli-endless-izvjestaj-ref/l19_field_endless_best_lantern.jpg]]
![[leveli-endless-izvjestaj-ref/l06_endless_pace_amber.jpg]]
![[leveli-endless-izvjestaj-ref/l07_endless_new_best_amber.jpg]]
![[leveli-endless-izvjestaj-ref/l08_endless_hud_after_best_amber.jpg]]
![[leveli-endless-izvjestaj-ref/l09_endless_pause_amber.jpg]]
![[leveli-endless-izvjestaj-ref/l10_loot_endless_new_best.jpg]]
![[leveli-endless-izvjestaj-ref/l11_loot_endless.jpg]]

### C · Spreman sanduk

Bez pilule „Claim". Petlja traje 1,8 s (sanduk 20: 1,5 s, 34 px, ±10°):

1. skok;
2. doskok sa squashom;
3. poklopac zaviri (frejm „peek": zlatnici i zrake);
4. klimanje;
5. mir.

Sjena stoji na tlu i skupi se dok je sanduk u zraku. Više sanduka u kadru kreće u drugoj fazi (0,23 s). Ispod sanduka je ravna pločica sadržaja (★3 cvijet ×N · coin N), bez sjene i ruba dugmeta. Tap na sanduk ili pločicu otvara popup kao i prije. S Reduce motion sanduk je zatvoren i miran, a iskre stoje.

![[leveli-endless-izvjestaj-ref/l15_path_chest_ready_country.jpg]]
![[leveli-endless-izvjestaj-ref/l16_path_chest_ready_country_b.jpg]]

## § Ispravke pri prenosu (paket i snimke)

| Šta | Gdje | Ispravka |
|---|---|---|
| Mint zastavica para van okvira SVG-a — odsječena (i u CD mocku) | 16 × `*_pair_*.svg` | okvir proširen, sidro +8 px (#50) |
| `rgba()` boje → u Godotu puno crno: crna sjena sanduka, crna mrlja ispod zastavice pojasa i ispod trake cilja | 12 SVG-ova | hex + `fill-opacity` / `stroke-opacity` (#50) |
| Godot sam uključi `_process` → cilj „odigrao" prolaz dok je vozio (traka nije pukla), Endless dugme se samo „otključalo" poslije učitavanja | cilj, nalet, najava, čip, pilula, dugme | straža u `_process` + test kroz prave frejmove (#51) |
| LevelChip na kraju levela 6 pisao „Level 7" (finish_run pomjeri put prije zadnjih crtanja) | `run_controller` | čip drži level sa starta runa |
| „11 / 15" izlazio iz zaključanog dugmeta | `EndlessButtonFace` | broj se smanji da stane (40 → min 30 px) |
| Revive u Endlessu: drugi pad bi rekao „New best!" i „Was" s vremenom prvog pada | `GameState.finish_run` | poredi s rekordom sa starta runa |

## § Odlučeno pri prenosu

1. **Odgovor na CD pitanje o budžetu pločica:** pločica pojasa se crta u istom `_draw` kao kamen. To je 0 dodatnih čvorova, pa budžet +8 oblika po sezoni troše samo 4 zastavice. Natpis je dio zastavice, ne poseban čvor.
2. **Vrijeme pojave cilja** računa se iz stvarnih brojeva igre (`levels.json`) i u testu se poklapa s tabelom iz `level_finish.json` za svih 20 levela.
3. **Nalet postoji i u Practiceu** (tutorijal runovi takođe ubrzavaju svakih 15 s). Najava levela i pločica pojasa postoje samo u levelima kampanje.
4. **Pilula „Pace N" i najava levela** se prikazuju i s Reduce motion (to je informacija). Nalet, burst rekorda i animacija otključavanja se gase.
5. **Oblačić otključavanja** je postojeći `CoachBubble` (popups kit) s lavanda diskom i prstenovima, sa strelicom na dugme.
6. **R5 bez prethodnog rekorda** (prvi Endless sezone): „New best!" bez reda „Was".

## § Performanse

Laptop je za vrijeme mjerenja bio pod jakim opterećenjem (pozadinska igra). Mjerenje cijelog frejma headless se zato kretalo od 9 do 21 ms za isti kod. Novo i staro su u ponovljenom krugu u granicama šuma (`levels_endless_bench.gd`, A/B naizmjenično). Pouzdanije je mjerenje po pozivu: najbolje od 5 serija, µs pod istim opterećenjem, pa je na mirnom laptopu manje.

| Stvar | µs po frejmu | Koliko traje |
|---|---|---|
| nalet (5 linija + Pip + svijet) | 45–75 | 0,42 s na stepenicu |
| pilula Pace + rekord (oba aktivna) | 100–265 | ≤ 0,92 s |
| cilj — prolaz (polovine, luk, 10 konfeta) | 215–250 | 1 s na kraju levela |
| najava levela | 16–27 | 1,12 s na startu |
| Level Path — 2 spremna sanduka | 150–220 | dok je put otvoren (kao i prije, samo transform + zamjena frejma) |
| `remaining_distance()` (svaki frejm u levelu) | 9 | uvijek |
| Endless čip — novo stanje | 120–230 | 1 / s |

- **Run je jeftiniji nego prije paketa.** `GameState.get_run_duration()` košta ~80 µs po pozivu (pod opterećenjem), a run ga je zvao 3 puta po frejmu (kraj, spawn, traka). Sad ga zove jednom i prosljeđuje dalje.
- **Budžeti sprite-ova:**

  | Efekat | Izmjereno (test) | Budžet |
  |---|---|---|
  | nalet | ≤ 5 | — |
  | cilj dok vozi | 4 | 4 + 16 |
  | cilj u prolazu | 15 | ≤ 16 |
  | rekord | ≤ 12 | 12 |
  | pilula | 3 | — |
  | sanduk | sjena + 3 iskre | 4 + 3 iskre |

  Ništa se ne crta po frejmu. Nijedan efekat ne raste s gustinom, a parovi su i dalje dvije prepreke.
- **SVG:** 61 fajl, 107 KB bez C2PA (budžet 150 KB). Mali crteži (pločice, trofej, prstenovi, Pace, katanac) uvoze se 2× zbog oštrine.
- **Na telefonu još nije mjereno** (PERF-02).

## Testovi

| Test | Šta |
|---|---|
| `levels_endless_smoke` (novi) | sve iz tabele gore |
| `run_hud_v2_smoke`, `run_redesign_smoke`, `economy_balance_smoke` | Endless čip umjesto „Endless · 1:05"; pločica pojasa u čipu |
| `season_sync_smoke` | korak 11: zaključano dugme „14 / 15" + novi toast |
| svih 78 smoke testova | 74 prolaze u 4 paralelna radnika; 4 vremenska (hub za 15 s, prelaz 0,56 s, prelazak preko grma, hold-to-repeat) prolaze kad se puste sami — laptop je bio pod jakim opterećenjem. `season_sync_smoke`: čekanje huba 15 → 40 s |
| GUT | 84 / 84 (novi `test_levels_endless`: pojasevi, napredak, trenutak otključavanja u saveu, rekord kroz Revive) |

Alati: `levels_endless_bench.gd` (A/B + po pozivu), `levels_endless_capture.gd` (snimke ispod).

## Otvoreno

- **Playtest:** osjeća li se rast levela po pojasevima; je li nalet na 15 s previše ili premalo; čita li se par na 900+ px/s; trenutak otključavanja na skoku 15 → 16.
- **D · formacije** po pojasu (opciono) — nije rađeno ni u CD paketu.
- **FPS na telefonu** (PERF-02).

## Povezano

- [[../_index|04-experience]]
- [[leveli-endless-cd-brief|leveli-endless-cd-brief]] · [[level-path-izvjestaj|level-path-izvjestaj]] · [[run-hud-v2-izvjestaj|run-hud-v2-izvjestaj]]
- [[../../02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]]
- [[../../05-technical/performanse|performanse]] · [[../../05-technical/godot/greske-katalog|greske-katalog]]
