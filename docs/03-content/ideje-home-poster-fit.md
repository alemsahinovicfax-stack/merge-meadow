---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, kamp, ux, unlock, sezone, scratch]
povezano:
  - ideje-home-unlock-poster
  - ideje-home-barfit
  - ideje-camp-link
  - plan-prompts-home-poster-fit
  - CHECKPOINT
ai_sažetak: "HOME-18 — 🔒+ime na sredini locked kartice; poster dolje; linija coin/flower; manji coin, veći cvijet; watermelon izbačen."
---

# IDEJE — HOME-18 poster fit + drop watermelon

> **ID:** **HOME-18** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **HOME-18 ✅** 2026-09-06. Jedan agent-plan (nema A/B/C paste). Freeze: [[../06-production/plan-prompts-home-poster-fit|plan-prompts-home-poster-fit]].  
> **Prethodnik:** [[ideje-home-unlock-poster|HOME-17]] (title-TOP / gate 0.26 / watermelon ★2 **superseded**).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — 500c + 20 Harvest Pumpkin ostaje.

## Pitch

Playtest HOME-17: `UnlockGate` `anchor_top = 0.26` + `CenterTitle` TOP je pojeo sredinu kartice. Coin i pumpkin izgledaju kao jedan blok. Patch Watermelon je u basketu jer je u `seed_type_ids`, a Home roster ga ne crta (fiksnih 6 redova).

## Freeze

- **P107 vraćen** na locked free: `CenterTitle` full-rect, H+V CENTER, tekst `🔒\n{ime}`. Nema `_apply_locked_title_layout`.
- **P129 / BARFIT geometrija:** `%UnlockGate` donja zona, `anchor_top` **0.60** (0.56–0.64). Ne 0.26.
- Između coin i flower bloka: tanka centrirana linija + zrak. Isto na Home i Camp.
- Coin **40px**, cvijet **92px** — samo unlock poster. Basket picker ostaje 72.
- **`watermelon` nestaje iz igre.** Bloom = 6 tipova: clover, daisy, buttercup, tulip, sunflower, pumpkin. Jedan ★3 (`pumpkin`).
- Kamp Unlock / spend / 500/20 / attention / sivi locked basket redovi — ne dirati.
