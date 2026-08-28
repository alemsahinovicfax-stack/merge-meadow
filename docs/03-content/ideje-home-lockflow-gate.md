---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-lockflow
  - ideje-home-lockflow-pitanja
  - ideje-home-cardfit-gate
  - ideje-home-incard-gate
  - ideje-home-unlock-gate
ai_sažetak: "HOME-10 gate — locked free poster: ime sredina, Coins/Seeds 500/20 ispod, Unlock sivi pa zlatni; roster skriven; sequential prelazi na sljedeću; Lantern+Amber locked bez TEST_LOCK."
---

# IDEJE — HOME-10 locked-free kartica (ime + barovi + Unlock)

> [[ideje-home-lockflow|hub]]. Widget, parent, sequential `can_unlock_free`, Seeds = T3 i HIT-A **ostaju** iz [[ideje-home-cardfit-gate|HOME-09 gate]] / [[ideje-home-incard-gate|HOME-08]]. **Kod LOCKFLOW-A ✅.** Playtest korekcija layouta: [[ideje-home-barfit|HOME-11]] (spusti gate, skini okvir, debug 500c).

Ovo je **jednom za svagda** spec kako zaključane free sezone rade na Homeu. Nije poseban slučaj za Lantern. Nije poseban slučaj za Amber. Koja god free sezona trenutno bude `next_locked_free_id()` i stoji u hero-centru, **njen prozor** izgleda ovako.

## Poster (P115, P116)

Ime sezone ostaje **full-rect**, `horizontal_alignment` CENTER, `vertical_alignment` CENTER — CARDFIT-B / P107. **Ne** gurati naslov gore (P100 je playtest odbio).

Ispod imena, u **donjoj polovici** `CenterFill`, horizontalno **centrirano** (ne donji desni kut, override P110):

1. **Coins** — label `Coins  n / 500` + `ProgressBar` (`wallet_coins / def.coins_cost`).
2. **Seeds** — label `Seeds  n / 20` + `ProgressBar` (`t3_flower_count() / def.t3_flowers_required`). „Sjemena“ = bilo koji T3 u vrtu, ne seed bag (P86 / P98 / P126).
3. Gumb **Unlock** — `UiClickButton`. Sivi / `subtle` / `disabled` dok `not can_unlock_free`. **Zlatni** i klikabilan kad oba bara puna (P118).

```
        [ ime sezone — full-rect, H+V CENTER ]
                    ↓ donja polovica kartice
              [ Coins  n / 500  ]  bar
              [ Seeds  n / 20   ]  bar
                    [ Unlock ]
```

Gate panel: širi nego današnjih 220 px (barovi trebaju čitljivu širinu ~280–360), `z_index` ostaje 1, `mouse_filter` IGNORE osim gumba. Sidro npr. `anchor_left = 0.12`, `anchor_right = 0.88`, `anchor_top = 0.48`, `anchor_bottom = 1` + mali offset od dna — agent bira točne brojeve u A; **ne** `anchors_preset = 3` (desni kut).

`clip_contents` na `CenterSlot` ostaje. L/R i preview 20% **bez** gatea.

### Roster skriven dok je locked (P116)

Danas `_refresh_roster` postavlja `free_roster.visible = not paid_hero` — locked Lantern **pokazuje** 6 redova **i** gate. Playtest: dok je sezona zaključana, **nema** liste cvijeća. Lista je nagrada za Unlock — vidiš je kad sezona postane kao Bloom/Frost prije nje.

| Stanje hero-centra | CenterTitle | UnlockGate | FreeRoster |
|--------------------|-------------|------------|------------|
| Playable free (Bloom, Frost, …) | da, sredina | hidden | da |
| Next-lock free (Lantern, pa Amber, …) | da, sredina | da (barovi + gumb) | **hidden** |
| Further-lock (Amber dok je Lantern next) | ne u centru (bounce) | hidden | n/a |
| Paid-hero | PaidCenterTitle | hidden | PaidRoster |

Nakon `unlock_free`: gate `visible = false`, roster `apply_season` + `visible = true`. Igrač vidi cvijeće **te** sezone (Lantern: Dusk Firefly Grass … Midnight Lotus).

## Trošak 500 / 20 (P117)

„Za sada fiksno.“ Override per-season ljestvice iz SEZ-01 / HOME-07:

