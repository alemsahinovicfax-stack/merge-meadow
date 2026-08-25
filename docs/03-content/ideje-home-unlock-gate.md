---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-unlock
  - ideje-home-unlock-pitanja
ai_sažetak: "HOME-07 gate — next-lock centar: coins+T3 progress, Unlock sivo dok can_unlock_free; Browser fokusira next-lock."
---

# IDEJE — HOME-07 gate (progress + Unlock)

> [[ideje-home-unlock|hub]]. Postojeći `unlock_free` / `can_unlock_free` / Unlock sheet **logika** ostaje. Home UI se seli **inline**. **Parent panela overridean HOME-08:** child next-lock kartice, vidi [[ideje-home-incard-gate|HOME-08 gate]].

## Kad se vidi

Hero-centar je free `next_locked_free_id()` i nije TEST_LOCK. Npr. Lantern dok Frost playable.

Paid unowned: **nema** ovog panela (P54, P89).

Playable centar: panel skriven.

## Sadržaj

1. Progress **Coins** — `wallet_coins / def.coins_cost` (Lantern 150).
2. Progress **Flowers** — `t3_flower_count() / t3_flowers_required` (Lantern 8). „Sjemena“ = T3 garden flowers, ne seed bag (P86).
3. Gumb **Unlock** — `UiClickButton`. `disabled` + subtle/sivo dok `not can_unlock_free`. Primary kad oba praga.

Tap Unlock → `unlock_free` → sezona playable, `active` + strip na nju, sljedeća (Amber) further-lock.

## Browser (P85)

Tap next-lock kartice: `close` + Home `swap_home_band("free", id)` / `set_free_strip_focus` — **ne** `unlock_requested` sheet. Further/TEST_LOCK: bounce. Playable: select+close kao sad.

Sheet ostaje u sceni kao fallback; Stage ga **ne** otvara za next-lock.

## HIT-A

Unlock gumb `MOUSE_FILTER_STOP`. Ostatak Stage swipe-a: roster IGNORE.

## Acceptance

- Lantern centar: dvije trake + sivi Unlock ako nema 150c/8 T3.
- S resursima: Unlock se pali; tap grant-a lantern, Amber desno lock bounce.
- Browser Lantern → Home Lantern centar, sheet zatvoren.
