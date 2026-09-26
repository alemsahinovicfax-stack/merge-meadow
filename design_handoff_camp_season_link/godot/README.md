# SeasonLinkCard — prenos u Godot (red koraka)

Mjere 1:1 u px baze 1080 × 1920. Podaci: `season_link_export.json`. Stablo: `season_link_tree.txt`. Mockup: `../design/SeasonLink.dc.html` (prop `scene`), mjere: `../design/SeasonLink Specs.dc.html`.

## Nova visina

- `UiCamp.SEASON_H` **276 → 318**
- `UiCamp.SECTION_H` **1289 → 1247** (= 1585 − 318 − 20)
- `UiCamp.SECTION_GAP` ostaje **20**, `SECTION_H_NO_SEASON` ostaje **1585**

## Koraci

1. **Konstante (`ui_camp.gd`).** `SEASON_H 318`, `SECTION_H 1247`, `SEASON_PROGRESS_H 128`, `SEASON_SPLIT_H 128`, `SEASON_ICON 56`, `SEASON_ART_FRAME 128`, `SEASON_ART 108`. Dodaj `SEASON_ART_RADIUS 28`, `SEASON_ART_BORDER 3`, `SEASON_COIN_COL_W 310`, `SEASON_COIN_BAR_INDENT 70`, `SEASON_FLOWER_GAP 20`, `SEASON_NAME_W 471`, `FONT_SEASON_FLOWER 42`. Ispravi komentar uz `SEASON_H` ("nikad se ne mijenja").
2. **CoinProgress.** `VBoxContainer` 310 × 128, `alignment = END`, separation 6. Red: ikona 56 + `%SeasonLinkCoins` (separation 14). Traka u `MarginContainer` s `margin_left 70` — počinje tamo gdje i broj.
3. **SplitLine.** `custom_minimum_size = (5, 128)`.
4. **FlowerProgress.** Iz `VBox` u `HBoxContainer`, separation 20: `%SeasonLinkFlower` pa novi `FlowerBody` (`VBoxContainer`, 471 × 128) sa `%SeasonLinkFlowerName`, `%SeasonLinkT3`, `%SeasonLinkT3Bar`. Razmak: ime na vrhu, traka na dnu (spacer `size_flags_vertical = 3` između, ili separation 10 — daje 0–42 / 52–100 / 110–128).
5. **FlowerArt.** `flower_art.configure_frame(UiCamp.SEASON_ART_FRAME, UiCamp.SEASON_ART_RADIUS, UiCamp.SEASON_ART_BORDER, 0.0, 0, 0, UiCamp.SEASON_ART)`. `set_art(false, flower_type, 3)` ostaje — igra crta postojeći SVG (Harvest Pumpkin) ili proceduralni fallback (Crystal Peony, Midnight Lotus).
6. **FlowerName (novi label).** U `_show()`: `flower_name.text = GameState.get_seed_display_name(flower_type)`. U `_ready()`: `UiCamp.style_label(flower_name, UiCamp.FONT_SEASON_FLOWER, UiCamp.DARK_INK)`, `autowrap_mode = OFF`, `text_overrun_behavior = OVERRUN_NO_TRIMMING`, `clip_text = false`. Fit: ako `get_minimum_size().x > SEASON_NAME_W`, smanji na 38 pa 34 — nikad ellipsis. `mouse_filter` IGNORE (dolazi iz `_ignore_tree`).
7. **Burst.** Bez promjene (`_draw()`, 0,42 s + 0,45 s). Ime i ikona ostaju vidljivi jer `_show(def, coins_cost, t3_required)` ne dira `flower_art` ni ime.
8. **Smoke.**
   - `camp_season_link_smoke`: kartica `1032 × 318`; `%SeasonLinkFlowerName` sada MORA postojati, `text == "Harvest Pumpkin"`, font ≥ 34, širina ≤ 471, bez trimminga (`%SeasonCoinCap` i dalje ne smije postojati); provjera "coin icon and flower art must share a row" → centar `%SeasonLinkCoinIcon` = centar `%SeasonLinkT3` (±2); "bars must share a row" ostaje.
   - `camp_layout_smoke`: `StashSection.y` u CampPage = **362**.
   - `camp_section_fixed_smoke`: `StashSection.size.y` = **1247** s karticom, 1585 bez.

## Šta se ne dira (kod)

`navigate_to_lock()`, `_on_unlock_clicked()`, `unlock_button_*`, `season_card_style()`, `progress_*_style()`, tintovi, burst, sve u `StashSection`.
