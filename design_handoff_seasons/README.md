# Season Kit — faza 1 od 4 (Country Bloom + Moonlit Warren)

## Ideja
Danas sezone imaju samo boju (iste 3 trake u 8 nijansi, ista staza s tintom, isti kamen i panj, 42 od 48 vrsta cvijeća su isti krug). Pravilo iz Arene v2 („svaka sezona je drugo MJESTO“) širi se na cijelu igru: **svaka sezona dobija jedan Season Kit** — mjesto, paleta, 2–4 potpis-motiva, ambijent i 18 crteža cvijeća — koji se reže na svaku površinu (Home kartica, Home polje, Shop kartica, Arena, Run). Kit je **red podataka** (`design/seasons_kit.js` = `godot/seasons_export.json`); renderer je jedan i generički. Faze 2 i 3 dodaju redove, ne kod.

Faza 1 dokazuje oba kraja: **Country Bloom** (besplatna, svijetla: valoviti brežuljci, ograda na grebenu, pokošena trava) i **Moonlit Warren** (plaćena, tamna: veliki mjesec, humke, jazbine).

> Napomena: `docs/04-experience/design-drafts/seasons-cd-brief.md` i `seasons-ref/` nisu bili na `master` grani u trenutku rada (2026-10-03). Rađeno po sažetku briefa iz poruke i po paketima Home v3, polje v2, Shop v2, Arena v2, Run, plant_frame. Mjere i raspored su iz tih paketa.

## Šta otvoriti
| Fajl | Šta je |
|---|---|
| `design/SeasonScreen.dc.html` | Jedan ekran 1080 × 1920. Propovi: `season` (country_bloom · moonlit_warren), `surface` (card · field · shop · arena · run), `state` (card: active · owned · locked · buy · field: 0 · 6 · 13 · shop: buy · busy · dim · play · pending · failed · arena: empty · full · hunting · eating · frozen · bag_empty · run: mid · fail), `lush` (0–4, Arena), `still` (zamrzne animacije), + `pip` (walk · sniff · sleep kad je still), `u` (0–1, zamrznut kadar prelaza kartica → polje), `grayscale` (provjera runa). Na kartici „active“: tap na Play/karticu = prelaz 560 ms, Seasons na polju = nazad 440 ms. |
| `design/Season Specs.dc.html` | Kit po sezoni (paleta, motivi, ambijent, run), sve površine za oba kita, prelaz u = 0,5 / 0,99, list cvijeća 6 × 3 na 64 / 128 / 192 (krem disk · livada · tamni well), tabela kontrasta (računa se u browseru) i dugme **Pokreni samoprovjeru**. |
| `design/seasons_kit.js` | Jedini izvor brojeva: `KITS`, `SHAPES`, `buildScene()` (recept → putanje), `spotRects()`, `ambientParticles()`, kontrast. |
| `design/ArenaScreen.dc.html` (+ ArenaField, SeedChip, SeedBasket, Muncher, `arena_v2_data.js`) | Kopija Arene v2; `arena_v2_data.js` uvozi kit i spaja `kits[id].arena` u `FIELDS` za CB i MW, rezove cvijeća čita iz `flowers_meta`, sjemenke u MW su MW tipovi. Raspored Arene nije diran. |
| `assets/flowers/<type_id>_t<tier>.svg` | 36 crteža + `flowers_meta.json` (bajtovi, rez, rub). |
| `assets/seasons/<id>/obstacle_*.svg` | 2 prepreke po sezoni (176 × 150). |
| `assets/pip/pip_sniff.svg`, `pip_sleep.svg` | Pip poze za polje (izmjena `pip_idle.svg`, isti rub i boje). |
| `tools/flowers_gen.js` | Generator cvijeća (`node tools/flowers_gen.js`), isti jezik kao `scripts/art/flowers_gen.py`. |
| `godot/seasons_export.json`, `ui_seasons.gd`, `seasons_tree.txt` | Export, konstante + helperi (ridge, R2, spot_rects, kontrast), stablo i šta se mijenja. |

## Status: sezona × površina
| Sezona | Kartica | Polje | Shop | Arena | Run | Cvijeće |
|---|---|---|---|---|---|---|
| Country Bloom | **kit** | **kit** | — (besplatna) | **kit** | **kit** | **18 novih** |
| Moonlit Warren | **kit** | **kit** | **kit (panorama)** | **kit** | **kit** | **18 novih** |
| Frost · Lantern · Amber | danas (trake) | danas | — | Arena v2 recept | tint | proceduralno — faza 2 (+ Camp link) |
| Coral · Starfall · Ember | danas | danas | danas (trake) | Arena v2 recept | tint | proceduralno — faza 3 |

