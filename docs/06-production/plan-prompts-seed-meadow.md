---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, sezone, sjeme, home, meadow, plan, prompt]
povezano:
  - ideje-seed-pool
  - ideje-seed-pool-pitanja
  - ideje-home-meadow
  - ideje-home-meadow-pitanja
  - plan-prompts-camp-cliff
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode playlist SEED-01 + HOME-12 — jedan prompt po chatu: A B C sjeme pa A B C polje."
---

# Plan promptovi — SEED-01 + HOME-12 (jedan fajl)

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** fenced blok ispod → odobri → Agent.  
> **Ne** zalijepi dva bloka u isti chat. **Ne** spajati SEED i MEADOW u isti kod-chat.  
> **Grana:** **`master`**. Fair F2P: paid = tema. **Ne 8 tscn polja.** CAMP-02 = [[plan-prompts-camp-cliff|odvojen fajl]].  
> Freeze: [[../03-content/ideje-seed-pool-pitanja|S1–S16]] · [[../03-content/ideje-home-meadow-pitanja|P137–P158]]

**P0** ✅ 2026-09-01 (docs). **SEED-A ✅** **SEED-B ✅** **SEED-C ✅** **MEADOW-A ✅** **MEADOW-B ✅** **MEADOW-C ✅** 2026-09-01. Kod **1–6 ✅**.

## Paste redoslijed (kod)

| # | Prompt | Što |
|---|---------|-----|
| 1 | **SEED-A ✅** | SeedCatalog + JSON `seed_type_ids` = merge tipovi |
| 2 | **SEED-B ✅** | Journal svi tipovi; camp Trade/Exchange imena |
| 3 | **SEED-C ✅** | T1–T3 fallback draw; arena pour katalog |
| 4 | **MEADOW-A ✅** | Jedan SeasonField, sve playable; Seasons; Play dual |
| 5 | **MEADOW-B ✅** | Cvijeće iz `seed_type_ids` otvorenog fielda (nakon 1 i 4) |
| 6 | **MEADOW-C ✅** | Pip wander (nakon 5) |

## Freeze

**SEED S1–S16:** jedan type_id; Bloom CHAIN 7 ostaje; ostale sezone `seed_type_ids` = roster id; SeedCatalog; journal svi tipovi; fallback T1–T3; pour katalog; nema SAVE_VERSION.

**HOME P137–P158:** jedan `SeasonField` + `apply_season(season_id)`; `can_open` = playable; Play dual; Endless uvijek run; Seasons natrag; playable centar ≠ Browser; locked/unowned nema polja; paid owned da; session flag + field_id, nema SAVE_VERSION; cvijeće iz `seed_type_ids` tog id-a (B nakon SEED-A).

Ne dirati: Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum pravila, CAMP-01 spend, hub pager.

---

## P0 arhiva — urađeno 2026-09-01 (ne paste)

### SEED-P0 (Docs)

```
MODE: Plan only — ne implementiraj.
Projekt: Merge Meadow SEED-01 docs freeze — jedan seed namespace po sezoni.
(P0 u vaultu 2026-09-01.)
```

### MEADOW-P0 (Docs)

```
MODE: Plan only — ne implementiraj.
Projekt: Merge Meadow HOME-12 docs freeze.
(P0 već u vaultu; amend 2026-09-01: sva playable, jedan shell.)
```

---

## 1 — SEED-A (Katalog + JSON) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow SEED-01 SEED-A — SeedCatalog + seasons.json seed_type_ids jesu merge tipovi.

Freeze S1–S6 S12 S14. Ne journal UI (B). Ne pour/draw fallback (C) osim display/rarity API. Ne SeasonField. Ne SAVE_VERSION.

Danas: frost roster frost_snowdrop ali seed_type_ids clover,daisy,buttercup. get_active_season_spawn_types laže. CHAIN 7 Bloom. SEED_DISPLAY_NAMES hardkod 7.

SEED-A:
1) seasons.json: Bloom seed_type_ids clover…watermelon ostaje; Bloom roster[].id USKLADI na te id-eve (display_name smije ostati Meadow Clover). Ostale sezone: seed_type_ids = roster[].id isti red (makni clover copy-paste).

2) Novi SeedCatalog: all_type_ids stabilni red; season_id_for; display_name; rarity; types_for_season. Unique ids.

