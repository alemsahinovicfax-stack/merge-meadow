---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, unlock, gate, plan, prompt]
povezano:
  - ideje-home-barfit
  - ideje-home-barfit-gate
  - ideje-home-barfit-pitanja
  - ideje-home-lockflow
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-11 — BARFIT-P0 docs → A spusti gate, skini okvir, debug 500c/20 T3."
---

# Plan promptovi — HOME-11 barfit (gate niže, bez okvira, debug 500c)

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **BARFIT-P0 → A**  
> **Ideje:** [[../03-content/ideje-home-barfit|hub]] · [[../03-content/ideje-home-barfit-gate|gate]] · [[../03-content/ideje-home-barfit-pitanja|pitanja]]

**BARFIT-P0** urađen 2026-08-26 (docs). **BARFIT-A** urađen 2026-08-26.

## Freeze

P129–P136 (gate `anchor_top` ~0.62 ispod 🔒+ime; UnlockGate bez wash okvira; CenterTitle CENTER + `🔒\nime` ostaje; debug `wallet_coins` floor 500 i T3 floor 20 uz `debug_unlock_all`; JSON 500/20 / gold / hide-roster / TEST_LOCK Ember / roster 0.85 wash midpoint **ne dirati**; v1.1+).

P115 ostaje „donja zona, centrirano“ — override samo **broj** 0.48. P107, P116–P128 ostaju.

Ne dirati: band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager, `seed_type_ids`, 48 stubova, produkcijski starting wallet.

---

## Prompt — BARFIT-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-11 docs freeze.

Dokumentiraj P129–P136: nakon HOME-10 locked poster, playtest vidi da UnlockGate (anchor_top 0.48, z_index 1, make_frame wash) prekriva katanac i ime (CenterTitle CENTER crta "🔒\n{ime}"). Spustiti bar sekciju ispod tog bloka. Skinuti suvišan okvir gate panela (ne roster frame). Debug build: floor 500 coins (+ 20 T3 da Unlock bude zlatan za test), ne produkcijski start, ne JSON cost. Ne gurati naslov gore.

Nema game/ u P0.

Relevantno: ideje-home-barfit*.md, ideje-home-lockflow-gate.md, season_stage.tscn UnlockGate/CenterTitle, season_unlock_gate.gd _apply_frame, main_menu.gd debug_unlock_all, game_state.gd wallet/t3, plan-prompts-home-barfit.md.
```

---

## Prompt — BARFIT-A (Gate niže + frameless + debug 500c)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-11 BARFIT-A — locked barovi ispod 🔒+ime, bez gate okvira, debug floor 500 coins + 20 T3.

Dijagnoza (ne reimplementirati widget): UnlockGate već živi u CenterSlot/CenterFill. LOCKFLOW-A: gold, 500/20 JSON, roster hidden, sequential, Lantern+Amber nisu TEST_LOCK. Playtest: panel od anchor_top=0.48 + z_index 1 prekriva CenterTitle ("🔒\nLantern Meadow" full-rect CENTER). make_frame na gateu je drugi wash-okvir — suvišan. Debug boot nema 500c pa se zlatni Unlock ne vidi.

BARFIT-A:
1) season_stage.tscn %UnlockGate: anchor_top ~0.62 (raspon 0.58–0.70, prefer 0.62). anchor_left 0.12 / right 0.88 / bottom 1 ostaju. offset_bottom -12 ostaje. offset_top ne gurati gore. grow_vertical NE both (min.y ne smije rasti u ime). min size.y smije pasti jer nestaje frame padding. z_index 1 ostaje. clip_contents na slotu ostaje.

2) season_unlock_gate.gd _apply_frame: NE CONTRAST.make_frame. StyleBoxEmpty ili Flat alpha 0, border 0, content margin ~8. Label ink i dalje CONTRAST.text_color. ProgressBar i Unlock gumb ostaju. Ne dirati SeasonCardContrast.FRAME_ALPHA (roster).

3) CenterTitle sidro i _fill_slot "🔒\n%s" NE dirati. Ne vaditi lock u novi node. Ne vertical_alignment TOP.

4) Debug funds: OS.is_debug_build() and not skip_debug_season_unlock, uz debug_unlock_all_seasons u main_menu. Helper na GameState: wallet_coins = max(wallet, 500); ako t3_flower_count() < 20 nadopuni clover stash do 20; save_player_save(); no-op u release; NIKAD smanjiti veći wallet; NE grantati lantern/amber/ember.

Smokes (season_home_smoke; skip_debug_season_unlock ostaje true — grant se NE pali u smokeu): UnlockGate.anchor_top >= 0.58; anchor_left i dalje < 0.5 (nije desni kut); panel bez vidljivog wash okvira (bg alpha ~0 ili empty); CenterTitle.text sadrži "🔒" i ime sezone na locked Frost/Lantern; FreeRoster i dalje HIDDEN na locked; 499c → subtle; 500c+20 T3 → gold + grant; nakon grant-a roster vidljiv. CenterTitle.vertical_alignment CENTER i anchor_bottom == 1 (regresija). Ember TEST_LOCK; Coral bez coin gatea.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati u A: seasons.json coins_cost/t3, gold hex, hide-roster logika, TEST_LOCK, debug skip id-evi, FreeRoster/PaidRoster anchors, FRAME_ALPHA, midpoint apply_season, band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, seed_type_ids, 48 stubova, produkcijski default wallet 0.

Relevantno: docs/03-content/ideje-home-barfit-gate.md, ideje-home-barfit-pitanja.md P129–P136, season_stage.tscn UnlockGate, season_unlock_gate.gd, game_state.gd, main_menu.gd, season_home_smoke.gd.

Acceptance: locked Lantern — vidi se katanac i puno ime; barovi ispod, nisu preko teksta; nema drugog okvira oko barova; debug play wallet ≥ 500 i T3 ≥ 20 pa je Unlock zlatni i klikabilan; tap i dalje unlock_free; Amber isti chrome kad je next-lock; non-debug start i dalje 0 coins; JSON 500/20.
```

---

## Redoslijed i ovisnosti

- **P0** prije A (docs). Urađeno 2026-08-26.
- **A** urađen 2026-08-26 — layout + frameless + debug funds.
- Ne spajati s roster/JSON/LOCKFLOW-B radom.

## Povezano

- [[plan-prompts-home-lockflow|HOME-10]] · [[plan-prompts-home-cardfit|HOME-09]] · [[plan-prompts-home-incard|HOME-08]]
