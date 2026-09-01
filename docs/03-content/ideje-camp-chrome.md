---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, chrome, scratch]
povezano:
  - ideje-camp
  - ideje-camp-pitanja
  - ideje-camp-grupe
  - plan-prompts-camp
ai_sažetak: "CAMP-01 A — StatusToast no-op; journal/T2 cliff grane van; CrystalCliff hidden; Seeds/Flowers copy; RunPrepCard van."
---

# IDEJE — CAMP-01 chrome (toast, cliff, companion, rename)

> [[ideje-camp|hub]] · freeze [[ideje-camp-pitanja|pitanja]] C1–C7, C20.  
> **Kod:** **CAMP-A ✅**. **Ne** donate, **ne** `try_upgrade_*`, **ne** caption rewrite Upgrade kartica (B).  
> **CAMP-02:** GardenCliff slot (C7 ostaci) → [[ideje-camp-cliff|C21]] hidden + prazan.

Ovo je **isti** `camp_scene` scroll. Samo šum i kriva imena.

## Layout danas

U [`camp_scene.tscn`](../../game/scenes/camp/camp_scene.tscn) `Content` VBox, odozgo:

| Node | Što radi | CAMP-A |
|------|----------|--------|
| `StatusToast` | Žuti panel, default `visible = false`; `_set_status_toast` ga pali | C1: ostaje hidden / no-op |
| `GardenCard` / `GardenTitle` = `Garden` | T1 bag + trade | C5: title **Seeds** |
| `%GardenCliff` | Next-step hint | C2+C20 grane van; C7 ostalo ostaje |
| `BagLabel`, `SeedBagGrid`, `ExchangeButton` | Trade | Ne dirati |
| `CrystalCard` / `CrystalTitle` = `Flower stash` | T3 grid + exchange | C6: title **Flowers** |
| `%CrystalCliff` | „Merge T3 in…“ / „Tap a flower…“ | C3: cijeli sklonjen |
| `CrystalTotalLabel`, `CrystalGrid`, `CrystalExchangeButton` | Exchange | Ne dirati |
| `UpgradeCards` (Sprinkler / Loot) | Caption „donate in Arena“ | **Ne dirati u A** |
| `RunPrepCard` | Companion title, hint, Pip/Mochi | C4: ukloniti karticu |

Footer Merge/Play i hub chrome **ne** dirati.

## StatusToast (C1)

[`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) `_set_status_toast`: ako `status` nije prazan, `status_label.text = status`, `status_toast.visible = true`. Zove se iz `_refresh_ui`, trade/exchange fail poruka, upgrade success, Mochi unlock (`poll_mochi_unlock_toast`).

A:

1. `_set_status_toast` **early return** (ne paliti visible).
2. Toast u tscn ostaje `visible = false` (preporuka) ili se node skine — UniqueName smije ostati da stari citati ne pucaju.
3. `_refresh_companion_ui` toast grana nestaje zajedno s pickerom.

Ne premještati poruku u hub top bar.

## GardenCliff (C2, C7, C20)

`_garden_cliff_text` danas:

1. Tutorial merge — **ostaje** (C7).
2. `1 more T2 to upgrade Sprinkler.` — **ukloniti** (C20).
3. Bag > 0 — T1 pour/trade — **ostaje**.
4. Crystal > 0 — flowers ready — **ostaje**.
5. `New blooms in Journal — swipe to the Journal tab.` — **ukloniti** (C2).
6. Fallback `Run → collect seeds → Merge here.` — **ostaje**.

`%GardenCliff` node **mora** ostati (`camp_layout_smoke`).

## CrystalCliff (C3)

[`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) `_refresh_crystal_card` seta `crystal_cliff.text` na prazan / merge / tap-exchange.

A: `crystal_cliff.visible = false` **ili** ukloni node i null-check u controlleru. Oba stringa nestaju. `CrystalTotalLabel` („Flowers: N“) ostaje.

## Naslovi (C5, C6)

Samo `.text`:

- `GardenTitle` → `Seeds`
- `CrystalTitle` → `Flowers`

Ne preimenovati `GardenCard`, `CrystalCard`, UniqueName. `CrystalTotalLabel` već kaže `Flowers: %d` — ostaje.

Controller može hardkodirati title u `_ready` ako tscn default ostane star; prefer tscn `text` + smoke assert.

## RunPrep / companion (C4, C15, C19)

Ukloniti iz tscn:

- `RunPrepCard` i djecu (`RunPrepTitle`, `CompanionTitle`, `CompanionHint`, `CompanionRow`, `PipSlot`, `MochiSlot`)

U [`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd):

- Maknuti `@onready` na companion slotove / title / hint ako nodea nema.
- Maknuti `_refresh_companion_ui`, `_on_companion_slot_pressed`, slot `slot_pressed` connect.
- `_refresh_ui` ne zove companion refresh.

**Ne dirati** [`game_state.gd`](../../game/scripts/autoload/game_state.gd) companion API, `companion_config.gd`, Pip u runu, `try_set_active_companion`.

## Što A **nije**

- `sprinkler_caption` / `multiplier_caption` rewrite.
- `MAGNET_COST_*`, `try_upgrade_magnet`, `garden_crystal_stash` spend.
- Journal scene, collection badge logika (badge smije ostati ako postoji van toast/cliff).
- Arena, Home, Shop, AdMob, SAVE_VERSION.

## Smokes (A)

[`camp_layout_smoke.gd`](../../game/scripts/dev/camp_layout_smoke.gd):

- `%GardenCliff` i dalje postoji.
- `GardenTitle.text` sadrži `Seeds`.
- `CrystalTitle.text` sadrži `Flowers`.
- `StatusToast` nije visible nakon `_refresh_ui("x")`.
- `CompanionTitle` / `PipSlot` null **ili** not visible.
- `CrystalCliff` null **ili** not visible.

Postojeći UniqueName assertovi (BagLabel, grids, Upgrade, Merge, Play) ostaju.

## Povezano

- [[ideje-camp-pitanja|C1–C7 C20]] · [[../06-production/plan-prompts-camp|prompti]]
