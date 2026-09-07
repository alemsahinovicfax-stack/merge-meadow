---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, chrome, scratch]
povezano:
  - ideje-camp-link
  - ideje-camp-link-pitanja
  - ideje-camp-cliff
  - plan-prompts-home-camp-field
ai_sažetak: "CAMP-03 A — Seeds/Flowers samo naslov; GardenCliff/BagLabel/CrystalTotalLabel hidden; scrollovi +10%. CAMP3-A ✅."
---

# IDEJE — CAMP-03 chrome (naslovi + 10%)

> [[ideje-camp-link|hub]] · freeze C22–C27, C34.  
> **Kod:** **CAMP3-A ✅**. Čeka FIELD-D (UpgradeCards hidden). Ne Flowers parity (B). Ne next-lock kartica (C). Upija CAMP-02 C21.

## Danas

[`camp_scene.tscn`](../../game/scenes/camp/camp_scene.tscn) GardenVBox: GardenTitle, GardenCliff (hint), BagLabel `Seeds: 0 / 40`, SeedBagScroll 220, Exchange. CrystalVBox: CrystalTitle, CrystalCliff hidden, CrystalTotalLabel `Flowers: n`, CrystalScroll 220.

[`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) `_refresh_garden_card` seta cliff + bag_label; `_refresh_crystal_card` seta crystal_total_label.

## A — samo naslov, malo veći grid

1. `%GardenCliff`: uvijek `visible = false`, `text = ""`. `_garden_cliff_text` vraća `""` ili se ne piše u UI. UniqueName ostaje. Override C7/C21.
2. `%BagLabel` hidden (nema `Seeds: n / cap`). UniqueName ostaje.
3. `%CrystalTotalLabel` hidden. UniqueName ostaje. CrystalCliff već hidden (C3).
4. `GardenTitle` / `CrystalTitle` ostaju **Seeds** / **Flowers**.
5. `SeedBagScroll` i `CrystalScroll` `custom_minimum_size.y` **220 → 242** (+10%), oba jednako.
6. Ne vraćati `%UpgradeCards`. Ne dirati Exchange / CrystalExchange.
7. StatusToast ostaje no-op (C1). Nema novog popup u Seeds.

## Smoke (C34)

`camp_layout_smoke`: GardenCliff postoji, hidden ili prazan, nema „Bag seeds are“. BagLabel i CrystalTotalLabel nisu visible. Naslovi Seeds / Flowers. Oba scrola min y ~242. UpgradeCards hidden. Toast hidden.

## Acceptance

- Kartica Seeds = naslov pa grid pa Trade.
- Kartica Flowers = naslov pa grid pa Exchange.
- Obje malo veće, jednako.
