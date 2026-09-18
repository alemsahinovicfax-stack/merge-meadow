# Handoff: Camp

Dizajn iz Claude Designa za prenos u `camp_scene.tscn`. Prati
`docs/04-experience/design-drafts/camp-cd-brief.md`.

Pretpostavlja da su **hub chrome i Arena već preneseni**
(`design_handoff_hub_chrome/`, `design_handoff_merge_arena/`) — Camp se
uklapa u **1597 px** između headera (143) i footera (180).

## Šta je ovo

**Fidelity: hi-fi za layout i stanja, placeholder za art.** Mjere, boje,
radiusi, fontovi i sva stanja su finalni u bazi 1080×1920. Cvijeće je
**placeholder** — oblik i veličina su spec, crtež nije.

Odabran je **smjer 1b — tabovi + hero sezona**:

| | 1a police | **1b tabovi** |
|---|---|---|
| Trade barova | 2 | **1** |
| Chipova vidljivo | 4 + 4 | **8** |
| 20+ tipova | scroll u 366 px | **4 reda, broj na tabu** |
| Sezona | strip 157 px na dnu | **hero 422 px na vrhu** |
| Tap do Flowers | 0 | 1 |

Jedan Trade bar znači da se pravila (tap = 1, držanje = 10/s, stop na
granici) uče **jednom**, a ne dva puta na dva dugmeta. Sezona na vrhu je
ono zbog čega se trguje — „Camp te zove nazad" (Pillar 3) je prvo što se
vidi. Cijena: jedan tap do Flowers, i tabovi moraju nositi broj tipova.

**HTML je referenca, ne kod za kopiranje.** Gradi se postojećim obrascima:
`StyleBoxFlat`, `UiClickButton`, `ui_palette.gd`. Bez shadera, gradijenata
i blura; sjena samo kao `StyleBoxFlat` shadow.

## Sadržaj paketa

| Fajl | Šta je | Gdje ide |
|------|--------|----------|
| `ui_camp.gd` | **Paste-ready.** Boje, vertikalni budžet, mjere, `section_style()`, `chip_style()`, `reserved_badge_style()`, `trade_button_style()`, `tab_style()`, `season_card_style()`. | `game/scripts/visual/` |
| `icons/` | `icon_merge_arrow.svg`, `icon_reserved.svg`, `icon_hold_stop.svg` — 128×128, `#2D3436`, tint kodom preko `modulate`. | `game/assets/ui/camp/` |
| `flowers/` | 8 placeholder rozeta. **Nisu za produkciju** — referenca za veličinu i kontrast, iste kao u Arena paketu. | — |
| `Camp Redesign.dc.html` | Svi artboardi: oba smjera, odluke (Turn 2), storyboard stopa držanja. | — |
| `Camp States.dc.html` | 8 stanja ekrana: prazna vreća, prazan stash, 20 tipova, 1 tip, sve sezone otključane, stop držanja. | — |
| `Camp Specs.dc.html` | Spec sheet chipa, 7 Trade stanja, sezona (3 kadra × 3 tinta), tabela animacija, asseti. | — |
| `CampScreen.dc.html` | Parametrizovan ekran (smjer, tab, set podataka, stanje Tradea, sezona). | — |
| `CampChip.dc.html` | Parametrizovan chip (tip, rarity, stanje, rezervisan, na granici). | — |
| `TradeBar.dc.html` · `SeasonLink.dc.html` | Parametrizovane komponente koje `CampScreen` uvozi. | — |
| `HubScreen.dc.html` · `support.js` | Kopija hub chromea (nije mijenjana) i runtime za `.dc.html`. | — |

## Prenos — 6 koraka

### 1. `ui_camp.gd`

Kopiraj u `game/scripts/visual/`. Nove nijanse su izvedene iz
`ui_palette.gd` — dodaj ih tamo ako ih zatraži još neki ekran:

