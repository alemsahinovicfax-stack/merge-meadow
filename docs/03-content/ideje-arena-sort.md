---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, sort, pour, vacuum, leftover, scratch]
povezano:
  - ideje-arena-sort-math
  - ideje-arena-sort-pour
  - ideje-arena-sort-vacuum
  - ideje-arena-sort-pitanja
  - ideje-arena-sort-grupe
  - plan-prompts-arena-sort
  - ideje-arena-leftover
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena
  - merge-arena-v1.1
  - ideje-kad-predloziti
  - CHECKPOINT
ai_sažetak: "ARENA-03 hub — pour sav T1 po CHAIN (ne floor-4); skip <4; vacuum kad T1-eq <4; overlay B+C i grant D ostaju; leftover-E superseded."
---

# IDEJE — Arena sort / T3 pour (ARENA-03 hub)

> **ID:** **ARENA-03** · v1.1+ (nije v1 launch blocker, nije D0-P).  
> **Kod:** **SORT-P0 ✅ A ✅ B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅**. Prompti: [[../06-production/plan-prompts-arena-sort|plan-prompts-arena-sort]]. Grupe: [[ideje-arena-sort-grupe|grupe]].  
> **Freeze:** S0–S30 **2026-08-29** (chat: pour sve, vacuum asap kad nema T3, let u korpicu) — [[ideje-arena-sort-pitanja|pitanja]].  
> **Prethodnik:** [[ideje-arena-leftover|ARENA-02 leftover]] P0…D ✅ · E-P0 docs ✅ · **E kod se ne radi.** Overlay B+C ✅. Grant D ✅.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — merge ostaje besplatan; overlay **nije** shop. [[../01-vision/design-pillars|Pillar 3]] — vacuum nije fail; sjeme ostaje u torbi.

## Pitch

ARENA-02 leftover-A je obećao: **na polju nema mrtvog T1**, jer se trese samo `k*4`. Remainder `n%4` živi u torbi. Overlay `3/4` ima smisla: „sačuvaj dok ne skupiš četvrti“.

**Muncher to ruši.** Pojede 1–3 sjemena usred vala. Tip koji je ušao kao čist ×4 više nije T3-sposoban. Remainder u torbi **ne pomaže** polje (L2: ne tresti 3 da se spoji s 1). Igrač vidi smeće na playfieldu **i** `3/4` u vreći — dvije priče.

Leftover-E bi vratio **jedan** neparni T1 i ostavio par za T2. Playtest želi drugo: **čim tip više ne može T3** (polje + torba < 4 T1-ekvivalenta), **svi** chipovi tog tipa idu u korpicu. Odmah. Ne čekati T2 od 3 T1. Za taj run taj tip se **više ne trese**. Ostali tipovi idu dalje.

Zato ARENA-03 **izbacuje** pred-ostatak u torbi na pouru. Tip s ≥4 T1 ide **sav** na polje, redom po unlock lancu, do capa 40. Auto-refill 12 ostaje. Tip s 0–3 na pouru **ne izlazi**. Na kraju, kad ništa više nema T3/pour puta — ista lista **You need more seeds!**.

ARENA-03 **nije** Sort gumb (ARENA-01 A13 C). Sort ovdje = **redoslijed queuea** prije rasipanja, u pozadini.

## Zašto leftover-A više nije dovoljan

| ARENA-02 L0b | ARENA-03 |
|--------------|----------|
| Pour `floor(n/4)*4` | Pour **sav** count tipa ako ≥4 i nije locked |
| Remainder čeka u torbi | Remainder nastaje **nakon** merge/Muncher, pa vacuum |
| E: 3 T1 → 1 bag + 2 polje | **Asap:** 3 T1 → 3 bag, lock tip |
| Queue: rarity, prva 2 tipa pa rest | Queue: **cijeli** `SeedUnlockConfig.CHAIN`, tip pa sljedeći |

Chat 2026-08-29: „nema smisla da ostaje [višak u torbici], gubi se logika zato što muncher jede.“

## Što kod danas radi (A ✅ B ✅)

