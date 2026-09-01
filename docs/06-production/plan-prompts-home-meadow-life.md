---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, sezone, meadow, play, pip, cvijece, plan, prompt]
povezano:
  - ideje-home-meadow-life
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-life-grupe
  - ideje-home-meadow-chrome
  - plan-prompts-home-meadow-chrome
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode playlist HOME-14 — LIFE-P0 ✅ A ✅ B ✅ C ✅ D ✅."
---

# Plan promptovi — HOME-14 meadow life

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** fenced blok ispod → odobri → Agent.  
> **Ne** zalijepi dva bloka u isti chat. **Ne** spajati s [[plan-prompts-home-meadow-chrome|HOME-13 kod]] ni [[plan-prompts-camp-cliff|CAMP-02]] ni [[plan-prompts-seed-meadow|SEED kod]].  
> **Grana:** **`master`**. Fair F2P: polje/Pip = tema. **Ne 8 tscn polja.**  
> Freeze: [[../03-content/ideje-home-meadow-life-pitanja|P179–P196]] · override P138 P175 P157 P160.

**LIFE-P0** ✅ 2026-09-01 (docs). **LIFE-A ✅** **LIFE-B ✅** **LIFE-C ✅** **LIFE-D ✅** 2026-09-01. Playlist gotova.

## Paste redoslijed (kod)

| # | Prompt | Stavka | Što |
|---|---------|--------|-----|
| 0 | **LIFE-P0 ✅** | sve | Docs freeze (ne paste) |
| 1 | **LIFE-A ✅** | Play | 3-koraka; nikad run s karusela |
| 2 | **LIFE-B ✅** | Row | Jednaki PlayRow |
| 3 | **LIFE-C ✅** | Field | 12–14 cvjetova + chrome-safe rect |
| 4 | **LIFE-D ✅** | Pip | Hod / njuh / spavanje |

B neovisno o A. **D čeka C.** Ne spajati A+D ni C+D.

## Freeze

**P179–P196:** karusel Play nikad run; non-playable → snap na `active_season_id`; playable hero → open field; polje Play → campaign run; PlayRow tri jednaka; 12–14 cvjetova u safe rectu (Daily, Settings, chip, PlayRow); MeadowPip on u polju (hod/njuh/spavanje, anti-repeat); PipPortrait ostaje off; v1.1+; nema SAVE_VERSION.

Ostaje HOME-12/13: jedan `SeasonField` + `apply_season`; session flagovi; Basket/Endless samo u polju; full-bleed; name chip + Back; Endless Hard = field id; `can_open` playable za open.

Ne dirati: Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum, CAMP-01/02, hub pager, SeedCatalog JSON, run `pip_visual` / `player.gd` / ArenaPip, Basket picker/T3, Endless Hard brojke.

---

## P0 arhiva — urađeno 2026-09-01 (ne paste)

### LIFE-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-14 docs freeze — meadow life: Play 3-koraka, jednaki PlayRow, više cvijeća u chrome-safe zoni, MeadowPip hod/njuh/spavanje.

Dokumentiraj P179–P196 i override P138/P175/P157/P160. Nema game/ u P0. CHECKPOINT sljedeci_korak ostaje D0-P. Grana master.