```gdscript
const COIN_GOLD := Color("#FFD56B")       # novčić, isti kao u headeru
const GOLD_EDGE := Color("#D6A82F")       # COIN_GOLD, 20 % tamnije
const RIM_EDGE := Color("#CBC2B6")        # WARM_WHITE, 20 % tamnije
const WELL := Color("#22342A")            # livada #293D2E, 20 % tamnije
const SUB_INK := Color("#555C5E")         # UI_TEXT posvijetljen do 6,5:1 na krem
const SEASON_INK := Color("#3D3D33")      # DARK_INK posvijetljen, 7,3:1 na tintu
const HOLD_FREEZE := Color("#FFDCC2")     # PEACH desaturisan za zamrznut fill
```

### 2. Vertikalni budžet — 1597 px

| Sloj | y | h |
|---|---|---|
| `CampPage` padding | 0 | 24 |
| `SeasonLink` (hero) | 24 | **422** |
| rastojanje (`space-between`) | 446 | 223 (min 20) |
| `StashSection` | 669 | **904** |
| `CampPage` padding | 1573 | 24 |

Zbir: 24 + 422 + 223 + 904 + 24 = **1597**.

Sekcija (904) iznutra: padding 18 · `StashTabs` 132 · gap 14 ·
`ChipGrid` 556 · gap 14 · `TradeBar` 152 · padding 18.

**Sekcija se mijenja sa stanjem, hero nikad:**

| Stanje | TradeBar | ChipGrid | Sekcija |
|---|---|---|---|
| normalno (6 tipova) | 152 | 556 (3 reda) | 904 |
| 20 tipova | 152 | 746 (4 reda, max) | 1094 |
| rezervisano u listi | 152 | 434 (176 + kept 244) | 782 |
| **stop držanja / upozorenje** | **224** | 434 | 854 |
| prazna lista | 152 | — (blok 400) | 748 |

`ChipGrid` se pakuje po **stvarnoj** visini redova (kept-chip je 244, ne
176) i reže se na broj redova koji staje — nikad ne prelazi u Trade bar.
Gornja granica grida: 1597 − 48 − 20 − 422 − 36 − 132 − 28 − TradeBar.

### 3. Slojevi → Godot node (§7 briefa → §10 briefa)

