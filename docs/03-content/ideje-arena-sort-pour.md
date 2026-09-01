---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, pour, sort, chain, refill, scratch]
povezano:
  - ideje-arena-sort
  - ideje-arena-sort-math
  - ideje-arena-sort-vacuum
  - ideje-arena-sort-pitanja
  - ideje-arena-leftover-pour
  - ideje-arena-grupe
ai_sažetak: "ARENA-03 pour — sav T1 po CHAIN; skip <4; lock samo bag <4 (VAC-L); cap 40; refill 12."
---

# IDEJE — ARENA-03 pour (sav T1, lanac, cap 40)

> [[ideje-arena-sort|hub]] · math [[ideje-arena-sort-math|math]].  
> Kod danas: [`_build_arena_pour_queue`](../../game/scripts/autoload/game_state.gd) `CHAIN` + sav count ako ≥4; [`ARENA_AUTO_REFILL_AT`](../../game/scripts/camp/merge_arena_controller.gd) = **12**. **SORT-A ✅ VAC-L ✅.**

## Cilj

Prije nego igrač spoji išta, **u pozadini** je queue: sva sjemena **po tipu i hronologiji unlocka**, ne pomiješana rarity-2. Tip s ≥4 T1 ide **cijeli** (31 daisy, ne 28). Tip s 1–3 **ne izlazi**. Lock (vacuum) skipa samo dok je `bag[type] &lt; 4` (VAC-L / S31). Polje se puni do **40**. Kad padne na **12**, auto-refill istog pravila. Prazno polje **ne** auto-poura na boot; nakon vacuuma s ≥4 u vreći — jedan pour (S32).

## Dva ulaza, jedno pravilo

| Ulaz | Kad | Što |
|------|-----|-----|
| Tap vreće | Bag > 0, ima slota | `_pour_available_seeds` → `pull_seeds_to_arena` |
| Auto-refill | Chipova **1–12**, bag > 0, ima slota | Isto, ciklus do 40 ili praznog pourable queuea |

Nema „auto smije samo ×4“. Auto trese **isti** queue kao tap (skip &lt;4; lock samo dok bag &lt; 4).

Polje **0** → ne auto (FLOW-B), osim S32 nakon vacuuma. Done slobodan.

## Queue = CHAIN, cijeli tip

[`SeedUnlockConfig.CHAIN`](../../game/scripts/progression/seed_unlock_config.gd):

```
clover, daisy, buttercup, tulip, sunflower, pumpkin, watermelon
```

Chat „daisy pa rose“ = **primjer dva uzastopna tipa**, nije nova flora. Rose nije u igri. Ako je clover 0, prvi živi tip je daisy, sljedeći buttercup.

Za svaki tip u tom redu, ako `bag[type] >= 4` i lock **ne** drži (S31: lock samo &lt;4): stavi `bag[type]` komada u queue (ne `floor/4`). Zatim sljedeći tip.

**Ne** `priority_types.size() >= 2` break. Danas se prva 2 rarity-najniža napune, pa rest — zato sorting „ima grešaka“. SORT-A to **briše**.

**Ne** A15 orphan-first 3-na-1 (L2). Pour 3 da se spoji s 1 na polju više nije pitanje: ili tip ima ≥4 ukupno (tada živi do vacuum), ili nema (skip / vacuum).

`take_seed_from_bag` ostaje jedan-po-jedan. `max_count` = slobodni slotovi (≤40), **bez** floor-4 na `max_count`.

## Skip

| Uvjet | Pour |
|-------|------|
| `bag[type] == 0` | skip |
| `bag[type]` 1, 2 ili 3 | skip (S4). Ostaje u korpici |
| tip locked **i** `bag &lt; 4` | skip (S6/S31) |
| `bag[type] >= 4` | sav count u queue (lock se diže) |

Mythic pumpkin / watermelon: isto. Nema posebnog floor-4.

## Cap 40 / refill 12

`ARENA_MAX_CHIPS` 40. `ARENA_AUTO_REFILL_AT` 12. **Ne dirati brojeve** u SORT osim ako queue logika mora prestati kad pull vrati `[]` (locked + remainder-only).

Auto kad pull 0: **ne** otvarati overlay (L15). Overlay samo na **tap** vreće kad nema pourable tipa.

Arena full 40 + još bag: postojeća full poruka, nije overlay.

Bag 0: postojeća empty poruka.

## Primjer 31 + 30

Prazno polje, tap:

1. Daisy 31 ≥ 4 → 31 u queue.
2. Buttercup 30 ≥ 4 → 30 u queue.
3. Pull max 40: 31 daisy, 9 buttercup.
4. Bag buttercup 21.

Merge daisy, vacuum 3 daisy (SORT-B). Daisy locked **dok je 3** (S31). Polje se smanji. Auto na 12 trese buttercup iz 21, ne daisy. Ako se leftover zbroji na ≥4 daisy, unlock i trese daisy (VAC-L, npr. suncokret na dva vala).

## Prazan pour vs overlay

| Bag | Lock | Polje | Tap vreće |
|-----|------|-------|-----------|
| 0 | — | bilo | Empty (postojeće) |
| samo 1–3 po tipu, ništa locked-pourable | — | slobodni slotovi | Overlay B |
| ≥4 nekog **unlocked** tipa | — | &lt;40 | pour sav do slota |
| ≥4 na tipu koji je bio locked, sad bag ≥4 | S31 unlock | slobodni slotovi | pour (VAC-L) |
| samo 1–3 (locked ili ne) | — | slobodni slotovi | Overlay B |
| ≥4 unlocked | — | 40 | Arena full |

## Što pour slice ne dira

Vacuum/lock (B), overlay open/hide (B/C već), grant D, combo, pest tajmeri, FEEL-B, `SEED_BAG_SOFT_CAP`.

## Smokes (SORT-A) — kasniji kod

1. Bag daisy 31, buttercup 30, polje 0, pour 40 → pulled 31 daisy + 9 buttercup; bag buttercup 21, daisy 0.
2. Bag clover 3, daisy 8 → pulled 8 daisy, clover ostaje 3.
3. Locked daisy + bag daisy **3** → pull 0 daisy. Bag daisy **20** poura (VAC-L, lock ne drži ≥4).
4. Auto: polje 0 ne poura. Prag 12 ostaje.
5. leftover_a_smoke floor-4 asserti **se mijenjaju** (6 clover → 6 van, ne 4).

## Povezano

- [[ideje-arena-sort-pitanja|S1 S2 S3 S4 S9 S14]] · [[ideje-arena-leftover-pour|ARENA-02 pour]] (override)
