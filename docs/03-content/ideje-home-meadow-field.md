---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, cvijece, scratch]
povezano:
  - ideje-home-meadow
  - ideje-home-meadow-shell
  - ideje-home-meadow-pip
  - ideje-seed-pool
  - ideje-home-meadow-pitanja
  - ideje-home-meadow-life-layout
ai_sažetak: "HOME-12 B — 6–10 cvjetova. HOME-14 C: 12–14 + chrome-safe rect."
---

# IDEJE — HOME-12 cvijeće na polju

> [[ideje-home-meadow|hub]] · freeze P145, P149, P157, P158.  
> **Kod:** **MEADOW-B ✅**. Ovisi o **MEADOW-A** i **SEED-A** (`seed_type_ids` = merge tipovi te sezone). **Ne** Pip (C).  
> **HOME-14 C:** 12–14 + chrome-safe rect — [[ideje-home-meadow-life-layout|life layout]].

## Što se vidi

Na `FieldGround` **6–10** cvjetova iz `get_season_def(home_season_field_id).seed_type_ids`. Draw [`camp_plant_draw.gd`](../../game/scripts/visual/camp_plant_draw.gd) (T1/T2 mix). Nakon SEED-A Frost vidi `frost_snowdrop`, ne clover.

`apply_season` / open **rebuild** childrene — ne ostavljati Bloom clover na Frost fieldu (to je bug).

Fiksni layout (% od size). Nema drag. `IGNORE`. Nije inventar.

## Tehnika

- Mali Control, **ne** `ArenaSeedChip`.
- Close meadow → free/hide flowers.
- Scale ~0.7–0.9 arena chip.

## Što B **ne** radi

- Pip. JSON rewrite. 8 flower scena. Arena instanca.

## Smoke

Open Bloom → 6–10 IGNORE, tipovi ⊆ Bloom `seed_type_ids`. Open Frost (playable) → tipovi ⊆ Frost pool, **nije** isti skup kao Bloom ako SEED-A gotov. Jedan SeasonField. Nema `ArenaSeedChip`.

## Acceptance B

- Polje pokazuje cvijeće **te** sezone.
- Promjena sezone mijenja cvijeće (rebuild).
- Tap cvijet no-op. Seasons zatvara.
