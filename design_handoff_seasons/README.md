# Season Kit — faze 1 + 2 (svih 8 sezona)

## Ideja
Svaka sezona je **drugo mjesto**, ne druga boja. Svaka sezona ima jedan **Season Kit** — mjesto, paletu, 2–4 potpis-motiva, ambijent i 18 crteža cvijeća — koji se reže na svaku površinu: Home kartica, Home polje, Shop kartica, Camp link, Arena i Run. Kit je **red podataka** (`design/seasons_kit.js` = `godot/seasons_export.json`); renderer je jedan i generički. Faza 2 je dodala 6 redova (Frost, Lantern, Amber, Coral, Starfall, Ember), 108 crteža, 12 prepreka i nekoliko generičkih primitiva — bez posebnog koda po sezoni.

## Šta otvoriti
| Fajl | Šta je |
|---|---|
| `design/SeasonScreen.dc.html` | Jedan ekran 1080 × 1920. Propovi: `season` (8), `surface` (card · field · shop · camp · arena · run · flowers), `state`, `lush`, `still`, + `sway` (njihanje cvijeća), `pip` (walk · sniff · sleep kad je still), `u` (zamrznut kadar prelaza), `grayscale`. Stanja: card active · owned · locked · buy · soon; field 0 · 6 · 13; shop buy · busy · pending · restoring · play · failed (Ember uvijek soon); camp short · ready · burst; arena empty · full · hunting · eating · frozen · bag_empty; run mid · fail. Bez `state` svaka sezona pokazuje svoje zadano stanje (CB active, Frost owned, Lantern/Amber locked, MW/Coral/Starfall buy, Ember soon). |
| `design/Season Specs.dc.html` | Kit svih 8 sezona; sve površine s 8 sezona jedna pored druge (kartica, stanja, polje 13 i 0/6, Shop, Camp, Arena, Run, Run grayscale); list cvijeća 6 × 3 po sezoni na 64 / 128 / 192; kontrast iz piksela recepta i dugme **Pokreni samoprovjeru**. Ekrani se montiraju postepeno (3 svakih 0,7 s); tweak `section` pokazuje samo jedan dio. |
| `design/seasons_kit.js` | Jedini izvor brojeva: `KITS`, `ROSTER`, `SHAPES`, `buildScene`, `spotRects`, `ambientLayers` / `ambientAt`, `laneTile`, `runItems`, `BANDS`, `PREV_FREE`, `PRICES`, `SOON`, kontrast. |
| `design/ArenaScreen.dc.html` (+ `arena_v2_data.js`, djeca) | Arena v2; `arena_v2_data.js` spaja `kits[id].arena` u `FIELDS` za **svih 8** sezona, rezove cvijeća čita iz `flowers_meta`; sjemenke su tipovi sezone. Raspored Arene nije diran. |
| `assets/flowers/<type_id>_t<tier>.svg` | **144** crteža + `flowers_meta.json` (bajtovi, rez, rub). |
| `assets/seasons/<season_id>/obstacle_*.svg` | **16** prepreka (2 po sezoni, 176 × 150). |
| `assets/pip/pip_sniff.svg`, `pip_sleep.svg` | Pip poze. |
| `tools/flowers_gen.js` | Generator cvijeća (`node tools/flowers_gen.js`); faza 2 = arhetipovi (glava s prstenovima, vlati, mahune, grozd, kugla, trolist) + 36 redova konfiguracije. |
| `godot/seasons_export.json` | meta, tokens, shapes, kits, surfaces, obstacles, animations, strings_en, godot_map, decisions, flowers. |
| `godot/ui_seasons.gd`, `godot/seasons_tree.txt` | Konstante + helperi (ridge_y s tilt, scatter_at, spot_rects, ambient_layers, ambient_at, lane_tile, run_items, kontrast) i stablo čvorova. |

