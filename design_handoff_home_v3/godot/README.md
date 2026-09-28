# Godot — red prenosa

1. Dodaj `ui_home_v3.gd` (konstante + `play_mode()`); ne briši `ui_stage.gd` / `ui_home_field.gd` dok v3 ne radi.
2. Složi stablo iz `home_tree.txt`; sve Panele kao StyleBoxFlat (ravna boja, radius, border, jedna sjena) iz `home_v3_export.json → components`.
3. SeasonCard: tri ColorRect trake po `CARD_BANDS`, boje iz `sky()/near()` — iste funkcije koristi Meadow, pa je šav nevidljiv.
4. Tabovi + strelice + SeasonDots; card swap tween 220 ms. Swipe po kartici = sezona; hub swipe samo u `layout.HubSwipeZone`.
5. PlayButton: `play_mode(viewed, active, field_open)` → RETURN_TO_ACTIVE (Back + disk) / OPEN_FIELD / START_RUN.
6. Statusi kartice (active, locked, unlock, buy, owned, soon) iz `components.SeasonCard.states`; unlock = 500 coina + 20 ★3 prethodne, redom.
7. OpenTransition: jedan `create_tween().set_parallel()` po `animations.open`; zatvaranje isti tween unazad (`CLOSE_MS`).
8. FieldPage: postojeći čvorovi iz field v2; dodaj samo ulazne trake (scale/y/x) iz `animations.open`.
9. Provjeri: tekst ≥ 34, dodir ≥ 120, jedan loop (AttentionRing), bez blura i gradijenata.
