---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, sezone, meadow, basket, daily, plan, prompt]
povezano:
  - ideje-home-meadow-dock
  - ideje-home-meadow-dock-pitanja
  - ideje-home-meadow-dock-grupe
  - ideje-home-meadow-life
  - plan-prompts-home-meadow-life
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode playlist HOME-15 — DOCK-P0 ✅ A ✅ B ✅ C ✅ D ✅."
---

# Plan promptovi — HOME-15 meadow dock

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** fenced blok ispod → odobri → Agent.  
> **Ne** zalijepi dva bloka u isti chat. **Ne** spajati s [[plan-prompts-home-meadow-life|HOME-14 kod]] ni [[plan-prompts-home-meadow-chrome|HOME-13 kod]] ni [[plan-prompts-camp-cliff|CAMP-02]].  
> **Grana:** **`master`**. Fair F2P: ★3 u basketu = tema, ne IAP. **Ne 8 tscn polja.**  
> Freeze: [[../03-content/ideje-home-meadow-dock-pitanja|P197–P214]] · override P165 P166 P173 P184 P185.

**DOCK-P0** ✅ 2026-09-02 (docs). **DOCK-A ✅** **DOCK-B ✅** **DOCK-C ✅** **DOCK-D ✅** 2026-09-02. Playlist A–D gotova.

## Paste redoslijed (kod)

| # | Prompt | Stavka | Što |
|---|---------|--------|-----|
| 0 | **DOCK-P0 ✅** | sve | Docs freeze (ne paste) |
| 1 | **DOCK-A ✅** | Picker | T3 ikona iznad imena; ★3; Clear+Close footer |
| 2 | **DOCK-B ✅** | Match | Meadow + basket isti T3 draw |
| 3 | **DOCK-C ✅** | Layout | Basket ispod Daily; Seasons u PlayRow; chip ne close |
| 4 | **DOCK-D ✅** | Daily | Streak tekst/claim van Home chesta |

A i D neovisni. B smije poslije A. **Ne spajati A+C.**

## Freeze

**P197–P214:** Basket 336×104 ispod Daily (karusel hidden); PlayRow Seasons\|Play\|Endless 320×96; `%SeasonsRowButton` close field; chip display-only; picker T3 ikona iznad imena; ★3 smije; Clear+Close stacked footer; meadow `plant_tier = 3`; safe rect + BasketCard; Home Daily bez arena line/claim; v1.1+; nema SAVE_VERSION.

Ostaje HOME-12–14: jedan `SeasonField` + `apply_season`; Play 3-koraka; Pip FSM; Endless Hard = field id; P174 Back/Escape; P164 Basket nije na karuselu; 12–14 cvjetova.

Ne dirati: Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum, CAMP-01/02, hub pager, SeedCatalog JSON, run `pip_visual` / `player.gd` / ArenaPip, Endless Hard brojke, `arena_daily_*` save polja.

---

## P0 arhiva — urađeno 2026-09-02 (ne paste)

### DOCK-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-15 docs freeze — meadow dock: T3 picker + ★3; Basket ispod Daily; Seasons u PlayRow; Daily bez arena streaka.

Dokumentiraj P197–P214 i override P165 P166 P173 P184 P185. Nema game/ u P0. CHECKPOINT sljedeci_korak ostaje D0-P. Grana master.

