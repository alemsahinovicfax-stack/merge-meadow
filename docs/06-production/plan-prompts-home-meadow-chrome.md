---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, sezone, meadow, chrome, basket, endless, plan, prompt]
povezano:
  - ideje-home-meadow-chrome
  - ideje-home-meadow-chrome-pitanja
  - ideje-home-meadow-chrome-grupe
  - ideje-home-meadow
  - plan-prompts-seed-meadow
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode playlist HOME-13 — P0 ✅ A–E ✅ (zatvoren)."
---

# Plan promptovi — HOME-13 meadow chrome

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** fenced blok ispod → odobri → Agent.  
> **Ne** zalijepi dva bloka u isti chat. **Ne** spajati s [[plan-prompts-seed-meadow|SEED/HOME-12 kod]] ni [[plan-prompts-camp-cliff|CAMP-02]].  
> **Grana:** **`master`**. Fair F2P: paid = tema. **Ne 8 tscn polja.**  
> Freeze: [[../03-content/ideje-home-meadow-chrome-pitanja|P159–P178]] · override P139 P140 P144 P149.

**CHROME-P0** ✅ 2026-09-01 (docs). **CHROME-A ✅** **CHROME-B ✅** **CHROME-C ✅** **CHROME-D ✅** **CHROME-E ✅** 2026-09-01. Playlist zatvoren.

## Paste redoslijed (kod)

| # | Prompt | Stavka | Što |
|---|---------|--------|-----|
| 0 | **CHROME-P0 ✅** | sve | Docs freeze (ne paste) |
| 1 | **CHROME-A ✅** | 4 | PipPortrait + MeadowPip van |
| 2 | **CHROME-B ✅** | 5 | Full-bleed tint iza Daily / Options / Play |
| 3 | **CHROME-C ✅** | 1 | Basket u polje; season filter; T3 ikona |
| 4 | **CHROME-D ✅** | 2 | Endless samo u sezoni; spawn = field id |
| 5 | **CHROME-E ✅** | 6 | Name chip natrag; SeasonsButton hide |

A smije prije B. **A–E ✅.** Ne spajati C+D.

## Freeze

**P159–P178:** Pip off (portrait + meadow UniqueName hidden); full-bleed MainMenu tint kad je polje open (ne hub TopBar); karusel tamni bg; Basket i Endless samo u polju; picker `types_for_season` ∩ unlocked; T3 `CampPlantDraw`; `clear_loadout` van poola; Endless Hard; tema = `home_season_field_id`; name chip + system Back; `%SeasonsButton` UniqueName hidden; P138 Play dual ostaje; nema SAVE_VERSION.

Ostaje HOME-12: jedan `SeasonField` + `apply_season`; `can_open` playable; session flagovi; cvijeće iz `seed_type_ids`; flower slotovi.

Ne dirati: Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum, CAMP-01/02, hub pager, run `pip_visual` / `player.gd` / ArenaPip, `merge_arena_controller`.

---

## P0 arhiva — urađeno 2026-09-01 (ne paste)

### CHROME-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-13 docs freeze — meadow chrome: Basket/Endless u polju, full-bleed, Pip van, name-chip natrag.

Dokumentiraj P159–P178 i override P139/P140/P144/P149. Nema game/ u P0. CHECKPOINT sljedeci_korak ostaje D0-P. Grana master.

Fajlovi: ideje-home-meadow-chrome.md hub; layout/basket/nav/pitanja/grupe; plan-prompts-home-meadow-chrome.md P0 A–E. Wire _index, ideje-kad-predloziti, ideje-home-meadow sljedeće HOME-13, CHECKPOINT zadnja_sesija, changelog.
```

---

## 1 — CHROME-A (Pip van) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-13 CHROME-A — Pip nestaje s biranja sezona i iz polja.

Ovisi o CHROME-P0. Freeze P159 P160. Ne full-bleed (B). Ne Basket (C). Ne Endless (D). Ne name chip (E). Ne SAVE_VERSION.

Danas: %PipPortrait u HomeColumn iznad SeasonStage (pip_placeholder_control, companion). Kartice/roster nemaju Pip sliku. U polju %MeadowPip wander (MEADOW-C). Run companion netaknut.

CHROME-A:
1) main_menu: %PipPortrait visible = false (karusel i field). Ne brisati UniqueName ako smoke/hub očekuje node — sakriti. Ne follow_active_companion / get_active_companion_id.

2) season_field: MeadowPip UniqueName ostaje. visible = false uvijek; _stop_wander na ready/open/rebuild; clear_flowers i dalje skip MeadowPip. Ne instancirati pip_visual.gd.

3) Smokes: season_meadow_smoke — Bloom/Frost open: MeadowPip hidden (ne wander assert). Node count i dalje 1, isti instance_id Frost vs Bloom. season_home_smoke: PipPortrait hidden after tutorial (node smije postojati).

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Play/Seasons/Endless routing, flower layout, Shop, AdMob, ArenaPip, player.gd, active_companion_id API, CAMP, SAVE_VERSION.

Relevantno: docs/03-content/ideje-home-meadow-chrome.md, ideje-home-meadow-chrome-pitanja.md P159–P160, ideje-home-meadow-pip.md (superseded wander), main_menu.tscn PipPortrait, season_field.gd / season_field_pip.gd, season_meadow_smoke.gd, season_home_smoke.gd.

Acceptance: na karuselu nema velikog Pipa; u polju nema wander Pipa; cvijeće ostaje; Play i dalje otvara polje; run Pip netaknut.
```

