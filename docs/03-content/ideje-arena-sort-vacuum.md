---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, vacuum, leftover, pest, t3, scratch]
povezano:
  - ideje-arena-sort
  - ideje-arena-sort-math
  - ideje-arena-sort-pour
  - ideje-arena-sort-pitanja
  - ideje-arena-leftover-field
  - ideje-arena-pest
  - plan-prompts-arena-sort
ai_sažetak: "ARENA-03 vacuum — T1-eq <4; VAC-A unbounded; VAC-F let; VAC-L lock samo bag <4."
---

# IDEJE — ARENA-03 vacuum (nema T3 → korpica + lock)

> [[ideje-arena-sort|hub]]. **SORT-B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅.** Overlay [[ideje-arena-leftover-popup|B+C]] **ne dirati**. Grant [[ideje-arena-leftover-grant|D]] **ne dirati**.  
> Freeze: [[ideje-arena-sort-pitanja|S5 S6 S10–S13 S15 S26–S32]]. Chat 2026-08-29: **asap_no_t3**.  
> Leftover-E (`_resolve_stranded_t1`, 3→1 bag + 2 polje) se **ne implementira**. Ovaj vacuum radi suprotno.

## Rupa koju pour A i E ne zatvaraju

Pour A ostavlja remainder u torbi **prije** igre. Muncher jede **tijekom** igre. E vraća samo neparni T1 i ostavlja par — igrač i dalje vidi 2 clover + osjećaj „nisam gotov s daisyjem“, a T3 ionako nema.

SORT-B: **nema T3 puta za taj tip** → polje se očisti od tog tipa, torba dobije T1. Lock dok je bag &lt; 4; ako leftover zbroji ≥4, tip se **opet trese** (VAC-L).

## Pravilo

Po `type_id`, nakon eat, uspješnog mergea, dropa bez mergea, i nakon pour/refill (isti helper `_resolve_t3_starved_types`):

1. Izračunaj `t1_eq` ([[ideje-arena-sort-math|math]]). Bag T1 u zbroju **samo** ako `bag[type] >= 4` i tip **nije** pour-locked (SORT-A ionako ne trese remainder).
2. Ako `t1_eq >= 4` → ništa za taj tip.
3. Ako `t1_eq < 4` i na polju ima chipova tog tipa (T1 ili T2):
   - Idle, **ne** dragging (kao T2 recycle). Ako su svi u drag — skip, sljedeći hook ponovi.
   - T1/T2: `add_seeds_to_bag_unbounded` (T2 = 2 T1) + ghost let u korpicu (VAC-F). Soft cap 40 se **ne** diže; vacuum **ne** skipa kad je debug bag već preko 40.
   - T3 se ne vraća (nema ga kao chip).
   - Dodaj `type` u session lock **samo ako** bag nakon add &lt; 4; inače unlock (VAC-L).
4. Chipovi se vraćaju s polja i kad je suma baga ≥ 40 (debug). Soft cap konstanta ostaje 40.

Ime helpera `_resolve_t3_starved_types`. Redoslijed vs FLOW-A: **vacuum prvo**, pa `_resolve_stranded_t2`. Nakon `_try_auto_refill` na eat/merge: **drugi** vacuum (H3). `_pour_available_seeds` nakon spawna: vacuum pa T2. Drop bez mergea: vacuum.

## VAC-A (playtest 2026-08-29) — H1–H3

Isprekidani leftover (1–3 T1, ne uvijek 5) nije S11. SORT-B je lagao da T3 put postoji, ili nije smio vratiti sjeme.

| Hipoteza | Što se događalo | Fix |
|----------|-----------------|-----|
| **H1** | Debug torba 100 → `remaining_capacity` 0 → vacuum skip | `add_seeds_to_bag_unbounded` samo za vacuum |
| **H2** | 3 polje + 1–3 u torbi = eq ≥ 4, a pour skipa `bag < 4` | `t1_eq` bag samo pourable (≥4, unlocked) |
| **H3** | Vacuum prije refill; pour nije zvao vacuum | drugi prolaz nakon refill; vacuum u `_pour_available_seeds` |
| **H4** | Drop bez mergea ne zove vacuum | vacuum na `_on_chip_released` i bez snap-a |
| **H5** | 5 T1 / eq ≥ 4 ostaje | nije bug (S11); smoke kontrola |

