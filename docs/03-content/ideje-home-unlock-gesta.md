---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, unlock, sezone, scratch]
povezano:
  - ideje-home-unlock
  - ideje-home-unlock-pitanja
  - ideje-home-focus-gesta
ai_sažetak: "HOME-07 gesta — swipe dolje selektuje playable fokus; L/R smije na next-lock; further bounce; band samo tap."
---

# IDEJE — HOME-07 gesta (select + next-lock)

> [[ideje-home-unlock|HOME-07 hub]]. L/R pretapanje HOME-06 **ostaje**. Band visine **ostaju** (tap preview).

## Swipe dolje (P81)

Na **hero** traci (free ili paid), prst dolje (`dy > 0`, axis lock 20px):

1. `focus = home_hero_center_id()`
2. Ako `is_season_playable(focus)` → `set_active_season(focus)` (Play tema + outline).
3. Inače → zadnji playable u tom bandu, ili `_highest_unlocked_free_id()` ako paid nema owned.
4. **Ne** `swap_home_band`. Preview tap i dalje radi swap.

Na preview traci vertikalni swipe dolje: isto select (ne cycle H — P55).

## Swipe gore (P82)

Bounce. Ne paid↔free.

## L/R free (P83)

`is_free_selectable(id)` = playable **ili** (`id == next_locked_free_id()` **i** nije `is_test_locked_season`).

- Cycle na Lantern (next-lock): `strip_focus_id = lantern`, **bez** `set_active`.
- Cycle na Amber (further / TEST_LOCK): bounce.
- Tap desno next-lock: cycle, **ne** Unlock sheet.
- Tap desno further: bounce.

Paid L/R: cijeli `paid_defs()` uključujući unowned i Ember (fokus bez `set_active` ako nije owned).

## Test (P84)

`debug_unlock_all_seasons` preskače `lantern_meadow`, `amber_canopy`, `ember_fen`. Nakon debug: Bloom+Frost playable; Lantern next-lock; Amber further.

## Acceptance

- Free-hero + swipe dolje na Bloom → `active = country_bloom`.
- Fokus Lantern + swipe dolje → `active` ostaje Frost (zadnji playable), Lantern ostaje fokus vizualno ili se active outline vrati na Frost — **active** = Frost; fokus strip smije ostati Lantern (browse) dok active nije Lantern.
- Clarify: select sets **active** (Play). Strip fokus može ostati na locked kartici. Outline = playable active (P75) pa outline na Frost susjedu dok je Lantern centar.
- Tap preview paid i dalje visinski glajd.
