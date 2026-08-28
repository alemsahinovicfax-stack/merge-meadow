---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, roster, unlock, plan, prompt]
povezano:
  - ideje-home-lockflow
  - ideje-home-lockflow-gate
  - ideje-home-lockflow-roster
  - ideje-home-lockflow-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-10 — LOCKFLOW-P0 docs → A locked poster+500/20+gold → B roster desno+no ellipsis+wash."
---

# Plan promptovi — HOME-10 lockflow (locked poster, roster, wash)

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **LOCKFLOW-P0 → A → B**  
> **Chrome korekcija:** [[plan-prompts-home-barfit|HOME-11 BARFIT]] (gate niže, bez okvira, debug 500c).  
> **Ideje:** [[../03-content/ideje-home-lockflow|hub]] · [[../03-content/ideje-home-lockflow-gate|gate]] · [[../03-content/ideje-home-lockflow-roster|roster]] · [[../03-content/ideje-home-lockflow-pitanja|pitanja]]

**LOCKFLOW-P0** urađen 2026-08-26 (docs). **LOCKFLOW-A** urađen 2026-08-26. **LOCKFLOW-B** urađen 2026-08-26.

## Freeze

P115–P128 (gate donja polovica centrirano ispod imena; roster skriven na locked; 500 coins / 20 T3 u JSON za Frost/Lantern/Amber; Unlock sivi→gold; Lantern+Amber locked bez TEST_LOCK; sequential isti chrome na next; roster `anchor_right` ~0.78–0.88 bez lijevog clipa i bez ellipsisa; niska alpha wash + `apply_season` na morph midpoint; paid roster isti chrome bez coin Unlock; Ember paid TEST_LOCK; debug skip + debug-strip fixture; v1.1+).

P81–P114 ostaju osim overridea: P109 (širina/ellipsis), P110 (gate kut), P108 (samo alpha/darken), P90 frame opaque, HOME-08 roster+gate zajedno, JSON 80/5 · 150/8 · 220/12. P104/P105 (Amber nije TEST_LOCK, Ember jest) **ostaju**. P107 naslov sredina **ostaje**.

Ne dirati: band 20/80, L/R in-place mehanika, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager, `seed_type_ids`, 48 stubova.

---

## Prompt — LOCKFLOW-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-10 docs freeze.

Dokumentiraj P115–P128: locked free sezona = ime na sredini kartice (P107 ostaje) + ispod dva bara (Coins 500, Seeds 20 bilo kojeg T3) + Unlock sivi dok barovi nisu puni, zlatni i klikabilan kad jesu; tap unlock_free sklanja barove/gumb i pokazuje roster te sezone; isti chrome prelazi na sljedeću locked free (Lantern pa Amber). Lantern Meadow i Amber Canopy zaključane u saveu/debug skip, ALI nisu TEST_LOCK (bounce gasi gate — HOME-09). Roster na locked skriven. Roster na unlocked širi desno (anchor_right ~0.78–0.88) jer CARDFIT-B min 320 + anchor 0.48 reže lijevo i ostavlja ellipsis. Boja panela: niska alpha wash umjesto opaque darkened 0.88 jer swipe kasni (apply_season tek na kraju morpha). Ember ostaje paid TEST_LOCK. Ne brisati produkcijski player_save slijepo; debug/smoke smije stripati lantern+amber iz unlocked_seasons.

Nema game/ u P0.

