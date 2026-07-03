---
status: draft
tags: [mehanika, merge]
---

# Merge kamp

## Sažetak

Između runova igrač spaja iste resurse 2→1 u pastelnom kampu — satisfying pop, tier rast, unlock upgradea.

## Kako funkcionira

1. Igrač **ulazi u kamp** s orbovima s loot ekrana; orbs se pojavljuju na merge gridu / slotovima.
2. Sistem **dopušta drag** dva ista tiera → merge u jedan viši tier + VFX + SFX pop.
3. Ishod: viši tier orbs **hrane upgrade bar** (magnet, množitelj) ili se troše za unlock ljubimca.

## Feel / game feel

- Merge mora biti **odmah satisfying** (scale bounce, čestice, kratak ding).
- Kamp je **cozy** — sekundarna emocija iz [[../01-vision/koncept|koncept]].
- Nema fail state na merge — samo napredak (Pillar 3).

## Balans

| Tier | Primjer | Izvor |
|------|---------|-------|
| T1 | Pastel orb | Svaki run |
| T2 | Shiny orb | 2× T1 merge |
| T3 | Crystal orb | 2× T2 merge |
| T4+ | Launch: do T3–T4 | Kasniji content |

Merge chain ne smije biti predugačak u v1 — max 3–4 tiera za launch.

## UI feedback

- Merge grid s jasnim “ghost” preview kad dragaš.
- Progress bar ispod magneta/množitelja: “12/20 T2 orbs”.
- Nefinished: pulsing slot kad merge spreman.

## Monetizacija

| Moment | Tip |
|--------|-----|
| Speed-up merge queue | IAP consumable (opcionalno v1) |
| Extra merge slot 24h | Rewarded ili IAP |
| **Ne** | Plati da mergeaš — krši Pillar 2 |

## Ovisnosti

- Zahtijeva: loot iz [[lane-run|lane-run]]
- Povezano s: [[mnozitelj-upgrade|mnozitelj-upgrade]], [[../progresija|progresija]]

## Otvorena pitanja

- [ ] Grid 4×4 vs linearni slotovi — UX prototip
- [ ] Idle merge (auto) — OUT za v1

## Reference

- [[../01-vision/konkurencija-i-inspiracija|Merge Mansion — kamp retention]]
