---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, daily, arena, scratch]
povezano:
  - ideje-home-meadow-dock
  - ideje-home-meadow-dock-pitanja
  - plan-prompts-home-meadow-dock
ai_sažetak: "HOME-15 D ✅ — Home Daily gift bez arena streak teksta i bez claim_arena_daily; arena HUD ostaje u merge areni."
---

# IDEJE — HOME-15 daily (streak van Home chesta)

> [[ideje-home-meadow-dock|hub]] · freeze P206, P214.  
> **Kod:** **DOCK-D ✅**. Ne Basket layout (C). Ne picker (A).

## Danas

[`main_menu.gd`](../../game/scripts/ui/main_menu.gd) Daily caption: `"Tap to open\n%s" % arena_line` / `"Back tomorrow\n%s"` via `GameState.get_arena_daily_home_line()`. `_on_daily_chest_pressed` može `claim_arena_daily()` uz gift.

[`merge_arena_controller.gd`](../../game/scripts/camp/merge_arena_controller.gd) `DailyLabel` = `get_arena_daily_hud_text()` — **ostaje**.

## D — Home Daily ✅

1. Caption samo gift: **Tap to open** ili **Back tomorrow**. Nema `get_arena_daily_home_line`.
2. Tap Daily: samo `claim_daily_chest` (postojeći gift). **Ne** `claim_arena_daily`.
3. Ne brisati `arena_daily_*` / `arena_daily_streak` iz savea (**nema** `SAVE_VERSION`).
4. Arena daily task + HUD u merge areni ostaje; `arena_daily_smoke` ostaje.

## Smoke (P214) ✅

Home / meadow ili mali daily helper: caption ne sadrži "Arena streak" ni "Arena daily". Nakon `claim_daily_chest`, `arena_daily_streak` ne raste. `arena_daily_smoke` i dalje prolazi.

## Acceptance

- Daily gift na Homeu izgleda kao samo daily gift.
- Arena streak/progress živi u areni, ne na chest kartici.
