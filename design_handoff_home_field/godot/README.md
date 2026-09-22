## Home — polje sezone · paket za prenos u Godot 4

Izvor dizajna: `design_handoff_home_field/HomeField.dc.html` (8 stanja) i
`HomeField Specs.dc.html` (mjere, sve sezone, prelaz, animacije, mapa slojeva).
Brief: `docs/04-experience/design-drafts/home-field-cd-brief.md`.

Ovaj paket je nadogradnja, ne zamjena: `field_export.json` i `ui_home_field.gd`
drže samo ono što je novo ili promijenjeno u odnosu na
`design_handoff_home/godot/home_export.json` + `ui_home.gd`. Tokeni koji nisu
ovdje se ne mijenjaju.

### Fajlovi

| fajl | šta je |
| --- | --- |
| `field_export.json` | ista šema kao `home_export.json`: `meta`, `tokens`, `derived_fills`, `season_meadow`, `layout`, `components`, `scenes`, `animations`, `strings_en`, `assets`, `godot_map`, `smoke_tests`, `decisions` |
| `ui_home_field.gd` | `UiHomeField` — konstante, izvedene boje, StyleBoxFlat fabrike, tekstovi koji se računaju, tween helperi |
| `README.md` | ovaj fajl |

### Prenos u 7 koraka

1. **Pozadina.** `main_menu.gd` → `sync_field_backdrop()`: obriši granu koja
   nanosi tint sezone. `FieldBackdrop` je uvijek `#2E4733`, isto kao Home i Camp.
2. **Raspored.** `_apply_mode_layout(true)`: obriši `FIELD_COLUMN_OFFSETS`
   (48, 380, −48, −24) i `FIELD_COLUMN_SEPARATION` 12. Polje je `VBoxContainer`,
   padding 24, gap 16, djeca po redu iz `layout` (`FieldTopRow` 124 → `Meadow`
   flex 605 → `BasketCard` 180 → `UpgradeCard` ×2 192 → `PlayRow` 176; suma s pet
   gapova od 16 je točno 1549). Visine korpe i nadogradnje su stvarne visine
   sadržaja — ne zaokružuj ih, jer razliku pojede `Meadow`.
3. **Livada.** `MeadowGround` postaje `Panel` sa `UiHomeField.meadow_frame()`
   plus tri `ColorRect` trake (`MEADOW_BANDS`). Tint sezone ide **samo** ovdje.
   `meadow_safe_rect()` i `_chrome_controls()` za livadu se brišu — chrome je
   izvan livade i nema šta izbjegavati.
4. **Cvjetovi i Pip.** 13 mjesta iz `MEADOW_SPOTS`; mjesto je vidljivo kad
   `GameState.garden_crystal_stash[type] >= need`, inače je `soil_spot()` pill.
   `MeadowPip` 72 → 190 px, FSM ostaje.
5. **Nadogradnje.** `_refresh_field_upgrades()` gradi karticu od 192 px:
   `UpgradeLevel` čip, 4 segmenta, red efekta (`magnet_effect()` /
   `loot_effect()`), `UpgradeCost` s imenom cvijeta i dugme s razlogom
   (`upgrade_button_label()`). **Obavezno:** `pick_upgrade_flower_type()` se mora
   zvati pri svakom refreshu, ne tek pri trošenju — inače cijena ne postoji prije
   tapa (§10, poznati problem 3).
6. **Korpa i picker.** `BasketCard` 336 × 104 → 1032 × 180 s `BasketButton`.
   Prazno stanje koristi `icon_seed_light.svg` (#FFF6D6) — tamni `icon_seed.svg`
   se na wellu `#22342A` ne vidi.
   `BasketPickerOverlay` iz centriranog panela 560 u bottom sheet 1080 × 1308;
   `PICKER_ROW_MIN_HEIGHT` 128 → 148.
7. **Izlaz i prelaz.** `%SeasonsRowButton` → 300 × 124 gore lijevo, **bez**
   `tutorial_complete` uslova. `open_season_field()` / `close_season_field()`
   dobijaju `tween_open_field()` + `tween_chrome_in()` + `tween_flowers_settle()`.

### Obrisati

- `SeasonField/SeasonsButton` — mrtav node, uvijek skriven (§10, problem 1).
- Tint granu u `sync_field_backdrop()`.
- `meadow_safe_rect()` i pripadni `_chrome_controls()`.
- `tutorial_complete` uslov na `%SeasonsRowButton`.
- Izgled dugmeta na `%SeasonNameChip` — postaje običan `Label` + tagline.

### Hub swipe

U grupi `block_hub_swipe` ostaju `BackButton`, `BasketCard`, obje `UpgradeCard`,
`PlayButton`, `EndlessButton` i picker. `Meadow`, `FieldTitle` i `FieldBackdrop`
**nisu** u grupi — livada propušta horizontalni swipe, pa se hub i dalje lista.

### Smoke testovi

Moraju se ažurirati: `season_meadow_smoke` (13 mjesta, dio prazan; nema
`meadow_safe_rect`; Seasons vidljiv prije tutoriala; nove veličine Play/Endless),
`home_basket_picker_smoke` (bottom sheet, red 148, `BasketButton`),
`season_home_smoke` (otvaranje polja ima tween — test mora čekati
`FieldTransition`). Nepromijenjeni prolaze: `camp_season_link_smoke`,
`meta_hub_flow_smoke`, `season_unlock_smoke`. Novi checkovi su u
`field_export.json` → `smoke_tests.new_checks`.

### Assets

Nula novih crteža. Svaki panel, mjesto u zemlji, traka, segment, čip i dugme je
`StyleBoxFlat`. Jedini novi fajl je `icons/icon_seed_light.svg` (postojeći glif u #FFF6D6).
Cvijeće je `flowers/ph_*.svg`, Pip je `icons/pip_idle.svg`
(kopija `game/assets/sprites/pip_idle.svg`). Prava ilustracija livade, ako
ikad dođe, zamjenjuje tri ravne trake 1:1 i ništa drugo se ne mijenja.
