---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, math, sort, t3, scratch]
povezano:
  - ideje-arena-sort
  - ideje-arena-sort-pour
  - ideje-arena-sort-vacuum
  - ideje-arena-sort-pitanja
  - ideje-arena-leftover-math
  - merge-arena-v1.1
ai_sažetak: "ARENA-03 math — T1-eq = T1 + 2×T2 + pourable bag (≥4); vacuum <4 asap; 3+3 remainder vacuum; 5 T1 još T3."
---

# IDEJE — ARENA-03 math (T3 put, ne pred-ostatak)

> [[ideje-arena-sort|hub]]. Freeze **S5**: vacuum kad T1-ekvivalent tipa **&lt; 4**. Chat 2026-08-29: **asap**, ne čekati T2 od 3 T1.  
> Merge (ne mijenja se): T1+T1 → T2, T2+T2 → T3 crystal, `MAX_MERGE_TIER = 3`.

## Zašto 4 i dalje vrijedi

Jedan T3 **košta** četiri T1 istog `type_id`:

```
T1  T1  →  T2
T1  T1  →  T2
T2  T2  →  T3
```

ARENA-02 je to pretvorilo u **pour pravilo**: na polje samo `k*4`. ARENA-03 to pretvara u **izlazno pravilo**: na polju (plus torba) smije biti mrtvo sjeme samo dok još ima T3 put. Čim nema, sjeme ide u korpicu.

## T1-ekvivalent (po tipu)

```
t1_eq(type) = T1_na_polju + 2 × T2_na_polju + pourable_bag(type)
pourable_bag = bag[type] ako ≥ 4 i tip nije pour-locked, inače 0
```

T3 na polju nije u zbroju — već je crystal / stash. Torba drži samo T1 (kao danas). Remainder `1–3` u torbi **nije** T3 put (SORT-A ne trese &lt;4) — VAC-A ga ne broji. T2 na polju broji kao 2 T1 jer FLOW-A / vacuum vraća T2 kao 2 T1.

| Stanje | t1_eq | T3 moguć? | Akcija SORT-B |
|--------|------:|-----------|---------------|
| 0 | 0 | ne | ništa (nema chipova) |
| 1 T1 polje, bag 0 | 1 | ne | vacuum 1 → bag |
| 3 T1 polje, bag 0 | 3 | ne | vacuum **sva 3** odmah (ne ostavljaj par) |
| 1 T1 + 1 T2, bag 0 | 3 | ne | vacuum → bag +3 T1 |
| 2 T2, bag 0 | 4 | da (jedan T3) | **ne** vacuum |
| 5 T1 polje, bag 0 | 5 | da | **ne** vacuum; igrač mergea |
| 3 T1 polje, bag 1 | 3 | ne | vacuum 3 (1 u torbi nije pourable) |
| 3 T1 polje, bag 3 | 3 | ne | vacuum 3 → bag 6 (H2 remainder) |
| 3 T1 polje, bag 8 | 11 | da | **ne** vacuum (pour će tresnuti) |
| 3 T1 polje, bag 0, locked | 3 | ne | vacuum (ako još nisu skinuti) |

Bag 8 + polje 3 = pourable T3 put: leftover-A **ne bi** tresnuo remainder &lt;4. VAC-A **vacuumira** 3+1 / 3+3 jer pour skipa. Čim je pourable bag ≥4, tip živi. Čim t1_eq (s pourable bagom) padne ispod 4, vacuum.

## 31 daisy + 30 buttercup

Chat primjer koristio „rose“; u lancu sljedeći nakon daisy je **buttercup**. Brojevi ostaju.

| | Daisy | Buttercup |
|--|------:|----------:|
| Start torba | 31 | 30 |
| `31 % 4` | 3 | 2 |
| Leftover-A bi tresnuo | 28 | 28 |
| ARENA-03 trese | **31** | **30** (kroz valove, cap 40) |

Prvi tap, prazno polje, 40 slota, clover 0:

```
queue: daisy ×31, buttercup ×30
pour: 31 daisy + 9 buttercup
bag: buttercup 21
```

Igrač spoji daisy do T3. 31 T1 = 7 T3 + **3** leftover (ako Muncher 0). 7×4 = 28; ostane 3. t1_eq daisy = 3 + bag 0 = 3 **&lt; 4** → vacuum 3 u torbu, daisy **locked**. Buttercup na polju (9 minus merge/eat) i bag 21 i dalje žive.

Muncher pojede 3 buttercup negdje u valu: 30−3 = 27 T1-eq ako je sve još T1. 27 ≥ 4 → **nema** vacuum. Kad preostane 3 (ili 1 T1+1 T2, itd. ispod 4), vacuum + lock.

## 3 T1 vs 5 T1

**3 T1, asap (freeze):** igrač **ne** stigne spojiti 2 u T2. Sva 3 lete u torbu. To je svjesno: T3 ionako nema; ostavljanje para na polju je leftover-E, a E se **ne** radi.

**5 T1:** jedan T3 + 1 leftover. Vacuum **ne** pali dok je 5 na polju. Nakon T3 ostane 1 → t1_eq 1 → vacuum 1.

## Copy `n/4` (overlay, ne pour)

Stuck overlay i dalje pokazuje **koliko T1 tog tipa imaš u torbi / 4**. Nakon vacuuma daisy 3 → red `3/4`. Tipovi s 0 se ne crtaju (L5). Pour više ne „čisti“ 4 prije stucka — stuck je „nema unlocked tipa ≥4“.

## Cap 40 vs bag 100

Pour gleda **slobodne slotove polja** (do 40), ne `SEED_BAG_SOFT_CAP`. Debug grant 100 (D) smije biti u dictu. SORT ne diže cap.

## Što math ne rješava sam

- Redoslijed queuea i skip locked — [[ideje-arena-sort-pour|pour]]
- Kad se pali vacuum, koji chip, bag full — [[ideje-arena-sort-vacuum|vacuum]]
- Overlay hide / grant 100 — ARENA-02 C / D

## Povezano

- [[ideje-arena-sort|hub]] · [[ideje-arena-leftover-math|ARENA-02 math]] (L0b override)
- [[ideje-arena-sort-pitanja|S1 S4 S5 S11]]
