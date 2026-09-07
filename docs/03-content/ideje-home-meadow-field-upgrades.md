---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, upgrade, magnet, scratch]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-field-pitanja
  - ideje-camp
  - ideje-camp-link
  - plan-prompts-home-camp-field
ai_sažetak: "HOME-16 D — Magnet i Loot Boost kompaktno gore desno na polju; kamp UpgradeCards hidden; spend 2 T3 ostaje. FIELD-D ✅."
---

# IDEJE — HOME-16 upgrades (Magnet / Loot na polju)

> [[ideje-home-meadow-field|hub]] · freeze P225–P229, P232.  
> **Kod:** **FIELD-D ✅**. Ne Daily/picker/swipe logika (A–C). CAMP3-A **ne** smije vratiti UpgradeCards. Fair F2P: nema IAP.

## Danas

Kamp [`camp_scene.tscn`](../../game/scenes/camp/camp_scene.tscn) `%UpgradeCards`: SprinklerCard + LootCard s captionima (px / × / Spend 2 flowers). [`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) zove `try_upgrade_magnet(_selected_crystal_type)` / `try_upgrade_multiplier`.

[`game_state.gd`](../../game/scripts/autoload/game_state.gd) `try_upgrade_*` + 2 T3 iz Flowers — **ostaje**. C11: preferred ako ≥2, inače cheapest rarity ≥2.

Settings na Homeu: gore desno (`anchor` top-right, ~64 px).

## D — premjesti UI, ne ekonomiju

1. Kamp `%UpgradeCards` `visible = false`. UniqueName **ostaje** (`camp_layout_smoke` / `camp_donate_smoke` traže nodeove). Ne brisati `try_upgrade_*`, `magnet_level`, `multiplier_level`.
2. Na **otvorenom polju**, gore desno **ispod Settings**, VBox: **Magnet** pa **Loot Boost**. Svaki red: kratki naslov + Upgrade gumb. **Nema** caption / px / × / „Spend 2 flowers“.
3. Label **Magnet** (ne Sprinkler). Loot Boost ime ostaje. Gumb: Upgrade ili Maxed.
4. Spend: `try_upgrade_magnet("")` / `try_upgrade_multiplier("")` (prazan preferred = CAMP-B cheapest ≥2). Nema flower pickera na polju.
5. Vidljivo samo `home_season_field_open`. Karusel: hidden.
6. U [`season_field.gd`](../../game/scripts/ui/season_field.gd) `_chrome_controls` / `meadow_safe_rect` (+ 8–16 px). Pip FSM ne dirati.
7. FIELD-C: ovi kontroleri u `block_hub_swipe` kad je polje otvoreno.

## Smoke (P232)

Bloom open: Magnet i Loot Boost visible, y ≥ Settings end.y, stacked (Loot.y > Magnet.y). Caption labela nema / prazna. Kamp scene: UpgradeCards hidden. `try_upgrade_magnet` s 2 T3 i dalje radi (`camp_donate_smoke` GameState path ili meadow tap). Close/karusel: field upgrade chrome hidden. Flowers ne sijeku novi chrome.

## Acceptance

- Upgrade se bira na polju, ne u kampu.
- Kamp više ne pokazuje Sprinkler/Loot kartice.
- 2 T3 sink i leveli netaknuti.
