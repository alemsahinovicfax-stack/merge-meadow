---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, tehnicko, data-model, scratch]
povezano:
  - ideje-sezone
  - ideje-sezone-ux-home
  - ideje-sezone-ekonomija
  - ideje-sezone-pitanja
ai_sažetak: "SEZ-01 data model — SeasonDef JSON + GameState polja; B–E implementirano (paid IAP stub)."
---

# IDEJE — Sezone data model + implementacijski skeleton

> [[ideje-sezone|SEZ-01]]. **B–E implementirano** — katalog `res://data/seasons/seasons.json`; Shop/Browser paid IAP stub.

## SeasonDef (katalog)

Izvor: **`res://data/seasons/seasons.json`** + `SeasonDef` / `SeasonCatalog` (`game/scripts/seasons/`).

| Field | Type | Notes |
|-------|------|-------|
| `id` | String | `country_bloom` |
| `kind` | enum | `free` / `paid` |
| `order` | int | free only; paid 0 ili -1 |
| `display_name` | String | |
| `tagline` | String | |
| `coins_cost` | int | free unlock |
| `t3_flowers_required` | int | free unlock |
| `iap_product_id` | String | paid only |
| `seed_type_ids` | Array[String] | spawn / almanac pool |
| `thumbnail_path` | String | |
| `run_bg_path` | String | |
| `animal_skin_id` | String | |
| `obstacle_theme_id` | String | |
| `clear_rabbit_id` | String | |

## GameState (runtime + save)

| Field | Type | Notes |
|-------|------|-------|
| `active_season_id` | String | default `country_bloom` |
| `unlocked_seasons` | Array[String] | includes S1 |
| `owned_paid_seasons` | Array[String] | IAP |
| Helpers | | `is_season_unlocked`, `can_unlock_free`, `unlock_free`, `set_active_season`, `get_season_def` |

### Save

- Bump `SAVE_VERSION` kad se uvede.
- Migracija: stari save → `unlocked_seasons = [country_bloom]`, `active = country_bloom`, paid empty.
- Ne spremati run-in-progress vezan uz sezonu osim ako već postoji pattern.

## Spawn / run wiring (kasnije)

```
Play pressed
  → read active_season_id
  → SeasonDef.seed_type_ids ∩ unlocked seeds  ✅ SEZ-D
  → apply BG / obstacle tint (placeholder)  ✅ SEZ-D
  → start run_scene (shared levels)
```

Almanac unlock thresholds mogu biti **per-season** ili globalni remap — TBD.

## UI wiring (kasnije)

| UI | Fajlovi (danas) | Posao |
|----|-----------------|-------|
| Home Stage | `main_menu.tscn` / `main_menu.gd` | Stage + teaser + swipe |
| Browser | novi `season_browser.gd` + scene | Modal |
| Shop packs | `shop_screen.gd` | Rows + IAP |
| IAP | `iap_manager.gd` | non-consumable season products |
| Camp | — | opcionalno badge aktivne sezone |

Gesture: Stage swipe vs hub `SwipePager` — izolacija inputa (sub-rect / accept_event).

## Build order — plan za plan (Faze A–E)

| Faza | Što | Ishod |
|------|-----|-------|
| **A** | Docs locked + odgovori na pitanja | Design freeze slice |
| **B** | SeasonDef data + GameState + save migrate | ✅ Headless: `season_unlock_smoke` |
| **C** | Home Stage + Browser free lane | ✅ `season_home_smoke` |
| **D** | Run theme hook (BG + seed pool min) | ✅ `season_run_smoke` |
| **E** | Paid IAP + Shop + Browser paid row | ✅ Buy → own → select (`season_iap_smoke`) |

Ne raditi E prije B/C. Ne raditi full art za S2–S3 prije A.

## Test / smoke (kad kod)

- New game → only S1 unlocked, active S1
- Unlock S2 with mocked coins+T3
- Cannot unlock S3 before S2
- Paid own without free S2 (ako odluka dozvoli)
- Save/load active + unlocked
- Hub page swipe still works with Stage present

## Rizici

| Rizik | Note |
|-------|------|
| Scope creep art | 1 season ship-quality first |
| Seed ID explosion | Prefer theme remap early |
| Gesture conflicts | Prototype Stage isolation early in C |
| IAP restore | Mirror existing remove-ads pattern |

## Povezano

- [[ideje-sezone-ux-home|UX]] · [[ideje-sezone-ekonomija|ekonomija]] · [[ideje-sezone-content|content]]
- [[../05-technical/godot/iap-billing-setup|iap-billing-setup]]
