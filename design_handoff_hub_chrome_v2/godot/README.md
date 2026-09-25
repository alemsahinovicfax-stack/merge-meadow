# Hub chrome v2 → Godot — red prenosa

Sve je 1:1 u px baze 1080 × 1920. Vrijednosti: `hub_chrome_v2_export.json`, konstante: `ui_chrome.gd` (diff), stablo: `hub_tree.txt`.

## Koraci

1. **Ikone.** Kopiraj `../assets/icons/*.svg` u `game/assets/ui/chrome/` (prepisuje v1 fajlove istog imena, `icon_flower.svg` je nov). Pokreni `scripts/godot-import.ps1`, commitaj `.import`. Nijednoj ikoni ne postavljaj `modulate` RGB — samo `.a`.
2. **Tokeni.** Primijeni diff iz `ui_chrome.gd` na `game/scripts/visual/ui_chrome.gd`: `CHROME_DEEP #2A2233`, `CHIP_WELL`, nove mjere footera, brisanje `TAB_ICON_GAP`, `TAB_LABEL_FONT_SIZE`, `tab_ink()`; `chip_style()` gubi argument.
3. **Header.** `meta_hub_controller.gd _setup_chip()`: `chip_style()`, ikona 64, gap 10, broj `NUMBER_INK`. Preimenuj `DiamondChip → FlowerChip`, ikona `icon_flower.svg`, `refresh_top_bar()` čita `GameState.get_garden_crystal_total()`. Settings ikona → `icon_settings_light.svg` @ 56.
4. **Footer.** `PageIndicator.custom_minimum_size.y = 144`, `NavPanel/Content` 141. `hub_tab.gd`: makni `_label`; tile 184 × 108 @ (16, 20); hit-zona cijeli slot 216 × 141; `set_active(true)` → `tab_<key>.svg` @ 72, y −2; `false` → `tab_<key>_light.svg` @ 64, a 0.82; `tooltip_text` = ime taba. Badge offset (6, −8). Indikator 72 × 8 @ y 6, x = `get_scroll_page() * 216 + 72`. Lock pilula: font 38, ikona 34.
5. **Stranice (+36).** Vidi tabelu u glavnom README § Δ po stranici. Traži po cijelom `game/` brojeve `1597` i `1740` — svaki pogodak ili ide na `UiChrome.PAGE_H` ili se sabira s `FOOTER_DELTA`.
6. **Coin u runu.** `coin_visual.gd`: `_ready()` → `texture = load(UiChrome.ICON_COIN)`, `scale = Vector2.ONE * (96.0 / 128.0)`; iz `_draw()` ostaje samo `_draw_shadow()`. Kolizija r 18 na roditelju — bez promjene.
7. **Ostala mjesta coin/seed/flower** (brief §5.1–5.2): ista putanja fajla, samo skini `modulate = OUTLINE` gdje postoji (nova ikona je u boji). Home korpa: `icon_seed_light` → `icon_seed.svg`. Camp Flowers tab / prazno stanje / Shop fallback: `arena/icon_crystal.svg` → `chrome/icon_flower.svg`.
8. **Smoke.** Ažuriraj `hub_chrome_smoke`, `camp_layout_smoke`, `camp_section_fixed_smoke`, `arena_redesign_smoke`, `season_home_smoke`, `meta_hub_flow_smoke`; pusti cijeli suite + GUT.

## Šta se briše

- `UiChrome.TAB_ICON_GAP`, `TAB_LABEL_FONT_SIZE`, `tab_ink()`, argument `chip_style(fill)`
- `HubTab._label` i sav kod koji mu postavlja font/boju
- `UiRun.COIN_FILL / COIN_EDGE / COIN_INNER / COIN_GLINT` (kad coin_visual koristi teksturu)
- `game/assets/ui/chrome/icon_seed_light.svg`
- `icon_diamond.svg` iz hub headera (fajl ostaje za run HUD)
- nakon provjere: `assets/pickups/coin.png`, `seed.png` + `PickupAssets.get_coin_texture()` fallback
