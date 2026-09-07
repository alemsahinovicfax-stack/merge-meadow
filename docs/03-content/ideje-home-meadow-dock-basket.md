---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, basket, scratch]
povezano:
  - ideje-home-meadow-dock
  - ideje-home-meadow-dock-pitanja
  - ideje-home-meadow-chrome-basket
  - plan-prompts-home-meadow-dock
ai_sažetak: "HOME-15 A ✅ B ✅ — picker T3/★3/footer; meadow i basket isti T3 crystal draw."
---

# IDEJE — HOME-15 basket (picker + T3 match)

> [[ideje-home-meadow-dock|hub]] · freeze P201–P204, P208–P210.  
> **Kod:** **DOCK-A ✅** **DOCK-B ✅**. Ne micati BasketCard (to je C). Ne Daily (D).

## Danas (nakon A+B)

Picker red: VBox T3 `CampPlantDraw.draw_fitted_plant(type_id, 3)` iznad `ime ★`. `%PickerList` samo cvijeće. `%PickerFooter`: Clear basket pa Close. `set_loadout` i `get_unlocked_loadout_types_for_season` uključuju ★3 ako je unlockan u sezoni. Greenhouse/album i dalje skip mythic.

[`home_basket_visual.gd`](../../game/scripts/ui/home_basket_visual.gd) i [`season_field_flower.gd`](../../game/scripts/ui/season_field_flower.gd) `plant_tier = 3` — isti crystal path u [`camp_plant_draw.gd`](../../game/scripts/visual/camp_plant_draw.gd). Count 12–14 i slotovi/safe rect ostaju.

## A — picker ✅

1. Svaki cvijet-red: VBox — gore mali Control s `CampPlantDraw.draw_fitted_plant(type_id, 3)`, dolje ime + ★.
2. Lista uključuje ★3 ako je `types_for_season(home_season_field_id)` ∩ unlocked. `set_loadout` prihvaća mythic za Home basket. Arena/kamp greenhouse **ne** dirati.
3. `%PickerList` **samo** cvijeće. Footer VBox ispod scrolla: **Clear basket**, pa **Close** (postojeći `%PickerCloseButton` ili ekvivalent), Close ispod Clear.

Ne Endless. Ne PlayRow. Ne mythic JSON rewrite.

## B — T3 match ✅

Meadow flowers: `plant_tier = 3` (isti path kao basket). Count 12–14 i slotovi/safe rect ostaju (P185 count, P186/P205). Ne novi sprite.

## Smoke

**A (P208–P209) ✅:** [`home_basket_picker_smoke.gd`](../../game/scripts/dev/home_basket_picker_smoke.gd) — Bloom open picker: rarity-3 u listi ako unlockan; red ima child Control za draw; Clear nije dijete PickerList; Clear i Close siblingovi u footeru, Close ispod Clear.

**B (P210) ✅:** [`season_meadow_smoke.gd`](../../game/scripts/dev/season_meadow_smoke.gd) — flowers `plant_tier == 3`; 12–14; BasketVisual i dalje T3.

## Acceptance

- U pickeru se vidi T3 slika iznad imena; ★3 se može izabrati.
- Clear i Close su na dnu, jedno iznad drugog.
- Basket i cvijeće na polju izgledaju kao isti T3 draw.
