---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, leftover, pour, bag, ux, scratch]
povezano:
  - ideje-arena-leftover-math
  - ideje-arena-leftover-pour
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena-leftover-pitanja
  - ideje-arena-leftover-grupe
  - plan-prompts-arena-leftover
  - ideje-arena-sort
  - plan-prompts-arena-sort
  - ideje-arena
  - ideje-arena-bloom
  - ideje-arena-pest
  - merge-arena-v1.1
  - ideje-kad-predloziti
  - CHECKPOINT
ai_sažetak: "ARENA-02 hub — leftover T1 pour ÷4; overlay n/4; C hide; D debug 100; E superseded od ARENA-03 vacuum."
---

# IDEJE — Arena leftover (ARENA-02 hub)

> **ID:** **ARENA-02** · v1.1+ (nije v1 launch blocker, nije D0-P).  
> **Kod:** **P0 ✅ A ✅ B ✅ C-P0 ✅ C ✅ D ✅** · **E-P0** docs ✅ · **E kod ne** (zamjena: [[ideje-arena-sort|ARENA-03]] vacuum). Prompti leftover: [[../06-production/plan-prompts-arena-leftover|plan-prompts-arena-leftover]].  
> **Nasljednik pour:** [[ideje-arena-sort|ARENA-03]] — sav T1 po CHAIN; vacuum kad t1_eq &lt; 4; overlay B+C i grant D **ostaju**.  
> **Freeze:** L0–L20 **2026-08-28** · L21–L30 **2026-08-28** · L31–L37 **2026-08-28** (field T1 docs; E kod superseded ARENA-03) — [[ideje-arena-leftover-pitanja|pitanja]].  
> **Prethodnik:** [[ideje-arena|ARENA-01]] COMB-A…FEEL-B ✅ (combo, leftover **T2**→2×T1, auto-pour na 10, daily, Pip, clear-field VFX).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — merge ostaje besplatan; popup **nije** shop, **nije** IAP, **nije** pay-to-merge. [[../01-vision/design-pillars|Pillar 3]] — nije fail state; igrač ide u Camp skupiti još T1, ne gubi run.

## Pitch

ARENA-01 je arenu učinio zabavnijom. Nije riješio **mrtvo sjeme na polju**.

Igrač istrese torbu. Mergea što može do T3. Ostatak — 1 daisy, 2 clover, 3 tulip — **leži na playfieldu**. Nema para. Nema T3. FEEL-B da jedan vizualni beat. Done vrati T1 u bag. Igrač **ne zna** zašto je to tamo, niti što da radi sljedeće osim tapnuti Done iz navike.

Instinkt je ispravan: **„imam još u torbi / trebam još sjemena“**. Loše mjesto za taj instinkt je **polje**. Polje je merge sandbox. Torba je inventar. Kamp je mjesto gdje se sjeme skuplja (run, trade, chest).

ARENA-02 **ne** dodaje T4, Sort, spend panel, ni coin sink za odd T1. Radi tri stvari:

1. **Pour samo višekratnike od 4 po tipu** — 4 T1 = 1 T3. Ostatak `n % 4` ostaje u torbi, nikad na polje.
2. **Auto-refill na 12** (bilo 10) — ista FLOW-B petlja, drugi prag; cap polja i dalje 40; prazno polje i dalje ne auto-poura.
3. **Kad više nema što istresti** (svi tipovi 1–3 u torbi) — vreća ostaje klikabilna, ali **mijenja funkciju**: overlay **You need more seeds!** + ista T1 lista kao u kampu, count kao **`3/4`**. Tap bilo gdje → **Camp**. Overlay se **gasi** prije odlaska; povratak na Arena tab pokazuje **isti čist ekran kao nakon Done** (L21–L23). Naslov mora biti **čitljiv** na dim panelu (L24). Overlay **ostaje** (E ga ne dira).
4. **Mid-session field leftover (E)** — docs L31–L37. **Kod se ne radi.** ARENA-03 vacuum (3 T1 → sva 3 u torbu + lock) je zamjena. [[ideje-arena-sort-vacuum|sort vacuum]].