| Komad | Ponašanje |
|-------|-----------|
| `_build_arena_pour_queue` | `CHAIN`, sav `bag[type]` ako ≥4 i nije locked. Nema floor-4. Nema „prva 2 rarity“. |
| `pull_seeds_to_arena` | `max_count` = slobodni slotovi, bez floor-4. |
| Auto-refill | `ARENA_AUTO_REFILL_AT = 12`, cap 40, polje 0 ne auto. **Ostaje.** |
| `_resolve_t3_starved_types` | `t1_eq < 4` → idle T1/T2 u torbu kao T1 + lock do Done. |
| FLOW-A | T2 bez para → 2× T1 u bag (nakon vacuuma). |
| Overlay B+C | **Ostaje.** Lista `n/4` na kraju. |
| Grant D | Freeze 100 T1. **Ostaje.** |
| Leftover-E | Docs only. **Ne kodirati.** Vacuum B je zamjena. |

## Igračev loop (cilj)

```
Torba: daisy 31, buttercup 30  (clover 0; "rose" u chatu = primjer sljedećeg tipa)
  → tap vreće: do 40 slota
      31 daisy, pa 9 buttercup
      bag: buttercup 21
  → igrač mergea daisy → T3 crystal
  → ostane 3 daisy (Muncher 0) → vacuum: 3 u torbu, daisy LOCKED ovaj run
  → polje ima buttercup; refill 12 trese još buttercup iz 21
  → Muncher pojede 3 buttercup od onih na polju+valu
      još T1-eq ≥ 4 → igra ide
  → kad buttercup T1-eq < 4 → vacuum + lock
  → tap vreće: nema tipa ≥4 unlocked → overlay You need more seeds! + n/4
  → tap → Camp
```

`3/4` i dalje znači: **nemaš četvrti T1 do T3**. Sada su to vacuumirani leftoveri, ne pred-ostatak koji pour nikad nije htio tresnuti.

## Freeze (sažetak)

Puna tablica: [[ideje-arena-sort-pitanja|pitanja]].

| # | Tema | Odluka |
|---|------|--------|
| **S0** | Bol | Floor-4 remainder + pomiješan queue + mrtvo sjeme nakon Munchera |
| **S1** | Pour | Sav T1 tipa ako ≥4 i nije locked. Ne `n%4` u torbi na ulazu |
| **S2** | Red | `CHAIN`: clover → daisy → buttercup → tulip → sunflower → pumpkin → watermelon. Primjer daisy/rose nije flora |
| **S3** | Cap / refill | 40 / 12. Polje 0 ne auto |
| **S4** | Start &lt;4 | Ne trese se. Ostaje T1 u korpici |
| **S5** | T3 prag | T1-eq = T1_polje + 2×T2_polje + T1_torba. Vacuum kad **&lt; 4**, **odmah** |
| **S6** | Lock | Taj tip se ne trese do Done. Drugi tipovi OK |
| **S7** | Overlay | B+C ostaje na kraju. `n/4` copy ostaje |
| **S8** | E / L0b | Override. E kod **ne** |

## Što ARENA-03 ne dira

Combo HUD/coins, daily, Pip/tint, pest FSM (brzina, eat duration, T3 freeze) osim eat→vacuum, Home, Shop, AdMob, `SAVE_VERSION`, kanon spec, grant D, overlay hide C, `SEED_BAG_SOFT_CAP` konstanta 40.

## Sliceovi

| Prompt | Što |
|--------|-----|
| **SORT-P0** | Ovi docs. Nema `game/` osim citata. **✅** |
| **SORT-A** | Pour: nema floor-4; CHAIN queue; skip &lt;4 i locked; cap 40; refill 12. **✅** |
| **SORT-B** | Vacuum T1-eq &lt; 4 + lock. **✅** |
| **VAC-A** | Over-cap add; bag u eq samo pourable; vacuum nakon refill/pour/drop. **✅** |
| **VAC-F** | Ghost let u korpicu + bag punch. **✅** |
| **VAC-L** | Lock samo bag &lt; 4; leftover ≥4 opet pour. **✅** |

Ne spajati A i B. Ne LEFTOVER-E. Overlay i D zasebno već gotovi.

## Povezano

- [[ideje-arena-sort-math|math]] · [[ideje-arena-sort-pour|pour]] · [[ideje-arena-sort-vacuum|vacuum]]
- [[ideje-arena-sort-pitanja|pitanja]] · [[ideje-arena-sort-grupe|grupe]]
- [[../06-production/plan-prompts-arena-sort|prompti]]
- [[ideje-arena-leftover|ARENA-02]] · [[ideje-arena-leftover-popup|overlay]] · [[ideje-arena-leftover-grant|grant D]]
- [[ideje-arena|ARENA-01]] A13 Sort gumb **nije** ovo
