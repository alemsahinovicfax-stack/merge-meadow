---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, journal, kamp, sezone, unlock, plan, prompt]
povezano:
  - CHECKPOINT
  - ideje-sezone-ekonomija
  - ideje-camp-link
  - ideje-camp-link-pitanja
  - plan-prompts-home-camp-field
  - plan-prompts-home-lockflow
ai_sažetak: "Jedan freeze — Journal deferred swipe; free unlock 500c + 20 star-3 T3 prethodne sezone; kamp kartica nav, gumb delay spend."
---

# Plan freeze — star-3 unlock + Journal swipe + Camp link

> **Jedan** agent-plan (nema 7 paste chatova). Grana **`master`**. Fair F2P: coins + cvijeće, ne IAP.  
> Override **C32** (kamp Unlock gumb sada spend nakon Home delay). Override **C26** scroll **280**. Override P86/P126 „bilo koji T3“.

## Freeze

- Journal: susjed **ne** gradi ~49 redova u `_ready`. Staggered/deferred kad je stranica current. `refresh_for_meta_hub` in-place ako lista postoji.
- Free S2+: `500` coins **i** `20` rarity-3 T3 cvijeća **prethodne** free sezone. `unlock_free` **troši** oba.
- Home + Camp bar: `Coins n/need` + `★★★  n / 20` (zbroj star-3 prethodne sezone).
- Kamp kartica tap = Home locked poster, **ne** spend. Kamp Unlock (kad `can_unlock_free`) = Home + ~0.4 s + `unlock_free`. Gumb sivi dok ne može, gold kad može.
- Seeds/Flowers scroll min y **280**. SeasonLink visina = GardenCard.
- Debug fixture: samo Bloom unlocked; 19 pumpkin; bag remap na Bloom tipove; coins ≥ 500.
- Bez `SAVE_VERSION`. Ne Shop/AdMob/IAP paid/leftover/Magnet.

## Povezano

- [[../03-content/ideje-sezone-ekonomija|ekonomija]] · [[../03-content/ideje-camp-link|CAMP-03]] · [[CHECKPOINT|CHECKPOINT]]
