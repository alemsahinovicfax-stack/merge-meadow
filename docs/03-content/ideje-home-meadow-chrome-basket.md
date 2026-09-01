---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, basket, sjeme, scratch]
povezano:
  - ideje-home-meadow-chrome
  - ideje-home-meadow-chrome-pitanja
  - ideje-seed-pool
  - plan-prompts-home-meadow-chrome
ai_sažetak: "HOME-13 C — Basket samo u polju; picker types_for_season ∩ unlocked; ikona T3 CampPlantDraw; clear_loadout van poola."
---

# IDEJE — HOME-13 basket (sezona + T3)

> [[ideje-home-meadow-chrome|hub]] · freeze P164–P168.  
> **Kod:** **CHROME-C ✅** 2026-09-01. SEED-01 katalog već postoji — ne rewrite JSON.

## Vidljivost

- Karusel: `%BasketCard` **nije** u gornjem stacku (Daily ostaje).
- Polje: isti (ili premješteni) `%BasketCard` **lijevo od Play** u donjem redu.
- Overlay `%BasketPickerOverlay` ostaje na Home; samo lista i kada se otvara.

## Picker lista

Danas `_rebuild_picker_list` hoda `get_unlocked_loadout_types()` (globalni chain).

Cilj: za svaki red, `type_id` ∈ `SeedCatalog.types_for_season(home_season_field_id)` **i** unlocked, **ne** mythic.

Bloom open → Bloom pool. Frost open → Frost pool (npr. `frost_snowdrop`), ne clover-copy.

## Ikona

[`home_basket_visual.gd`](../../game/scripts/ui/home_basket_visual.gd) danas crta pickup T1.

Izabrano: [`camp_plant_draw.gd`](../../game/scripts/visual/camp_plant_draw.gd) **tier 3** (isti jezik kao roster T3 / meadow T2 mix, ovdje uvijek T3 kao „spremno sjeme“). Prazan loadout = postojeći empty outline.

## Loadout

- `set_loadout` / `clear_loadout` / `loadout_type_id` ostaju; i dalje save.
- Na `apply_season` / open field: ako loadout nije u poolu te sezone → `clear_loadout` (P168).
- Run bias i dalje `is_loadout_in_active_season_pool` — nakon clear-a nema lažnog Bloom sjemena u Frost runu.

## Što C **ne** radi

- Ne Endless (D). Ne full-bleed (B). Ne mythic u basketu. Ne CAMP bag.

## Smoke

`home_basket_picker_smoke` + `season_meadow_smoke`: karusel BasketCard not visible; Bloom open → Basket visible, picker bez frost-only id-a; Frost open → lista iz Frost poola; T3 draw path (nije pickup-only assert ako je teško — bar `set_loadout` + visual method). Close → Basket hidden.