---

## 2 — CHROME-B (Full-bleed tint) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-13 CHROME-B — polje je cijela pozadina MainMenu iza Daily, Settings i Play.

Ovisi o P0. A smije biti gotov. Freeze P161 P162 P163. Ne Basket move (C). Ne Endless hide (D). Ne name chip (E). Ne 8 tscn. Ne hub TopBar/nav tint.

Danas: FieldGround tint samo unutar SeasonStage. Play, DailyChestCard, SettingsButton, MainMenu Background ostaju tamnozeleni.

CHROME-B:
1) Kad home_season_field_open: SeasonTheme.bg_modulate(home_season_field_id); ako WHITE, Bloom pastel kao season_field.gd. Pokrij cijeli MainMenu rect IZA Daily, Settings, Play (z_index chromea iznad). Sibling backdrop na MainMenu ILI proširi FieldGround — jedan apply_season id.

2) Karusel (field closed): stari MainMenu Background. Decor mounds smiju hide samo dok je field open.

3) Cvijeće i SeasonField overlay ostaju; FLOWER_SLOTS / count ne dirati.

Smokes: season_meadow_smoke — Bloom open: tint nije samo stari Stage rect (uzorak iza Daily ili Play nije default dark green). Close: tamni bg. Frost open: tint ≠ Bloom; i dalje 1 SeasonField.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, Unlock JSON, CAMP, leftover, hub pager, SAVE_VERSION, Play dual P138, flower slots, run Pip.

Relevantno: ideje-home-meadow-chrome-layout.md, ideje-home-meadow-chrome-pitanja.md P161–P163, main_menu.tscn Background/HomeTopStack/SettingsButton, season_field.gd apply_season, SeasonTheme, season_meadow_smoke.gd.

Acceptance: u sezoni Daily/Options/Play sjede na temi te sezone; karusel je i dalje tamni Home; jedan shell.
```

---

## 3 — CHROME-C (Basket u polje) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-13 CHROME-C — Basket samo u otvorenoj sezoni, lijevo od Play; sjeme te sezone; T3 u korpi.

Ovisi o CHROME-B. Freeze P164–P168. Ne Endless (D). Ne name chip (E). Ne SEED JSON rewrite.

Danas: %BasketCard u HomeTopStack ispod Daily, vidljiv na karuselu. Picker = get_unlocked_loadout_types() global chain. home_basket_visual = pickup T1.

CHROME-C:
1) Karusel: BasketCard not visible. Daily ostaje. Polje open: Basket visible lijevo od Play (isti donji red kao Play; Endless smije još biti karusel-visible dok D ne padne — ne implementirati D).

2) _rebuild_picker_list: SeedCatalog.types_for_season(home_season_field_id) ∩ unlocked, skip mythic. Overlay ostaje na Home.

3) home_basket_visual: izabrano = CampPlantDraw tier 3; prazno = outline. Ne pickup texture kao filled state.

4) apply_season / open field: ako loadout_type_id nije u poolu → clear_loadout. set_loadout API ostaje.

Smokes: home_basket_picker_smoke — karusel Basket hidden; field Bloom: Basket visible; picker nema frost-only id. Meadow/Frost open: lista iz Frost seed_type_ids. Close: Basket hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP bag, Unlock JSON, flower slots, SAVE_VERSION, begin_endless_run, Play dual.

Relevantno: ideje-home-meadow-chrome-basket.md, P164–P168, main_menu.gd _rebuild_picker_list / BasketCard, home_basket_visual.gd, camp_plant_draw.gd, SeedCatalog.types_for_season, home_basket_picker_smoke.gd, season_meadow_smoke.gd.

Acceptance: na biranju sezona nema Basketa; u Bloom polju biraš Bloom sjeme; ikona je T3 biljka; Frost čisti clover loadout.
```

