---
status: draft
tags: [dizajn, kontrole]
---

# Kontrole i input

## Sažetak

**Portrait, jednoručna** igra — swipe lijevo/desno u runu, drag u kampu za merge. Bez joysticka.

## Orijentacija

- [x] Portrait
- [ ] Landscape
- [ ] Oba (adaptive)

Portrait = thumb reach, jedna ruka u redu/krevetu (vidi [[../01-vision/ciljana-publika|ciljana-publika]]).

## Kontrolna shema

| Akcija | Input | Kontekst |
|--------|-------|----------|
| Pomicanje u laneu | Swipe L/R | Lane run |
| Merge predmeta | Drag & drop | Kamp |
| Pause | Tap (gornji kut) | Run + kamp |
| Dupli loot / Revive | Tap gumba | Loot ekran (rewarded) |
| Retry / U kamp | Tap | Loot ekran |
| Upgrade | Tap kartice | Kamp |

**Nema:** virtual joystick, dual-stick, gesture conflicts s system back (Android handled u UX fazi).

## HUD elementi (run)

- Orb counter (donji centar — thumb zone)
- Množitelj badge (uz counter)
- Pause (gornji lijevo, 44×44 pt min)
- Magnet level ikona (gornji desno, opcionalno)

## HUD elementi (kamp)

- Merge grid / slotovi (centar)
- Upgrade kartice (donji third)
- Daily / Shop / Play (bottom nav)

## Mobile UX pravila

- **Thumb zone:** primarne akcije u donjoj polovici ekrana.
- **Minimalni touch target:** 44×44 pt (Apple HIG / Material).
- **Gesture conflicts:** swipe u runu ne scrolla UI; kamp drag ne triggera back.
- **Zvuk:** off by default u javnom transportu (postavke).

## Haptic feedback

| Događaj | Haptic |
|---------|--------|
| Orb pickup | Light |
| Merge pop | Medium |
| Fail | Light double |
| Upgrade unlock | Success pattern |

Opcionalno u postavkama — default ON.

## Ostalo

- **Gamepad / keyboard:** OUT za v1
- **Tablet:** phone layout scaled; dedicated tablet layout OUT (scope)

## Otvorena pitanja

- [ ] Swipe osjetljivost — playtest na Android mid-range
- [ ] Lijevoruki mod — mirror HUD kasnije

## Povezano

- [[mehanike/lane-run|lane-run]]
- [[mehanike/merge-kamp|merge-kamp]]
- [[../04-experience/ui-ux|ui-ux]]
- [[../05-technical/platforme|platforme]]