Fajlovi: ideje-home-meadow-dock.md hub; basket/layout/daily/pitanja/grupe; plan-prompts-home-meadow-dock.md P0 A–D. Wire _index, ideje-kad-predloziti, life/chrome sljedeće HOME-15, CHECKPOINT zadnja_sesija, changelog.
```

---

## 1 — DOCK-A (Picker T3 / ★3 / footer) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-15 DOCK-A — basket picker: T3 slika iznad imena cvijeta; ★3 se može izabrati; Clear basket i Close jedno iznad drugog na dnu.

Ovisi o DOCK-P0. Freeze P201 P202 P203 P208 P209. Override P166. Ne micati BasketCard (C). Ne meadow plant_tier (B). Ne Daily (D). Ne PlayRow.

Danas: main_menu.gd _rebuild_picker_list — Clear prvi red PickerList; redovi UiClickButton "ime ★"; get_unlocked_loadout_types_for_season i set_loadout skip is_mythic_seed. PickerCloseButton ispod scrolla.

DOCK-A:
1) Svaki cvijet-red: VBox — gore Control CampPlantDraw.draw_fitted_plant(type_id, 3); dolje ime + ★. Ne ArenaSeedChip. Ne JSON rewrite.
2) Lista = SeedCatalog.types_for_season(home_season_field_id) ∩ unlocked, UKLJUČUJUĆI rarity 3. set_loadout prihvaća mythic za Home basket. Greenhouse/arena plant rules ne dirati.
3) PickerList samo cvijeće. Footer VBox ispod scrolla: Clear basket pa Close (PickerCloseButton), Close ispod Clear. Clear clicked i dalje clear_loadout.

Smokes: home_basket_picker_smoke — Bloom open picker: rarity-3 u listi ako unlockan (npr. pumpkin); cvijet-red ima child Control za T3 draw iznad labele; Clear nije dijete PickerList; Clear i Close siblingovi u footer VBox, Close.position.y > Clear. Frost lista i dalje Frost pool. Close overlay i dalje hide.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, Play routing, PlayRow, BasketCard parent, meadow FLOWER_COUNT/slots, MeadowPip, Endless Hard, name chip, SeedCatalog JSON.

Relevantno: ideje-home-meadow-dock-basket.md, P201–P203, main_menu.gd _rebuild_picker_list / set_loadout, game_state.gd get_unlocked_loadout_types_for_season / is_mythic_seed, home_basket_picker_smoke.gd, camp_plant_draw.gd.

Acceptance: u pickeru T3 slika iznad imena; ★3 se bira; Clear i Close na dnu stacked.
```

---

## 2 — DOCK-B (T3 match polje ↔ basket) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-15 DOCK-B — ista T3 slika u basketu i na cvijeću u polju.

Ovisi o DOCK-P0. A smije biti gotov. Freeze P204 P210. Override P185 samo vizual (T1/T2 mix → T3). Ne picker overlay (A). Ne PlayRow/Basket parent (C). Ne mijenjati flower count/slots/safe rect osim što draw koristi tier 3.

Danas: home_basket_visual.gd draw_fitted_plant(..., 3). season_field_flower.gd plant_tier 1 ili 2. CampPlantDraw T3 = crystal, T2 = bloom.

DOCK-B:
1) SeasonFieldFlower setup: plant_tier = 3 (ne clamp na 2). Isti CampPlantDraw.draw_fitted_plant path kao BasketVisual.
2) FLOWER_COUNT 13 / 12–14 clamp i FLOWER_SLOTS i meadow_safe_rect ostaju. IGNORE. Ne ArenaSeedChip.
3) BasketVisual ostaje T3. Ne novi sprite sheet.

Smokes: season_meadow_smoke — Bloom/Frost open: svaki meadow_flower plant_tier == 3; count 12–14; IGNORE; pool ⊆ season seed_type_ids. Basket set_loadout i dalje T3 visual (postojeći path). Close: flowers gone.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, Play routing, PlayRow, BasketCard parent, picker footer, MeadowPip FSM, SeedCatalog JSON.

Relevantno: ideje-home-meadow-dock-basket.md, P204, season_field_flower.gd, home_basket_visual.gd, camp_plant_draw.gd, season_meadow_smoke.gd.

