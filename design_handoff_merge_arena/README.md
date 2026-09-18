# Handoff: Merge Arena

Dizajn iz Claude Designa za prenos u `merge_arena.tscn`. Prati
`docs/04-experience/design-drafts/merge-arena-cd-brief.md`.

Pretpostavlja da je **hub chrome već prenesen** (`design_handoff_hub_chrome/`) —
Arena se uklapa u 1597 px između headera (143) i footera (180).

## Šta je ovo

**Fidelity: hi-fi za layout i stanja, placeholder za art.** Mjere, boje, radiusi
i stanja su finalni u bazi 1080×1920. Cvijeće, Muncher i vreća su **placeholderi**
— oblik i veličina su spec, crtež nije.

Odabran je **smjer B — sadnica (cream rim + tamni well)**. Odluka je mjerena na
isporučenom `seed_clover.svg`, ne na hipotetskom artu:

| Latica Meadow Clovera ★1 | na cream jastučiću (A) | na wellu (B) |
|---|---|---|
| `#A8E6CF` | **1,34:1** | 9,3:1 |
| `#7FD4A8` | **1,68:1** | 7,5:1 |

Smjer A gubi masu cvijeta na postojećem Country Bloom artu. Tvrdi outline spašava
siluetu, ne tijelo — zato odluka ne zavisi od otvorenog pitanja outlinea (niže).

## Sadržaj paketa

| Fajl | Šta je |
|------|--------|
| `ui_arena.gd` | **Paste-ready.** Boje, mjere, `spawn_slots()`, `chip_rim_style()`, `chip_well_style()`, `combo_style()`, `hud_pill_style()`. Ide u `game/scripts/visual/`. |
| `icons/` | `icon_crystal.svg`, `icon_target.svg`, `icon_check.svg` → `game/assets/ui/arena/` |
| `flowers/` | 8 placeholder rozeta × 2 konvencije outlinea. **Nisu za produkciju** — referenca za veličinu i kontrast. |
| `Merge Arena Redesign.dc.html` | Svi artboardi: 2 smjera, 4 scene, spec sheetovi, T3 storyboard. |
| `ArenaScreen.dc.html` · `SeedChip.dc.html` | Parametrizovano (scena, tier, stanje, T3, Muncher, vreća). |

## Prenos — 5 koraka

### 1. `ui_arena.gd`

Kopiraj u `game/scripts/visual/`. Četiri nove nijanse su izvedene iz
`ui_palette.gd`, dodaj ih tamo ako ih koristi još neko:

```gdscript
const SEED_WELL := Color("#22342A")   # livada #293D2E, 20 % tamnije
const RIM_EDGE := Color("#CBC2B6")    # warm white, 20 % tamnije
const GOLD_EDGE := Color("#D6A82F")   # coin gold, 20 % tamnije
const FLOWER_CORE := Color("#FFE8B8") # iz seed_clover.svg
```

### 2. Vertikalni budžet — 1597 px

| Sloj | y | h |
|---|---|---|
| `ArenaHud` | 0 | 120 |
| `HintLine` | 120 | **128 (fiksno, 2 reda)** |
| `Playfield` | 248 | 1133 |
| `DoneButton` | 1397 | 140 |
| zona `NavLockPill` | 1561 | 36 (24 px čisto) |

Naslov „Merge Arena" je **ukinut** (§3.3 #4) — tab u footeru već nosi tu
informaciju; +52 px ide polju.