## Status: sezona × površina (2026-10-06)
| Sezona | Faza | Kartica | Polje | Shop | Camp link | Arena | Run + 2 prepreke | Ambijent | Cvijeće |
|---|---|---|---|---|---|---|---|---|---|
| Country Bloom | 1 | ✅ active | ✅ | — besplatna | — početna | ✅ | ✅ bala · kapija | latice | ✅ 18 |
| Frost Orchard | 2 | ✅ owned · locked | ✅ | — | ✅ (→ Pumpkin) | ✅ | ✅ blok leda · panj pod snijegom | pahulje | ✅ 18 |
| Lantern Meadow | 2 | ✅ locked · owned | ✅ | — | ✅ (→ Crystal Peony) | ✅ | ✅ stub s fenjerom · kamen s mahovinom | svici | ✅ 18 |
| Amber Canopy | 2 | ✅ locked · owned | ✅ | — | ✅ (→ Midnight Lotus) | ✅ | ✅ srušeno deblo · panj s gljivama | lišće + prašina | ✅ 18 |
| Moonlit Warren | 1 | ✅ buy · owned | ✅ | ✅ | — | ✅ | ✅ humka · deblo | zvijezde + mrvice | ✅ 18 |
| Coral Tide Garden | 2 | ✅ buy · owned | ✅ | ✅ | — | ✅ | ✅ stijena sa školjkama · koralj | odsjaji + mjehurići | ✅ 18 |
| Starfall Glade | 2 | ✅ buy · owned | ✅ | ✅ | — | ✅ | ✅ meteorit · panj jele | zvijezde + meteori + latice | ✅ 18 |
| Ember Fen | 2 | ✅ soon | ✅ | ✅ soon | — | ✅ | ✅ panj koji tinja · busen rogoza | žeravica + dim | ✅ 18 |

## Kitovi faze 2
- **Frost Orchard** (besplatna, svijetla) — ravan bijeli horizont, **dva reda voćki** s kapama snijega (`row` po grebenu), **zaleđena bara**, **nanosi**. Nebo `#D9E7F6 → #EEF5FC`, tlo `#EAF1F9`, voćke `#B9CBE0 / #A7BDD6`, led `#C6D8EC`. Ambijent: 18 pahulja padaju i njišu se. Run: ugažen snijeg s tragom sanki (`rut`), daljina zaleđene lokve, blizina voćke uz rub.
- **Lantern Meadow** (besplatna, tamna — sumrak) — **girlanda papirnih fenjera** (svaki drugi upaljen, `row` duž `line`), **visoka trava sa strana** (`sideGrass`), noćurke u travi. Nebo `#120E22 → #241B3A`, tlo `#1C1730`. Ambijent: 16 svitaca lebdi. Camp: svjetliji sumrak (`#EEE6F7`) jer je tekst `#3D3D33`. Run: staza od kamenčića s mahovinom (`pebble`), fenjeri na stubovima uz rub.
- **Amber Canopy** (besplatna, svijetla — sunčana krošnja) — **krošnja odozgo** (`ridge.up` + lišće koje visi samo između gornjih kontrola), **dva tamna debla** (L ≤ 0,036, izbočena samo između kontrola), **snopovi svjetla** i mrlje sunca. Tlo `#F7E8C9 → #EED6A8`, krošnja `#F2C46A / #E8AE58`. Ambijent: 12 listova pada + 8 zrna prašine. Run: staza prekrivena lišćem.
- **Coral Tide Garden** (plaćena, svijetla) — **obala dijagonalno** (4 grebena s istim `tilt`), voda gore, pjena, mokar i suh pijesak, **koralj na rubu plime** (`row`), školjke i zvjezdače. Ambijent: odsjaji trepere + mjehurići. Shop panorama: voda gore, pijesak ispod imena. Run: daščana staza preko plićaka (`plank`).
- **Starfall Glade** (plaćena, tamna) — **prsten jela** (spikes + dva bočna poligona), **zvjezdano nebo i meteori**, čistina s paprati. Ambijent: 12 zvijezda treperi, 2 meteora prelijeću (`streak`), 8 latica pada. Run: staza od zvjezdane prašine, jele uz rub.
- **Ember Fen** (plaćena, tamna, uskoro) — **lokve s odsjajem vatre**, **rogoz uz rubove**, **dva pojasa dima** (puna boja, bez alpha/blura), tinjajuće žeravice. Ambijent: 14 žeravica se diže + 4 oblaka dima klize. Run: daščana staza preko močvare.