Acceptance: basket i cvijeće na polju koriste isti T3 draw; count i safe rect netaknuti.
```

---

## 3 — DOCK-C (Basket pod Daily + Seasons u redu) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-15 DOCK-C — Basket gore lijevo ispod Daily (kao Daily); u PlayRow Seasons | Play | Endless; ime sezone ne zatvara polje.

Ovisi o DOCK-P0. A/B smiju biti gotovi. Freeze P197–P200 P205 P211–P213. Override P165 P184 P173. Ne picker lista (A). Ne plant_tier (B). Ne Daily streak (D).

Danas: BasketCard dijete PlayRow 320×96. DailyChestCard 336×104 u HomeTopStack. SeasonNameChip clicked → close_season_field. SeasonsButton na SeasonField hidden. HomeColumn offset_top 268. meadow_safe_rect bez BasketCard kao zasebnog chromea.

DOCK-C:
1) Premjesti %BasketCard u HomeTopStack ispod DailyChestCard. custom_minimum_size Vector2(336, 104). Visible samo field open. Karusel hidden. Ne duplicirati node.
2) PlayRow: dodaj %SeasonsRowButton (UiClickButton, label Seasons, 320×96, size_flags kao Play). Redoslijed Seasons, Play, Endless. Tap → close_season_field. Karusel: Seasons hidden. Stari %SeasonsButton UniqueName hidden ostaje.
3) SeasonNameChip: ne close — mouse_filter IGNORE ili disconnect clicked. Back/Escape ostaje (P174).
4) HomeColumn offset_top podići da Daily+Basket+separation ne preklope polje.
5) meadow_safe_rect: u _chrome_controls dodaj %BasketCard (uz Daily, Settings, chip, PlayRow). Pip FSM ne dirati.

Smokes: season_meadow_smoke + season_home_smoke — Bloom open: Basket global_rect.position.y >= Daily end.y; Basket size ~336×104; Basket.get_parent() nije PlayRow. SeasonsRowButton visible; emit clicked → home_season_field_open false. Chip emit clicked ne close. Karusel: Basket i Seasons hidden. _assert_play_row_equal na Seasons/Play/Endless (ne BasketCard). SeasonField %SeasonsButton hidden. Flowers i dalje ne sijeku Daily/Basket/chip/PlayRow.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, Play routing, picker T3/★3/footer, flower count, MeadowPip, Endless Hard, SeedCatalog JSON, Daily caption/streak.

Relevantno: ideje-home-meadow-dock-layout.md, P197–P200, main_menu.tscn HomeTopStack PlayRow, main_menu.gd _on_season_name_chip_pressed / basket visible, season_field.gd _chrome_controls, season_meadow_smoke.gd.

Acceptance: Basket kao Daily ispod njega; donji red Seasons|Play|Endless; chip ne vraća na karusel; Seasons vraća.
```

---

## 4 — DOCK-D (Daily bez arena streaka) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-15 DOCK-D — Daily gift na Homeu bez arena streak teksta i bez claim_arena_daily.

Ovisi o DOCK-P0. C smije biti gotov. Freeze P206 P214. Ne Basket parent (C). Ne picker (A). Ne SAVE_VERSION.

Danas: main_menu.gd Daily caption dodaje get_arena_daily_home_line(); _on_daily_chest_pressed može claim_arena_daily(). merge_arena_controller DailyLabel = get_arena_daily_hud_text().

DOCK-D:
1) Home Daily caption samo "Tap to open" ili "Back tomorrow". Ne zovi get_arena_daily_home_line.
2) Tap Daily: postojeći claim_daily_chest path. Ne claim_arena_daily.
3) Ne brisati arena_daily_* iz save/GameState. Arena HUD i arena_daily_smoke ostaju.

Smokes: Home/meadow ili postojeći daily assert — caption ne sadrži "Arena streak" ni "Arena daily". Nakon claim_daily_chest arena_daily_streak ne raste. arena_daily_smoke i dalje OK.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, PlayRow, Basket, picker, MeadowPip, merge_arena_controller daily HUD, SeedCatalog JSON.

Relevantno: ideje-home-meadow-dock-daily.md, P206, main_menu.gd _refresh daily caption / _on_daily_chest_pressed, game_state.gd get_arena_daily_home_line / claim_arena_daily / claim_daily_chest, arena_daily_smoke.gd.

Acceptance: Home Daily je samo gift; arena streak živi u areni.
```

---

## Redoslijed i ovisnosti

1. **DOCK-P0** docs — **✅ 2026-09-02**.  
2. **DOCK-A** picker T3 / ★3 / footer — **✅ 2026-09-02**.  
3. **DOCK-B** T3 match — **✅ 2026-09-02**.  
4. **DOCK-C** layout + Seasons — **✅ 2026-09-02**.  
5. **DOCK-D** Daily streak — **✅ 2026-09-02**.  
6. Ne spajati s HOME-14 LIFE ni HOME-13 CHROME kodom ni CAMP-02.

## Povezano

- [[../03-content/ideje-home-meadow-dock|HOME-15 hub]] · [[../03-content/ideje-home-meadow-life|HOME-14]] · [[../03-content/ideje-home-meadow-chrome|HOME-13]]  
- [[plan-prompts-home-meadow-life|HOME-14 life]] (zatvoren playlist)  
- [[plan-prompts-home-camp-field|HOME-16 field + CAMP-03]]  
- [[CHECKPOINT|CHECKPOINT]]
