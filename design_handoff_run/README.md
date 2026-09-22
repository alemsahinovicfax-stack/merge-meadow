# Handoff: Run (lane runner)

Dizajn iz Claude Designa za prenos u `run_scene.tscn`. Prati
`docs/04-experience/design-drafts/run-cd-brief.md`.

Run je **pun ekran 1080 × 1920** — nije unutar hub chromea. Nema header valuta,
nema footer tabova.

## Šta je ovo

**Fidelity: hi-fi za layout, stanja i mjere; placeholder za art.** Pip i cvijeće
su placeholderi (oblik i veličina su spec, crtež nije). Sve ostalo — HUD,
staze, pickupi, prepreke, beat trajanja — je finalno u bazi 1080 × 1920.

Odabran je **smjer A — košene staze na tamnoj livadi**. Odluka je mjerena na
paleti koja već postoji, ne na hipotetskom artu:

| | pastel pickup na svijetloj stazi (B) | na tamnoj stazi (A) |
|---|---|---|
| coin `#FFD56B` | 1,4:1 | **5,3:1** |
| krem rim `#FFF8F0` | 1,1:1 | **7,0:1** |
| mint `#A8E6CF` | 1,34:1 | **9,3:1** |

Zadnji red je isto mjerenje koje je odlučilo Arenu (`design_handoff_merge_arena/README.md`).
Smjer B dodatno troši 372 px na tamnu HUD traku, pa Run počinje izgledati kao
hub stranica — jedina stvar koju brief eksplicitno kaže da nije.

**Ergonomija HUD-a je ista u oba smjera** (§4.1 je zaključava: timer uvijek
vidljiv, coin + seed uvijek, tekst ≥ 38 px, brojevi ≥ 44 px, Pause ≥ 120 px).
Smjer je izbor **tla i chromea**, ne rasporeda.

## Sadržaj paketa

| Fajl | Šta je |
|------|--------|
| `ui_run.gd` | **Paste-ready.** Boje, mjere, `chip_style()`, `ring_color()`, `lane_rect()`, `seed_pip_positions()`, `obstacle_colors()`, `timer_lines()`. Ide u `game/scripts/visual/`. |
| `icons/icon_pause.svg` · `icon_basket.svg` | Novi. → `game/assets/ui/run/` |
| `icons/icon_coin.svg` · `icon_seed.svg` · `icon_diamond.svg` | Kopije — već su u `game/assets/ui/chrome/`, ne treba ih ponovo importati. |
| `flowers/` | 8 placeholder rozeta iz Arena handoffa — referenca za veličinu (76 px u wellu), nisu za produkciju. |
| `Run Redesign.dc.html` | Svi artboardi: 2 smjera × 3 scene, pickup/obstacle/HUD/magnet spec, fail + finish + pause, lane detalj, tabela animacija, asset lista. |
| `RunScreen.dc.html` | Parametrizovano: `dir`, `scene`, `magnet`, `timer`, `seconds`, brojači, `basket`, `cue`. |

## Prenos — 5 koraka

### 1. `ui_run.gd`

Kopiraj u `game/scripts/visual/`. Nijanse su izvedene iz `ui_palette.gd` i
`UiArena` — jedine nove su tlo i prepreke:

```gdscript
const GROUND := Color("#26382C")   # livada izvan staza
const LANE := Color("#3A5C41")     # kosena staza
const COLLAR := Color("#C7BE9A")   # izgazena trava oko prepreke
const STONE := Color("#A9AFA6")
const HAY := Color("#D9C98A")
const FAIL := Color("#E88B8B")     # brief §5 ju je oznacio kao novu — jest
```

`SEED_WELL`, `RIM_EDGE` (`CHIP_EDGE`), `GOLD_EDGE` (`COIN_EDGE`) i `BAG_BODY`
(`STUMP`) su **isti hexovi kao u `UiArena`** — ako `ui_arena.gd` već stoji u
projektu, ne dupliraj ih, referenciraj.

### 2. LaneField — staze su konačno vidljive