| Sezona | Danas (`seasons.json`) | HOME-10 |
|--------|------------------------|---------|
| Country Bloom | 0 / 0 (start) | 0 / 0 |
| Frost Orchard | 80 / 5 | **500 / 20** |
| Lantern Meadow | 150 / 8 | **500 / 20** |
| Amber Canopy | 220 / 12 | **500 / 20** |
| Paid (Moonlit, Coral, Starfall, Ember) | 0 / 0 + IAP | ne dirati |

Izvor i dalje [`seasons.json`](../../game/data/seasons/seasons.json) → `SeasonDef.coins_cost` / `t3_flowers_required`. Gate **ne** hardkodira 500/20 u labelama — čita def. Smoke smije assertati def == 500/20.

`can_unlock_free` već uspoređuje wallet i `t3_flower_count()` s def — samo se pragovi u JSON-u mijenjaju. Sequential `previous_free_id` ostaje (P120): ne otključaš Amber prije Lanterna čak i s 500c/20 T3.

20 T3 = **bilo koji** T3 u vrtu (suma kristala), ne 20 sjemena iz baga, ne 20 točno Lantern vrste.

## Stanja gumba (P118)

| Resursi | Izgled | Input |
|---------|--------|--------|
| `not can_unlock_free` (bilo koji bar nije pun) | `disabled`, `button_variant = "subtle"` (sivo) | `MOUSE_FILTER_IGNORE` — swipe prolazi |
| `can_unlock_free` (oba bara 500 i 20) | `disabled = false`, variant **gold** | `MOUSE_FILTER_STOP` — tap `unlock_free` |

Danas je „ispunjeno“ = `primary` (breskva `#FFB88C` iz [`ui_palette.gd`](../../game/scripts/visual/ui_palette.gd)). Playtest traži **zlato**. Na Amber kartici (`E8C48A` jantar) breskva/mint se topi u kartici. Zlato mora imati **kontrast**: tamni ink (`1A1A14` / `2D3436`) na zlatnom fillu, tanki tamni border. Ne cream tekst na svijetlom zlatu. Ne zeleni `primary`.

Novi `button_variant` `"gold"` u `UiClickButton` `@export_enum` + `UiPalette.button_style`. Hover/pressed: malo lighten/darken istog zlata. Disabled/subtle ostaje sivi (ne „ugaseno zlato“ — to izgleda kao da je već spreman).

`_ignore_hits` rekurzivno IGNORE-a djecu. `refresh_gate` **mora** vratiti STOP na gumb **nakon** svakog refresh/morph kad `can` — isti INCARD-B bug.

Tap → `unlock_free` (troši 500c, append, `active` + strip na tu sezonu, save) → `unlock_clicked` → Stage `refresh`: gate nestaje, roster te sezone, sljedeća locked free (Amber) je further dok je ne swipe-aš u centar.

## Tko vidi gate (P103 ostaje, brojevi novi)

Isti uvjeti kao HOME-09:

1. `home_band != "paid"`
2. `strip_center_id() == next_locked_free_id()`
3. `is_free_selectable(hero_id)` — **true** za Lantern i Amber kad su next (nisu TEST_LOCK)
4. `not is_season_playable(hero_id)`

| Save | Next-lock | Gate na | Trošak |
|------|-----------|---------|--------|
| Novi igrač (samo Bloom) | Frost | Frost prozor | 500 / 20 |
| Playtest fixture (Bloom+Frost, Lantern+Amber nisu u unlocked) | **Lantern** | Lantern prozor | 500 / 20 |
| Lantern upravo otključan | **Amber** | Amber prozor | 500 / 20 |
| Sve free playable | `""` | hidden | — |

**Ne vidi se:** playable centar; paid-hero; preview; L/R; further-lock (Amber dok je Lantern next — bounce, nema gatea na Amber).

Paid: Moonlit / Coral / Starfall / Ember **nema** ovog panela (P123/P124). Roster da (B). IAP ostaje Shop.

## Lantern + Amber locked, bez TEST_LOCK (P119, P127)

Playtest: „Napravi lantern meadow i amber canopy sezone zaključane.“

| | TEST_LOCK (`is_test_locked_season`) | Samo nisu u `unlocked_seasons` |
|--|-------------------------------------|--------------------------------|
| Swipe na next-lock | **bounce**, nikad u centru | **ulazi u centar**, gate se vidi |
| `can_unlock_free` | uvijek false | true s 500c/20 T3 + previous unlocked |
| HOME-09 lekcija | Amber TEST_LOCK = „Unlock nije napravljen“ | — |

