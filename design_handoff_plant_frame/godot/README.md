# Godot prenos — plant_frame

Vrijednosti su u `plant_frame.gd` (samo postojeće konstante), a struktura u `plant_frame_export.json`. Mapa „sloj → fajl“ je u briefu, §10.

## Redoslijed prenosa

1. **Odrez crteža (helper).** U `camp_plant_draw.gd` dodaj put koji crta *odrezanu* teksturu: `Image.get_used_rect()` jednom po teksturi (keš), pa duža strana ide u kutiju, centrirano. `draw_fitted_plant` s `FIT_FRAC 0.36` ostaje netaknut za Home polje, korpu i biranje sezone.
2. **Arena** (`ui_arena.gd`, `arena_chip_draw.gd`):
   - `RIM_BAND_*`, `T2_HAIRLINE_*`, `CHIP_T2_WELL_RADIUS`, `FLOWER_SIZE_T1/T2`;
   - `draw_flower` prelazi na odrezan crtež;
   - `_draw_ring`: PULSE 12 / grow 20, PARTNER 14 / grow 24, crta se poslije rima.
3. **Journal** (`ui_journal.gd`, `collection_journal_row.gd`, `collection_bloom_icon.gd`): `SLOT 136`, `SLOT_GAP 14`, `ART 110`, radius kristala 36; brišu se `TierLabel` i `ArtWell`.
4. **Camp** (`ui_camp.gd`, `camp_art_frame.gd`): `camp_art_frame.gd` ne crta well; `CHIP_ART_*`, `TRADE_ART_*`, `SEASON_ART`.
5. **Run** (`ui_run.gd`, `run/seed_visual.gd`):
   - `_draw` crta samo sjenu, biljku (odrezanu, 120) i pipove;
   - pip je krug 22 s cream rubom 3;
   - `SEED_PIP_RADIUS 78`, `PICKUP_SHADOW_OFFSET 70`.
6. Smoke testovi: `collection_journal_smoke`, `journal_new_snapshot_smoke`, `camp_layout_smoke`, `arena_redesign_smoke`, `run_redesign_smoke`.

## Šta se briše

- **Journal:** čvor `TierLabel` (T1/T2/T3), `TIER_LABEL_FONT`, `TIER_LABEL_GAP`.
- **Journal:** `ArtWell` u slotu, poziv `UiJournal.tier_well_style`, `WELL_INSET`.
- **Camp:** well u `camp_art_frame.gd` (čip, Trade bar, kartica sezone), `CHIP_ART_WELL_INSET`, `TRADE_ART_WELL_INSET`.
- **Run:** krem krug 120, rub 4 i tamni well 84 u `seed_visual.gd`, `SEED_WELL_SIZE`.

## Ne dirati

- `CHIP_RADIUS` (134) u `arena_seed_chip.gd`.
- `radius = 26` u `seed_pickup.tscn`.
- `FIT_FRAC` i njegove pozive na Home polju, korpi i biranju sezone.
- Header 143 i footer 144.
