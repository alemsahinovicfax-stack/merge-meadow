---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, arena, sort, pour, vacuum, plan, prompt]
povezano:
  - ideje-arena-sort
  - ideje-arena-sort-grupe
  - ideje-arena-sort-pitanja
  - ideje-arena-sort-math
  - ideje-arena-sort-pour
  - ideje-arena-sort-vacuum
  - ideje-arena-leftover
  - plan-prompts-arena-leftover
  - plan-prompts-arena
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi ARENA-03 — P0 ✅ A ✅ B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅."
---

# Plan promptovi — ARENA-03 sort / pour sve / T3 vacuum

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **SORT-P0 → A → B → VAC-A → VAC-F → VAC-L**. Ne spajati A i B. **Ne LEFTOVER-E.** Overlay B/C i grant D se ne dira.  
> **Grupe:** [[../03-content/ideje-arena-sort-grupe|ideje-arena-sort-grupe]] · freeze [[../03-content/ideje-arena-sort-pitanja|pitanja]] · hub [[../03-content/ideje-arena-sort|ideje-arena-sort]]  
> **Grana:** **`master`**. Nije D0 blocker. Kanon [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] se **ne** prepisuje dok „dodaj u scope“.

**SORT-P0** ✅ 2026-08-29 (docs). **A** ✅ 2026-08-29 (pour CHAIN). **B** ✅ 2026-08-29 (vacuum). **VAC-A** ✅ 2026-08-29 (over-cap + pourable bag + drugi prolaz). **VAC-F** ✅ 2026-08-29 (ghost let u korpicu). **VAC-L** ✅ 2026-08-29 (lock samo bag &lt; 4). Leftover-E kod **ne**.

## Freeze (sažetak za agente)

S1: pour **sav** `bag[type]` ako ≥4 i tip nije session-locked. Ne `floor(n/4)*4`. Tap i auto isto.  
S2: queue po `SeedUnlockConfig.CHAIN`, cijeli tip pa sljedeći. Ukloniti „prva 2 najniže rarity“. „Rose“ u chatu nije `type_id`.  
S3: cap **40**, `ARENA_AUTO_REFILL_AT` **12**, polje **0** ne auto.  
S4: `bag[type] < 4` → skip. Ostaje T1 u torbi.  
S5: t1_eq = T1_polje + 2×T2_polje + **pourable** T1_bag (≥4 i unlocked). Ako **&lt; 4**, vacuum **sve** idle chipove tog tipa u torbu kao T1 (T2→2). **Asap** — 3 T1 sva u bag, ne 1+2 (to je E, ne raditi). VAC-A: unbounded add preko cap; vacuum nakon refill/pour/drop. VAC-F: ghost leti u korpicu; state odmah.  
S6: lock tip **samo dok bag &lt; 4** (S31). ≥4 leftover opet pour. S32: prazno polje nakon vacuuma s pourable → jedan pour.  
S7/S20: overlay You need more seeds + n/4 **ostaje** (B+C). Auto-refill ne otvara overlay (S14).  
S8: ne `_resolve_stranded_t1`. S11: 5 T1 ne vacuum. S18: nema SAVE_VERSION. S21: ne dira C hide / D grant.

G4 ne kodirati. Citiraj „Ne dirati“ u A i B.

Ne dirati: combo HUD, daily, Pip, pest FSM osim eat→vacuum, Home, Shop, AdMob, NeedMoreSeedsOverlay, `_hide_need_more_overlay`, `apply_debug_leftover_test_bag`, kanon spec. A ne vacuum. B ne prepisuje floor-4 ponovo (A već uklonio).

---

## Prompt — SORT-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow ARENA-03 docs freeze — sort pour po CHAIN, sav T1 ako ≥4, vacuum kad t1_eq < 4 asap, overlay ostaje.

Dokumentiraj S0–S25 opširno (hrvatski scratch). Leftover-A floor-4 + remainder u torbi puca uz Munchera. Queue danas miješa (floor-4 + prva 2 rarity). Chat: izbaciti čuvanje viška na pouru; sva sjeme redom; kad ni polje ni torba nemaju T3 za tip, višak u korpicu i lock za taj run; start <4 se ne trese; cap 40 refill 12; overlay lista na kraju ostaje. Vacuum asap (3 T1 sva u bag, ne čekati T2). Daisy/rose je primjer — CHAIN clover daisy buttercup tulip sunflower pumpkin watermelon. Leftover-E ne kodirati. Overlay B+C i grant D ostaju. Fair F2P: nema IAP.