Pour L0b (`floor(n/4)*4`) **overridea** ARENA-03 SORT-A. Overlay i D ostaju.

## Debug bag (D ✅)

Svaki debug play, jednom po procesu: torba freeze **19/22/13/28/18** (zbroj 100). Nije `ensure_dev` min-10. Nije Arena tab return. Detalj: [[ideje-arena-leftover-grant|grant]].

## Zašto sada

Playtest nakon ARENA-01 (grant 5×20 T1): polje se napuni, merge ide, pa ostane „smeće“. FLOW-A čisti samo **T2 bez para**. Odd **T1** su A25 — ostaju do Done. FEEL-B slavi clear-of-pairs, ali ne šalje igrača po još sjemena. Torba s 3 daisy izgleda kao da se može tapnuti; tap trese 3 daisy na polje i problem se **ponovi**.

D0 je i dalje playtest / art / store. ARENA-02 je v1.1+ scratch kao ARENA-01. Ne blokira Play Console. Ne dira kanon [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] dok ne kažeš „dodaj u scope“.

## Što kod danas radi (C ✅ D ✅; E kod ne — ARENA-03)

| Komad | Datoteka | Ponašanje |
|-------|----------|-----------|
| Auto-pour prag | `merge_arena_controller.gd` `ARENA_AUTO_REFILL_AT := 12` | Kad chipova **1–12** i bag ima ×4, vreća se sama trese do 40 ili praznog ×4. **0 chipova ne auto-poura.** Pull 0 ne vrti refill. |
| Što se trese | `game_state.gd` `pull_seeds_to_arena` | **SORT-A:** sav `bag[type]` ako ≥4 i nije locked, red `CHAIN`. Ne floor-4. |
| Leftover T2 | FLOW-A `_resolve_stranded_t2` | T2 bez šanse za par → 2× T1 u bag. |
| Leftover T1 na polju | `_resolve_t3_starved_types` | **SORT-B:** `t1_eq < 4` → svi idle u torbu + lock. E kod **ne**. |
| Stuck overlay | `NeedMoreSeedsOverlay` | Bag tap kad nema tipa ≥4: **You need more seeds!** (`WARM_WHITE`) + `n/4`; tap → Done/Camp. **E ne dira.** |
| Done | `_on_done_pressed` | Hide overlay, commit chipova, camp hub. |
| Kamp T1 lista | `get_seed_bag_entries` + `seed_bag_chip.gd` | Kamp: `×n` + trade. Arena overlay: quota `n/4`. |
| Soft cap torbe | `SEED_BAG_SOFT_CAP := 40` | UI / `add_seeds_to_bag`. Debug grant 100 smije preći. |
| Debug bag | `apply_debug_leftover_test_bag` | Jednom po procesu overwrite **19/22/13/28/18**. Arena ne radi min-10. |

## Igračev loop (cilj)

```
Torba: clover 6, daisy 3
  → pour: clover 4 na polje, clover 2 + daisy 3 ostaju
  → 4 clover → 2 T2 → 1 T3 crystal
  → polje prazno ili samo mergeable valovi dok ima ×4
  → bag: clover 2, daisy 3 — tap vreće
  → "You need more seeds!"
      Daisy    3/4
      Clover   2/4
  → tap bilo gdje → Camp (run / chest / trade)
  → overlay se zatvara; Arena tab kasnije = prazno polje, bez dima
```

Intuicija `3/4`: **nemaš četvrtinu do T3**. Ne treba tutorial rečenica (L6). Naslov **You need more seeds!** mora se **vidjeti** u popup-u (L24) — danas je tamnosiv na tamnom panelu.

## Freeze (chat 2026-08-28)

Sažetak. Puna tablica: [[ideje-arena-leftover-pitanja|pitanja]].