## § Novi primitivi (faza 2) — sve u `seasons_kit.js`, isti kod za svih 8
- **Slojevi recepta:** `row` (motiv u redu duž grebena ili linije, veličina varira po R2), `poly` (+ `smooth` Catmull-Rom), `ellipse`, `line` (+ `smooth`), `ridge.up` (puni prema gore — krošnja), `ridge.tilt` (nagnut greben — obala), `shape` s listom tačaka `[x, y, size, rot]`, `scatter.noAvoid`. Pomoćnici `spikes()` (jele, rogoz, trava) i `sideGrass()`.
- **25 novih oblika:** tree, fir, drift, puddle, flake, lantern, firefly, leaf, acorn, mushroom, dapple, trunk, ripple, shell, starfish, coral, thrift, rock, meteor, fern, cattail, ember, bubble, glint, pad, smoke — svi od 6 primitiva (c, e, p, r, l, a).
- **Generički ambijent:** `layers: [{motion: drift | fall | rise | float | twinkle | streak, n, shape, size, pal, pal2, zone, drift, sway, sec, rot, angle, alpha, fade, pulse, duty, ph}]`; `ambientAt(L, t)` daje pomak/rot/skalu/alpha — po frejmu samo transform. Budžet 24 se poštuje i u `ambientLayers`. CB i MW su prevedeni na isti format (isti izgled).
- **Run:** `material.kind` = stripe · pebble · plank · rut (`laneTile`), far/near = `items` (`runItems` prevodi i stare ključeve faze 1).
- **Camp recept** `kits[id].camp` (1032 × 318) i **Shop recept** `kits[id].shop` (1032 × 364) — isti `buildScene`.
- **Cvijeće:** arhetipovi u `tools/flowers_gen.js` — `plant` (glava s prstenovima latica, lepeza ili krug, 3/4 pogled; pupoljci; druge glave; listovi; lopoč), `spikePlant` (vlati s vrhom: svitac, rogoz, kometa), mahune fenjera, grozd (glicinija), kugla (karanfil, hrastov cvat), trolist, list-grančica; `crystalLite`, `gemSmall`, `gemCenter`, `gemStar`, `facetPoly` za T3.

## § Odlučeno (faza 2)
1. **Mjesto iz Arene v2** za svih 6 (opisi `place` iz `arena_v2_data.js`), boje polja uzete tako da prođu pravilo kontrole. Arena dobija `kits[id].arena` (base/layers/scatter/combo) — svih 6 je usklađeno s poljem (Lantern: tamno tlo `#1C1730`, crna bočna trava i girlanda, isti fenjeri).
2. **Ispod kontrola** samo L ≥ 0,46 ili L ≤ 0,036. Tamne sezone (Lantern, Starfall, Ember) imaju skoro crno tlo i nebo, tekst `#FFF8F0`; svijetla stranica izbora ostaje svijetla (`page`).
3. **Polje:** 13 mjesta, dubine i pragovi isti; Pip zona **[151, 1306, 614, 131]**; dodana **Looks** pločica (876, 1265, 180) iz `field_wardrobe_button.gd` i njen keepout.
4. **Animacije polja:** njihanje cvijeća ±3° (3–5 s, faza po mjestu, prop `sway`), Pip njuši → cvijet 1 → 1,08 → 1 za 0,3 s + 3 čestice **oblika ambijenta sezone**; Pip spava → ambijent se smiri (alpha 0,35 za 1,2 s); cvijet izraste 0 → 1,12 → 1. Na kartici ambijent tek poslije prelaza (fade 0,3 s).
5. **Kartice:** Ember = soon (crteži 50 %, „Coming soon“ isprekidan rub, isprekidan rub kartice); locked pokazuje 320 / 500 i ★3 prethodne sezone 14 / 20; tačke traka iz `BANDS`, aktivna sezona (CB) breskva.
6. **Shop:** MW, Coral, Starfall, Ember; stanja buy · busy (ostali dim) · pending · restoring · play · failed; Ember bez cijene i dugmeta. Cijene iz store stringova (`PRICES`), bez lažne hitnosti.
7. **Camp link:** Frost/Lantern/Amber; cvijet u okviru = ★3 **prethodne** besplatne sezone; recept iza teksta je svijetao (tekst `#3D3D33` ≥ 4,5).
8. **Run:** geometrija ista; prepreke = masa s ravnom bazom + taman rub + ovratnik u boji kita; kolizija 64 × 64; pickup nedirnut.