Nema game/ u P0 osim citata. Ne dirati merge-arena-v1.1.md. Ne CHECKPOINT sljedeci_korak (ostaje D0-P). Grana master.

Fajlovi: NOVI ideje-arena-sort.md hub; sort-math / pour / vacuum / pitanja / grupe; plan-prompts-arena-sort.md P0 A B. Edit leftover hub: nasljednik ARENA-03, E superseded. Overlay/grant kratki link. Wire _index, ideje-arena, ideje-kad-predloziti, CHECKPOINT samo ARENA red + zadnja_sesija, changelog.

Relevantno: game_state.gd pull_seeds_to_arena _build_arena_pour_queue SeedUnlockConfig.CHAIN; merge_arena_controller ARENA_AUTO_REFILL_AT; ideje-arena-leftover L0b L31; leftover-popup; leftover-grant.
```

---

## Prompt — SORT-A (Pour sav T1 po CHAIN)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-03 SORT-A — pour sav T1 po unlock lancu; skip <4 i locked; cap 40; refill 12.

Freeze G1: S1 pull_seeds_to_arena / _build_arena_pour_queue NE floor-4; max_count slobodni slotovi bez floor-4. S2 red SeedUnlockConfig.CHAIN, za svaki tip stavi bag[type] komada ako >=4 i nije u session lock setu; UKLONITI petlju koja uzima samo prva 2 lowest-rarity. S3 ARENA_AUTO_REFILL_AT 12, ARENA_MAX_CHIPS 40, polje 0 NE auto. S4 skip 1–3. S9 nema A15 pour 3 na orphan. S14 auto pull 0 NE overlay. S19 mythic isto.

Ne vacuum u A (lock set smije postojati prazan ili stub da skip radi; puni lock je B). Ne overlay. Ne grant D.

Smokes: daisy 31 + buttercup 30, polje 0, pour 40 → 31 daisy + 9 buttercup, bag buttercup 21 daisy 0. clover 3 + daisy 8 → samo 8 daisy, clover 3. Ažurirati arena_leftover_a_smoke: 6 clover → 6 pulled 0 bag (ne 4/2); 3 daisy i dalje 0 pulled. Cap 40. Auto prag 12. Polje 0 ne auto.

Headless --rendering-driver opengl3. Ne paliti GUI usred A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay, apply_debug_leftover_test_bag, combo/daily/Pip, pest FSM, Home, Shop, AdMob, SAVE_VERSION, kanon spec, leftover-E.

Relevantno: docs/03-content/ideje-arena-sort-pour.md, ideje-arena-sort-pitanja.md S1–S4 S9 S14, ideje-arena-sort-grupe.md G1, game_state.gd, merge_arena_controller.gd, arena_leftover_a_smoke.gd, arena_flow_b_smoke.gd.

Acceptance: 31+30 scenario; <4 skip; nema floor-4; refill 12 i cap 40; overlay netaknut.
```

---

## Prompt — SORT-B (Vacuum T3-starved + lock)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-03 SORT-B — čim tip nema T3 put (t1_eq < 4), svi idle chipovi tog tipa u torbu kao T1; lock pour do Done.

Freeze G2: S5 t1_eq = field T1 + 2*field T2 + bag T1; ako < 4 vacuum sve idle T1/T2 tog tipa (T2 → add_seeds_to_bag 2). Asap: 3 T1 → 0 polje bag +3, NE leftover-E (1 bag + 2 polje). S6 lock set in-memory, clear na Done/Back; pour skip locked. S10 T2 kao FLOW-A. S11 5 T1 ne vacuum. S12 _pest_eat_chip i nakon mergea; helper npr. _resolve_t3_starved_types; predloženo PRIJE _resolve_stranded_t2. S13 ne dragging; skip ako nijedan idle. S15 remaining_capacity; soft cap 40. S16 FEEL-B ostaje. S8 NE _resolve_stranded_t1.

Ne dirati overlay B+C, pour CHAIN iz A osim čitanja locka, grant D, pest tajmere.

Smokes: 3 clover T1 → 0 polje bag +3 locked; 5 clover ostaju; 4 clover eat 1 → vacuum 3; daisy locked buttercup 8 poura buttercup; leftover_b/c i SORT-A smokes prolaze; FLOW-A T2 recycle za tip s t1_eq >= 4.

Headless --rendering-driver opengl3. Ne GUI usred B. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay, pull floor (već uklonjen u A), apply_debug_leftover_test_bag, combo/daily/Pip, Home, Shop, AdMob, kanon spec.

