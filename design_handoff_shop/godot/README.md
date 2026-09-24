# Godot paket — Shop

- `shop_export.json` — tokeni, mjere, stanja, animacije, stringovi, mapa na postojeće nodove, smoke testovi.
- `ui_shop.gd` — `class_name UiShop`: konstante, pravila prikaza (`cosmetic_mode`, `buy_mode`, `season_mode`, `use_mode`, `fail_text`, `price_font_px`) i StyleBoxFlat fabrike. Ide u `game/scripts/visual/`.
- `shop_tree.txt` — stablo nodova.

Redoslijed:
1. Kopiraj `ui_shop.gd`; ne mijenja ništa dok se ne koristi.
2. `PipDraw.draw_pip(..., palette_override := {})` — jedini API dodatak.
3. Novi `shop_cosmetic_preview.gd` (_draw po `components.CosmeticPreview`).
4. Prepravi `shop_cosmetic_row.gd`, `shop_booster_row.gd`, `season_pack_card.gd`; dodaj `shop_jump_chip.gd`, `shop_purchase_status.gd`.
5. `shop_screen.tscn`: ukloni TopBar/StatusLabel/lavender panele, postavi ScrollContainer + ShopHeaderRow.
6. Ažuriraj smoke testove iz `smoke_tests.must_update`.

Ekonomija, katalog, SKU-ovi i cijene ostaju isti.
