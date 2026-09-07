---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, daily, scratch]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-field-pitanja
  - ideje-home-meadow-dock-daily
  - plan-prompts-home-camp-field
ai_sažetak: "HOME-16 A ✅ — claimed Daily overlay: title Come back tomorrow; body bez ponovljenog come back tomorrow."
---

# IDEJE — HOME-16 daily (overlay body)

> [[ideje-home-meadow-field|hub]] · freeze P215–P217, P231.  
> **Kod:** **FIELD-A ✅**. Ne picker (B). Ne hub swipe (C). Ne Magnet (D). P206 caption ostaje.

## Danas

[`main_menu.gd`](../../game/scripts/ui/main_menu.gd) `_on_daily_chest_pressed` kad je `CLAIMED`:

- title: `"Come back tomorrow"`
- body: `"Daily chest already opened today — come back tomorrow!"`

Isti suffix u [`game_state.gd`](../../game/scripts/autoload/game_state.gd) `claim_daily_chest()` early-return.

Kartica caption (DOCK-D): **Tap to open** / **Back tomorrow** — **ne dirati**.

## A — body bez eha ✅

1. Overlay title ostaje **Come back tomorrow**.
2. Body: **Daily chest already opened today.** (nema ` — come back tomorrow!`).
3. Isti trim u `claim_daily_chest` early-return (ako se string ikad prikaže).
4. Ne dirati `claim_arena_daily`, `arena_daily_*`, caption kartice.

## Smoke (P231) ✅

Claimed Daily tap: overlay title sadrži "Come back tomorrow"; body sadrži "already opened today"; body **nema** "come back tomorrow" (case-insensitive). Caption i dalje "Back tomorrow" kad je claimed. `season_home_smoke` `_assert_home_daily_gift`.

## Acceptance

- Poruka se ne ponavlja. Title kaže vrati se sutra; body kaže već otvoreno danas.