---

## 4 — CHROME-D (Endless samo u sezoni) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-13 CHROME-D — Play Endless nestaje s karusela; u polju radi za svaku playable sezonu (Hard).

Ovisi o CHROME-B. Freeze P169–P171. P38 Hard ostaje. Ne Easy/Normal UI. Ne Basket (C) osim da Endless stoji desno od Play, Basket lijevo ako C već postoji.

Danas: %EndlessPlayButton u HomeColumn, visible nakon tutorial_complete na karuselu. begin_endless_run(HARD) koristi active_season_id — rupa: Frost u centru, Bloom još active → Bloom spawn.

CHROME-D:
1) visible samo home_season_field_open AND tutorial_complete. Karusel: hidden.

2) Press: set_active_season(home_season_field_id) ako treba, zatim begin_endless_run(HARD). Spawn = get_active_season_spawn_types() te sezone.

3) Ne dirati RunLevelLibrary Hard brojke. Ne dual Endless=open field.

Smokes: season_home_smoke — nakon tutorial, karusel EndlessPlayButton not visible (node postoji). season_meadow_smoke — Bloom/Frost open: Endless visible; optional: Frost field id → spawn types match frost seed_type_ids (helper ili GameState.get_active_season_spawn_types nakon open). Close: Endless hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, SAVE_VERSION, flower slots, run Pip, campaign Play dual, SeedCatalog JSON.

Relevantno: ideje-home-meadow-chrome.md, P169–P171, ideje-home-chrome-endless.md (Hard ostaje), main_menu.gd _on_endless_play_pressed / _refresh_menu, game_state.gd begin_endless_run / open_home_season_field, season_home_smoke.gd, season_meadow_smoke.gd.

Acceptance: Endless nije opcija dok biraš sezonu; u Frost polju Endless je Frost tema Hard; Bloom polje = Bloom pool.
```

---

## 5 — CHROME-E (Name chip natrag) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-13 CHROME-E — natrag na karusel preko imena sezone gore, ne gumba Seasons na cvijeću.

Ovisi o CHROME-B. Freeze P172–P174. P148 swipe L/R nije Back. Ne chevron osim ako korisnik eksplicitno swap-a; default = name chip.

Danas: %SeasonsButton top-center UiClickButton "Seasons" na SeasonField.

CHROME-E:
1) Novi %SeasonNameChip (Control/Button mali): tekst = season display name za home_season_field_id. Tap → close_season_field. Gore, ne preko Daily (HomeTopStack lijevo) ni Settings (desno).

2) %SeasonsButton UniqueName ostaje; visible = false; label ""; clicked ne close (ili disconnect). CAMP2-A pattern.

3) Android/system Back + KEY_ESCAPE: ako field open → close_season_field, ne hub pop.

Smokes: season_meadow_smoke — open: SeasonsButton hidden ali node postoji; SeasonNameChip visible, text sadrži Bloom/Frost ime; close via chip (call clicked ili close_season_field) → karusel. Frost chip ≠ Bloom. Close: chip hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, flower slots, hub pager, Play dual.

Relevantno: ideje-home-meadow-chrome-nav.md, P172–P174, season_stage.tscn SeasonsButton, season_stage.gd close_season_field, main_menu / meta_hub back handling, season_meadow_smoke.gd.

Acceptance: nema debelog Seasons CTA na sredini polja; vidiš ime sezone; tap ili Back vraća karusel; Play i dalje run na polju.
```

---

## Redoslijed i ovisnosti

1. **CHROME-P0** docs — **✅ 2026-09-01**.  
2. **CHROME-A** Pip van — **✅ 2026-09-01**.  
3. **CHROME-B** full-bleed — **✅ 2026-09-01**.  
4. **CHROME-C** Basket — **✅ 2026-09-01**.  
5. **CHROME-D** Endless — **✅ 2026-09-01**.  
6. **CHROME-E** name chip — **✅ 2026-09-01**.  
7. Ne spajati s HOME-12 MEADOW kodom ni CAMP-02.

## Povezano

- [[../03-content/ideje-home-meadow-chrome|HOME-13 hub]] · [[../03-content/ideje-home-meadow|HOME-12]]  
- [[plan-prompts-home-meadow-life|HOME-14 life]] · [[plan-prompts-seed-meadow|SEED-01 + HOME-12]] (zatvoren playlist)  
- [[CHECKPOINT|CHECKPOINT]]
