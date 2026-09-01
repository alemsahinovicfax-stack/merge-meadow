---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, sort, pitanja, freeze, scratch]
povezano:
  - ideje-arena-sort
  - ideje-arena-sort-grupe
  - ideje-arena-sort-pour
  - ideje-arena-sort-vacuum
  - plan-prompts-arena-sort
  - ideje-arena-leftover-pitanja
  - ideje-arena-pitanja
ai_sažetak: "ARENA-03 pitanja S0–S32 — pour CHAIN; vacuum t1_eq <4; lock samo bag <4 (VAC-L); VAC-F let; overlay ostaje; E ne."
---

# IDEJE — ARENA-03 pitanja (S0–S32)

> [[ideje-arena-sort|hub]]. Freeze **2026-08-29** (pour sve, vacuum asap, VAC-F let, VAC-L leftover ≥4 opet pour).  
> ARENA-02 L0–L37 **ostaju kao povijest**. **L0b override** ovim trackom. **L31–L37 / E kod se ne rade.** L0c (12/40), L0d overlay, L21–L30 C+D **vrijede**.  
> ARENA-01 A13 Sort gumb i dalje **C** (nema gumba). Ovo nije taj Sort.

## Freeze tablica

| # | Pitanje | Odluka |
|---|---------|--------|
| **S0** | Što popravljamo? | Floor-4 remainder u torbi uz Munchera; pomiješan pour queue; mrtvo sjeme na polju kad nema T3. |
| **S1** | Pour math? | **Sav** `bag[type]` ako ≥4 i nije locked. Ne `floor(n/4)*4`. Ručni tap **i** auto. |
| **S2** | Redoslijed tipova? | `SeedUnlockConfig.CHAIN` (clover…watermelon). Cijeli tip pa sljedeći. „Rose“ u chatu = primjer, nije flora. |
| **S3** | Cap / refill / polje 0? | **40** / **12**. Polje **0** ne auto-poura (boot / ručni refill). S32: nakon vacuuma ako je polje prazno i bag ≥4 — jedan pour. |
| **S4** | Tip s 1–3 T1 na pouru? | **Ne trese se.** Ostaje T1 u korpici. |
| **S5** | Kad vacuum? | Čim `t1_eq < 4` (T1_polje + 2×T2_polje + **pourable** bag ≥4 unlocked). **Asap.** Ne čekati T2 od 3 T1. Remainder 1–3 u torbi **nije** put. |
| **S6** | Lock? | Samo dok `bag[type] &lt; 4` (S31). Stari „do Done i s 20 u vreći“ **ne**. |
| **S7** | Overlay na kraju? | **Da.** B+C: **You need more seeds!** + `n/4`. Tap → Camp. Hide C ostaje. |
| **S8** | Leftover-E / L31? | **Ne implementirati.** Vacuum je zamjena (3→sva 3, ne 1+2). |
| **S9** | A15 orphan pour 3? | **Ne.** Nema floor-4 orphan-first. |
| **S10** | T2 na vacuum? | Da, kao FLOW-A: 2× T1 u torbu. |
| **S11** | 5 T1 na polju? | **Ne** vacuum (t1_eq ≥ 4). |
| **S12** | Hookovi? | Eat, merge, drop bez mergea, pour/refill (drugi prolaz). |
| **S13** | Koji chip? | Idle, ne dragging. Skip ako nijedan slobodan. |
| **S14** | Auto-refill pull 0 — overlay? | **Ne** (L15). Overlay samo tap vreće. |
| **S15** | Bag full na vacuum? | VAC-A: **vrati** chipove (`add_seeds_to_bag_unbounded`). Soft cap 40 se ne diže. |
| **S16** | FEEL-B? | **Ostaje.** |
| **S17** | Combo / daily / Pip? | **Ne dirati.** |
| **S18** | SAVE_VERSION? | **Ne.** Lock nije persist. |
| **S19** | Mythic? | **Da**, isto CHAIN / t1_eq / skip &lt;4. |
| **S20** | Overlay `n/4` copy? | **Ostaje.** Vacuumirani leftover i dalje `3/4`. |
| **S21** | Grant D / overlay C? | **Ne dirati.** |
| **S22** | Coin sink leftover? | **Ne.** |
| **S23** | Milestone / kanon? | v1.1+ scratch. Spec se ne prepisuje dok „dodaj u scope“. |
| **S24** | Grana / prompti? | **`master`**. SORT-P0 → A → B → VAC-A → VAC-F → VAC-L. Ne spajati A+B. Ne LEFTOVER-E. |
| **S25** | Pest FSM? | Ne dirati tajmere/T3 freeze. Eat samo zove vacuum. |
| **S26** | Što leti u korpicu? | Vacuum leftover + FLOW-A T2 recycle. **Ne** eat, merge, Done/Back. |
| **S27** | Kad bag/lock? | **Odmah** (VAC-A). Let je samo vizual. Ghost nije `ArenaSeedChip`. |
| **S28** | Trajanje / put? | ~0.38 s do usta vreće, stagger ~0.05 s, scale → 0.2, cubic in. |
| **S29** | Korpica „uzima“? | Scale punch na dolasku. Broj na vreći već od statea. |
| **S30** | SFX / FEEL-B? | Nema SFX ovdje. FEEL-B ostaje, ne spajati s letom. |
| **S31** | Lock vs nakupljeni leftover? | Lock samo `bag &lt; 4`. Ako vacuum/remainder zbroji **≥4**, unlock — tap i auto trese. |
| **S32** | Polje 0 nakon vacuuma s ≥4 u vreći? | Jedan pour. Boot / `_try_auto_refill` na praznom polju i dalje 0. |

