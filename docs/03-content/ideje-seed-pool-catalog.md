---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, sjeme, katalog, json, scratch]
povezano:
  - ideje-seed-pool
  - ideje-seed-pool-pitanja
  - ideje-sezone-data-model
ai_sažetak: "SEED-01 A — SeedCatalog + seasons.json seed_type_ids = roster merge id; Bloom 7 ostaje; season_run_smoke Frost ≠ clover."
---

# IDEJE — SEED-01 katalog (JSON + SeedCatalog)

> [[ideje-seed-pool|hub]] · freeze S1–S6, S12, S14–S16.  
> **Kod:** **SEED-A ✅**. **Ne** journal UI (B). **Ne** pour/draw fallback (C) osim što catalog API postoji za ime/rarity.

## JSON

[`seasons.json`](../../game/data/seasons/seasons.json):

- Bloom: `seed_type_ids` clover…watermelon **ostaje**. Roster id-evi **usklađeni** na te stringove (display_name smije ostati „Meadow Clover“).
- Frost, Lantern, Amber, Moonlit, Coral, Starfall, Ember: `seed_type_ids` = lista `roster[].id` u istom redoslijedu (6). Maknuti clover/daisy copy-paste.

`SeasonDef` već ima `seed_type_ids` + roster. A: loader smije napuniti catalog.

## SeedCatalog

Novi skript (ime po agentu):

- `all_type_ids() -> Array[String]` — sezone po `SeasonCatalog` redu, unutar sezone JSON red, unique (Bloom clover se ne duplicira ako neka sezona slučajno ostavi clover).
- `season_id_for(type_id) -> String`
- `display_name(type_id) -> String`
- `rarity(type_id) -> int`
- `types_for_season(season_id) -> Array[String]`

[`game_state.gd`](../../game/scripts/autoload/game_state.gd) `SEED_DISPLAY_NAMES` i `get_seed_rarity`: čitati katalog s fallback capitalize / rarity 1.

`get_active_season_spawn_types` već čita def — nakon JSON-a Frost više nije clover.

Unlock: `is_seed_type_unlocked` za Bloom CHAIN ostaje. Za tipove **van** CHAIN: unlocked ako je njihova sezona playable (S4). Ne širiti `seed_unlock_index`.

## Smoke

[`season_run_smoke.gd`](../../game/scripts/dev/season_run_smoke.gd): Frost pool **ne** smije biti identičan Bloom clover-daisy-buttercup ako JSON više nije to. Assert Frost sadrži `frost_snowdrop` (ili prvi roster id). Bloom i dalje clover.

Headless OpenGL. `godot-run.ps1` jednom na kraju A.

## Acceptance A

- Unique `type_id` po cvijetu; roster = spawn.
- Bloom CHAIN 7 netaknut.
- Frost run pool karakterističan.
- Nema SAVE_VERSION. Nema meadow UI.