`LaneGuides` node postoji i `visible = false` (§3.2 #6). Umjesto da ga upališ,
staza ide u pozadinu:

| Sloj | Mjera |
|---|---|
| Tlo | `GROUND`, cijeli viewport |
| Staza × 3 | 200 px široka, centri 25 / 50 / 75 % → 270 / 540 / 810 |
| Tlo između staza | **70 px** — ovo je ono što ih čini tri |
| Rub staze | 4 px `LANE_EDGE` lijevo i desno |
| Košene pruge | `LANE_MOW` svakih 124 px, **samo unutar staze** |
| Šav | dashed `LANE_SEAM` na 405 i 675 |

Pruge preko cijele širine trake su probane pa odbačene — spajaju tri staze u
jedno polje. Pruge se pomjeraju s `scroll_speed`, pa su jedini vizual koji
pokazuje speed ramp (×1,05 svakih 15 s).

Parallax: 2 sloja. Daleki = mekane mrlje `BLOB` na 0,35 × brzine. Bliski =
čuperci i cvjetići u rubnim pojasima (0…170 i 910…1080) na 1,0 ×.

### 3. RunHud — vertikalni budžet

| Sloj | y | h |
|---|---|---|
| safe area (notch) | 0 | 60 |
| `TimerChip` | 60 | **156 (fiksno 460 × 156)** |
| `PauseButton` | 74 | 128 |
| `CompanionChip` · `PickupBar` | 232 | 120 |
| `BasketBadge` | 364 | 76 |
| `PickupFeed` toast | 386 | 62 |

`TimerChip` je **fiksnih 460 × 156** i kad je mod normalan, inače HUD skače pri
prelasku na Endless (ista greška koju Arena handoff prijavljuje za `HintLine`).
Layout je prsten 104 px + dva reda teksta: mod (38 px) i sekunde (72 px). Najduži
string `Endless · Hard` staje u 445 od 460 px. Prsten ide `RING_LOW` (peach) pod
17 % — mirno, bez crvenog panic stanja (Pillar 2).

Brojači: coin i seed su krem (ovaj run), diamond je `DIAMOND_CHIP` soft sky
(wallet, upisano odmah) i **pojavljuje se samo kad je > 0**. Visina 120 px je
44 pt hit iz §4.1.

`Basket: %s` → ikona + tip. Prefiks ne nosi informaciju koju badge već nosi.

**Reakcijski prostor:** entitet spawna na y = −80 i potpuno je vidljiv od
y ≈ 232 (ispod prvog HUD reda). Do igrača na y = 1574 ostaje 1342 px ≈ 3,3 s pri
400 px/s. `TimerChip` prekriva srednju stazu na vrhu, ali samo prvih ~0,5 s
putanje — provjereno da ne krade reakciju.

### 4. Pickupi rastu, collision ostaje

| | danas | novo | collision |
|---|---|---|---|
| Coin | 40 px | **96** | nepromijenjen (r 18) |
| Seed | 52 px | **120** | nepromijenjen (r 26) |
| Diamond | 36 px | **88** | nepromijenjen |

52 px na 1080 bazi je ≈ 19 dp — to je pravi razlog zašto §3.2 #7 kaže da se
pickupi ne uklapaju. Magnet (`40 + 48 × level`) je taj koji skuplja, pa vizual
može rasti bez dodavanja dohvata: na levelu 0 radius 40 već pokriva krug od
96 px.

**Sjemenka u runu je isti objekat kao Arena `SeedChip`** — krem rim + tamni well
+ cvijet, samo 120 umjesto 134 px. Ono što uhvatiš u runu je doslovno ono što
vučeš u Areni; to je jedina veza petlje koju danas ništa ne prikazuje.

Rijetkost: **broj pipa na rimu**, ne boja (Ø 16 na radiusu 51; ★1 nula, ★2 dva
lavanda, ★3 tri gold). Dvije odbačene verzije: zlatni rim (★3 se na 120 px čita
kao coin) i pun vs dashed prsten (razlika preslaba kad je sjemenka u pokretu).

### 5. Obstacle — 3 motiva, nijedan zelen

Tijelo **176 × 150** u stazi od 200 px + `ObstacleCollar` 240 × 52 (izgažena
trava, zajednički sloj za sva tri motiva).

Motivi: **Stone**, **Stump**, **Hay bale**. Brief je predložio kamen / panj /
grm — grm je zamijenjen balom sijena jer je zelen kao livada: `#4A8250` na stazi
`#3A5C41` daje 1,8:1 i pada na grayscale testu iz §4.1. Sva tri su namjerno
nezelena i svjetlija od tla.

Pravilo koje nosi grayscale test:

> Pickup = svijetli krug ≤ 120 px koji **pluta** (odvojena sjena 64 × 18 na
> +40 px). Prepreka = masa ≥ 176 px s **ravnom bazom** i ovratnikom. Oblik i
> sjena ih razlikuju i bez boje.

Season tint ostaje `SeasonTheme.obstacle_modulate()` — već u kodu, radi na sva
tri motiva. Izračunate vrijednosti su u spec sheetu (`country_bloom`,
`frost_orchard`, `ember_fen`).

## MagnetRing

§3.2 #4: igrač ne vidi šta je kupio. Prsten je jedino mjesto u igri gdje se
magnet upgrade vidi.

| Level | Radius | Vizual |
|---|---|---|
| 0 | 40 | solid 4 px krem @ 20 %, bez pulsa |
| 1–4 | 88 / 136 / 184 / 232 | dashed 7 px @ 42 % + fill @ 7 % + puls 1,8 s |

Dashed jer se čita kao *polje*, ne kao objekat. Radius je doslovno
`GameState.get_magnet_radius()` — formula netaknuta.

## Fail / Finish / Pause

`_end_run()` danas ide instant na `go_to_scene(LOOT)` (§3.2 #9, §10 #3).

**Fail — 0,46 s:** freeze 0,20 s → shake ±14 px (0,24 s) → flash `FAIL` @ 26 %
(0,12 s) → Pip −13° → **5 tokena se prosipa**. Prosipanje *pokazuje* pravilo od
50 % loota umjesto da ga napiše.

**Finish — 0,62 s:** prsten na 0 → mint burst iz `TimerChip` (0,32 s) → banner
`Time!` + `Full basket — nothing lost` → svijet staje u 0,3 s.

**Pause** (novi node, ne postoji u `run_scene.tscn`): overlay `rgba(22,33,27,.82)`
+ krem panel 900 px. `Keep running` (peach CTA 140 px) · `Quit to Camp` (subtle
140 px).

Predlog na otvoreno pitanje iz briefa: **Quit to Camp = fail loot (50 %), bez
druge potvrde, bez revivea.** Posljedica je napisana u panelu („Quitting keeps
half of what you carry. No revive is used.") pa dodatni dijalog samo dodaje klik.
Revive ostaje isključivo na loot ekranu — ne miješati.

Puna tabela od 15 animacija je u `Run Redesign.dc.html` (sekcija „Tabela
animacija"). Sve su tween na poziciji / skali / alphi. Burst po pickupu je jedan
prsten, ne čestice. Vignette na failu je 1 PNG s alfom, ne shader.

## Tekstovi

Dizajn fajl ima tabelu **stari → novi** za 10 poruka. Glavna promjena: `PickupFeed`
prestaje biti 5 redova teksta i postaje leteći `+1` chip u brojač + toast s
imenom tipa samo za sjemenke (1,4 s, max 2 u stacku). Ime tipa je jedina
informacija koju chip ne nosi.

## Asseti za produkciju

| Fajl | Veličina |
|---|---|
| `coin_run.svg` | 96 × 96 |
| `seed_rim_run.svg` | 120 × 120 |
| `seed_well_run.svg` | 84 × 84 |
| `diamond_run.svg` | 88 × 88 |
| `obstacle_stone.svg` · `_stump.svg` · `_hay.svg` | 176 × 150 |
| `obstacle_collar.svg` | 240 × 52 |
| `run_ground.png` · `run_lane.png` | 1080 × 1024 · 218 × 512, tileable |
| `vignette_fail.png` | 1080 × 1920, alpha |
| `icon_pause.svg` · `icon_basket.svg` | 128 × 128 (u paketu) |

Kopiraj `icons/icon_pause.svg` i `icon_basket.svg` u `game/assets/ui/run/`, pa
`scripts/godot-import.ps1` i commitaj `.import` fajlove (CLAUDE.md § Novi asset).
`icon_coin` / `icon_seed` / `icon_diamond` su već importani u
`game/assets/ui/chrome/` — koristi te.

## Gotovo kad

- [ ] Tri lanea razlučiva na emulatoru bez oslanjanja na boju
- [ ] Prepreka ≠ pickup na **grayscale** screenshotu (sva 3 motiva × 3 pickupa)
- [ ] `Endless · Hard · 60s` staje; `TimerChip` ne skače pri promjeni moda
- [ ] Brojevi ≥ 44 px, tekst ≥ 38 px na uređaju
- [ ] Swipe i dalje 3 lanea / 0,12 s; magnet radius i spawn šanse netaknute
- [ ] MagnetRing vidljivo veći na levelu 2 nego 0
- [ ] Fail beat ≤ 0,5 s do loot scene; nema mid-run IAP/ads
- [ ] Pause ne troši revive; Quit vodi na loot kao fail
- [ ] Smokes: postojeći `run_*` + novi `run_redesign_smoke` po uzoru na arena

## Otvorena pitanja za tebe

1. **Obstacle collision.** Jedina promjena brojeva koju predlažem: 64 × 64 →
   **150 × 110** (13 px oproštaja po strani od nacrtanog tijela 176 × 150). Bez
   toga igrač prolazi kroz ivice nacrtane prepreke. Utiče na težinu.
2. **Koliko motiva u v1.** Sva tri (stone / stump / hay) su specificirana, ali
   1 motiv + season tint je dovoljan za vertical slice. Preporuka: **stump +
   stone** u v1, hay u v2 (dva su dovoljna da spawn ne izgleda repetitivno).
3. **Smjer A ili B.**

## Van zadatka — nije u dizajnu

- **Near-miss feedback:** kad prođeš 40 px od prepreke, ovratnik kratko
  zasvijetli krem. Bez mehanike, samo „bilo je blizu".
- **Basket streak:** kad Basket tip padne 3 ×, badge dobije mint puls. Vidljiva
  nagrada za loadout bez novog broja.
- **Lane preview:** 3 tačke na dnu koje pokazuju u kojem si laneu. Pomaže samo
  prvi run — vjerovatno ne treba.
- **Ne bih:** power-upi mid-run, 4. lane, boss. Svaki dodaje HUD sloj u ekran
  koji je upravo postao čitljiv, a Pillar 2 ne traži ništa od toga.