## Zašto ove odluke

### S1 — ne čuvati `n%4` na ulazu

Muncher jede. Remainder u torbi ne krpa polje (stari L2). Igrač trese **što ima** (≥4), mergea, pa leftover **nastane** i ode u korpicu.

### S2 — CHAIN, ne „2 rarity“

Kod danas prekida queue nakon 2 tipa najniže rarity. To nije „po tipu i hronologiji“. Daisy/rose u chatu je scenarij, ne novi `type_id`.

### S4 vs S5

&lt;4 **prije** poura = ne izlazi. &lt;4 **na polju+torbi usred igre** = vacuum (nastalo od merge/eat). Isti broj 4, dva trenutka.

### S5 asap, ne leftover-E

3 T1 nema T3. Ostavljanje para je drugi design (E). Freeze: skloni sve, lock, sljedeći tip.

### S6 lock do Done

S4 već skipa 3. Stari lock-do-Done je blokirao suncokret 6 (dva viška / remainder koji nije stao). **S31:** lock samo dok bag &lt; 4.

### S31–S32 leftover opet u pour

Cap 40 reže tip na valove. Vacuum + remainder u vreći zbroje ≥4. Queue/overlay ne smiju tretirati to kao stuck. Polje 0 na boot ne auto; nakon vacuuma koji otvori ≥4 — jedan pour (S32).

### S7 overlay ostaje

Kad nijedan unlocked tip nema ≥4, vreća i dalje priča **trebam još sjemena**, ne prazan tap.

### S8 E ne

Dva suprotna pravila na 3 T1. Jedan track.

### S26–S29 let

Nestanak izgleda kao greška. Ghost do usta vreće + punch. State ostaje sinkron da smokes i refill ne čekaju tween.

## Što nije u S-tablici

Sort gumb, T4, ads, energy, fail, lasso, Home sezone, AdMob. ARENA-01 G5 constraints i dalje.

## Povezano

- [[ideje-arena-sort-grupe|grupe]] · [[../06-production/plan-prompts-arena-sort|prompti]]
- [[ideje-arena-leftover-pitanja|ARENA-02 L]] · [[ideje-arena-leftover-popup|overlay]] · [[ideje-arena-leftover-grant|D]]
