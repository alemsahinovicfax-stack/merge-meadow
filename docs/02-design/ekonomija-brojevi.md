---
type: dizajn
status: aktivan
milestone: M7
tags: [dizajn, ekonomija, balans, brojevi, source-of-truth]
povezano:
  - ekonomija
  - spec-vertical-slice
  - mehanike/merge-kamp
  - CHECKPOINT
ai_sažetak: "Sve balans-konstante slice-a na jednom mjestu (run, loot, kamp, sprinkler) + gdje su u kodu."
---

# Ekonomija — brojevi (live tablica)

## Sažetak

Konkretne konstante za feel i balans. [[ekonomija|ekonomija]] = *zašto*; ovaj doc = *koliko* + **gdje u kodu**.

> Greybox draft — mijenja se nakon playtesta.

## Run (`scripts/run/run_controller.gd`)

| Konstanta | Vrijednost | Značenje |
|-----------|-----------|----------|
| `RUN_DURATION` | `60.0` s (post-tutorial) / `75` kanon M8 | `POST_TUTORIAL_RUN_DURATION` u `game_state.gd` |
| `BASE_SCROLL_SPEED` | `400.0` px/s | početna brzina |
| `RAMP_STEP` | `0.05` | +5% brzine po koraku |
| `RAMP_EVERY` | `15.0` s | ramp interval |
| `SPAWN_INTERVAL` | `1.2` s | spawn pokušaj |
| `SPAWN_CHANCE` | `0.7` | šansa spawna |
| `OBSTACLE_CHANCE` | `0.25` | udio prepreka |
| `PICKUP_SEED_CHANCE` | `0.30` | udio sjemena (ostatak coin) |

## Loot (`game_state.gd → finish_run`)

| Pravilo | Formula |
|---------|---------|
| Finish | 100% sjemena + novčića |
| Fail | `ceil(50%)` oba (novčići + sjeme) |
| Double | ×2 **samo loot trenutnog runa** (`last_*`); wallet + bonus jednom za ovaj run |
| Revive | nastavi run, ne dira loot |
| To Camp | sjemena → `seed_bag`; novčići već u `wallet_coins` pri `finish_run` |
| **Fail vs finish UI** | crvena/zelena traka + naslov; status `X → Y` na failu (50%) |

## Novčići (`wallet_coins`)

| Pravilo | Vrijednost / napomena |
|---------|----------------------|
| Izvor: run pickup | ~70% spawnova (balans **niski prioritet** do shopa) |
| Izvor: exchange | 3× isti tip iz baga → `8` coins |
| Izvor: rewarded ×2 | ×2 `last_run_coins` / `last_seed_bag` (samo ovaj run) |
| Sink v1 | **samo kozmetika** (shop M8) — ne magnet, ne loadout |
| Magnet upgrade | **T2 bloom donate** — novčići ne utječu na snagu |
| Wallet u kampu | ✅ label `Wallet: X coins` |
| Set bonus coins | **v1.1+** (Meadow Starter +5%) |
| Debug playtest | `DEBUG_DEV_RESOURCES` → **20 coins + 20 Clover** na boot / ulaz u kamp |
| Loadout (F5) | 1 slot, `LOADOUT_SPAWN_BONUS` **+5%** šanse za sjeme u runu |

### Shop cijene (draft — M8)

| Item | Cijena (coins) |
|------|----------------|
| Pip skin | 250 |
| Pozadina livade | 150 |

### Otvoreni targeti (playtest — kasnije)

| Parametar | Napomena |
|-----------|----------|
| Prosječno coins / run | TBD nakon shop prototipa |
| Fine-tune shop cijena | nakon 5-min playtest gatea |

## Kamp / vrt (`game_state.gd`)

| Konstanta | Vrijednost | Značenje |
|-----------|-----------|----------|
| `CAMP_BED_COUNT` | **9** | gredice vrta (3×3) |
| `GREENHOUSE_SLOT_COUNT` | **2** | staklenik (★★★ only) |
| `MAX_MERGE_TIER` | `2` | T1 sjeme → T2 cvijet |
| merge | 2× isti `type_id` + isti tier | T1+T1=T2 |
| T2 nakon mergea | **zadrži** na gredici ili **doniraj** sprinkleru | igrač bira (E2 ✅) |
| `sprinkler_donations` | 0–2 | donirani T2 prije upgradea |
| `discovered_blooms` | po `type_id` | priprema za dnevnik/setove |
| `EXCHANGE_SEED_COUNT` | `3` | K4 zamjena viška |
| `EXCHANGE_COINS_REWARD` | `8` | novčići po zamjeni |

### Rarity → gdje se sadi

| Rarity | Primjer | Lokacija |
|--------|---------|----------|
| ★–★★ | Clover, Tulip | vrt (gredice) |
| ★★★ | Pumpkin, Watermelon | staklenik |

## Sprinkler (`game_state.gd`)

| Konstanta | Vrijednost |
|-----------|-----------|
| `MAGNET_MAX_LEVEL` | `4` |
| `MAGNET_COST_T2` | `2` donirana T2 cvijeta po levelu |
| `MAGNET_BASE_RADIUS` | `40` px |
| `MAGNET_RADIUS_PER_LEVEL` | `48` px |

### Provjera kapaciteta
- 9 gredica → max **4 T2** odjednom (8 slotova u mergeu) → 2 za sprinkler + 2 zadržana za kolekciju.
- Staklenik odvaja ★★★ od vrta — manje zagušenja kad dođe više tipova.

## Balans pass 1 (2026-07-05)

| Promjena | Prije | Sada | Razlog |
|----------|-------|------|--------|
| Post-tutorial run | 20 s | **60 s** | 20 s prekratko za camp loop; 75 s ostaje M8 target |
| Spawn interval / chance | 1.2 / 0.7 | bez promjene | ~8–12 pickupa u 60 s — OK za prvi pass |
| Obstacle chance | 0.25 | bez promjene | dovoljno rizika bez frustracije |
| Magnet T2 cost | 2 donacije | bez promjene | 9 gredica i dalje podržava 2 upgrade ciklusa |

**Osjećaj:** 60 s daje prostor za loadout (+5% spawn) i sprinkler upgrade bez žurbe. Fine-tune nakon shop prototipa (F8.4).

## Odluke (2026-07-04)

- **E2 cilj igrača:** oboje — T2 za **sprinkler** ili **kolekciju** (setovi/dnevnik kasnije).
- **Tierovi:** T1→T2 samo (bez T3 u v1).
- **Redoslijed implementacije:** 9 gredica → izbor T2 → staklenik + zamjena.

## Otvorena pitanja

- [x] `RUN_DURATION` post-tutorial — **60 s** (pass 1); 75 s ako M8 playtest traži
- [ ] Exchange rate po rarity (sad flat 3→8)
- [ ] Set bonus brojke kad dnevnik uđe u kod

## Povezano

- [[ekonomija|ekonomija]]
- [[spec-vertical-slice|spec-vertical-slice]]
- [[../03-content/ideje-gameplay-ekonomija|ideje-gameplay-ekonomija]]