## Kitovi
**Country Bloom** — nebo u 4 stepenaste trake `#E3F0EE → #F5F9E2`, 2 oblaka, brežuljci `#D3E7C0 / #C3DDA8`, greben `#B4D497` s **ogradom** (stub `#F4EAD6`/sjena `#C9B48F`, letve `#E6D8BC`), **7 pokošenih pruga** `#BCDCA0 / #ACD18F`, prednja pruga `#C3E0A8`, **bale sijena** `#E8D28C`. Ambijent: 14 latica na vjetru. Tekst na livadi `#1A1A14`. Run: tlo `#2F4A33`, pokošena traka `#44663F` (pruge 40/124), daljina = mrlje djeteline (0,35×), blizina = ograda + čuperci + tratinčice uz rub (1,0×), latice; prepreke **bala sijena** i **kapija ograde**.

**Moonlit Warren** — noćno nebo u 4 trake `#141833 → #262C53`, 16 zvijezda, **mjesec** `#EDEBFF` (desno, ispod Upgrades, na kartici ne dira disk), daleke humke `#2B3263` s osvijetljenim rubom `#4A5290`, tlo `#232955`, **2 humke s jazbinama** (`#0F1228` + rub `#4D5698`), **mahovina** `#2E4F5A` + kapi rose, tamni prednji pojas `#1A1E3E`. Ambijent: 10 zvijezda treperi + 8 mrvica mjesečine (18). Tekst na livadi `#FFF8F0`; stranica izbora ostaje svijetla `#DFE1FF`. Shop: panorama — mjesec izlazi između imena i dugmeta, humke na horizontu. Run: tlo `#1A1E3E`, staza od mjesečevog kamenčića `#323A6E`, daljina = jazbine (0,35×), blizina = mahovina + rosa, mrvice; prepreke **humka s jazbinom** i **oboreno deblo s mahovinom**.

## § Odlučeno
1. **Kit = red podataka, renderer = jedan.** `SeasonBackdrop` je generalizovani `ArenaMeadowBg`: slojevi `band` (nebo stepenasto), `ridge` (zbir sinusa, + osvijetljen rub), `mow` (pruge između pomaknutih grebena), `fence` (stubovi po grebenu + letve), `shape` (motiv), `scatter` (R2 niz, bez RNG-a). 0 PNG, 0 gradijenata; računa se jednom, po frejmu samo pomak/skala/alpha.
2. **Kartica = minijatura polja po istom receptu.** Slojevi su u % recta, oblici i cvijeće uniformno `k = w / 1080`. Sve što je *mjesto* (pozadina, 13 mjesta, ambijent) živi u prostoru recta kartice; kontrole ostaju u prostoru stranice. Na u = 1 rect = stranica → isti pikseli; tokom prelaza cvijeće stoji na svojoj pruzi (nema klizanja preko tla).
3. **Kontrast naljepnica = dvostruki rub:** `max(c(ink rub, livada), c(fill, livada)) ≥ 6,14`. Zato zone ispod kontrola moraju biti ili svijetle (CB, L ≥ 0,46) ili vrlo tamne (MW, L ≤ 0,036 zbog lavande Endless). Mid-tonovi su zabranjeni ispod kontrola; rasuti elementi ne crtaju centar u keepout zonama polja (mirne zone).
4. **Tekst direktno na livadi je boja kita** (`ink_field`): `#1A1A14` na svijetlom, `#FFF8F0` na tamnom; Home ≥ 38 osim imena cvijeta 34 (fiksno iz v3).
5. **13 mjesta:** broj, dubine (88 / 116 / 136 / 168), pragovi i indeksi isti kao polje v2. CB zadržava pozicije (F red stoji ispred ograde na grebenu); MW pomjera M red na humke (x 20 / 80) i krunu uz jazbinu.
6. **Cvijeće:** taman vanjski rub po kitu (CB `#3D2B3D`, MW `#221B3A`) — jedan debeli rub siluete po grupi, tanke unutrašnje linije, ravni odsjaji. T1 pupoljak, T2 cvijet, **T3 = isti T2 crtež kao brušeni kristal** (fasete svijetlo/tamno/vrh, svjetlo gore-lijevo), **bez krugova, prstenova i iskrica**. Rijetkost → kompleksnost: ★1 jedan cvijet, ★2 slojevit cvijet + pupoljak/druga glava, ★3 više dijelova (bundeva + loza + cvijet + vitice; ljiljan s dva cvijeta u 3/4 pogledu).
7. **Pip na polju:** postojeći FSM (walk .5 / sniff .25 / sleep .25) dobija poze: hod = bob 0,42 s; njuši = `pip_sniff.svg` + nagib prema cvijetu, **cvijet se nakloni** (0,6 s oko baze) + **5 čestica polena**; spava = `pip_sleep.svg` + sabijanje + 3 „z“. **Cvijet izraste** = 0 → 1,12 → 1 za 0,42 s kad mjesto pređe prag.
8. **Petlje:** polje = ambijent + AttentionRing (samo prazna korpa) ≤ 2; kartica 0; Shop = tačke dugmeta samo dok čeka store; Arena 0 (polje miruje dok se igra); Run = ambijent + MagnetRing ≤ 2.
9. **Run:** geometrija ista (staze 270/540/810 × 200, šavovi 405/675, daljina 0,35×). Prepreke su svijetle mase 176 × 150 s ravnom bazom + ovratnik 240 × 52 u boji kita, kolizija 64 × 64 ostaje; pickupi nedirnuti → razlika oblikom i u grayscaleu.
10. **Pillar 2:** plaćena sezona dobija temu, ne snagu (isti brojevi, iste nagrade); besplatna je jednako bogata (3 motiva, ambijent, 18 crteža); Shop bez lažne hitnosti (nema tajmera, popusta ni „limited“).