Fajlovi: ideje-home-meadow-life.md hub; play/layout/pip/pitanja/grupe; plan-prompts-home-meadow-life.md P0 A–D. Wire _index, ideje-kad-predloziti, ideje-home-meadow i chrome sljedeće HOME-14, CHECKPOINT zadnja_sesija, changelog.
```

---

## 1 — LIFE-A (Play 3-koraka) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-14 LIFE-A — Play na karuselu nikad ne pali run; pregled locked/unowned vraća selektiranu sezonu; playable otvara polje; polje Play = run.

Ovisi o LIFE-P0. Freeze P179–P183 P193. Ne PlayRow (B). Ne cvijeće (C). Ne Pip (D). Ne SAVE_VERSION.

Danas: main_menu.gd _on_play_pressed: field open → run; can_open_home_season_field (playable hero) → open_season_field; else begin_campaign_run. Unowned paid i locked free padaju na run.

LIFE-A:
1) _on_play_pressed: ako home_season_field_open → begin_campaign_run + SceneRouter run (kao danas).
2) Else ako is_season_playable(home_hero_center_id()) → open_season_field (P181; drugi playable u centru otvara TO polje).
3) Else → season_stage.snap_carousel_to_active() (ili ekvivalent): home_band + strip focus na active_season_id, refresh. Ne run. Ne open field. Fallback DEFAULT_SEASON_ID ako active prazan.
4) can_open_home_season_field ostaje za open; ne koristiti run kao else s karusela.

Smokes: season_home_smoke + season_meadow_smoke — locked free ili unowned paid u hero + Play: home_season_field_open == false, hero == active_season_id, nije SCENE_RUN. Bloom playable center Play → field, field_id country_bloom. Field open Play path ostaje run (spy/flag, ne obavezno puna run scena). Ostali HOME-13 asserte (Basket/Endless/chip) ostaju.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, Unlock JSON, flower slots, MeadowPip, PlayRow min size, Endless Hard, name chip, SAVE_VERSION.

Relevantno: docs/03-content/ideje-home-meadow-life.md, ideje-home-meadow-life-play.md, P179–P183, main_menu.gd _on_play_pressed, game_state.gd can_open_home_season_field / active_season_id / home_hero_center_id, season_stage.gd open_season_field / refresh / swap_home_band, season_home_smoke.gd, season_meadow_smoke.gd.

Acceptance: pregled paid/locked + Play = karusel na selektiranoj sezoni; na toj sezoni Play = polje; u polju Play = run; nikad run dok biraš sezonu.
```

---

## 2 — LIFE-B (Jednaki PlayRow) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-14 LIFE-B — Basket, Play i Endless u polju iste proporcije.

Ovisi o LIFE-P0. A smije biti gotov. Freeze P184 P194. Ne Play routing (A). Ne cvijeće (C). Ne Pip (D). Ne Basket picker/T3.

Danas: main_menu.tscn PlayRow — Basket 336×104, Play 360×96, Endless 260×96.

LIFE-B:
1) Tri djece %PlayRow: ista custom_minimum_size i jednaki size_flags_horizontal (npr. svi 320×96, expand fill). Alignment center, separation kao danas.
2) Karusel: Basket i Endless hidden (CHROME-C/D). Play ista visina, centriran. Ne duplicirati gumbe. PlayThemeBadge ostaje hidden sibling.
3) Ne dirati _rebuild_picker_list, home_basket_visual T3, Endless press/Hard.

Smokes: season_meadow_smoke — Bloom/Frost open: tri PlayRow djece ista custom_minimum_size. season_home_smoke ili meadow: karusel Play visina ista kao field Play min height. Basket/Endless karusel i dalje hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, flower slots, MeadowPip, _on_play_pressed logika, begin_endless_run, SeedCatalog JSON.

Relevantno: ideje-home-meadow-life-layout.md, P184, main_menu.tscn PlayRow/BasketCard/PlayButton/EndlessPlayButton, season_meadow_smoke.gd, season_home_smoke.gd.

Acceptance: u polju tri gumba izgledaju kao isti red; na karuselu samo Play, ista visina.
```

---

## 3 — LIFE-C (Cvijeće + chrome-safe) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-14 LIFE-C — više cvijeća na proširenom polju; sjeme ne ide pod Daily, Settings, name chip, PlayRow.

Ovisi o LIFE-P0. Freeze P185 P186 P195. Ne Pip FSM (D) — ali helper safe rect mora biti dovoljan da D ga zove. Ne Play routing. Ne PlayRow size osim što PlayRow ulazi u exclusion.

Danas: season_field.gd FLOWER_COUNT 8; FLOWER_SLOTS uključuje (0.50, 0.82). CHROME-B full-bleed; cvijeće i dalje u SeasonField.

LIFE-C:
1) 12–14 cvjetova iz seed_type_ids field id-a; T1/T2 mix; IGNORE; apply_season rebuild. Ne ArenaSeedChip. Ne JSON rewrite.
2) Helper meadow_safe_rect (MainMenu ili SeasonField): global rect DailyChestCard, Settings, SeasonNameChip, PlayRow → field local, inset 8–16px. Slotovi samo unutar ostatka. Clip SeasonField. Flower z_index ispod chromea.
3) clear_flowers i dalje skip SeasonsButton i MeadowPip.

Smokes: season_meadow_smoke — Bloom open: 12–14 IGNORE, tipovi ⊆ Bloom seed_type_ids; nijedan cvijet get_global_rect ne siječe Daily/Settings/SeasonNameChip/PlayRow (uz margin). Frost open: count u rasponu, pool Frost, nije Bloom clover skup. Close: flowers gone. Ostali A–E chrome asserte ostaju ako nisu u konfliktu s countom (stari 6–10 raspon ažurirati).

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, MeadowPip visible/FSM (još CHROME-A hide dok D), Play routing, PlayRow min size, SeedCatalog JSON, run Pip.

Relevantno: ideje-home-meadow-life-layout.md, P185–P186, season_field.gd FLOWER_COUNT / FLOWER_SLOTS / _rebuild_flowers, main_menu.tscn DailyChestCard SettingsButton SeasonNameChip PlayRow, season_meadow_smoke.gd.

Acceptance: polje ima više cvijeća; nijedno ispod Daily/Play/Basket/chip; Frost i dalje Frost pool.
```