`HintLine` mora biti fiksnih 128 px i kad je tekst jednoredni, inače HUD skače
(§3.3 #3). `ComboMeter` **pluta u Playfieldu** (gore desno), ne u HUD redu — iz
istog razloga.

### 3. Playfield — spawn ide na rešetku

**Ovo je glavni nalaz.** Na 1080 × 1133 s keepout zonama za vreću, Pipa, gnijezdo
i combo, ostaje **~40 legalnih pozicija** pri `CHIP_MIN_CENTER_DIST` (142,8 px).
Slučajni spawn (dart throwing) puca iznad ~22 sjemenke.

`ARENA_MAX_CHIPS` može ostati 30, ali spawn mora ići kroz
`UiArena.spawn_slots(count, rng)` — heksagonalna rešetka, korak 150 px / jitter
± 3,5 za > 24, korak 164 / ± 9 za ≤ 24 (organskije kad ima mjesta).

### 4. SeedChip — `arena_seed_chip.gd`

| Šta | Vrijednost |
|---|---|
| Prečnik · min. razmak centara | 134 px · 142,8 px (oba nepromijenjena) |
| T1 oblik · vidljiv cream | krug · rub 3 + band 11 = **14 px** |
| T2 oblik · vidljiv cream | r 38 · rub 3 + band 15 = **18 px** + unutrašnji prsten |
| Rim fill · rub | `#FFF8F0` · 3 px `#CBC2B6` |
| Well fill · rub | `#22342A` · 2 px `#16211B` |
| Cvijet | T1 78 px · T2 84 px |
| ★3 | rim `#FFD56B` + dashed `#D6A82F` |
| Sjena | offset (0, 6) · `#14201A` @ 42 % · **bez blura** |

`chip_well_inset(tier)` vraća inset uključujući border — ne sabiraj ga dvaput.

**Bez natpisa na sjemenki.** Tier nosi oblik i debljina rima, ★3 gold rim. Svaki
tekst koji staje na 134 px chip pada na ~18 px (≈ 6,5 sp) — ispod minimuma od
38 px iz §4.1, isti defekt koji §3.3 #5 prijavljuje za današnji `T2` natpis.

Stanja: `drag` scale 1,12 / rot −3° / sjena 18 · `pulse` prsten 6 px `#F2D940` ·
`partner` prsten 7 px `#FFD56B` + scale 1,04 · `merging` scale 1,28 ·
`eaten` scale 0,62 + alpha 40 % · `flying` scale 0,34.

### 5. SeedBag, Muncher, HUD

`SeedBag` — `BAG_SIZE` 214 × 178 (prazna 214 × 126), vrat 118 × 34,
hit-zona 280 × 250, brojač krug r 42. Pozicija x 540, 40 px iznad dna polja.
Stanja: prazna / 1 sjeme / otvorena (3 tipa vire) / izbacivanje (rot −12°) /
punch (scale 1,14).

`Muncher` — **56 → 104 px**. `ARENA_PEST_EAT_RADIUS` (36 px) je odvojen od
vizuelnog radiusa pa balans ostaje; samo pomjeri provjeru sudara na centar.
6 stanja, svako razlučivo **bez boje**: oči (otvorene 14 px / zatvorene 20 × 5),
ledena heksagonalna ljuska 140 px, `zzz`, gnijezdo 210 × 104.

`StashCounter` — **novi sloj**, gore desno, `get_garden_crystal_total()`.
Rješava §3.3 #10 („kristal nestane"): T3 kristal leti u njega 0,52 s, pa punch.

`DailyTask` — pill 76 px; završen ide `#A8E6CF` + precrtan tekst + kvačica.

`NeedMoreSeedsOverlay` — CTA „Back to Camp" 140 px umjesto zatvaranja na bilo
koji tap (§3.3 #11). Lista tipova pokazuje `n/4` po tipu.

## T3 trenutak — 0,74 s

1. **0,00** burst prsten 12 px `#FFF5D1`, 0,4 → 1,9 (0,22 s, cubic out)
2. **0,22** kristal kreće ka `StashCounter`, scale 1 → 0,45 (0,52 s, cubic in)
3. **0,74** `StashCounter` punch 1,0 → 1,16 → 1,0 (0,18 s, back)
4. paralelno: `MeadowBg` crossfade na bujniju varijantu (0,60 s)

Puna tabela od 19 animacija je u dizajn fajlu (sekcija „Tabela animacija").

## Pozadina

Dvije PNG teksture 1080 × 1133 (`meadow_base`, `meadow_lush`) + alpha crossfade
po broju T3 kristala (0 → 4). Ne proceduralno — livada je ambijent, ne UI.

## Tekstovi

Dizajn fajl ima tabelu **stari → novi** za 13 poruka. Kraće je čitljivije na
38 px; najduža nova je 55 znakova i staje u 2 reda. Primjer:
„Poured 12 seeds — drag matching ones together!" → „Poured 12 — drag matching
seeds together!"

## Otvoreno pitanje — outline cvijeta

`seeds-flowers-cd-brief.md` §2 propisuje outline „~20 % tamniji od fill-a,
2–4 px", ali jedini isporučeni asset `seed_clover.svg` koristi tvrdi
`#2D3436` @ 3,2 px / 80. Treba razriješiti **prije nego cvijeće za 7 preostalih
sezona krene u produkciju**. Ne blokira Arenu — smjer B radi pod obje konvencije.

Placeholderi u `flowers/` su isporučeni u obje verzije (`_hard` = tvrdi outline)
da se razlika vidi.

## Asseti za produkciju

| Fajl | Veličina |
|---|---|
| `seed_rim_t1.svg` / `_t2.svg` | 134 × 134 · krug / r 38 |
| `seed_rim_mythic_t1.svg` / `_t2.svg` | 134 × 134 · gold |
| `bag_body.svg` / `_empty.svg` | 214 × 178 / 214 × 126 |
| `bag_neck.svg` | 118 × 34 |
| `muncher_body.svg` | 104 × 104 · oči i usta kodom |
| `muncher_frost.svg` | 140 × 140 · heksagon |
| `muncher_nest.svg` | 210 × 104 |
| `meadow_base.png` / `meadow_lush.png` | 1080 × 1133 |
| `icon_crystal.svg` · `icon_target.svg` · `icon_check.svg` | 128 × 128 (u paketu) |

Kopiraj `icons/` u `game/assets/ui/arena/`, pa `scripts/godot-import.ps1`
i commituj `.import` fajlove (CLAUDE.md § Novi asset).

## Gotovo kad

- [ ] Done dugme puno vidljivo, 24 px čisto do `NavLockPill`
- [ ] 30 sjemenki na polju bez preklapanja (`spawn_slots`, ne random)
- [ ] HUD ne skače pri promjeni hinta ni pojavi comboa
- [ ] Sjemenka čitljiva na svih 8 `type_id` × T1/T2 × ★1–★3
- [ ] T1 vs T2 razlučivo na **grayscale** screenshotu
- [ ] Muncher razlučiv u svih 6 stanja bez boje
- [ ] T3 kristal vidljivo ide u `StashCounter`
- [ ] Overlay se zatvara samo preko „Back to Camp"
- [ ] Smoke: `merge_arena_smoke`, `arena_pest_smoke`, `arena_nav_lock_smoke`

## Van zadatka — nije u dizajnu

- **„Sort by type" dugme:** ne bih. Rešetkasti spawn već grupiše slično po
  redovima, a dugme koje preslaže polje ukida vrijednost magneta.
- **Dugi pritisak na sjemenku** → kratko osvijetli sve iste na polju. Pomaže kad
  je 30 na polju.
- **Muncher nosi ukradenu sjemenku 0,3 s** prije nego je pojede — daje igraču
  prozor da je „spasi" mergeom; pritisak postaje prilika.
- **StashCounter tap** → tooltip „spend in Camp", bez navigacije (zaključana je).
