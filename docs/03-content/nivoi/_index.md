---
status: draft
tags: [hub, nivoi]
---

# Run leveli (1–100)

Svaki **run level** = jedna JSON/Resource konfiguracija (trajanje, spawn, pretraga).

## Struktura level configa (draft)

```json
{
  "id": 1,
  "duration_sec": 60,
  "scroll_speed": 1.0,
  "orb_spawn_rate": 0.8,
  "obstacle_density": 0.1,
  "rare_orb_chance": 0.05
}
```

## Curve sažetak

| Raspon | Trajanje | Prepreke | Cilj |
|--------|----------|----------|------|
| 1–10 | 50–60 s | Rijetke | Tutorial, D1 |
| 11–40 | 60–75 s | Srednje | Tjedan 1 |
| 41–70 | 75–90 s | Gušće | Mid-game |
| 71–100 | 90 s | Najgušće | Pre-endless |
| Endless | Procedural | Rampa | Post-launch grind |

## Endless mode

- Bazira se na level 50+ poolu
- Blago smanjen `orb_spawn` da kontrolira inflaciju
- Generator detalji — **mjesec 2** (post-launch)

## Vertical slice (M7)

- **10 ručno napravljenih** levela (1–10 curve)
- Endless OUT u M7

## Povezano

- [[../02-design/progresija|progresija]]
- [[../05-technical/arhitektura|arhitektura]]
