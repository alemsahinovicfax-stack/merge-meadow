---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, sjeme, arena, draw, scratch]
povezano:
  - ideje-seed-pool
  - ideje-seed-pool-catalog
  - ideje-seed-pool-pitanja
ai_sažetak: "SEED-01 C — camp_plant_draw T1–T3 fallback za svaki type_id; SORT pour red SeedCatalog, ne samo CHAIN."
---

# IDEJE — SEED-01 draw + arena pour

> [[ideje-seed-pool|hub]] · freeze S8, S9, S11.  
> **Kod:** **SEED-C ✅**. Ovisi o A. **Ne** leftover/vacuum. **Ne** meadow.

## Draw

[`seed_visual_config.gd`](../../game/scripts/visual/seed_visual_config.gd) `palette(type_id)`: poznati Bloom 7 ostaju; inače **deterministički** fallback (hash HSV iz id-a, crystal/petal/seed).  

[`camp_plant_draw.gd`](../../game/scripts/visual/camp_plant_draw.gd): `match` 7 ostaje; `_` default = rarity shape (sprout/bloom/crystal) + fallback paleta. **Nikad** crta clover geometriju za `frost_snowdrop`.

Arena [`arena_seed_chip.gd`](../../game/scripts/camp/arena_seed_chip.gd) već zove plant draw — ne fork.

T1, T2, T3 **sva** moraju nešto nacrtati za svaki catalog id.

## Pour

ARENA-03 `_build_arena_pour_queue` (ili ekvivalent) redoslijed tipova: `SeedCatalog.all_type_ids()`, filtriraj one s T1 u bagu. Ne `for type in CHAIN` samo 7.

Ne dirati: vacuum prag, leftover T2→2 T1, overlay n/4, FLOW-A.

## Smoke

Headless: `palette("frost_snowdrop")` ≠ `palette("clover")` (ili draw fallback path). Pour queue s bagom `{frost_snowdrop: 4, clover: 4}` uključuje **oba** redoslijedom kataloga. `arena_sort` / postojeći pour smoke: Bloom 7 i dalje prolazi; proširiti ili novi `seed_catalog_smoke.gd`.

Ne GUI usred C. `godot-run.ps1` jednom na kraju.

## Acceptance C

- Arena i camp T1–T3 izgledaju po tipu (nije sve clover).
- Pour ne gubi non-CHAIN tipove u bagu.
- Leftover/vacuum netaknuti.
