# Camp v2 — prenos u Godot (red koraka)

Mjere 1:1 u px baze 1080 × 1920. Konstante: `ui_camp.gd` (ovdje samo izmjene — spoji u `game/scripts/visual/ui_camp.gd`). Stablo: `camp_tree.txt`. Podaci: `camp_v2_export.json`.

## Koraci

1. **Konstante.** Spoji `ui_camp.gd` u postojeći `UiCamp`. Obriši sve što je označeno `# OBRISATI`. Kompajliraj — greške pokazuju gdje se stare konstante još koriste.
2. **Rupa.** U `camp_scene.tscn` obriši `ContentStack/StackGap`. `ContentStack.separation = 20`. `StashSection.custom_minimum_size.y = UiCamp.section_height(hero_visible)`, `size_flags_vertical = 0`.
3. **Lista.** Unutar `SectionVBox`: `StashScroll` (vertikalno) dobija `size_flags_vertical = 3`; `StashGrid` je njegovo dijete. Ukloni rezanje redova po `grid_budget()` — lista samo skrola.
4. **SeasonLinkCard.** Obriši `SeasonEyebrow`, `HomeHint`, oba caption labela. `UnlockButton` premjesti u `SeasonHead` (desno od imena), 300 × 120. `unlock_button_text()` sada vraća `String`. Visina kartice 276.
5. **Tabovi.** Obriši `%MergeShortcut` i `_sub` u `camp_stash_tab.gd`. Visina reda 120, okvir ikone 76, brojač 56 × ≥80.
6. **CampChip.** Okvir arta 128, well inset 8, crtež 96 / 100. Rezervisan chip 176: `ReservedBadge` je vidljiv umjesto `RarityPips`. `PricePill` bez "each".
7. **TradeBar.** Obriši `SelectedValue` i podnaslov dugmeta. Dugme 300 × 120 s opcionom ikonom (`trade_button_icon()`). `HoldFill.size.x = 300 * hold_fill_ratio(sold, sellable_left)`.
8. **Signal držanja.** Na tap: fill skoči za 1/gomila pa se isprazni (0,30 s). Na tick (10/s): `FlyCoin` 44 px tween od dugmeta do `CoinChip` (max 3 živa) + `CoinChipBump`. `TradeFeedback` "+N" raste po ticku.
9. **Prazno stanje.** `EmptyState` zamjenjuje `StashScroll` (sekcija ostaje iste visine). Bez rečenice. `EmptyCta` 120 dodir / 100 vizuelno.
10. **Testovi.** Ažuriraj smoke testove iz `camp_v2_export.json → smoke_tests.must_update`; dodaj `camp_section_fixed_smoke`.

## Šta se briše (kod)

- `StackGap`, `SECTION_GAP_MIN`, `SECTION_H_DEFAULT`, `GRID_MAX_ROWS`
- `SeasonEyebrow`, `HomeHint`, `home_hint_style()`, `HOME_HINT_H`, `FONT_SEASON_EYEBROW`, `FONT_SEASON_CAP`, `FONT_HOME_HINT`, `UNLOCK_BTN_H`
- `%MergeShortcut`, `shortcut_style()` (ako ga više ništa ne koristi), `SHORTCUT_W`, `SHORTCUT_ICON`, `FONT_SHORTCUT`, `_sub` na tabu, `FONT_TAB_SUB`
- `SelectedValue`, `trade_info_text()`, `FONT_TRADE_SUB`, `FONT_BTN_SUB`
- `EmptyBody`, `EMPTY_BLOCK_H`, `EMPTY_BODY_MAX_W`, `FONT_EMPTY_BODY`
- `FONT_EACH`, `FONT_BADGE_FLOOR`, tekst "Hold stops here"
