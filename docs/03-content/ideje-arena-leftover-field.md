---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, leftover, field, pest, muncher, t1, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-math
  - ideje-arena-leftover-pour
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-pitanja
  - ideje-arena-leftover-grupe
  - ideje-arena-pest
  - plan-prompts-arena-leftover
  - ideje-arena-sort
ai_sažetak: "ARENA-02 field leftover — E-P0 docs; E kod superseded od ARENA-03 vacuum (3 T1 sve u torbu, ne ostavlja par)."
---

# IDEJE — ARENA-02 field leftover (Muncher vs ÷4)

> [[ideje-arena-leftover|hub]]. **LEFTOVER-E-P0** (ovi docs) ✅. **LEFTOVER-E kod ne implementirati** — zamjena [[ideje-arena-sort-vacuum|ARENA-03 vacuum]] (suprotno: 3 T1 **sva 3** u torbu + lock, ne ostavlja par). Overlay [[ideje-arena-leftover-popup|B+C]] **ostaje kakav jeste**. Grant 100 [[ideje-arena-leftover-grant|D]] ✅.  
> Freeze: [[ideje-arena-leftover-pitanja|L31–L37]] (L1 reopen). Chat 2026-08-28: **return_unmergeable**.  
> Kod danas: [`_resolve_stranded_t2`](../../game/scripts/camp/merge_arena_controller.gd) nakon eat/merge; [`_pest_eat_chip`](../../game/scripts/camp/merge_arena_controller.gd) ne vraća T1.

## Debug 100 vs field leftover

To **nije** ovaj mehanički bug.

[[ideje-arena-leftover-grant|LEFTOVER-D]] ✅ stavlja freeze **19/22/13/28/18** jednom po debug procesu. Stari playtest **50** bio je `ensure_dev(10)` × 5. E **ne** dira D. Muncher leftover na polju ostaje E.

## Rupa koju pour A nije zatvorio

Pour A je obećao: **na polju nema mrtvog T1**, jer se trese samo `k*4`. Remainder živi u torbi. Overlay (`3/4`) ima smisla: „sačuvaj dok ne skupiš četvrti“.

Muncher to **krši u sesiji**. Pojede 1 od 4 clover → 3 T1 na polju. FLOW-A reciklira samo **T2 bez para** (`_t2_has_pair_chance` false → 2× T1 u bag). Odd **T1** ostaju do Done. FEEL-B može flashati „nema para“, ali clover i dalje leži.

Tada:

- Torba s clover 2 **ne pomaže** ta 3 na polju (L2: ne tresti 3 da se spoji s 1, niti 1 da se spoji s 3 — pour remainder nije „popravak“).
- Igrač vidi leftover **na polju** opet — točno ono što A treba spriječiti.
- `3/4` u overlayu (torba) i 3 clover na polju pričaju **dvije** priče. Overlay ostaje točan za torbu. Polje treba **svoj** resolve, analogan FLOW-A.

L1 (2026-08-28 ujutro) je rekao: pest nije ovaj track. Playtest je pokazao da bez field resolvea ÷4 torba **gubi smisao** čim Muncher jednom ujede. L1 se **reopena** kao L31. Overlay se **ne** mijenja.

## Invariant (dva sloja)

| Sloj | Pravilo | Kad |
|------|---------|-----|
| **Pour (A)** | Iz torbe na polje samo `floor(n/4)*4` po tipu | Tap vreće, auto-refill |
| **Field (E)** | Na polju, T1 **istog tipa** uvijek ima para (paran count) | Nakon eat i nakon merge |

T2 i dalje FLOW-A. T3 i dalje crystal. E **ne** dira overlay, refill 12, pest tajmere, T3 freeze.

Pour-complete (tresni 1–3 iz torbe da se vrati ×4 na polju) je **odbijen**. To bi ukinulo L2 i pretvorilo remainder u „Muncher insurance“. Remainder u torbi ostaje za **sljedeći val ×4** i za overlay `n/4`, ne za krpanje polja.

## Pravilo — `count % 2 == 1` → vrati **jedan** T1

Po `type_id`, samo tier 1. Ne `n%4`. Ne vraćaj sva 3.

