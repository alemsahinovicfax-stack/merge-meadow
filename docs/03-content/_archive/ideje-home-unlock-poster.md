---
type: sadrzaj
status: arhiva
milestone: "v1.1+"
tags: [sadrzaj, home, kamp, ux, unlock, basket, daily, sezone, scratch, arhiva]
povezano:
  - ideje-home-lockflow
  - ideje-home-barfit
  - ideje-camp-link
  - ideje-home-meadow-field
  - plan-prompts-home-unlock-poster
  - CHECKPOINT
ai_sažetak: "HOME-17 — centrirani unlock poster (coin + jedan ★3); basket sva sjemena (locked siva); prazan basket i claimable chest blink+shake."
---

> **Arhivirano 2026-09-07** — HOME-17 superseded sa **HOME-18** ([[../ideje-home-poster-fit|ideje-home-poster-fit]]). Zadržano kao historijski zapis odluka.

# IDEJE — HOME-17 unlock poster + basket roster + attention

> **ID:** **HOME-17** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **HOME-17 ✅** 2026-09-06. Jedan agent-plan (nema A/B/C paste). Freeze: [[../../06-production/_archive/plan-prompts-home-unlock-poster|plan-prompts-home-unlock-poster]].  
> **Prethodnik:** [[ideje-home-barfit|HOME-11]] gate niže + [[ideje-camp-link|CAMP-03]] SeasonLink + [[../06-production/plan-prompts-star3-unlock-hub|star-3 hub]].  
> **Nasljednik:** [[ideje-home-poster-fit|HOME-18]] — title-TOP / gate 0.26 / watermelon ★2 **superseded**.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — coins + jedan ★3 trenutne sezone, ne IAP.

## Pitch

Locked free sezona (Home gate i Camp SeasonLink) nije lijepa: tekst „Coins n/need“ i „★★★ n/20“ bez slike. Basket krije sjeme koje igrač još nije otključao. Prazan basket i daily chest ne zovu tap dovoljno.

## Freeze

- Svaka sezona ima **točno jedan** `rarity == 3`. Bloom: `pumpkin` ostaje ★3; `watermelon` → ★2. Ostale sezone već 1× ★3.
- Unlock sljedeće sezone broji **samo taj ★3 trenutne** (prethodne free) sezone. Frost = 20 Harvest Pumpkin. Lantern = 20 Crystal Peony. Amber = 20 Midnight Lotus.
- Isti poster na Home `%UnlockGate` i Camp `%SeasonLinkCard`:

```
[slika coina]
[n / 500]
[bar]

[slika cvijeta]
[★★★]
[ime]
[n / 20]
[bar]
[Unlock]
```

- Home locked-only: `CenterTitle` TOP (`🔒` + ime). Playable zadržava P107 (ime na sredini). Override P129 `anchor_top` 0.62.
- Camp: SeasonLink **ne** mora biti iste visine kao GardenCard.
- Kamp Unlock: tap kartice = Home (ne spend); gold Unlock = Home + 0.4 s + `unlock_free`.
- Basket picker: svi `types_for_season`; `!is_seed_type_unlocked` = sivi, tap no-op. Bez scrolla.
- Prazan basket (polje open, loadout enabled, type prazan): blink + blagi shake.
- Daily chest READY: blink + shake, druga krivulja. Claimed/opening = stop.
- JSON 500/20, SAVE_VERSION, Shop/AdMob — ne dirati.
