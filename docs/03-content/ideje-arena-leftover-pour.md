---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, pour, leftover, refill, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-math
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena-leftover-pitanja
  - ideje-arena-sort-pour
  - ideje-arena-grupe
ai_sažetak: "ARENA-02 pour — L0b overridean ARENA-03 SORT-A (sav T1 po CHAIN); refill 12 i polje 0 ne auto ostaju."
---

# IDEJE — ARENA-02 pour (÷4 + refill 12)

> [[ideje-arena-leftover|hub]] · math [[ideje-arena-leftover-math|math]].  
> Kod danas: [`pull_seeds_to_arena`](../../game/scripts/autoload/game_state.gd) **SORT-A** (sav T1 po CHAIN, ne floor-4). [`ARENA_AUTO_REFILL_AT`](../../game/scripts/camp/merge_arena_controller.gd) = **12**. **LEFTOVER-A** povijest; L0b overridean.  
> **Nasljednik:** [[ideje-arena-sort-pour|ARENA-03 pour]] overridea L0b (sav T1, ne floor-4). Cap 40 / refill 12 / polje 0 ne auto **ostaju**.

## Cilj

Svaki T1 koji **skoči na polje** dio je kompleta od 4 istog `type_id` (iz torbe, u tom valu). Ostatak 1–3 **ne napušta** torbu. Igrač na polju uvijek ima posao do T3 (osim dok Muncher ne pojede 1 — tada leftover-E **ne**; [[ideje-arena-sort-vacuum|ARENA-03 vacuum]] skida cijeli tip kad t1_eq &lt; 4).

## Dva ulaza, jedno pravilo

| Ulaz | Kad | Što zove |
|------|-----|----------|
| Tap vreće | Igrač, vreća nije prazna, ima slota | `_pour_available_seeds` → `pull_seeds_to_arena` |
| Auto-refill | Nakon merge/eat/recycle, chipova **1–12**, bag > 0, ima slota | Isto `_pour_available_seeds` (ciklus do 40 ili bag ne može više ×4) |

**Isto** floor-4. Nema „auto smije tresnuti 2 daisy“. Chat freeze L0b.

## Floor-4 u queueu

Danas `_build_arena_pour_queue` za svaki tip stavlja samo `floor(count/4)*4` komada (skip ako je 0). `pull_seeds_to_arena` floor-a i `max_count`.

`take_seed_from_bag` ostaje jedan-po-jedan; samo **dužina** queuea po tipu se siječe.

Redoslijed tipova (rarity, unlock index) ostaje. **A15 orphan prefer** (tip s točno 1 chipom na polju ide prvi): **samo ako** količina koju bismo tresli za taj tip ostaje višekratnik 4. Pour **3** clover da se spoje s 1 na polju **krši** L0b → **ne** (L2). Orphan s 1 na polju + 4+ u torbi: trese 4 (polje ide na 5 — to je **lošije** za T3). Zato L2 default: orphan **ne** smije narušiti ÷4; praktično orphan-first je **isključen** dok na polju nije 0 mod 4 za taj tip. Dokumentiraj u kod komentaru da A15 nije ukinut zauvijek — samo podređen ÷4.

## Auto-refill 10 → 12

FLOW-B A14 D: cap 40, auto kad polje padne na prag. Playtest: 10 je rano; polje izgleda „prazno“ dok još ima merge. **12** = isti mehanizam, `ARENA_AUTO_REFILL_AT := 12`.

Ostaje iz FLOW-B:

- `_chips.size() <= 0` → **ne** auto-pour (leftover T2 / prazno čeka tap).
- `_chips.size() > 12` → ne auto.
- Done **uvijek** OK usred petlje (A24 C).
- Reentrancy: `_auto_pouring` + deferred drugi val ako i dalje ≤12.

Novi stop: bag ima sjeme ali **nema** tipa s `count >= 4` → `pull` vraća `[]`. Auto-refill prestaje. Tap vreće ide u **popup** (LEFTOVER-B), ne u prazan pour + „Nothing to pour.“

## Prazan pour vs stuck

| Bag | Polje | Tap vreće |
|-----|-------|-----------|
| 0 | bilo | „Bag is empty.“ (postojeće) |
| samo 1–3 po tipu | slobodni slotovi | **LEFTOVER-B overlay**, ne spawn |
| ≥4 nekog tipa | full 40 | „Arena full“ (postojeće) |
| ≥4 nekog tipa | <40 | pour floor-4 |

`info_label` „Nothing to pour.“ za remainder-only **ne** koristiti — to zvuči kao bug. Overlay je namjera.

## Primjeri FLOW-B + ÷4

**A.** 11 chipova, merge na 10 — **stari** prag; sada prag 12 pa 11 **već** auto-poura prije tog mergea. Smoke A: postavi 13, merge na 12 → bag se smanji ×4 chunkovima.

**B.** Bag clover 6, polje 0, tap: 4 na polje, bag 2. Auto ne pali (0 chipova nakon T3 skidanja — čeka tap ili Done). Ako T3 skine chip i ostane 0, FLOW-B **ne** treset; igrač tapne vreću: ako ostali tipovi imaju ×4, pour; inače overlay.

**C.** Polje 12, bag daisy 3: auto vidi ≤12 ali pull 0 → nema spawn, nema infinite loop. Overlay tek na **tap**.

## Što ne dirati u pour sliceu

Combo, daily, Pip, FEEL-B, pest eat radius/speed, Home, `SEED_BAG_SOFT_CAP` konstanta (L7: debug 100 OK), bloom, Sort.

## Smokes (LEFTOVER-A)

1. `seed_bag = {clover: 6}` → `pull_seeds_to_arena(40)` → 4 pulled, bag clover 2.
2. `{daisy: 3}` → pulled 0, bag 3.
3. `{tulip: 8}` → 8 pulled, bag 0.
4. Auto-refill: polje 12, bag clover 8 → pour 8 (ili do cap), prag 12 ne 10.
5. Postojeći `arena_flow_b_smoke` ažurirati prag 10→12; orphan test **ne** smije zahtijevati pour 1.

## Povezano

- FLOW-B A14 A15 A24 u [[ideje-arena-grupe|ARENA-01 grupe]]  
- [[ideje-arena-leftover-pitanja|L2 L7]] · [[ideje-arena-leftover-popup|kad pull=0 / hide]] · [[ideje-arena-leftover-grant|debug 100]] · [[ideje-arena-leftover-field|field neparni T1]]