| T1 tog tipa na polju | Legalni merge | Akcija E |
|---------------------:|---------------|----------|
| 0, 2, 4, 6… | parovi (0, 1, 2… T2 puta) | ništa |
| 1 | nema para | taj **1** u torbu |
| 3 | 2 mogu T1+T1 → T2 | **1** u torbu, **2** ostaju |
| 5 | 4 mogu dva para | **1** u torbu, **4** ostaju |

Primjer Muncher:

```
Polje: 4 clover T1
Muncher jede 1
  → 3 clover
  → E: 3 % 2 == 1 → 1 clover u torbu, 2 na polju
Igrač spoji 2 → 1 T2
  → FLOW-A: ako nema drugog T2 / 2 T1 / pour šanse, T2 → 2 T1 u torbu
```

Neto: pojedeno sjeme je **nestalo** (Muncher i dalje boli). Polje nema usamljeni T1. Torba dobije neparni T1 natrag — overlay `n/4` opet ima smisla.

Ako E **ne** vrati 1 dok su 3 na polju, igrač može spojiti 2, ostane 1, E nakon **mergea** vrati taj 1. Isti kraj. Freeze i dalje vraća odmah na neparni count (eat), da 3 clover ne leže kao „smeće“ dok igrač odlučuje.

## Kad se pali (L32)

Isti hookovi kao `_resolve_stranded_t2`:

1. `_pest_eat_chip` — nakon `_remove_chip` pojedene mete.
2. Nakon uspješnog mergea (postojeći pozivi `_resolve_stranded_t2`).

Novi `_resolve_stranded_t1` **uz** T2, ne umjesto. Redoslijed predložen: T1 pa T2 (neparni T1 skine se prije nego T2 gleda `field_t1 >= 2` u `_t2_has_pair_chance`). Ako T2 resolve prvo vidi 1 T1 kao „ima šansu“, T2 bi ostao; zato **T1 prvo**. Dokumentiraj u E kod-promptu; E-P0 freeze: T1 resolve prije T2.

Ne na frame tick. Ne na auto-refill pull 0. Ne na overlay. Ne na `set_arena_page_active`.

## Koji chip (L33)

Od T1 tog tipa: **ne** `is_dragging()`. Idle. Ako su svi u drag/magnet locku — skip (chip ostaje; sljedeći eat/merge ponovi). Isti duh kao T2 kad bag nema 2 slota.

## Bag full (L34)

`seed_bag_remaining_capacity() < 1` → ne skidaj T1. Soft cap 40 se **ne** diže. Muncher leftover na punoj torbi je rijedak debug/edge; Done i dalje commita.

## Što E **nije**

- Nije izmjena overlaya (B+C). Stuck vreća i dalje `You need more seeds!` + `n/4`.
- Nije pour 1–3 iz torbe na orphan (L2).
- Nije FLOW-A rewrite. T2 recycle ostaje.
- Nije D (100 T1). D je zaseban slice (`apply_debug_leftover_test_bag`).
- Nije fail, ads, IAP, coin za odd T1 (L18).
- Nije `SAVE_VERSION`.
- Nije pest FSM (brzina, eat duration, T3 freeze 2 s) osim što eat callback zove resolve.
- Nije combo HUD / daily / Pip — recycle T1 nije combo break osim ako uklanjanje chipa već gasi streak (status quo FLOW-A T2; ne dirati).

## Smokes (LEFTOVER-E) — kasniji kod

1. Spawn 4 clover T1, bag clover 0. Simulirani eat jednog → polje **2** clover, bag clover **1**.
2. Spawn 1 daisy T1 sam → 0 na polju, bag daisy +1.
3. Spawn 2 clover T1 → ostaju 2; bag ne raste.
4. FLOW-A: T2 bez para i dalje 2× T1 u bag (`arena_flow_a` / postojeći leftover T2 put).
5. leftover_a (÷4 pour), leftover_b/c (overlay) prolaze.
6. Overlay se **ne** otvara od eat/resolve.

Headless OpenGL. Ne GUI usred E.

## Povezano

- [[ideje-arena-leftover-math|math]] — pour `n%4` vs field `n%2`  
- [[ideje-arena-leftover-pitanja|L1 L2 L31–L37]]  
- [[../06-production/plan-prompts-arena-leftover|LEFTOVER-E-P0]] (E kod ne) · [[ideje-arena-sort|ARENA-03]] · D zasebno