## § Ispravke faze 1 (lekcije §10.1)
- Sve unutar 0–100 % recta: grebeni se uzorkuju 0–100 (bilo −2…102), zatvaraju se na 0/100 (bilo 101); MW Shop traka 64–101 → 64–100. Izgled CB i MW je isti.
- Pip zona 778 → **614** (Looks pločica).
- Ambijent CB/MW u generičkom formatu (stari `petals` / `stars_motes` ostaju u JSON-u dok se `season_ambient.gd` ne zamijeni).

## § Šta se briše
- `SeasonTheme.bg_modulate`, `SeasonTheme.obstacle_modulate`, `home_field_tint` — sve sezone imaju kit.
- `UiCamp.season_tint` (Camp link crta recept `camp`).
- `UiShopV2.season_bands` / `season_pack_card.gd` trake (Shop crta recept `shop`).
- `SEASON_HUE` proceduralno cvijeće i `CampPlantDraw` krug za 42 tipa — svih 48 tipova ima crtež.
- `HomeV3Card._band()`, `SeasonField._band_sky/_far/_near`, specijalni slučajevi u `season_ambient.gd`.
- Zajednički kamen/panj u runu (16 prepreka po sezoni).
- **Ne popunjavati** `run_bg_path` / `obstacle_theme_id` (§10.1) — run čita `kits[id].run`.

## § Samoprovjera (§9) — Season Specs → „Pokreni samoprovjeru“, 2026-10-06
| # | Stavka | | Mjereno |
|---|---|---|---|
| 1 | Različito mjesto na svakoj površini | **da** | 8 različitih potpisa recepta (oblici + slojevi); 8 materijala staze, 16 prepreka |
| 2 | Kartica = polje bez šava | **da** | isti `buildScene`; isti slojevi i boje na 1032 × 1160, 516 × 580 i 1080 × 1633 za svih 8 |
| 3 | Kontrast iz piksela recepta | **da** | najslabije naljepnice: Amber 6,42 · Frost 7,35 · CB 7,41; tekst na livadi: Frost 5,54 · MW 6,87; coin/staza: Frost 3,26 · Coral 4,02 |
| 4 | Sve unutar 0–100 % | **da** | svi slojevi polja, Camp i Shop recepata |
| 5 | Run grayscale: prepreka ≠ pickup | **da** | oblik (masa s bazom + ovratnik + taman rub) vs plutajući krug; red „Run grayscale“ u Specs |
| 6 | Cvijeće (144) na 64 px | **da** (+ ručno) | najveći nova_bloom_t3 11.7 KB (≤ 12); T1 svaki tip svoja silueta |
| 7 | Budžet | **da** | ambijent max 22 čestice (Starfall polje), ≤ 2 petlje po ekranu, 0 PNG, 0 gradijenata u receptima |
| 8 | Imena fajlova | **da** | 144 cvijeća + 16 prepreka + 2 Pip poze se učitavaju |
| 9 | Pip zona | **da** | [151, 1306, 614, 131] |

U toku rada samoprovjera je našla 4 greške koje su ispravljene: Amber lišće ispod GrownChip-a (5,94 → svjetlije lišće), Amber deblo ispod Basket-a (rub poligona → deblo izbočeno samo između kontrola), Ember žeravica i odsjaj lokve ispod napomene (pomjereno), MW Shop traka do 101 %.

## Odluke po preporuci (2026-10-06)
- **Lantern Arena** usklađena s poljem (`kits.lantern_meadow.arena`: base, far_grass, dusk_ground, side_grass, garland, fenjeri, vlati).
- **Camp kartica**: jedna tvrda sjena `0 8 0 rgba(26,26,20,.22)` (pravilo §8), ne meka iz paketa Camp link.
- **Polje** i dalje pokazuje T3 (kao faza 1).
- **Specs**: ekrani se montiraju postepeno; tweak `section` za brz pregled.

## Šta je na tebi / Claude Code
Sve što ne mogu uraditi iz dizajna (stvarne cijene, Godot implementacija, brisanje starog koda) je u **`PREPORUKE_ZA_CLAUDE_CODE.md`** — redoslijed, fajlovi i kriterij gotovosti, spremno da se preda Claude Code-u.
