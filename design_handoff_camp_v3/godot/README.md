# Camp v3 — prenos u Godot (red koraka)

Mjere 1:1 u px baze 1080 × 1920. Konstante: `ui_camp.gd` (samo izmjene — spoji u `game/scripts/visual/ui_camp.gd`). Stablo: `camp_tree.txt`. Podaci: `camp_v3_export.json`.

1. **Pozadina.** `CampPage` bg = `UiCamp.PAGE_BG` (#4E3F5A). Sjene sekcije i kartice → `PAGE_SHADOW`. Header/footer ne diraj.
2. **Pravilo.** Dodaj `UiCamp.gate_count()` / `gate_open()` i koristi ih na jednom mjestu (Arena kontroler čita isto). Test: `[13,3,40] → 53 true`, `[49] → false`, `[12,12,12,12] → 48 false`, `[50] → true`.
3. **Chip.** U `camp_stash_chip.gd` uvedi `PipsRow` (HBox) s `RarityPips` + `MergeableMark`. Vidljivo samo na Seeds i `is_mergeable(count)`. Prijelaz 3↔4 tokom prodaje: tween 0,14 s.
4. **Trade bar.** `MergeableWarning` ispod `TradeRow`. Tekst iz `merge_line_text(count)`; prazno = sakriveno. Visina bara `trade_height_v3()`, lista `grid_budget_v3()`. Držanje NE staje na 4 (to je samo za rezervisano cvijeće).
5. **Arena gate.** Polje ostaje. Dodaj `GateCount` pilulu iznad korpe (y 1141) i sakrij brojač korpe. Tap na korpu: `gate_open()` → sipa; inače `NeedSeedsModal` (UiPopups modal). Mehanika polja se ne mijenja.
6. **Nadogradnje.** Spremanje po sezoni: `upgrades[season_id] = {magnet, loot, third}`; nova sezona = 0, povratak čita stari zapis. Cijena: 2 ★3 te sezone iznad Kept granice + `UP_COIN_COST[L]`. Stanje dugmeta: `upgrade_state()`.
7. **Twin Seeds.** U pickupu sjemena: `if randf() < UiCamp.twin_chance(L): +2 else +1`, prije loot množitelja; cap 40 isti. FloatPop "+2".
8. **Korpa.** Picker lista samo `seen_in_run[season][type]`. Prazan picker: "Seeds you catch in a run show up here".
9. **Testovi.** `camp_mergeable_smoke` (oznaka/linija za 3/4/12), `arena_gate_sum_smoke` (4 primjera), `upgrades_per_season_smoke` (0 na novoj, restore na povratku, 5 stanja), `twin_seeds_smoke` (p na 0 i 4).