---

## 4 — LIFE-D (MeadowPip hod / njuh / spavanje) ✅ 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-14 LIFE-D — Pip u polju sporo šeta, njuši cvijeće i spava; bez vidljive repeticije; ne ide pod chrome.

Ovisi o LIFE-C (safe rect + cvijeće). Freeze P187–P189 P196. Override P160. Ne Play routing. Ne PlayRow. Ne mijenjati flower count.

Danas: season_field.gd _hide_pip_and_stop na ready/open/rebuild; MeadowPip UniqueName hidden (CHROME-A). season_field_pip.gd PipDraw IGNORE. Stari MEADOW-C tween po flower indexu.

LIFE-D:
1) Field open: MeadowPip visible. Close/karusel: hide + stop FSM. UniqueName ostaje. Jedan node; Frost isti instance_id. Ne pip_visual.gd. PipPortrait ostaje hidden.
2) FSM: Walk (sporo, ease, random točka u meadow_safe_rect ili prema cvijetu), Sniff (kratko, ne isti cvijet zaredom), Sleep (duži idle, jitter). Weighted random sljedeće stanje bez odmah istog. Ne flower-index petlja.
3) Rebuild cvijeća ažurira targete (ne freed nodeovi). z_index ispod chromea. IGNORE.

Smokes: season_meadow_smoke — Bloom/Frost open: MeadowPip visible, IGNORE, count 1, isti instance_id; is_pip_alive ili FSM/wander running. Close: hidden, stop. Karusel: hidden. Zamijeni CHROME-A assertove „should be hidden / should not wander“ za open field. Ne assertirati sniff frame. season_home_smoke: PipPortrait i dalje hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, Play routing, PlayRow size, flower count/slots (C), Basket, Endless Hard, name chip, player.gd, ArenaPip, active_companion_id.

Relevantno: ideje-home-meadow-life-pip.md, P187–P189, ideje-home-meadow-pip.md (wander povijest), season_field.gd, season_field_pip.gd, pip_draw.gd, season_meadow_smoke.gd, season_home_smoke.gd.

Acceptance: u polju Pip živi (hod/njuh/spavanje) i ne ide pod gumbe; na karuselu nema Pipa; run Pip netaknut.
```

---

## Redoslijed i ovisnosti

1. **LIFE-P0** docs — **✅ 2026-09-01**.  
2. **LIFE-A** Play 3-koraka — **✅ 2026-09-01**.  
3. **LIFE-B** jednaki PlayRow — **✅ 2026-09-01**.  
4. **LIFE-C** cvijeće + safe rect — **✅ 2026-09-01**.  
5. **LIFE-D** MeadowPip FSM — **✅ 2026-09-01**. Playlist A–D gotova.  
6. Ne spajati s HOME-13 CHROME kodom ni CAMP-02.

## Povezano

- [[../03-content/ideje-home-meadow-life|HOME-14 hub]] · [[../03-content/ideje-home-meadow-chrome|HOME-13]] · [[../03-content/ideje-home-meadow|HOME-12]]  
- [[plan-prompts-home-meadow-chrome|HOME-13 chrome]] (zatvoren playlist)  
- [[CHECKPOINT|CHECKPOINT]]