| Sloj (`data-layer`) | Node / fajl | Vrijednost |
|---|---|---|
| `CampScreen` | `camp_scene.tscn` → `Content` | 1080 × 1920, `MeadowBg` `#2E4733` |
| `CampPage` | `%CampPage` | padding 24, bez pozadine |
| `StashSection` | `%GardenCard` (preimenovati) | 1032 × 904 · r 26 · fill `WARM_WHITE` · border 2 `OUTLINE` · shadow (0, 8) `#14201A` @ 26 % |
| `StashTabs` | **novo** `%StashTabs` | h 132 · gap 14 · 387 + 387 + 190 |
| `TabActive` | `UiClickButton` | fill `PEACH` · border 4 `PEACH_EDGE` · r 20 |
| `TabInactive` | `UiClickButton` | fill `UI_TEXT` @ 6 % · border 2 `UI_TEXT` @ 18 % · r 20 |
| tab ikona | `TextureRect` | okvir 84 · r 50 % (seed) / 22 (flower) · fill `WARM_WHITE` / `GOLD` · border 3 `RIM_EDGE` / `GOLD_EDGE` · ikona 48 |
| tab brojač | `Label` + panel | h 72 · min w 96 · r 16 · font 46 |
| `ArenaShortcut` | **novo** `%MergeShortcut` (`UiClickButton`) | 190 × 132 · r 20 · fill `MINT` · border 3 `#7FC9AC` · font 40 |
| `ChipGrid` | `%SeedBagGrid` / `%CrystalGrid` u `%StashScroll` | 2 kolone · gap 14 · chip 489 |
| `SeedChip` / `FlowerChip` | `camp_stash_chip.gd` (novi, jedan za oba) | 489 × 176 (rezervisan 244) · r 20 |
| `ArtFrame` + `ArtWell` | isti obrazac kao Arena | 104 · r 50 % / 26 · well inset 10 · border 2 `WELL_EDGE` |
| `RarityPips` | `Label` | ★ 32 px, `UI_TEXT` |
| `CountPill` | panel + `Label` | h 62 · r 14 · fill `WARM_WHITE` @ 70 % · ikona 32 · font 48 |
| `PricePill` | panel + `Label` | h 62 · r 14 · fill `PRICE_BG` · border 2 `GOLD_EDGE` · novčić 34 · font 46 · „each" 30 |
| `ReservedBadge` | **novo** u chipu | h 56 · r 14 · fill tint sezone · border 2 tint edge · lock 32 · font 38 |
| `SelectMark` | `Panel` overlay | inset 0 · border 4 `UI_TEXT` @ 55 % · r 15 |
| `TradeBar` | `%ExchangeBar` | 992 × 152 (224 sa stripom) · r 20 · fill `WARM_WHITE` · border 2 `OUTLINE` |
| `TradeButton` + `HoldFill` | `%ExchangeButton` (`UiClickButton`, auto_repeat 10/s) | 430 × 120 · r 20 · fill `PEACH` · border 3 `PEACH_EDGE` |
| `TradeFeedback` | **novo**, gornji desni ugao bara | h 58 · r 16 · fill `COIN_GOLD` · border 3 `GOLD_EDGE` · offset (−16, −20) |
| `ReservedWarning` | **novo** | h 60 · r 14 · fill `PRICE_BG` (stop) / `MOUTH` (prodaja rezervisanog) |
| `SeasonLink` | `%SeasonLinkCard` | 1032 × 422 · r 26 · fill tint · border 3 tint edge |
| `CoinProgress` / `FlowerProgress` | `SeasonUnlockProgress` | bar h 18 · r 9 · fill `COIN_GOLD` / `WARM_WHITE` · podloga `DARK_INK` @ 20 % |
| `UnlockButton` | `UiClickButton` | 992 × 132 · r 20 · spremno `GOLD` + border 3 `GOLD_INK` |
| `EmptyState` | **novo** | blok 400 · art 110 (dashed 4) · naslov 48 · tekst 36 · CTA 110 `MINT` |
| `ScrollHint` | **novo**, samo u 1a | h 62 · r 16 · fill `UI_TEXT` @ 88 % · font 36 |

### 4. Horizontalni lanac — 1080 px

**Sekcija:** 24 (padding) + 2 (border) + 18 + **992** + 18 + 2 + 24 = 1080

**Red tabova (992):** 387 + 14 + 387 + 14 + **190** (`Merge ↗`) = 992

**Red chipova (992):** 489 + 14 + 489 = 992

**Chip iznutra (489):** 2 + 14 + **104** (art) + 14 + **343** (tijelo) + 14 + 2 = 489
— tijelo: ime/★ (flex) · `ReservedBadge` · pill red 128 + 10 + 205 = 343

**Trade bar (992):** 2 + 16 + **88** (art) + 18 + **406** (info) + 18 + **430** (dugme) + 16 + 2 = 992

### 5. Tabele stanja

**Chip** — `chip_style(state, rarity)`:

| Stanje | fill | border | pomak |
|---|---|---|---|
| neodabran | `RARITY_BG_1..3` | 2 px rarity edge | 0 |
| odabran | rarity + 14 % bijelo | **5 px `PEACH`** | y −3, shadow 10 |
| pritisnut | rarity × 0,92 | 5 px `PEACH` | 0, shadow 3 |
| rezervisan | isti kao gore | isti | + `ReservedBadge`, h **244** |
| na granici | isti | isti | badge `PRICE_BG` + 3 px `GOLD_EDGE`, tekst „Hold stops here" |
| nema zaliha | `RARITY_BG_LOCKED` | 2 px `#B6B6B2` | ink `#5C5C58` |

**Trade** — `trade_button_style(state)`:

