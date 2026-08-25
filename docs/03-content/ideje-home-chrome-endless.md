---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, endless, sezone, chrome, scratch]
povezano:
  - ideje-home-chrome
  - ideje-home-chrome-pitanja
  - run_level_library
  - game_state
ai_sažetak: "HOME-03 Endless — uvijek Hard (Lv 85 + spawn 0.9); tema = active_season_id kao Play; UI picker nestaje."
---

# IDEJE — HOME-03 Endless (tema + Hard)

> [[ideje-home-chrome|HOME-03 hub]]. Kod: [`game_state.gd`](../../game/scripts/autoload/game_state.gd) `begin_endless_run`, [`run_level_library.gd`](../../game/scripts/run/run_level_library.gd).

## Dva sloja (ne miješati)

| Sloj | Što radi | HOME-03 |
|------|----------|---------|
| **Tema / sezona** | Spawn pool, BG tint, obstacle modulate | Već `GameState.active_season_id`. Endless **nema** drugi ID. |
| **Teškoća / krivulja** | Koji campaign-like nivo se koristi kao endless baza | Danas Easy=20 / Normal=50 / Hard=85 + `ENDLESS_SPAWN_MULT` 0.9 |

Igrač na Homeu bira **sezonu trakom** (ili Browser za paid active + badge). Zatim:

- **Play** = campaign run, ta tema, campaign level.
- **Play Endless** = ista tema, **uvijek Hard krivulja**.

Nema "Endless Country vs Endless Frost" pickera. Frost u centru + Play Endless = Frost spawn + Hard density.

## Što kod već radi

- [`get_active_season_spawn_types()`](../../game/scripts/autoload/game_state.gd) — run spawn.
- [`lane_background.gd`](../../game/scripts/visual/lane_background.gd) / [`obstacle.gd`](../../game/scripts/run/obstacle.gd) — tint po `active_season_id`.
- [`get_active_run_level_config()`](../../game/scripts/autoload/game_state.gd) — ako `run_is_endless`, `get_endless_config_for_difficulty(endless_difficulty)`.

CHROME-A **ne** mora duplirati season hook. Mora:

1. Prestati nuditi Easy/Normal u UI.
2. Na Endless press: `begin_endless_run(EndlessDifficulty.HARD)` (ne spremljeni NORMAL).
3. Opcionalno: pri startu endlessa `endless_difficulty = HARD` + save da HUD i reload budu konzistentni.

## Hard brojke (ne rebalansirati u HOME-03)

Iz `RunLevelLibrary`:

- Hard maps to **level 85** curve.
- Spawn interval multiplier **0.9** vs tom nivo.

Fair F2P: teže = skill, ne coins. Paid sezona i dalje **tema**, ne lakši Endless.

## HUD

`run_controller` već može pokazati `get_endless_difficulty_label()` → **"Hard"** je OK (informacija, nije picker). Ne stavljati Easy/Normal toggle u pause.

## Save / enum

- Polje `endless_difficulty` ostaje (save v kompatibilnost).
- Enum Easy/Normal/Hard ostaje za `get_endless_config_for_difficulty` i headless alate (`set_run_level.gd` preview).
- Stari save s Normal: **prvi** Play Endless prepisuje na HARD (P38). Ne migrirati masovno u `_apply_save_dict` osim jednog retka „endless start always HARD“.

## Što ne raditi

- Ne spajati endless spawn na `strip_focus_id` umjesto `active` — Play i Endless dijele **active** (P21 badge i dalje važi: strip Frost, active Moonlit → Endless je Moonlit).
- Ne dodavati „Endless plays strip even if paid active“ — to bi lagalo badge. Default P39: **active**.
- Ne dirati campaign 1–100.
- Ne dirati IAP.

## Smoke

- Postojeći endless/hub smoke: ako bira Easy, prebaciti na Hard ili samo `begin_endless_run(2)`.
- `season_run_smoke` tema: i dalje `active_season_id`; nije HOME-03 blocker.
- Opcija: mali assert u home smoke da EasyButton ne postoji.

## Povezano

- D2 Endless stub (CHECKPOINT) — HOME-03 sužava UI, ne briše mode.
- [[ideje-home-chrome-layout|layout]]
