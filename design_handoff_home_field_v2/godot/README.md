# Prenos u Godot — red koraka

Preduvjet: hub chrome v2 je u igri (stranica 1080 × 1633 od y 143, footer 144).

1. **Tokeni.** U `scripts/visual/ui_home_field.gd` primijeni `godot/ui_home_field.gd`: nove konstante, `MEADOW_BANDS [0.32, 0.68]`, nova `MEADOW_SPOTS`, fabrike `sticker()` / `tile()` / `corner_dot()` / … i izmijenjene `picker_*`, `upgrade_*`, `art_frame*`, `magnet_effect` / `loot_effect`. Obriši što piše u root README § Šta se briše.
2. **Font.** Labele u polju prelaze na `UiStage.font(weight, px)` (Nunito) — isto kao biranje sezone.
3. **Livada.** `%SeasonField` dobija metu tweena `MEADOW` (cijela stranica); `season_field.gd` crta tri trake po novim udjelima, mjesta iz `MEADOW_SPOTS` (baza = `spot_base()`), Pip u `PIP_BASE_ZONE`. `meadow_frame()` → `sticker`-less Panel bez ruba (radius i rub idu na 0 u tweenu).
4. **FieldOverlay (novo).** Pod `SeasonStage` dodaj `FieldOverlay` (Control, full rect, `mouse_filter IGNORE`) s čvorovima iz `field_tree.txt` na apsolutnim pozicijama. `HomeColumn` u field modu više ne nosi raspored — `_apply_mode_layout()` samo sakriva/pokazuje `FieldOverlay`.
5. **Premještanje u sceni, ne u runtime.** `%PlayButton`, `%EndlessPlayButton`, `%SeasonsRowButton`, `%TutorialHintPanel`, `%SeasonNameChip/NameLabel` sele u `FieldOverlay` u `.tscn`-u (CAMP-04 zamka). `FieldTopRow`, `BasketCard` i stalni `%FieldUpgradeStack` se brišu.
6. **GiftChest.** Nova instanca iste scene kao `%DailyChestCard` (`home_gift_card.gd`) u `FieldOverlay`; `_refresh_chest_card()` osvježava obje, polje ga više ne gasi. U polju `set_drop(true)` (tvrda sjena 0 8 0).
7. **BasketButton.** Okvir 84 + `HomeBasketVisual`; tri stanja iz `loadout_enabled()` i `get_loadout_type()`. Za "empty" pokreni `UiHomeField.tween_attention(ring)` i zaustavi ga čim je sjeme izabrano ili se polje zatvori.
8. **Sheetovi.** `%BasketPickerOverlay` → `SheetLayer/BasketSheet` (krem, 1326, redovi 148, portret 112; `_rebuild_picker_list()` ostaje). `MagnetRow` / `LootBoostRow` sele u novi `SheetLayer/UpgradesSheet` (922) kao `MagnetCard` / `LootCard`; `_apply_upgrade_card()` ostaje, čip "you have" otpada.
9. **UpgradesButton.** Trake iz `magnet_level` / `multiplier_level`; `UpgradeDot.visible = can_spend_flowers_for_upgrade() and (magnet_level < 4 or multiplier_level < 4)`; tap otvara UpgradesSheet.
10. **Prelaz.** `tween_open_field(shell, ground)` pa `tween_chrome_in()` s redom Play, Seasons, Endless, Gift, Basket, Upgrades, ime + čip. Zatvaranje: `chrome_out` 0,12 pa `field_close` 0,24.
11. **Swipe.** U `block_hub_swipe` idu Gift, Basket, Upgrades, tri dugmeta i `SheetLayer` dok je otvoren; livada, ime i GrownChip ne.
12. **Smoke.** Ažuriraj `season_meadow_smoke`, `home_basket_picker_smoke`, `season_home_smoke`; dodaj `home_field_overlay_smoke` (vidi `home_field_v2_export.json` › `smoke_tests`).

## Šta se briše u kodu

`FieldTopRow`, `BasketCard`, stalni `FieldUpgradeStack` blok, `meadow_frame()`, `field_panel()`, `back_button()`, `basket_card()`, `basket_button()`, `have_text()`, `PANEL_*`, `DISABLED_FILL/EDGE/INK`, `SUB_ON_DARK`, `TOP_ROW_H`, `BACK_W`, `BASKET_H`, `UPGRADE_H`, `UPGRADE_LEFT_W`, `PLAY_ROW_H`, `PLAY_W`, `ENDLESS_W`, `MEADOW_INNER`, `%SeasonNameChip/Tagline`, `icon_seed_light.svg`.