| Stanje | dugme | dodatno |
|---|---|---|
| mirno | `PEACH` · „Trade / hold 10 / s" | — |
| tap | `PEACH` · scale 0,97 | `+N` pop → header |
| držanje | `PEACH_EDGE` + `HoldFill` `PEACH` | pop broji zbirno |
| auto prelaz | `PEACH` | mint plata iza novog imena |
| **stop na granici** | `#FFF3E6` · „Tap to sell 1 / no hold for this one" | strip `PRICE_BG`, fill zamrznut u `HOLD_FREEZE` |
| prodaja rezervisanog | `PEACH` · „sells reserved" | strip `MOUTH` |
| disabled | `UI_TEXT` @ 10 % · „nothing to trade" | bar ostaje, ne nestaje |

**SeasonLink** — `unlock_button_style(state)`:

| Stanje | dugme | tekst |
|---|---|---|
| nedovoljno | `WARM_WHITE` @ 55 % · border `DARK_INK` @ 30 % | „needs 180 more coins and 8 more flowers" |
| spremno | `GOLD` · border 3 `GOLD_INK` | „Unlock Frost Orchard / spends 500 coins and 20 flowers" |
| otključavanje | `COIN_GOLD` | prsten 520 px `#FFF5D1` @ 55 %, prošlo vrijeme |