3) game_state SEED_DISPLAY_NAMES i get_seed_rarity čitaju katalog. is_seed_type_unlocked: CHAIN pravila za Bloom 7; tip van CHAIN unlocked ako je njegova sezona playable. Ne širiti seed_unlock_index. get_active_season_spawn_types ostaje def.seed_type_ids.

Smokes: season_run_smoke — Frost pool sadrži frost_snowdrop (ili prvi Frost roster id), NIJE identičan Bloom clover-daisy-buttercup. Bloom i dalje clover. Headless opengl3. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati: Shop IAP, AdMob, Unlock 500/20, leftover/vacuum, CAMP-01 spend, meadow UI, collection_journal layout (B), plant_draw match (C), SAVE_VERSION.

Relevantno: ideje-seed-pool-catalog.md, S1–S16, seasons.json, season_def.gd, game_state.gd spawn, season_run_smoke.gd.

Acceptance: jedan type_id; Frost run karakterističan; Bloom CHAIN 7; roster=spawn; nema save bump.
```

---

## 2 — SEED-B (Journal + camp imena) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow SEED-01 SEED-B — Bloom album svi SeedCatalog tipovi; camp Trade/Exchange imena.

Ovisi o SEED-A. Freeze S7 S10. Ne pour (C). Ne meadow.

get_collection_journal_entries loop all_type_ids ne samo CHAIN. Stanja locked/seen/album ista. Journal scene mora scrollati sve retke. Ne markirati sve discovered.

Camp chip/exchange labele iz catalog display_name. Exchange rate i dalje rarity lookup (radi za nove id). Ne mijenjati take-count formule.

Smoke: entries.size() == SeedCatalog.all_type_ids().size(); sadrži frost_snowdrop (ili ekvivalent) kao locked ako nije discovered. camp_layout_smoke ostaje zelen.

Headless opengl3. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati: JSON costs, leftover, plant_draw, Play dual, Shop IAP, SAVE_VERSION.

Relevantno: ideje-seed-pool-journal.md, collection_journal, game_state journal helpers, camp_controller exchange labels.

Acceptance: album nudi sva sezonska sjemena; camp čitljiva imena; exchange ne puca.
```

---

## 3 — SEED-C (T1–T3 draw + pour katalog) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow SEED-01 SEED-C — draw_plant T1–T3 za svaki type_id (fallback); arena pour red SeedCatalog.

Ovisi o SEED-A. Freeze S8 S9 S11. Ne leftover/vacuum rewrite. Ne meadow.

seed_visual_config.palette: Bloom 7 ostaje; else deterministički fallback ≠ clover palete za frost id. camp_plant_draw default branch rarity shape + fallback; NE clover geometrija za frost_snowdrop. ArenaSeedChip i dalje isti draw.

Pour queue: red all_type_ids ∩ bag T1, ne samo CHAIN. FLOW-A leftover i VACUUM pragovi NE dirati.

Smoke: palette frost ≠ clover; pour bag {frost_snowdrop:4, clover:4} uključuje oba. Postojeći Bloom sort smoke ostaje ili proširi. Headless opengl3. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati: journal layout (B), Shop, AdMob, CAMP-01, SAVE_VERSION, SeasonField.

Relevantno: ideje-seed-pool-draw.md, camp_plant_draw.gd, seed_visual_config.gd, merge_arena pour queue.

