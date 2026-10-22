---
type: sadrzaj
status: aktivan
milestone: M8
tags: [hub, nivoi, run, endless, balans]
povezano:
  - balans-ciklus-1-izvjestaj
  - ekonomija-brojevi
  - leveli-endless-cd-brief
  - level-path-cd-brief
ai_sažetak: "Run leveli 1–20 po sezoni (ista težina u svakoj sezoni) i Endless rampa — brojevi u game/data/run_levels/levels.json, provjera economy_sim.gd + economy_balance_smoke.gd (balans ciklus 1, 2026-10-21)."
---

# Run leveli (1–20 po sezoni) i Endless

> Balans ciklus 1 (2026-10-21) — zamjenjuje stari plan „leveli 1–100 + Endless Easy / Normal / Hard". Zašto i rezultati simulacije: [[../../02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]].

## Sažetak

- Svaka sezona ima **Level Path od 20 levela**; level N je **iste težine u svakoj sezoni** (odluka 2026-10-20). Poslije levela 20 Play ponovo igra level 20.
- Leveli rastu do 20: **duži** (60 → 120 s), **brži**, **više prepreka**, **parovi** (prepreka u dvije staze, treća slobodna), **više plijena** (gušći spawn + duže) i **češće rijetko sjeme**.
- **Ciklus 1b (2026-10-22, „prelagano"):** težina je pomjerena **+5 levela** (level 1 = stari level 6: start 432 px/s, parovi od levela 1; 16–20 ekstrapolirano do 550 px/s, 40 % parova). Prepreke idu **svojim tokom 3× češće** (L1 ≈ 9, L10 ≈ 27, L20 ≈ 80 u minuti; razmak ≥ 300 px). ★3 ×1,25. Trajanje i plijen po levelu isti.
- **Endless** nema tajmer: stepenica („Pace") svakih **20 s**, težina kreće 60 s ispred sata (kao stari level ~8), isto 3× prepreka; poslije 8 min (težine) brzina raste bez kraja. Plijen ostaje cijeli; rekord po sezoni.
- **Endless sezone se otključava poslije levela 15** te sezone.

## Gdje je šta

| Šta | Gdje |
|---|---|
| Brojevi (20 levela + Endless ključevi) | `game/data/run_levels/levels.json` |
| Čitanje, Endless stepenice | `game/scripts/run/run_level_library.gd` (`get_level`, `get_endless_config_at`, `endless_tier`, `ENDLESS_TIER_SEC`) |
| Polja levela | `game/scripts/run/run_level_config.gd` |
| Rijetkost sjemena, par prepreka | `game/scripts/run/run_balance.gd` |
| Run (brzina, spawn, parovi, Endless) | `game/scripts/run/run_controller.gd` |
| Otključavanje Endlessa, rekord | `game/scripts/economy/level_path.gd` (`ENDLESS_UNLOCK_LEVEL`, `record_endless`) |
| Simulacija | `game/scripts/dev/economy_sim.gd` |
| Provjera pravila | `game/scripts/dev/economy_balance_smoke.gd` |
| Telemetrija runova (debug build) | `game/scripts/run/run_telemetry.gd` → `user://balance_log.csv` |

## Polja levela (`levels.json`)

| Polje | Značenje |
|---|---|
| `duration_sec` | trajanje levela |
| `scroll_speed_mult` | brzina na startu × 400 px/s |
| `speed_ramp` | brzina raste ×(1 + ramp) svakih 15 s |
| `spawn_interval` / `spawn_chance` | pokušaj spawna (s) i šansa |
| `obstacle_chance` | udio prepreka u spawnovima |
| `pair_chance` | udio prepreka koje zatvore dvije staze |
| `pickup_seed_chance` | udio sjemena među pickupima (ostalo coin) |
| `rare2_mult` / `rare3_mult` | težina tipa sjemena po rijetkosti (★1 = 1) |

Endless ključevi (`endless.keys`) nose ista polja + `t` (s); vrijednost stepenice se interpolira između ključeva i drži 20 s. `after_last_speed_per_tier` — rast brzine poslije zadnjeg ključa; `max` — granice prepreka i parova.

## Kako mijenjati

1. Promijeni `levels.json` (ili generator u izvještaju ciklusa).
2. `economy_balance_smoke` — pravila (svaki level ≥ prethodni, Endless samo teži, granice).
3. `economy_sim.gd -- --out=...` — prolaz %, plijen, dani do sezona i cijena.
4. Playtest u debug buildu → `user://balance_log.csv` → `economy_sim.gd -- --calibrate`.

## Povezano

- [[../_index|03-content]]
- [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]] · [[../../02-design/progresija|progresija]]
- [[../../04-experience/design-drafts/leveli-endless-cd-brief|leveli-endless-cd-brief]] · [[../../04-experience/design-drafts/level-path-cd-brief|level-path-cd-brief]]