Ne leftover-E. Ne frame tick. Overlay/grant/CHAIN pour (osim lock čitanja) **ne dirati**.

## Asap = 3 T1 odmah

Ne čekati da igrač spoji 2 u T2. 3 daisy T1 → 0 na polju, bag +3, daisy locked. Buttercup na polju ostaje.

5 daisy → ne vacuum. 1 T2 + 1 T1 (eq 3) → vacuum oba, bag +3.

## Lock (S6 / S31)

In-memory set (nije save key). **S31:** lock drži samo dok `bag[type] &lt; 4`. Nakupljeni leftover (dva vala, remainder koji nije stao + vacuum) ≥4 → unlock, autopour/tap trese.

**Clear** na Done / Back. Overlay `n/4` za stvarni remainder 1–3.

Primjer suncokret: cap 40 reže val. Višak s polja + višak iz sljedećeg vala = 6 u vreći. Stari S6 je to locked do Done; VAC-L trese 6.

## VAC-L (playtest 2026-08-29) — leftover opet u pour

Stari S6 lock-do-Done: 6 suncokreta u vreći (dva viška) + prazno polje = run „gotov“. S31 unlock na ≥4. S32: nakon vacuuma ako je polje prazno i bag pourable → jedan pour. Boot `_try_auto_refill` na praznom polju i dalje 0.

## Kad se ne pali

- Frame tick.
- Overlay open.
- `set_arena_page_active` sam.
- Tip t1_eq ≥ 4 (S11: 5 T1; 3 polje + pourable bag ≥4).

## FLOW-A T2

Ostaje za slučaj t1_eq ≥ 4 (npr. 1 T2 + 2 T1 + bag 0 = 4, T2 ima T1 put). Vacuum ne dira taj slučaj. Kad t1_eq &lt; 4, vacuum skine T2 kao 2 T1 umjesto da čeka FLOW-A „nema para“.

## VAC-F — let u korpicu

Nestanak chipa izgleda kao bag. State (bag + lock + `_chips`) ostaje **odmah** (VAC-A). Vizual: ghost (`ArenaVacuumFly`, nije `ArenaSeedChip`) leti do usta vreće (~0.38 s, stagger ~0.05 s, scale → 0.2), vreća punch na dolasku.

Isti helper za FLOW-A leftover T2 recycle. **Ne** pest eat, **ne** merge partner, **ne** Done/Back leftover. FEEL-B flash se **ne** spaja s letom. SFX nije ovaj slice. Done/Back kill tween + ghost.

## FEEL-B

Ostaje za preostale parove. Ne spajati clear-flash s VAC-F letom. Nije fail. Nema coina.

## Pest FSM

Ne dirati brzinu, eat duration, T3 freeze 2 s. Eat callback **nakon** `_remove_chip` mete zove vacuum (Muncher je već smanjio t1_eq).

## Overlay

Vacuum **ne** otvara overlay. Overlay na tap kad nema pourable unlocked tipa (postojeći B). C hide ostaje.

## Što vacuum nije

- Nije leftover-E (neparni T1, ostavi par).
- Nije pour-complete 1–3 iz torbe (S4: &lt;4 se ne trese).
- Nije D.
- Nije IAP / coin za leftover.
- Nije `SAVE_VERSION`.

## Smokes

**SORT-B** `arena_sort_b_smoke`: 3 clover → bag + lock; 5 ostaju; eat 4→vacuum 3; locked daisy **3** ne poura, buttercup da.

**VAC-A** `arena_vacuum_stuck_smoke`: daisy bag 50 + 3 clover → vacuum clover; 3+3 remainder → field 0 bag 6; 5 clover ostaju; 3 polje + bag 8 ostaju; pour daisy vacuumira leftover clover bez mergea.

**VAC-F** `arena_vacuum_fly_smoke`: 3 clover → 0 chipova na polju, bag 3, lock; helper `_vacuum_fly_chip` postoji (ghost nije chip).

**VAC-L** `arena_vacuum_l_smoke`: 3+3 remainder → pourable 6; dva vala leftover; 3 ostaje locked; polje 0 ručni refill 0; S32 pour na praznom polju.

## Povezano

- [[ideje-arena-sort-pitanja|S5 S6 S10–S16]] · [[ideje-arena-leftover-field|E]] (superseded)
- [[../06-production/plan-prompts-arena-sort|SORT-B]] · VAC-A · VAC-F · VAC-L
