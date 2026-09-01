---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, layout, cvijece, scratch]
povezano:
  - ideje-home-meadow-life
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-chrome-layout
  - ideje-home-meadow-field
  - plan-prompts-home-meadow-life
ai_sažetak: "HOME-14 B+C — PlayRow tri jednaka; 12–14 cvjetova u chrome-safe rectu (Daily, Settings, chip, PlayRow)."
---

# IDEJE — HOME-14 layout (PlayRow + cvijeće)

> [[ideje-home-meadow-life|hub]] · freeze P184–P186, P194–P195.  
> **Kod:** **LIFE-B ✅** 2026-09-01 (PlayRow). **LIFE-C ✅** 2026-09-01 (cvijeće + `meadow_safe_rect`). Ne spajati s D. Ne dirati Basket picker/T3.

## PlayRow (B)

Danas u [`main_menu.tscn`](../../game/scenes/main_menu.tscn): Basket, Play, Endless **320×96**, `size_flags_horizontal = 4` (shrink center). Karusel: samo Play, centriran. Polje: tri jednaka tilea.

Karusel: Basket i Endless **hidden** (CHROME-C/D ostaje). Play ista **visina**, centriran (HBox alignment center). Ne duplicirati gumbe. `%PlayThemeBadge` ostaje sibling, hidden.

Ne dirati `_rebuild_picker_list`, T3 visual, Endless Hard/tema.

## Cvijeće (C) ✅

[`season_field.gd`](../../game/scripts/ui/season_field.gd): `FLOWER_COUNT := 13`; 13 UV slotova unutar `meadow_safe_rect()`; clamp 12–14. Pool = `get_season_def(home_season_field_id).seed_type_ids`, T1/T2 mix, IGNORE, rebuild na `apply_season`. Nije inventar. Ne `ArenaSeedChip`. Ne SeedCatalog JSON.

## Chrome-safe rect (C ✅; D koristi isti helper)

Cvijeće (i kasnije Pip) **ne** smiju sjesti ispod:

- `%DailyChestCard` / `HomeTopStack`
- Settings gumb
- `%SeasonNameChip`
- `%PlayRow` (Basket / Play / Endless)

Helper `SeasonField.meadow_safe_rect()`: `get_global_rect()` tih nodeova, pretvori u field local, inset **12px** + pola cvijeta. Slotovi i wander točke samo unutar ostatka. `SeasonField` **clip**; meadow actor `z_index` **ispod** chromea.

`%PipPortrait` ostaje hidden — ne računati kao chrome hit, ali ni ne vraćati.

## Što layout **ne** radi

- Ne Pip FSM (D). Ne Play routing (A). Ne hub TopBar. Ne mijenjati Daily/Settings poziciju osim što ih safe rect **izbjegava**.

## Smoke

**B (P194):** field open — tri PlayRow djece ista `custom_minimum_size`; karusel Play `size.y` / min height isti.

**C (P195):** Bloom open — 12–14 IGNORE, tipovi ⊆ Bloom pool; nijedan cvijet `get_global_rect` ne siječe Daily/Settings/chip/PlayRow (uz margin). Frost open — Frost pool, count u rasponu. Close — cvijeće free/hide.

## Acceptance

- U polju tri gumba izgledaju kao isti red, ne jedan veći.
- Više cvijeća na proširenom polju, nijedno ispod Daily/Play/Basket/chip.
