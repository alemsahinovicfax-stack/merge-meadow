---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, kamp, unlock, seeds, flowers, plan]
povezano:
  - ideje-camp-row
  - ideje-camp-read
  - CHECKPOINT
ai_sažetak: "CAMP-05 ✅ — two-free fixture; chip red + filled stars; SeasonLink = Garden dimenzije."
---

# Plan freeze — CAMP-05 camp row

> **Jedan** agent-plan (nema paste playliste). Grana **`master`**. Fair F2P: 500c + 20 Harvest Pumpkin.  
> Override CAMP-04 chip stack 176 / uvijek 3 slota `☆`. Home poster HOME-18 netaknut.

## Freeze

- `debug_playtest_two_free()`: Bloom + Frost; `owned_paid_seasons` prazan. Wire debug hub/menu ako `not skip_debug_season_unlock`.
- Ne zvati `debug_unlock_all_seasons()` s boota (grant-a paid).
- Chip: IconCol (80 + samo ★) | TextCol (ime, broj desno) | PricePill. `CHIP_MIN_H` ~104–116.
- `rarity_stars.apply_row` rebuild na N popunjenih ★. Nema `☆`.
- SeasonLink `_match_garden_height` + Unlock ≈ Exchange. Scroll 420.
- 500/20, delay spend, Shop/AdMob — ne dirati.

## Povezano

- [[../03-content/ideje-camp-row|hub]] · [[../03-content/_archive/ideje-camp-read|CAMP-04 (arhivirano)]] · [[CHECKPOINT|CHECKPOINT]]