| # | Tema | Odluka |
|---|------|--------|
| **L0** | Što je bol | Odd T1 **na polju** + tap vreće trese ostatak. |
| **L0b** | Pour math | **Uvijek** `floor(n/4)*4` **po tipu**, ručni tap **i** auto-pour. 6 clover → 4 van, 2 u torbi. |
| **L0c** | Auto-refill prag | **12** (bilo 10). Cap 40. Polje 0 ne auto-poura. |
| **L0d** | Stuck vreća | Klikabilna; overlay + lista `n/4`; tap bilo gdje → Camp. Nije IAP. Done/Back ostaju. |
| **L21–L25** | Dismiss / restore / naslov | Hide overlay prije Camp; page-inactive hide; čist Arena ekran; svijetli EN naslov u popup-u. [[ideje-arena-leftover-popup\|popup]] |
| **L26–L30** | Debug 100 T1 | Svaki debug play, jednom po procesu, overwrite freeze tablice (19/22/13/28/18). Ne na Arena tab return. [[ideje-arena-leftover-grant\|grant]] |
| **L31–L37** | Field T1 | Neparan T1 tog tipa na polju → 1 u torbu (3→1 bag + 2 polje). Overlay ne dirati. [[ideje-arena-leftover-field\|field]] |

## Hub persist (zašto C postoji)

[`meta_hub_controller.gd`](../../game/scripts/meta/meta_hub_controller.gd) drži `_arena_page`. Tap overlay → `_on_done_pressed` → Camp, ali **ne** `need_more_overlay.visible = false`. Overlay se gasi samo u `_deferred_boot` (jednom po instanci). Igrač se vrati na Arena tab i vidi **isti popup** na praznom polju. To nije „isti ekran kao prije“. C to zatvara. Detalj: [[ideje-arena-leftover-popup|popup]].

## Što ARENA-02 ne dira

Combo math/coins, daily keys, Pip/tint, FEEL-B VFX (ostaje za pest/odd), pest FSM (brzina, eat, T3 freeze 2 s), Home dual-band, Shop, AdMob, SAVE_VERSION (nema novog keya u A/B/C/D/E), kanon spec markdown, bloom panel (već nema u areni). Debug 100 **nije** produkcijski loot. Overlay E **ne** dira.

## Sliceovi

| Prompt | Što |
|--------|-----|
| **LEFTOVER-P0** | Ovi docs. Nema `game/` osim citata. **✅** |
| **LEFTOVER-A** | Refill 12 + pour floor-4. **✅** |
| **LEFTOVER-B** | Overlay + kamp lista `n/4` + tap → Camp. **✅** |
| **LEFTOVER-C-P0** | Docs L21–L30: dismiss, restore, naslov, grant 100. Nema `game/`. **✅** |
| **LEFTOVER-C** | Hide overlay + čitljiv naslov + čist povratak. **✅** |
| **LEFTOVER-D** | Debug overwrite 100 T1 jednom po procesu. **✅** |
| **LEFTOVER-E-P0** | Docs L31–L37: field unpaired T1. Nema `game/`. **✅** |
| **LEFTOVER-E** | `_resolve_stranded_t1`. **Ne raditi** — [[ideje-arena-sort\|ARENA-03]] SORT-B. |

Ne spajati A i B. Ne spajati **C i D**. Overlay C ostaje. Pour L0b → ARENA-03.

## Povezano

- [[ideje-arena-leftover-math|math]] · [[ideje-arena-leftover-pour|pour]] · [[ideje-arena-leftover-popup|popup]] · [[ideje-arena-leftover-grant|grant]] · [[ideje-arena-leftover-field|field]]
- [[ideje-arena-leftover-pitanja|pitanja]] · [[ideje-arena-leftover-grupe|grupe]]
- [[../06-production/plan-prompts-arena-leftover|prompti leftover]] · [[ideje-arena-sort|ARENA-03]] · [[../06-production/plan-prompts-arena-sort|prompti sort]]
- [[ideje-arena|ARENA-01]] · [[ideje-arena-bloom|bloom / leftover T2]] · A14 A15 A25