Acceptance: T1 T2 T3 izgledaju po tipu; pour ne gubi non-CHAIN sjeme; vacuum/leftover isti.
```

---

## 4 — MEADOW-A (Shell: jedan Field, sve playable) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-12 MEADOW-A — jedno SeasonField za svaku playable sezonu (prazan tint); tap ili Play ulaze; Play na polju = run; gumb Seasons natrag.

Freeze P137–P140, P143–P148, P153–P156, P158. Ne cvijeće (B). Ne Pip (C). Ne SeedCatalog JSON (SEED-A). Ne frost_field.tscn.

Danas: main_menu _on_play_pressed = run. season_stage hero center tap = open_browser. Dual-band uvijek.

MEADOW-A:
1) GameState: home_season_field_open: bool = false; home_season_field_id: String = ""; NIJE u save. can_open_home_season_field = is_season_playable(home_hero_center_id()). open postavi field_id, prefer set_active_season na taj id. close clear. Locked/unowned false. Paid owned playable true.

2) season_stage.tscn: JEDAN child SeasonField full-rect. FieldGround + %SeasonsButton "Seasons". BandColumn + roster + UnlockGate hide kad open. Nema druge Field scene po sezoni.

3) apply_season(season_id): ground tint SeasonTheme.bg_modulate(id); ako WHITE, lokalni pastel SAMO na FieldGround (ne dirati run tablicu). Open zove apply_season(field_id).

4) season_stage.gd: hero center (free ili paid-hero) playable → open field, NE open_browser. L/R karusel ostaje. Kad field open, gui_input ne ciklusira bandove (STOP na field). Seasons → close.

5) main_menu _on_play_pressed: field open → run; else can_open → open field NE run; else run. Endless NE dirati.

Smokes: novi season_meadow_smoke.gd — default off; open Bloom → flag true, field_id country_bloom, BandColumn hidden, Seasons exists, get_node SeasonField count == 1. Close → karusel. Playable Frost fixture: can_open true, open → field_id frost_orchard, apply_season (tint/id ≠ Bloom). Locked lantern (debug skip): can_open false. season_home_smoke: playable center nije Browser assert; UnlockGate locked ostaje.

Headless --rendering-driver opengl3. Ne GUI usred A. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati u A: Shop, AdMob, seasons.json seed_type_ids/costs, leftover/vacuum, merge_arena_controller, CAMP-01, CAMP-02, SAVE_VERSION, Pip, flower chips, 8 field scena.

Relevantno: docs/03-content/ideje-home-meadow-shell.md, P137–P158, season_stage.gd/.tscn, main_menu.gd, game_state.gd, season_theme.gd.

Acceptance: playable centar — tap/Play → polje, još Home; Play na polju → run; Seasons → karusel; druga playable sezona isti SeasonField drugi id/tint; locked nema polja; Endless endless; nema Pipa/cvijeća.
```

---

## 5 — MEADOW-B (Cvijeće iz poola otvorene sezone) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-12 MEADOW-B — 6–10 dekorativnih cvjetova iz seed_type_ids otvorenog field id-a.

Ovisi o MEADOW-A i SEED-A. Ne Pip (C). Freeze P145 P157 P158.

apply_season / open REBUILD flower children iz get_season_def(home_season_field_id).seed_type_ids. camp_plant_draw. NE ArenaSeedChip. IGNORE. Fiksni layout. Close → free/hide. Nije inventar.

Smoke: Bloom open → 6–10 IGNORE, tipovi ⊆ Bloom pool. Frost playable open → tipovi ⊆ Frost pool, skup ≠ Bloom nakon SEED-A. Jedan SeasonField.

Headless --rendering-driver opengl3. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Play routing, Seasons, Endless, Shop, AdMob, arena controller, CAMP-02, SAVE_VERSION, Pip, JSON costs.

Relevantno: ideje-home-meadow-field.md, camp_plant_draw.gd, seasons.json seed_type_ids.

Acceptance: cvijeće prati otvorenu sezonu; rebuild na apply_season; tap no-op; Seasons zatvara.
```

---

## 6 — MEADOW-C (Pip wander) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-12 MEADOW-C — jedan Pip na SeasonField, wander među cvijećem trenutne sezone.

Ovisi o MEADOW-B. Freeze P145 P149. Jedan Pip node, ne Pip po sezoni.

Reuse pip_visual / pip_draw. IGNORE. Tween između trenutnih flower točaka; rebuild cvijeća ažurira targete. Close → stop tween hide/free. Ne active_companion_id / run Pip.

Smoke: open → Pip visible IGNORE; close hidden; wander running ili position mijenja; Frost open isti Pip node.

Headless --rendering-driver opengl3. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: flower layout osim targeta, Play/Seasons/Endless, Shop, AdMob, run companion, merge_arena_controller.

Relevantno: ideje-home-meadow-pip.md, pip_visual.gd, ArenaPip IGNORE.

Acceptance: Pip šeta na otvorenom polju; nije klik; Play=run; Seasons=karusel; run companion netaknut.
```

---

## Povezano

- [[../03-content/ideje-seed-pool|SEED-01 hub]] · [[../03-content/ideje-home-meadow|HOME-12 hub]]
- [[plan-prompts-home-meadow-chrome|HOME-13 chrome]] · [[plan-prompts-camp-cliff|CAMP-02]] · [[CHECKPOINT|CHECKPOINT]]
