---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, basket, scratch]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-field-pitanja
  - ideje-home-meadow-dock-basket
  - plan-prompts-home-camp-field
ai_sažetak: "HOME-16 B ✅ — basket picker jedan stupac, bez scrolla; panel raste da svi T3 redovi + footer stanu."
---

# IDEJE — HOME-16 basket (no-scroll picker)

> [[ideje-home-meadow-field|hub]] · freeze P218–P220, P231.  
> **Kod:** **FIELD-B ✅**. Ne Daily (A). Ne swipe (C). Ne Magnet (D). DOCK-A T3/★3/Clear+Close **ostaju**.

## Danas

[`main_menu.tscn`](../../game/scenes/main_menu.tscn) `PickerPanel` ~560×720; `PickerScroll` `custom_minimum_size.y = 400`, `size_flags_vertical` expand. Lista je VBox jedan stupac (T3 ikona iznad imena). Bloom ima **7** tipova.

## B — sve na ekranu ✅

1. **Jedan stupac** (ne 2-col grid).
2. **Nema scrolla:** ukloni `PickerScroll` ili `scroll` off + size-to-content (`vertical_scroll_mode` disabled, lista nije u clip containeru koji siječe redove).
3. `%PickerPanel` **visinu raste** da stanu: title + svi cvjet-redovi (max 7 Bloom) + `%PickerFooter` (Clear pa Close).
4. Ne clipati T3 ikone ni imena. Horizontalna širina smije malo rasti ako treba, ne novi layout.
5. `%PickerList` i dalje samo cvijeće. Footer sibling ispod liste, ne u scrollu.

## Smoke (P231) ✅

Bloom open picker (`home_basket_picker_smoke` + `season_meadow_smoke`): nema `ScrollContainer` pretka liste. Svi flower-redovi `get_global_rect` unutar `PickerPanel` (uz margin). Clear/Close i dalje u footeru, Close ispod Clear. 7 Bloom redova (watermelon unlock) stanu. Frost i dalje Frost pool.

## Acceptance

- Igrač vidi svako cvijeće sezone bez povlačenja liste.
- T3 / ★3 / Clear+Close iz HOME-15 ostaju.
