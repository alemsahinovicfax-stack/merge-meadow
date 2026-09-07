---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, sezone, meadow, basket, daily, scratch]
povezano:
  - ideje-home-meadow-dock
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-chrome-pitanja
  - plan-prompts-home-meadow-dock
  - CHECKPOINT
ai_sažetak: "HOME-15 pitanja P197–P214 — Basket T3/★3 picker; Basket ispod Daily; Seasons u PlayRow; Daily bez arena streaka. Override P165 P166 P184 P185 P173."
---

# IDEJE — HOME-15 pitanja (P197–P214)

> [[ideje-home-meadow-dock|hub]]. Freeze **2026-09-02**.  
> P1–P196 ostaju osim override tablice ispod. LIFE Play/Pip/count ostaju. Chrome tint/Endless/Basket-samo-u-polju ostaju.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P197** | Gdje je Basket u polju? | `%BasketCard` u `HomeTopStack` **ispod** `%DailyChestCard`, gore lijevo. Min size kao Daily (**336×104**). Karusel: Basket **hidden** (P164 ostaje). |
| **P198** | PlayRow u polju? | **Seasons \| Play \| Endless**, svi **320×96**, isti `size_flags_horizontal`. Karusel: samo Play, ista visina. Override P184 / P165. |
| **P199** | Tko zatvara polje umjesto chipa? | Novo PlayRow dijete `%SeasonsRowButton`, label **Seasons**. Tap → `close_season_field`. Vidljiv samo field open. Stari `%SeasonsButton` na SeasonField UniqueName **hidden**. |
| **P200** | Chip tap? | `%SeasonNameChip` samo ime; **ne** zatvara polje (`mouse_filter` IGNORE ili disconnect). Back/Escape i dalje close (P174). |
| **P201** | Picker red? | **T3 ikona iznad** imena (VBox: `CampPlantDraw.draw_fitted_plant(type_id, 3)`, pa ime + ★). |
| **P202** | ★3 / mythic u basketu? | **Da**, ako je u `SeedCatalog.types_for_season(field_id)` ∩ unlocked. `set_loadout` **ne** rejecta mythic za Home basket. Greenhouse u areni/kampu **ne** dirati. Override P166. |
| **P203** | Clear / Close? | Footer ispod scrolla: **Clear basket** pa **Close**, jedno iznad drugog. `%PickerList` samo cvijeće (Clear **nije** u listi). |
| **P204** | T3 match polje ↔ basket? | Isti `draw_fitted_plant(type_id, 3)` na BasketVisual, picker ikoni i meadow flower (`plant_tier = 3`). Count 12–14 ostaje. Override samo P185 T1/T2 mix. U `CampPlantDraw` T3 = crystal. |
| **P205** | Safe rect? | `meadow_safe_rect` chrome: Daily, **BasketCard**, Settings, chip, PlayRow (+ 8–16px). Pip FSM ne dirati. |
| **P206** | Daily streak na Homeu? | Caption samo **Tap to open** / **Back tomorrow**. Nema `get_arena_daily_home_line`. Tap **ne** zove `claim_arena_daily`. Arena HUD u merge areni ostaje. Save `arena_daily_*` **ne** brisati. |
| **P207** | Milestone / ne dirati? | **v1.1+**. Ne `SAVE_VERSION`. Ne Shop, AdMob, CAMP, Pip, Play routing, Endless Hard, SeedCatalog JSON, 8 tscn. |
| **P208** | Smoke A (picker sadržaj)? | Bloom picker: rarity-3 u listi ako je unlockan; svaki cvijet-red ima child Control za T3 draw **iznad** imena. |
| **P209** | Smoke A (footer)? | Clear **nije** dijete `%PickerList`. Clear i Close siblingovi u footer VBox; Close **ispod** Clear. |
| **P210** | Smoke B (T3 match)? | Meadow flowers `plant_tier == 3`; BasketVisual i dalje T3 `draw_fitted_plant`. Count 12–14. |
| **P211** | Smoke C (Basket pos)? | Field open: Basket `global` y ispod Daily; min size ~336×104; **nije** dijete PlayRow. Karusel: Basket hidden. |
| **P212** | Smoke C (Seasons / chip)? | Field open: `%SeasonsRowButton` visible; emit clicked → field close. Chip clicked **ne** close. Karusel: Seasons hidden. `%SeasonsButton` (SeasonField) i dalje hidden. |
| **P213** | Smoke C (PlayRow)? | Field open: Seasons, Play, Endless ista `custom_minimum_size` (320×96). `_assert_play_row_equal` **ne** koristi BasketCard. |
| **P214** | Smoke D (Daily)? | Caption bez "Arena streak" / "Arena daily". `claim_daily_chest` **ne** bumpa `arena_daily_streak`. `arena_daily_smoke` u areni ostaje. |

## Override mapa (HOME-13 / HOME-14)

| Staro | HOME-15 |
|-------|---------|
| P165 Basket lijevo od Play | P197 ispod Daily |
| P184 PlayRow = Basket/Play/Endless | P198 Seasons/Play/Endless |
| P166 picker bez mythic | P202 ★3 smije |
| P185 T1/T2 mix | P204 T3 draw (count ostaje) |
| P186 safe bez BasketCard | P205 + BasketCard |
| P173 / CHROME-E chip tap = close | P200 chip display-only; P199 Seasons close |
| Daily caption + arena line / claim | P206 samo gift |

## Ostaje iz HOME-12 / 13 / 14

P137–P143 open field. P146 session. P153 jedan Field. P161–P163 tint. P164 Basket nije na karuselu. P169–P172 Endless u polju. P174 Back/Escape close. P179–P183 Play 3-koraka. P187–P189 Pip. P185 count 12–14.

## Nije otvoreno

- Chevron umjesto chipa. Easy Endless. Merge na polju. IAP na ulaz. 8 tscn. Brisanje arena daily iz savea.

## Povezano

- [[ideje-home-meadow-chrome-pitanja|P159–P178]] · [[ideje-home-meadow-life-pitanja|P179–P196]]
- [[../06-production/plan-prompts-home-meadow-dock|prompti]]