Zato: **ne** vraćati `lantern_meadow` ni `amber_canopy` u `is_test_locked_season`. Ember **ostaje** paid TEST_LOCK (P124).

`debug_unlock_all_seasons` i dalje skipa `DEBUG_SKIP_FREE_ID` (lantern) **i** `DEBUG_SKIP_AMBER_ID` (amber) **i** Ember. Ne grantati ih.

Produkcijski `user://player_save.json` se **ne** briše slijepo. Ako je korisnikov save već grantao Lantern (stari playtest), Home neće pokazati Lantern kao locked — next je Amber ili ništa. LOCKFLOW-A smije u **debug/smoke** skinuti ta dva id-a iz `unlocked_seasons` (helper), da fixture bude: Bloom+Frost playable, Lantern next-lock, Amber further. Nije migracija SAVE_VERSION.

## Sequential — isti chrome prelazi dalje (P120)

Igrač otključa Lantern (500/20, zlatni Unlock). Gate nestaje. Roster Lanterna. Swipe desno na Amber: **isti** poster (ime Amber Canopy, Coins n/500, Seeds n/20, sivi ili zlatni Unlock). Nije hardkod `if season_id == lantern_meadow`. `refresh_gate(hero_id)` već radi za bilo koji next-lock — A samo mijenja layout, variant i vidljivost rostera.

Further ostaje bounce. Ne skačeš Amber prije Lanterna.

## Ember / paid (P124, P123)

Bez promjene Fair F2P. Ember Fen: TEST_LOCK, IAP, nema coin Unlock. Coral unowned: roster (B), nema gatea.

## Što ne dirati u LOCKFLOW-A

- Roster `anchor_right` / ellipsis / `FRAME_ALPHA` (B)
- Band 20/80, L/R in-place (osim što A već zove `refresh` nakon unlock)
- Shop Select, AdMob, SAVE_VERSION, `seed_type_ids`, 48 stubova
- `season_unlock_sheet` fallback; Stage i dalje ne otvara sheet za next-lock (P85)
- Naslov full-rect CENTER — ne dirati sidro naslova

## Tehnički (za LOCKFLOW-A, ne P0 kod)

- [`game/data/seasons/seasons.json`](../../game/data/seasons/seasons.json): Frost, Lantern, Amber → 500 / 20.
- [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd): layout preko tscn sidra; gold variant; i dalje čita def.
- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn): UnlockGate sidro donja polovica, centrirano; širi min size.
- [`season_stage.gd`](../../game/scripts/ui/season_stage.gd): `_refresh_roster` — `visible` false kad je gate vidljiv / kad hero nije playable next-lock.
- [`ui_palette.gd`](../../game/scripts/visual/ui_palette.gd) + [`ui_click_button.gd`](../../game/scripts/ui/ui_click_button.gd): `"gold"`.
- [`game_state.gd`](../../game/scripts/autoload/game_state.gd): **ne** dodavati lantern/amber u TEST_LOCK; debug skip ostaje; opcionalni debug-strip za smoke fixture.
- Smokes: Lantern next-lock; 499c ili 19 T3 → gumb sivi; 500/20 → gold + grant; nakon grant-a FreeRoster vidljiv na Lanternu, gate na Amber kad je Amber centar; Ember TEST_LOCK; Coral bez coin gatea. Stari asserti 150/8 i 220/12 **obrnuto**.
- Headless OpenGL. `godot-run.ps1` jednom na kraju A, ne watcher.

## Acceptance

- Fixture Bloom+Frost playable, Lantern+Amber nisu u unlocked: swipe na Lantern **ne** bounce; **Lantern Meadow** na sredini; **nema** liste cvijeća; ispod imena Coins `n / 500`, Seeds `n / 20`, Unlock sivi ako nema resursa.
- Bez 500c ili bez 20 T3: Unlock nije clickable; swipe L/R radi.
- S 500c i 20 T3: gumb **zlatni**, čitljiv na ljubičastoj Lantern kartici; tap grant-a Lantern; gate nestaje; roster Lanterna (Paper Lantern Bloom itd.); `active_season_id` lantern.
- Swipe na Amber: **isti** poster, 500/20, sivi dok nema (novih) 500/20; nije Bloom-crni kut dolje-desno.
- Paid Coral: roster (nakon B), **nema** Unlock.
- Ember: TEST_LOCK; nema coin Unlock; debug ga ne grant-a.
- Novi save (samo Bloom): Frost centar = isti chrome, 500/20.
