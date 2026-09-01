---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, sjeme, katalog, journal, arena, camp, scratch]
povezano:
  - ideje-seed-pool-pitanja
  - ideje-seed-pool-catalog
  - ideje-seed-pool-journal
  - ideje-seed-pool-draw
  - ideje-seed-pool-grupe
  - plan-prompts-seed-meadow
  - ideje-home-meadow
  - ideje-sezone
  - CHECKPOINT
ai_sažetak: "SEED-01 hub — jedan type_id namespace; seed_type_ids = merge tipovi sezone; journal svi tipovi; T1–T3 draw fallback; camp imena; CHAIN ostaje Bloom 7."
---

# IDEJE — Seed pool po sezoni (SEED-01 hub)

> **ID:** **SEED-01** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **SEED-A ✅ B ✅ C ✅**. Sljedeće [[../06-production/plan-prompts-seed-meadow|plan-prompts-seed-meadow]] korak **4 MEADOW-A**.  
> **Polje:** [[ideje-home-meadow|HOME-12]] čita ovaj katalog (MEADOW-B **nakon** A).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — paid pool = tema, ne jači magnet / loot.

## Pitch

Svaka sezona ima **svoja** sjemena u runu, na Home polju, u areni i u kampu. Journal (Bloom album) mora znati **sve** te tipove (locked silhouette → seen → T2/T3).

Danas to **laže**: [seasons.json](../../game/data/seasons/seasons.json) `roster[].id` (`frost_snowdrop`) nije merge tip. `seed_type_ids` Frost/Amber je `clover,daisy,buttercup`. Paid sezone kopiraju Bloom 7. Run (`get_active_season_spawn_types`) i journal (`SeedUnlockConfig.CHAIN`) žive u **Bloom** svijetu. `camp_plant_draw` matcha 7 imena — novi id padne na clover-like granu ili prazno.

Dva ID prostora = bag pri „promijeni sezonu“.

## Kanon

- **Jedan** `type_id` za merge T1→T2→T3, run spawn, arena chip, camp bag/trade, journal, meadow cvijet.
- Country Bloom **zadržava** `clover`…`watermelon` (CHAIN 7).
- Ostale sezone: `seed_type_ids` = postojeći `roster[].id` (6 po sezoni). Roster Home koristi **iste** id-eve.
- **SeedCatalog**: `all_type_ids()` stabilni red (sezone po katalogu, unutar sezone red JSON-a); `season_id_for`; `display_name`; `rarity`.
- `seed_unlock_index` / CHAIN **samo** Bloom. Nova sezona playable ⇒ njen pool smije spawnati. Journal i dalje silhouette dok nije discovered.
- T1/T2/T3 draw: paleta + **fallback** (hash + rarity shape). Arena i camp isti `draw_plant`.
- Journal: loop katalog, ne samo CHAIN.
- Camp Trade/Exchange: ime + rarity iz kataloga. Nema IAP za sjeme.
- Arena SORT pour red = katalog (tipovi u bagu), ne samo 7 CHAIN. Leftover/vacuum pravila **ne** dirati.
- **SAVE_VERSION:** ne.

Slice: [[ideje-seed-pool-catalog|A katalog]] · [[ideje-seed-pool-journal|B journal+camp]] · [[ideje-seed-pool-draw|C draw+pour]].

## Što SEED-01 **nije**

- HOME-12 overlay / Play dual / Pip (to je meadow).
- 8 plant scena. Novi merge_arena_controller.
- Shop season IAP, AdMob, Unlock 500/20, CAMP-01 spend formula.
- Gredice UI. Launch blocker.

## Agent

- „Frost spawna clover“, „album nema snowdrop“, „arena svi T1–T3“, „camp prodaja imena“ → **SEED-01**.
- Polje na Homeu → HOME-12.
- Ne spajati A/B/C. Ne spajati s MEADOW kodom u istom chatu.

## Povezano

- [[ideje-seed-pool-pitanja|S1–S16]] · [[../06-production/plan-prompts-seed-meadow|prompti]]
- [[ideje-sezone-data-model|SEZ data]] · [[ideje-home-meadow|HOME-12]]