**Prazna stanja:** vreća („Your bag is empty" → `Play a run ↗`), stash
(„No flowers yet" → `Merge in Arena ↗`). Trade bar ide `disabled`,
**ne nestaje**. Tab i dalje pokazuje `0`.

**20+ tipova:** grid 4 reda (8 chipova), broj tipova je na tabu, lista
se skrola dragom. Najduže testirano ime: `Paper Lantern Bloom` (ellipsis).

### 6. Smoke testovi

| Test | Šta se mijenja |
|---|---|
| `camp_layout_smoke` | jedna lista i jedan Trade bar umjesto dvije kartice; provjera 1597 px budžeta po stanjima iz koraka 2 |
| `camp_trade_*` | jedno `%ExchangeButton`; kursevi nepromijenjeni |
| `camp_hold_floor_smoke` | **novi** — drži Trade na ★3 tipu na granici: repeat mora stati, tap mora dalje raditi |
| `camp_season_unlock_smoke` | `SeasonLink` je sada 422 px hero, ne strip |

## Pravilo: rezervisano ★3 cvijeće

Sezona traži `t3_flowers_required` komada jednog ★3 tipa
(`GameState.star3_type_id_for_season(next)`, broj
`GameState.star3_flower_count_for_unlock(next)` — npr. **20 Harvest
Pumpkina za Frost Orchard**). Taj broj je **granica**, ne blokada.

**Šta radi:**

1. Iznad granice — pravilo je nevidljivo. Držanje ide 10/s, chip nosi
   `Kept · 12 / 20` u tintu sezone.
2. Kad bi **sljedeći** auto-tik odveo tip **ispod** granice, držanje
   **samo stane**. Igrač vidi: amber strip `Hold stopped · Frost Orchard
   keeps 20 of these`, fill zamrznut tamo gdje je stao, dugme postaje
   `Tap to sell 1 / no hold for this one`, badge na chipu prelazi u amber
   `Hold stops here`. Novčići zarađeni do tog trenutka ostaju.
3. Ispod granice — **pojedinačni tap prodaje dalje**, strip ponavlja
   koliko sezoni treba. Držanje ostaje isključeno za taj tip dok se broj
   ne vrati iznad granice.

**Bez dijaloga za potvrdu i bez blokade.** Auto prelaz radi dalje na
tipovima koji nisu na granici; držanje se prekida samo kad je tip na
granici i nema drugog odabranog tipa za nastavak.

U kodu: jedan guard prije svakog auto-tika u repeat-u razmjene. Pojedinačni
tap ide **postojećom** putanjom, netaknut. Chip: jedan bool `at_floor`
mijenja `ReservedBadge` (isti node, ne drugi).

## Tabela animacija

| Šta | Trajanje | Easing | Redoslijed |
|---|---|---|---|
| Odabir chipa | 120 ms | cubic out | border 2 → 5 `PEACH`, fill +14 %, y −3; prethodni chip se vraća u istih 120 ms |
| Pritisak chipa | 80 ms | linear | fill ×0,92, pomak pušten; na otpuštanje → odabran |
| Trade tap pop | 90 ms + 260 ms | out → in | `+N` scale 0,7 → 1, pa let do coin chipa u headeru, alpha 0 u zadnjih 80 ms |
| Držanje fill | kontinuirano | linear | širina prati 10/s; reset na 0 u 140 ms na otpuštanje |
| Auto prelaz | 200 ms | cubic out | mint plata fade in, 600 ms pauza, fade out; art i cijena crossfade 120 ms |
| **Stop držanja** | **140 ms** | cubic out | repeat stop → fill se zamrzne i pređe u `HOLD_FREEZE` → strip slide 60 px → tekst dugmeta crossfade → badge chipa u amber (sve u istih 140 ms) |
| Promjena taba | 160 ms | cubic out | lista crossfade + slide 24 px; tab fill i border u `PEACH` |
| Unlock burst | 420 ms | cubic out | prsten 520 px scale 0,2 → 1 @ 55 %, fade; dugme `GOLD` → `COIN_GOLD` u 200 ms |

## Tekstovi — staro → novo (EN)

| Staro | Novo |
|---|---|
| — (nema opisa liste) | `Arena fuel` · `reward` (ispod naslova taba) |
| `Exchange` | `Trade` |
| — | `hold 10 / s` (podnaslov dugmeta) |
| — | `N each` (uz cijenu na chipu) |
| — | `Kept · 12 / 20` |
| — | `Hold stops here` |
| — | `Hold stopped · Frost Orchard keeps 20 of these` |
| — | `Tap to sell 1` · `no hold for this one` |
| — | `Frost Orchard needs 8 more of these` |
| — | `Your bag is empty` + `Play a run ↗` |
| — | `No flowers yet` + `Merge in Arena ↗` |
| — | `Merge ↗` |
| — | `6 types` (samo 1a) |
| `Season` | `Next free season` + ime sezone |
| — | `needs 180 more coins and 8 more flowers` |
| — | `Unlock Frost Orchard` · `spends 500 coins and 20 flowers` |
| — | `nothing to trade` · `pick a type to trade` |

## Kontrast — provjereno

Sav sekundarni tekst je **pun ton**, ne alpha — alpha na krem podlozi pada
ispod 4,5:1 (§4.1). Izmjereno na finalnom dizajnu, **0 padova**:

| Šta | Prema | Ratio |
|---|---|---|
| UI_TEXT #2D3436 | WARM_WHITE #FFF8F0 | **12,0:1** |
| SUB_INK #555C5E | WARM_WHITE #FFF8F0 | **6,5:1** |
| TAB_INK #4A5153 | WARM_WHITE #FFF8F0 | **7,7:1** |
| UI_TEXT #2D3436 | PEACH #FFB88C | **7,5:1** |
| UI_TEXT #2D3436 | MINT #A8E6CF | **9,0:1** |
| DARK_INK #1A1A14 | PRICE_BG #FFE8B8 | **14,6:1** |
| DARK_INK #1A1A14 | FROST #C5D5E8 | **11,7:1** |
| SEASON_INK #3D3D33 | FROST #C5D5E8 | **7,3:1** |
| SEASON_INK_DIM #44443A | Unlock (nedovoljno) | **8,0:1** |
| DISABLED_INK #5C5C58 | RARITY_BG_LOCKED #E4E4E0 | **5,3:1** |
| WARM_WHITE #FFF8F0 | ScrollHint #3F4547 | **9,3:1** |

Najmanji tekst: „each" i ★ na 30–32 px, sve ostalo 36–52 px — iznad
minimuma od 24 px (§4.1). Dodirne zone: Trade i Unlock 120 px, chip 176,
tab 132, `Merge ↗` 132, empty CTA 110.

## Asseti za produkciju

| Fajl | Veličina |
|---|---|
| `icon_merge_arrow.svg` | 128 × 128 (u paketu) |
| `icon_reserved.svg` | 128 × 128 (u paketu) |
| `icon_hold_stop.svg` | 128 × 128 (u paketu) |
| `icon_seed.svg` · `icon_coin.svg` · `icon_lock.svg` | 128 × 128 — **već u hub paketu** |
| `icon_crystal.svg` | 128 × 128 — **već u Arena paketu** |
| `chip_frame_seed.svg` / `chip_frame_flower.svg` | 104 × 104 · krug / r 26 (opciono — može `StyleBoxFlat`) |
| `ph_*.svg` (8) | placeholder cvijeće, **nije za produkciju** |

Kopiraj `icons/` u `game/assets/ui/camp/`, pa `scripts/godot-import.ps1`
i commituj `.import` fajlove (CLAUDE.md § Novi asset).

## Gotovo kad

- [ ] Vertikalni budžet se zatvara na 1597 px u **svim** stanjima iz koraka 2
- [ ] Trade bar nikad nije odsječen — ni sa stripom (224 px)
- [ ] 8 chipova vidljivo na 6 tipova; 20 tipova daje 4 reda i broj na tabu
- [ ] Seed i flower chip razlučivi na **grayscale** screenshotu (oblik rima, ne boja)
- [ ] Rarity čitljiva bez boje (★☆☆ / ★★☆ / ★★★)
- [ ] `Kept · N / M` vidljiv prije prodaje, ne poslije
- [ ] Držanje staje na granici, tap prodaje dalje, novčići do tada ostaju
- [ ] Prazna vreća i prazan stash imaju CTA koji staje u panel
- [ ] `Merge ↗` vodi na Arena tab
- [ ] Nijedan tekst ne skraćuje se ellipsisom osim imena tipa
- [ ] Smoke: `camp_layout_smoke`, `camp_trade_*`, `camp_season_unlock_smoke`, **novi** `camp_hold_floor_smoke`

## Van zadatka — nije u dizajnu

- **Sell all** — ne sada (tvoja odluka). Kad zatreba: ide u Trade bar kao
  drugo dugme, ne u naslov, i mora poštovati istu granicu.
- **Sortiranje** — ne sada. Redoslijed je danas rarity pa ime; to je
  predvidivo i ne treba kontrolu.
- **„keep N" po tipu** — ne sada. Granica sezone već radi taj posao
  automatski, bez UI-ja.
- **Dugi pritisak na chip** → tooltip s punim imenom kad je skraćeno.
  Nije dizajnirano, rješava jedini ellipsis u paketu.
- **Tap na `SeasonLink`** → Home (bez trošenja). Nacrtano kao `Details ↗`
  u hero kartici.

## Ostalo otvoreno

1. **Ime sezone na chipu.** Badge nosi `Kept · 12 / 20` bez imena sezone —
   na 343 px tijela chipa ime ne staje bez skraćivanja. Ime nosi Trade
   upozorenje i hero kartica. Ako želiš ime i na chipu, treba mu drugi red
   (chip 244 → 300) ili font 30 px.
2. **Prelaz kad se granica podigne.** Kad se sezona otključa, sljedeća
   sezona traži drugi ★3 tip — badge treba animirati prelaz s jednog tipa
   na drugi. Nije nacrtano (zavisi od redoslijeda sezona).
3. **`ScrollHint` u 1b.** Broj tipova je na tabu, pa hint ne postoji; ako
   lista ikad dobije više od 4 reda, treba mu mjesto (72 px u gridu).
4. **Outline cvijeta** — otvoreno pitanje iz Arena paketa, nepromijenjeno.
   Ne blokira Camp; chip radi pod obje konvencije.
