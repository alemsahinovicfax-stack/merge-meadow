---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, kamp, unlock, seeds, flowers, plan]
povezano:
  - ideje-camp-fill
  - ideje-camp-row
  - CHECKPOINT
ai_sažetak: "CAMP-06 — thirds fill; link symmetry; chip name+count row; no Pip's Garden / no outer scroll."
---

# Plan freeze — CAMP-06 camp fill

> **Jedan** agent-plan. Grana **`master`**. Fair F2P: 500c + 20 Harvest Pumpkin.  
> Override CAMP-05 MainScroll+420 / `_match_garden_height` / chip TextCol stack. Home HOME-18 netaknut.

## Freeze

- Hide/remove `%CampTitle`. MainScroll vertical scroll disabled. Garden/Crystal/SeasonLink stretch 1:1:1.
- Drop Seed/Crystal scroll min 420. Drop `_match_garden_height`.
- SeasonLink title ≥ 36; icon side ~88 both cols + coin star spacer; vline width 4–6, SHRINK_CENTER, short height.
- Chip: IconCol | Name (center, ~32) + Count same HBox | PricePill.
- `debug_fill_camp_design_stash()` with two-free fixture when not skip_debug.
- 500/20, Shop/AdMob — ne dirati.

## Povezano

- [[../03-content/ideje-camp-fill|hub]] · [[../03-content/ideje-camp-row|CAMP-05]] · [[CHECKPOINT|CHECKPOINT]]