Relevantno: docs/03-content/ideje-arena-sort-vacuum.md, ideje-arena-sort-pitanja.md S5–S6 S10–S16, merge_arena_controller.gd _pest_eat_chip _resolve_stranded_t2.

Acceptance: 3 T1 asap u torbu + lock; 5 T1 žive; drugi tip poura; overlay na kraju i dalje.
```

---

## Prompt — VAC-F (Ghost let u korpicu)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-03 VAC-F — leftover sjeme leti u korpicu umjesto da nestane.

Freeze S26–S30: vacuum T1/T2 i FLOW-A T2 recycle lete ghostom do usta vreće (~0.38 s, stagger 0.05, scale 0.2, cubic in). Bag + lock + _chips odmah (VAC-A). Ghost nije ArenaSeedChip. Bag scale punch na dolasku. Ne pest eat, ne merge, ne Done leftover. Ne SFX. FEEL-B ostaje, ne spajati flash. Done/Back kill tween.

Ne dirati overlay B+C, grant D, CHAIN pour, t1_eq math, pest FSM, SEED_BAG_SOFT_CAP.

Smokes: arena_vacuum_fly_smoke 3 clover → 0 chipova bag 3 lock + fly helper; vacuum_stuck, sort_b, leftover a/b/c, flow a/b prolaze.

Headless --rendering-driver opengl3. Ne GUI usred F. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay, apply_debug_leftover_test_bag, combo/daily/Pip, Home, Shop, AdMob, kanon spec, leftover-E.

Relevantno: docs/03-content/ideje-arena-sort-vacuum.md VAC-F, ideje-arena-sort-pitanja.md S26–S30, merge_arena_controller.gd _resolve_t3_starved_types _resolve_stranded_t2, arena_seed_bag.gd.

Acceptance: 3 T1 nestaju kao let u vreću; state odmah; smokes zeleni.
```

---

## Prompt — VAC-L (Leftover ≥4 opet u autopour)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-03 VAC-L — vacuum leftover koji se u vreći skupi na ≥4 ide opet u tap/autopour.

Freeze S31–S32: lock samo dok bag[type] < 4; nakon vacuuma ako ≥4 unlock. is_arena_pour_locked false kad n ≥ 4. Overlay isto. Polje 0 na boot/_try_auto_refill ne auto. Iznimka: kraj _resolve_t3_starved_types ako vacuumirao i polje prazno i pourable → jedan _pour_available_seeds. Ne leftover-E.

Ne dirati overlay hide C, grant D, CHAIN, VAC-A math, VAC-F tween, pest FSM.

Smokes: arena_vacuum_l_smoke (3+3 remainder pour 6; dva vala; 3 lock skip; empty refill 0; S32 pour). sort_b i leftover_a: locked daisy 3 skip, ne daisy 20.

Headless --rendering-driver opengl3. Ne GUI usred L. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay hide, apply_debug_leftover_test_bag, combo/daily/Pip, Home, Shop, AdMob, kanon spec.

Relevantno: docs/03-content/ideje-arena-sort-pitanja.md S31 S32, ideje-arena-sort-pour.md, game_state.gd lock/queue, merge_arena_controller.gd _resolve_t3_starved_types.

Acceptance: 6 leftover suncokreta trese se u istom runu; 3 i dalje skip; empty field ručni refill 0.
```

---

## Redoslijed i ovisnosti

1. **SORT-P0** docs — **✅ 2026-08-29**.  
2. **SORT-A** pour CHAIN + skip &lt;4 — **✅ 2026-08-29**.  
3. **SORT-B** vacuum + lock — **✅ 2026-08-29**.  
4. **VAC-A** over-cap + pourable bag + drugi prolaz — **✅ 2026-08-29**.  
5. **VAC-F** ghost let u korpicu — **✅ 2026-08-29**.  
6. **VAC-L** lock samo bag &lt; 4 — **✅ 2026-08-29**.  
7. Ne spajati A i B. Ne LEFTOVER-E. Ne COMB/FLOW rewrite.  
8. Overlay C i grant D već ✅ (ARENA-02).

## Povezano

- [[../03-content/ideje-arena-sort|hub]] · [[../03-content/ideje-arena-sort-grupe|grupe]] · [[../03-content/ideje-arena-sort-pitanja|pitanja]]
- [[plan-prompts-arena-leftover|ARENA-02 leftover]] P0…D ✅ · E **ne**
- [[plan-prompts-arena|ARENA-01]] COMB–FEEL ✅
- [[CHECKPOINT|CHECKPOINT]]
