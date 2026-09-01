---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, donate, upgrade, ekonomija, scratch]
povezano:
  - ideje-camp
  - ideje-camp-pitanja
  - ideje-camp-grupe
  - ekonomija-brojevi
  - plan-prompts-camp
ai_sažetak: "CAMP-01 B — Upgrade skida 2 T3 iz Flowers; caption magnet px / loot ×; donate_bloom i arena se ne oživljavaju."
---

# IDEJE — CAMP-01 donate (Flowers → Sprinkler / Loot Boost)

> [[ideje-camp|hub]] · freeze [[ideje-camp-pitanja|pitanja]] C8–C20.  
> **Kod:** **CAMP-B ✅**. A chrome već ✅.  
> Kanon [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] sink T2/T3 donate — B **overridea resurs** (T3 za oba), ne level kap / × tablicu.

## Efekat (podsjetnik)

| Kartica | Level | Što igrač dobije |
|---------|-------|------------------|
| Sprinkler | 0–4 | Magnet radius `40 + lv × 48` px u sljedećem runu |
| Loot Boost | 0–4 | Loot × `MULTIPLIER_VALUES[lv]` u sljedećem runu |

B **piše to u caption**. Ne uči donate.

## Sada (B ✅)

[`game_state.gd`](../../game/scripts/autoload/game_state.gd):

- `try_upgrade_magnet` / `try_upgrade_multiplier` troše `UPGRADE_FLOWER_COST` (2 T3) preko `spend_flowers_for_upgrade`; **ne** čitaju donation prag.
- `donate_bloom*` i dalje postoje (legacy); arena ih **ne zove**.
- `sprinkler_donations` / `multiplier_donations` ostaju u saveu.

[`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) `_refresh_upgrade_cards`: ready = `level < max` i `can_spend_flowers_for_upgrade`; caption magnet px / loot × + Spend/Need 2 flowers.

## Cilj (C8–C11)

1. Gumb **enabled** kad `level < max` **i** postoji flower tip s `count >= 2`.
2. Tap: skini **2** s odabranog tipa (pravilo C11), zatim `magnet_level += 1` / `multiplier_level += 1`.
3. Nema `sprinkler_donations` praga. Polja u saveu smiju ostati; B ih ne čita za enable.
4. Ako nema tipa s ≥2: disabled. **Ne** skidati 1+1 s dva tipa.

### C11 — koji tip

Redoslijed:

1. `_selected_crystal_type` ako `garden_crystal_stash[type] >= 2`.
2. Inače svi tipovi s `count >= 2`, sort: **rarity ASC**, pa count DESC, pa `SeedUnlockConfig.CHAIN`.
3. Nema kandidata → disabled.

Exchange select i Upgrade smiju dijeliti isti select. Ako igrač nema select, auto-cheapest i dalje radi.

### Trošak

`2` po tapu. Konstanta: reuse `MAGNET_COST_T2` / `MULTIPLIER_COST_T3` **broj** (oba su 2) ili novi `UPGRADE_FLOWER_COST := 2`. Ne mijenjati level max (4) ni `MULTIPLIER_VALUES`.

Helper preporuka: `can_spend_flowers_for_upgrade() -> bool` + `spend_flowers_for_upgrade() -> bool` (skine 2, save). `try_upgrade_magnet` / `try_upgrade_multiplier` zovu spend pa level++. Ako spend fail, no-op.

## Caption (C13)

Zamijeniti donate stringove.

**Sprinkler** (nije max):

```
Wider seed magnet next run · {now_px}→{next_px} px
Spend 2 flowers
```

Jedan `Label` (`SprinklerCaption`) smije spojiti u jedan autowrap string, npr. `Wider seed magnet next run · 40→88 px · Spend 2 flowers`.

**Loot Boost** (nije max):

```
More loot next run · now ×1.0, next ×1.25
Spend 2 flowers
```

**Maxed:** Sprinkler `Max level · reach {px} px` (već postoji). Loot `Max level` (već postoji). Gumb `Maxed` + disabled.

**Nedovoljno flowers:** caption i dalje efekat + `Need 2 flowers` (ili ostavi Spend 2 i disabled gumb). Ne „donate in Arena“.

## Što B **ne** radi

- Ne zove `donate_bloom`, `donate_bloom_from_bed`, `donate_crystal_from_bed`, bloom inbox donate.
- Ne vraća arena panel Donate/Keep/Basket.
- Ne dira FLOW-A leftover, SORT vacuum, overlay.
- Ne dira Exchange rate (`CRYSTAL_EXCHANGE_COINS_BY_RARITY`).
- Ne dira `CAMP_BED_BONUS` kad magnet max (ostaje legacy).
- Ne StatusToast (A već mrtav) — `_on_upgrade_pressed` zove `_refresh_ui()` bez status stringa, ili string koji toast ignorira.
- Ne SAVE_VERSION.
- Ne Home / Shop / AdMob.

## Ekonomija sync

Nakon B, agent u istom PR-u (kratko) ažurira [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] red: Sprinkler cost = 2 T3 flowers (ne T2 donate). Loot Boost = 2 T3 flowers, atomic. Arena donate rečenice → „CAMP-01: spend u kampu“.

Kanon `merge-arena-v1.1.md` se **ne** prepisuje dok „dodaj u scope“.

## Smokes (B)

Novi `game/scripts/dev/camp_donate_smoke.gd`:

- 2 clover T3, `magnet_level` 0 → Upgrade → magnet 1, clover stash 0.
- 1 flower → gumb disabled, level 0.
- Isto za multiplier (odvojen fixture).
- Max level: gumb disabled, stash ne padne.
- Caption ne sadrži `donate in Arena`.

`camp_layout_smoke` i A assertovi (Seeds/Flowers, toast hidden) **prolaze**. Arena leftover/sort smokes **ne** dirati.

## Povezano

- [[ideje-camp-pitanja|C8–C20]] · [[../06-production/plan-prompts-camp|prompti]]
- [[../02-design/ekonomija-brojevi|ekonomija-brojevi]]
