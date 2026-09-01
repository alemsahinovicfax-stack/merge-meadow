---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, math, leftover, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-pour
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena-leftover-pitanja
  - ideje-arena-sort-math
  - merge-arena-v1.1
ai_sažetak: "ARENA-02 math — pour floor-4 u torbi; field mid-session T1 parovi (n%2); n/4 HUD; cap 40 vs bag 100."
---

# IDEJE — ARENA-02 math (4 T1 = T3)

> [[ideje-arena-leftover|hub]]. Freeze **L0b**: pour višekratnik 4 **po `type_id`**.  
> **Nasljednik:** [[ideje-arena-sort-math|ARENA-03 math]] — t1_eq, sav pour, vacuum &lt; 4. Overlay `n/4` ostaje.  
> Kod mergea (ne mijenja se ovim trackom): T1+T1 → T2, T2+T2 → T3 crystal, `MAX_MERGE_TIER = 3`.

## Zašto 4

Jedan T3 **košta** četiri T1 istog tipa:

```
T1  T1  →  T2
T1  T1  →  T2
T2  T2  →  T3
```

Ako na polje staviš **3** daisy, možeš napraviti jedan T2 i ostaje jedan T1 — **nema** T3. Ako staviš **5**, napraviš jedan T3 i ostaje jedan T1 na polju — pour A to sprječava. Ako staviš **4**, put je čist dok Muncher ne pojede jedan — tada [[ideje-arena-leftover-field|E]] skine neparni T1.

„Dovoljno za T3“ u torbi: `bag[type] >= 4`.  
Ostatak koji **nikad** ne ide na polje: `bag[type] % 4` ∈ {0,1,2,3}.  
Pour količina za taj tip: `floor(bag[type] / 4) * 4`.

## Copy `n/4`

U stuck overlayu (LEFTOVER-B) svaki red pokazuje **koliko imaš / koliko treba za jedan T3**, ne „koliko fali“ kao zaseban broj.

| U torbi | Prikaz | Čitanje |
|---------|--------|---------|
| 1 daisy | `1/4` | Nemaš ni pola puta. |
| 2 daisy | `2/4` | Pola. |
| 3 daisy | `3/4` | Još jedan T1 pa T3. |
| 4+ | ne vidi se u stuck overlayu | Pour je već skinuo višekratnike 4; stuck znači svi tipovi < 4. |

`5/4` **se ne crta** u normalnom toku: prvo pour skine 4, ostane 1 → kasnije `1/4`. L5: tipovi s count 0 se **ne** prikazuju.

Ista lista kao kamp (`get_seed_bag_entries`: rarity pa ime). Samo se mijenja **count label**, ne layout chipa.

## Tablica — jedan tip

Pretpostavka: dovoljno slota na polju, nema drugih tipova, pest ne jede.

| Bag prije | Pour | Na polju | Bag poslije | Može T3 s tog vala? |
|-----------|------|----------|-------------|---------------------|
| 0 | 0 | — | 0 | — |
| 1 | 0 | — | 1 | ne |
| 2 | 0 | — | 2 | ne |
| 3 | 0 | — | 3 | ne |
| 4 | 4 | 4 T1 | 0 | da, 1 T3 |
| 5 | 4 | 4 T1 | 1 | da + 1 u torbi |
| 6 | 4 | 4 T1 | 2 | da + 2 u torbi |
| 7 | 4 | 4 T1 | 3 | da + 3 u torbi |
| 8 | 8 | 8 T1 | 0 | da, 2 T3 |
| 20 | 20 | 20 T1 | 0 | da, 5 T3 (ako cap dopusti sve odjednom) |

Cap **polja** je 40 (`ARENA_MAX_CHIPS`). 20 clover stane. 48 clover: prvi val 40 (10×4), bag 8, sljedeći auto-pour 8.

## Mixed tipovi

Pour je **po tipu**, ne „ukupan bag % 4“.

Primjer: clover 6, daisy 3, tulip 8, sunflower 1.

| Tip | floor×4 | Ostaje |
|-----|---------|--------|
| clover | 4 | 2 |
| daisy | 0 | 3 |
| tulip | 8 | 0 |
| sunflower | 0 | 1 |
| **suma pour** | **12** | bag 2+3+1=6 |

Dvanaest T1 na polje — sve mergeable do T3 (3 T3: jedan clover, dva tulip). Torba: clover 2, daisy 3, sunflower 1. Sljedeći tap vreće: **nema** ×4 → overlay.

## Cap 40 vs debug 100

`SEED_BAG_SOFT_CAP` 40 ograničava **dodavanje** u torbu u produkciji. Playtest grant 5×20 = 100 smije biti iznad capa (kao `ensure_dev_unlocked_seeds`). Pour **ne** gleda soft cap; gleda **slobodne slotove polja** i floor-4.

Ako je polje prazno i bag 100 (20×5 tipova): max 40 chipova. Algoritam i dalje bira queue (rarity / A15 orphan **samo ako** količina ostaje višekratnik 4 — L2). Smije npr. 8+8+8+8+8 ili 20+20 ako prva dva tipa popune 40. Svaki chunk po tipu ostaje `k*4`.

## Polje vs torba — tko drži ostatak

Dva brojača, ne miješati:

| Gdje | Pravilo | Operator |
|------|---------|----------|
| **Pour** (torba → polje) | samo `floor(n/4)*4` po tipu | `n % 4` ostaje u torbi |
| **Field** mid-session (E) | T1 istog tipa paran count | `n % 2 == 1` → 1 T1 natrag u torbu |
| T2 | FLOW-A | T2 bez para → 2× T1 u torbu |

| Gdje | Što smije biti |
|------|----------------|
| Polje | T1 s parom (paran broj po tipu, nakon E). T2 dok FLOW-A kaže da ima para. T3 crystal. |
| Torba | Pour remainder `n%4`, plus T1 koji je E vratio s polja, plus što još nije istreseno. |

Odd T1 **namjerno** žive u torbi. Pour ih ne stavlja van. Muncher ih više ne ostavlja na polju (E). FEEL-B ostaje za trenutak dok resolve skine chip.

## Što math ne rješava sam

- Muncher jede 1 od 4 → 3 T1. Pour A to **ne** sprječava. [[ideje-arena-leftover-field|E]] / L31.
- FLOW-A leftover T2 ako T2 ostane bez para (pest pojeo partnera).
- Kamp trade / gredice / crystal — ista torba; overlay samo **prikaz** `n/4`.
- Overlay hide / debug 100 nisu math — [[ideje-arena-leftover-popup|C]] · [[ideje-arena-leftover-grant|D]].
- 50 T1 u starom playu = `ensure_dev` 5×10 — D ✅ to zamjenjuje freeze 100.

## Povezano

- [[ideje-arena-leftover-pour|pour]] — kada se trese, refill 12  
- [[ideje-arena-leftover-field|field]] — neparni T1 na polju dok traje igra  
- [[ideje-arena-leftover-popup|popup]] — kad se ne trese; hide prije Camp  
- [[ideje-arena-leftover-grant|grant]] — debug 100 T1  
- [[ideje-arena-leftover-pitanja|L0b L1 L3 L5 L7 L21–L37]]
