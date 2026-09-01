---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, sjeme, journal, camp, scratch]
povezano:
  - ideje-seed-pool
  - ideje-seed-pool-catalog
  - ideje-seed-pool-pitanja
ai_sažetak: "SEED-01 B — Bloom album svi SeedCatalog tipovi; camp Trade/Exchange imena iz kataloga."
---

# IDEJE — SEED-01 journal + camp labele

> [[ideje-seed-pool|hub]] · freeze S7, S10.  
> **Kod:** **SEED-B ✅**. Ovisi o A. **Ne** pour red (C). **Ne** meadow.

## Journal

[`game_state.gd`](../../game/scripts/autoload/game_state.gd) `get_collection_journal_entries`: loop `SeedCatalog.all_type_ids()`, ne samo `CHAIN`. Ista stanja (locked / seen / album_t2 / album_t3), `discovered_blooms`, `collection_kept_tiers`.

[`collection_journal`](../../game/scenes/ui/collection_journal.tscn) / controller: mora **renderati** sve retke (scroll). Locked = silhouette. Grupiranje po sezoni **opcionalno**.

Ne paliti sve kao discovered. Unlock i dalje discovered/kept.

## Camp

Trade seed chip i Exchange flower: `SEED_DISPLAY_NAMES` / catalog `display_name`. Rarity za exchange rate već `get_seed_rarity` — mora raditi za nove id-eve (A).

Ne mijenjati take-count / coin rate formule osim lookup rarity.

## Smoke

Journal entries size >= Bloom 7 + ostali season tipovi (npr. ≥ 7+6*7 ako 7 non-bloom×6 — 4 free after bloom = 3×6, 4 paid×6). Broj = `all_type_ids().size()`. Camp layout i dalje Seeds/Flowers. Opcionalno: display_name frost_snowdrop ≠ "Frost_snowdrop" ako JSON ima display_name.

## Acceptance B

- Album nudi sve sezonske tipove (locked dok nisu seen).
- Camp pokazuje čitljiva imena. Exchange ne puca na novi type_id.
