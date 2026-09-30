# Godot — red prenosa

1. Dodaj `ui_home_v3.gd` (konstante + `play_mode()`); ne briši `ui_stage.gd` / `ui_home_field.gd` dok v3 ne radi.
2. Složi stablo iz `home_tree.txt`; sve Panele kao StyleBoxFlat (ravna boja, radius, border, jedna sjena) iz `home_v3_export.json → components`.
3. SeasonCard: tri ColorRect trake po `CARD_BANDS`, boje iz `sky()/near()` — iste funkcije koristi Meadow, pa je šav nevidljiv.
4. Tabovi + strelice + SeasonDots; card swap tween 220 ms. Swipe po kartici = sezona; hub swipe samo u `layout.HubSwipeZone`.
5. PlayButton: `play_mode(viewed, active, field_open)` → RETURN_TO_ACTIVE (Back + disk) / OPEN_FIELD / START_RUN.
6. Statusi kartice (active, locked, unlock, buy, owned, soon) iz `components.SeasonCard.states`; unlock = 500 coina + 20 ★3 prethodne, redom.
7. OpenTransition (runda 2): jedan `tween_method(_apply_u, 0, 1, OPEN_MS/1000)`; `_apply_u(u)` postavlja SVE tragove iz `animations.open` (geometrija na `ease_t(u)`, blijeđenja na `win(u, a, b)`). Zatvaranje: isti `_apply_u`, u 1 → 0 za `CLOSE_MS`. Tako su kadrovi otvaranja i zatvaranja isti.
   - **Jedan objekat (P2–P4):** SeasonName, MeadowPip i PlayButton su po JEDAN čvor iznad SeasonField-a. SeasonField za to vrijeme skriva svoj SeasonLabel / MeadowPip / FieldPlayButton (ili ih Home reparentira). Na u = 1 vrijednosti su tačno NAME_FIELD / PIP_FIELD / PLAY_FIELD, pa predaja nema skok.
   - **Jedne trake (P5):** kartica crta trake `round(h*0.32)`, `round(h*0.68)`; SeasonField trake su skrivene dok u < 1, a na u = 1 se kartica sakrije i trake SeasonField-a pokažu u istom frameu.
   - **FieldClip:** SeasonField je dijete Control-a s `clip_contents` i rectom kartice (radius preko StyleBoxFlat maske ili bez radiusa — razlika je ispod 48 px ugla).
   - **Pip:** `season_field.gd` `_restart_wander()` zvati tek u `finished` otvaranja; na zatvaranju `_stop_wander()` i uzeti `meadow_pip.position` kao početak.
   - **Unos:** `is_field_transitioning()` ili slide/drag → ignoriši tabove, strelice, karticu, Play, Seasons.
   - **OpenTransition ne prima dodir** (`OPEN_TRANSITION_MOUSE_FILTER` = `MOUSE_FILTER_IGNORE`) — pokriva cijelu stranicu, pa bi inače pojeo tap na tabove. Dodir primaju SeasonCard, PlayButton i FieldClip (samo na u = 1).
8. FieldPage: postojeći čvorovi iz field v2; `tween_chrome_in` i `tween_flowers_settle` zamijeniti vrijednostima iz `_apply_u` (ANIM_CHANGES: chrome stagger 0, flower stagger 12 ms, start u .20).
9. Runda 4 — imena cvijeća: diskovi iz `ROSTER6` (kolone 276 / 516 / 756, red 2 na 560). Ime koje fali: `font(900, MISSING_NAME_SIZE)`, linije = jedan red ako je `text_w ≤ MISSING_NAME_MAX_W`, inače `UiStage.balance_lines(text, font, 34, MISSING_NAME_MAX_W)` (najviše 2), centrirano na disk, `MISSING_NAME_GAP` ispod njega. Smoke test: za svih 8 sezona kutije imena se ne sijeku, dno ≤ 830, dvoredna širina ≤ `MISSING_NAME_CONTENT_MAX_W`.
10. Provjeri: tekst ≥ 34, dodir ≥ 120, jedan loop (AttentionRing), bez blura i gradijenata.