Relevantno: ideje-home-lockflow*.md, ideje-home-cardfit*.md, season_stage.tscn FreeRoster/UnlockGate anchors, season_roster_panel.gd ellipsis, season_card_contrast.gd FRAME_ALPHA, season_unlock_gate.gd, game_state.gd TEST_LOCK/debug skip, seasons.json coins_cost, plan-prompts-home-lockflow.md.
```

---

## Prompt — LOCKFLOW-A (Locked poster + 500/20 + gold)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-10 LOCKFLOW-A — locked-free poster (ime + barovi + zlatni Unlock), 500/20, Lantern+Amber locked bez TEST_LOCK.

Dijagnoza (ne reimplementirati widget): season_unlock_gate.gd već živi u CenterSlot/CenterFill. Danas je donji DESNI kut (P110), Unlock subtle→primary, trošak iz JSON 80/5 · 150/8 · 220/12, roster VIDLJIV i na locked. Playtest: prva zaključana free = ime na SREDINI (P107 ostaje, ne gurati gore) + ISPOD imena Coins i Seeds barovi + Unlock sivi dok nisu puni, ZLATNI i klikabilan kad jesu. Tap → unlock_free → barovi i gumb nestaju → roster te sezone. Isti chrome na sljedećoj locked free.

LOCKFLOW-A:
seasons.json: frost_orchard, lantern_meadow, amber_canopy → coins_cost 500, t3_flowers_required 20. Country Bloom ostaje 0. Paid ne dirati. Gate UI čita def.coins_cost / def.t3_flowers_required — ne magični 500/20 u skripti.

NE vraćati lantern_meadow ni amber_canopy na is_test_locked_season. Ember Fen ostaje TEST_LOCK paid. can_unlock_free / unlock_free sequential ostaju (prethodna free mora biti unlocked).

Gate layout: maknuti anchors_preset 3 (donji desni). Donja polovica CenterFill, horizontalno centrirano (npr. anchor_left ~0.12, anchor_right ~0.88, anchor_top ~0.48, anchor_bottom 1 + mali offset dna). Širi panel da stanu barovi. z_index ostaje 1. clip_contents na slotu ostaje. Ime CenterTitle full-rect CENTER — ne dirati naslov sidro.

Roster: free_roster.visible = false dok je gate vidljiv / hero je next-lock i nije playable. Nakon unlock_free + refresh: roster apply_season + visible true. Paid roster ne dirati u A osim da i dalje nema coin gate.

Unlock gumb: disabled + subtle + MOUSE_FILTER_IGNORE dok !can_unlock_free; novi button_variant "gold" (UiPalette + UiClickButton enum) + STOP kad može. Tamni ink na zlatnom fillu (kontrast na Amber jantaru). refresh_gate MORA vratiti STOP nakon _ignore_hits/refresh/morph kad can.

debug_unlock_all_seasons i dalje skipa lantern_meadow I amber_canopy po id-u I ember_fen. Ne grantati ih. A smije debug/smoke helper koji skine lantern+amber iz unlocked_seasons (fixture: Bloom+Frost playable, Lantern next-lock). NE brisati user://player_save.json slijepo. NE SAVE_VERSION bump.

Smokes (season_home_smoke / season_unlock_smoke): fixture Bloom+Frost playable, lantern+amber nisu u unlocked; Lantern selectable, swipe ne bounce; gate child CenterSlot, DONJA polovica ne desni kut; roster HIDDEN na locked Lantern; Coins n/500 Seeds n/20; 499c ili <20 T3 → Unlock sivi; 500c+20 T3 → gold + grant; nakon grant-a FreeRoster vidljiv na Lanternu, gate na Amber kad je Amber centar; Ember i dalje TEST_LOCK; Coral bez coin gatea. Stari asserti 150/8 i 220/12 OBRNUTI.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati u A: roster anchor_right / ellipsis / FRAME_ALPHA (to je B), band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, seed_type_ids, 48 stubova, naslov full-rect CENTER.

Relevantno: docs/03-content/ideje-home-lockflow-gate.md, ideje-home-lockflow-pitanja.md P115–P120 P124 P127, seasons.json, game_state.gd, season_unlock_gate.gd, season_stage.tscn UnlockGate, season_stage.gd _refresh_roster/_refresh_unlock_gate, ui_palette.gd, ui_click_button.gd, season_home_smoke.gd, season_unlock_smoke.gd.

Acceptance: save Bloom+Frost playable, Lantern+Amber locked → swipe na Lantern ne bounce; Lantern Meadow ime na sredini; NEMA liste cvijeća; ispod Coins n/500 + Seeds n/20 + Unlock sivi; s 500c/20 T3 gumb ZLATNI i klikabilan; tap grant-a Lantern; roster Lanterna se pojavi; swipe Amber = isti poster 500/20; Ember locked; Coral bez coin Unlock.
```