## § Šta se briše
- `SeasonTheme.bg_modulate / obstacle_modulate / home_field_tint` za sezone s kitom (ostaje fallback za ostalih 6 dok ne stignu).
- `HomeV3Card._band()` trake i `SeasonField` `MeadowSky/Far/Near` → `SeasonBackdrop`.
- 18 današnjih `game/assets/sprites/flowers/*.svg` (zamijenjeni; isti nazivi) i `CampPlantDraw` proceduralni krug za 6 MW tipova.
- Run: zajednički kamen/panj i `SeasonTheme` tint pozadine za CB i MW.

## § Samoprovjera (§9) — Season Specs → „Pokreni samoprovjeru“, 2026-10-03
| # | Stavka | | Mjereno |
|---|---|---|---|
| 1 | Dva različita mjesta na svakoj površini | **da** | različiti slojevi i oblici (CB: oblak, bala, ograda, pruge · MW: mjesec, humka, jazbina, mahovina); Shop ima samo MW jer je CB besplatna |
| 2 | Kartica = polje bez šava | **da** | isti `buildScene(kit.field, rect)`; na u = 1 putanje identične (0 razlika); 13 mjesta u istom rectu |
| 3 | Kontrast | **da** | najslabije: CB strelice (krem) na čupercima 6,18; MW naljepnice gore (lavanda) 6,78; MW ime cvijeta na mahovini 8,37; tekst svuda ≥ 8,5; cvijeće ≥ 3,2 |
| 4 | Run grayscale: prepreka ≠ pickup | **da** | oblik (masa s ravnom bazom + ovratnik vs plutajući krug); prepreka/staza CB 3,97 / 5,46, MW 3,26 / 3,45 |
| 5 | Cvijeće na 64 px | **da** (ručno) | 12 različitih silueta; T3 čitljiv po fasetama |
| 6 | Budžet | **da** | cvijeće najviše 11,2 KB (star_jasmine_t3) (≤ 12); ambijent max 18 (≤ 24); ≤ 2 petlje po ekranu; 0 PNG |
| 7 | Imena fajlova | **da** | 36 × `<type_id>_t<tier>.svg`, 4 prepreke, 2 Pip poze — sve se učitavaju |

## Otvorena pitanja
1. **Brief §5/§6 nije bio na masteru** — ako tabela cvijeća u §6 traži drugačije motive (npr. šta tačno crta T1), crteži se mijenjaju u `tools/flowers_gen.js`, izlaz ostaje isti.
2. **Polje prikazuje T3** (kao `SeasonFieldFlower`, `plant_tier = 3`) — sve izraslo je kristal. Da li polje treba pokazivati T2 s kristalom samo na kruni?
3. **Cijena** u mocku je store string `€2.99` (Shop v2 `PRICES.eur`); Home v3 je imao `$4.99` placeholder.
4. **Godot SVG prepreke** — tijela su SVG (bolje od 3 crtana poligona), ali traže `.import`; ako želiš 0 asseta, iste oblike mogu prepisati u recept.
5. Kartica CB u stanjima *locked/buy* postoji samo kao test kita (CB je uvijek otključan i besplatan).
