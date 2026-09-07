---
type: produkcija
status: arhiva
milestone: "v1.1+"
tags: [produkcija, home, kamp, unlock, basket, daily, plan, arhiva]
povezano:
  - ideje-home-unlock-poster
  - ideje-home-lockflow
  - ideje-camp-link
  - CHECKPOINT
ai_sažetak: "HOME-17 ✅ — unlock poster coin+★3; jedan T3 po sezoni; basket sva sjemena; basket/chest attention."
---

> **Arhivirano 2026-09-07** — superseded sa **HOME-18** ([[plan-prompts-home-poster-fit|plan-prompts-home-poster-fit]]).

# Plan freeze — HOME-17 unlock poster + basket + attention

> **Jedan** agent-plan (nema paste playliste). Grana **`master`**. Fair F2P: coins + jedan ★3, ne IAP.  
> Override **P107/P129** samo dok je Home gate vidljiv (naslov TOP, gate više). Override CAMP3 height-match GardenCard. Override P86/P126 „bilo koji T3“ već iz star-3 huba — sada **točno jedan** ★3 po sezoni.

## Freeze

- Bloom `watermelon` rarity **2**; `pumpkin` jedini Bloom ★3. `star3_type_id_for_season` = točno jedan id.
- Shared `season_unlock_progress`: coin sprite + `n / need` + bar; cvijet T3 + ★★★ + ime + `n / need` + bar. Home gate + Camp SeasonLink.
- Home locked: CenterTitle TOP; gate `anchor_top` ~0.22–0.32. Playable P107 ostaje.
- Camp kartica raste (nema `_match_garden_height`).
- Basket lista = svi tipovi sezone; never-unlocked sivi / no-op.
- Basket attention kad je loadout prazan (enabled). Chest attention kad je READY. Različite krivulje.
- Bez `SAVE_VERSION`. Ne Shop/AdMob/IAP paid/leftover/Magnet.

## Povezano

- [[../../03-content/_archive/ideje-home-unlock-poster|hub]] · [[ideje-home-lockflow|HOME-10]] · [[ideje-home-barfit|HOME-11]] · [[../03-content/ideje-camp-link|CAMP-03]] · [[../CHECKPOINT|CHECKPOINT]]