---

## Prompt — LOCKFLOW-B (Roster desno + no ellipsis + wash)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-10 LOCKFLOW-B — roster širi desno, puna imena, blaga transparentna pozadina, apply_season na morph midpoint.

LOCKFLOW-B (samo roster chrome; A je lock flow + 500/20 + gold + hide roster — ne dirati):

Dijagnoza: FreeRoster/PaidRoster custom_minimum_size.x=320 + anchor_right=0.48 → dodijeljena širina ~0.48*Fill-16 (~160–190px). Min pobjeđuje sidro, grow_horizontal=2, clip_contents reže negativan x. Ikone nestaju lijevo; name_l OVERRUN_TRIM_ELLIPSIS. CARDFIT-B je ovo pogoršao. Na unlocked kartici gate je skriven (A) pa roster SMIJE rasti desno.

1) Širina: FreeRoster i PaidRoster anchor_right ~0.78–0.88 (prefer ~0.85), offset_left 8, offset_right -8, sidro donji lijevi ostaje. custom_minimum_size.x uskladiti da NE raste lijevo (min ≤ stvarno sidro, ili ~380–420 samo ako Fill to drži). grow_horizontal NE both. clip_contents na slotu ostaje. Ikona 52 / font 22 / zvijezde 18 / red 56 ostaju.

2) Imena: skinuti TRIM_ELLIPSIS. Puna imena. Ako treba, autowrap 2 reda — ne "...". Smoke: Harvest Pumpkin, Paper Lantern Bloom, Golden Oak Bloom točan string u labelu (nema ellipsis character).

3) Wash: SeasonCardContrast FRAME_ALPHA ~0.20–0.35 (preporuka 0.28), ne 0.88; smanjiti ili maknuti darkened(0.55) da kroz panel sja mood kartice. Ista paleta mood_color. Tekst i dalje čitljiv (P108 luminance). Gate na locked smije isti wash. PaidRoster isti algoritam.

4) Timing: zvati _refresh_roster (apply_season) u _apply_free_cycle / _apply_paid_cycle MIDPOINT, ne čekati _finish_*_morph. refresh() na kraju ostaje.

Smokes: FreeRoster.position.x >= 0 na hero Bloom; size.x znatno > 260 i prati ~0.7+ Fill; Bloom vs Moonlit bg_color RGB i dalje različit; imena bez "..."; CenterTitle i dalje VERTICAL_ALIGNMENT_CENTER i full-rect (regresija A/CARDFIT-B). Harvest Pumpkin / Golden Oak Bloom / Reef Crown vidljivi. Locked Lantern (A fixture) roster i dalje HIDDEN.

Headless OpenGL. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne watcher.

Ne dirati u B: 500/20 JSON, TEST_LOCK Ember, gold variant, gate sidro/layout iz A, debug skip, band 20/80, L/R in-place mehanika, seed_type_ids, Shop Select, AdMob, SAVE_VERSION, 48 stubova.

Relevantno: docs/03-content/ideje-home-lockflow-roster.md, ideje-home-lockflow-pitanja.md P121–P123, season_stage.tscn FreeRoster/PaidRoster, season_roster_panel.gd, season_card_contrast.gd, season_stage.gd _apply_free_cycle/_apply_paid_cycle/_refresh_roster, season_home_smoke.gd.

Acceptance: selektovana otključana sezona — lista cvijeća u kartici, ikone vidljive, nije odsječena lijevo, ide desno; puna imena bez tri točkice; swipe Bloom→Frost wash se mijenja S karticom (nema pola sekunde starog tamnog okvira); locked Lantern i dalje bez rostera (A).
```

---

## Redoslijed i ovisnosti

- **P0** prije A/B (docs). Urađeno 2026-08-26.
- **A** urađen 2026-08-26. **B** urađen 2026-08-26 — širina desno, no ellipsis, wash, midpoint.
- Ne spajati A i B u jedan prompt.

## Povezano

- [[plan-prompts-home-cardfit|HOME-09]] · [[plan-prompts-home-incard|HOME-08]] · [[plan-prompts-home-unlock|HOME-07]]
