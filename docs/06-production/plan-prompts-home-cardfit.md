---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, roster, unlock, plan, prompt]
povezano:
  - ideje-home-cardfit
  - ideje-home-cardfit-gate
  - ideje-home-cardfit-naslov
  - ideje-home-cardfit-roster
  - ideje-home-cardfit-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-09 — CARDFIT-P0 docs → A Amber+gate → B naslov+kontrast+širina."
---

# Plan promptovi — HOME-09 cardfit (Amber gate, naslov, kontrast)

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **CARDFIT-P0 → A → B**  
> **Ideje:** [[../03-content/ideje-home-cardfit|hub]] · [[../03-content/ideje-home-cardfit-gate|gate]] · [[../03-content/ideje-home-cardfit-naslov|naslov]] · [[../03-content/ideje-home-cardfit-roster|roster]] · [[../03-content/ideje-home-cardfit-pitanja|pitanja]]

**CARDFIT-P0** urađen 2026-08-25 (docs). **CARDFIT-A** urađen 2026-08-25. **CARDFIT-B** još nije.

## Freeze

P103–P114 (gate na svakoj next-lock free, Amber off TEST_LOCK, Ember paid TEST_LOCK, sequential `can_unlock_free`, naslov sredina, roster/gate frame iz `_mood_color`, širi roster, gate z_index, debug skip Lantern+Amber, paid roster bez coin Unlock, v1.1+).

P81–P102 ostaju osim overridea: P84 (samo Ember ostaje TEST_LOCK), P90/P94 (frame po sezoni), P100 (naslov sredina, ne gore).

Ne dirati: band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager, `seed_type_ids`, 48 stubova.

---

## Prompt — CARDFIT-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-09 docs freeze.

Dokumentiraj P103–P114: Unlock gate na svakoj next-lock free sezoni (u ovom saveu Amber Canopy) jer INCARD-B postoji ali Amber je TEST_LOCK pa se gate nikad ne vidi; skinuti amber_canopy s is_test_locked_season; Ember ostaje paid TEST_LOCK; sequential can_unlock_free; naslov sezone opet vertikalno centriran (override P100); roster i gate pozadina po sezoni iz _mood_color (kontrast); širi roster ~320px / 0.42–0.50 kartice; debug_unlock_all skipa Lantern i Amber po id-u.

Nema game/ u P0.

Relevantno: ideje-home-cardfit*.md, ideje-home-incard*.md, game_state.gd TEST_LOCK, season_unlock_gate.gd, season_roster_panel.gd, season_stage.tscn CenterTitle/FreeRoster/UnlockGate, plan-prompts-home-cardfit.md.
```

---

## Prompt — CARDFIT-A (Amber off TEST_LOCK + Unlock gate vidljiv)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-09 CARDFIT-A — Unlock na next-lock free, uključujući Amber.

Dijagnoza (ne reimplementirati widget): HOME-08 INCARD-B je već u CenterSlot/CenterFill (season_unlock_gate.gd). Gate se ne vidi kad je Lantern playable jer amber_canopy je TEST_LOCK_FREE_ID — is_free_selectable false, swipe bounce, refresh_gate visible=false. Playtest: napravi coins+Seeds trake i Unlock sivo→primary na SVACOJ trenutno zaključanoj free sezoni (primjer Amber Canopy).

CARDFIT-A:
U game_state.gd: is_test_locked_season više NE vraća amber_canopy. Ember Fen ostaje TEST_LOCK paid. can_unlock_free / unlock_free sequential ostaju (prethodna free mora biti unlocked). Amber 220 coins / 12 T3 iz seasons.json, ne hardkodirati u UI.

Gate uvjeti ostaju: free-hero + strip_center_id == next_locked_free_id() + is_free_selectable + not playable. To sada prolazi za Frost ILI Lantern ILI Amber ovisno o saveu. Paid: nema coin gate. Coral bez Unlock.

Unlock gumb: disabled + subtle + MOUSE_FILTER_IGNORE dok !can_unlock_free; primary + STOP kad može; tap unlock_free. refresh_gate MORA vratiti STOP nakon _ignore_hits/refresh/morph kad can — inače gumb ostane mrtav.

debug_unlock_all_seasons i dalje skipa lantern_meadow I amber_canopy (po id-u, ne preko TEST_LOCK) I ember_fen. Ne grantati Amber.

Browser/shop: Amber nije više test-lock no-op; next-lock → Home fokus (P85). Ember i dalje test-lock.

Smokes (season_home_smoke / season_unlock_smoke): obrnuto od HOME-07 za Amber — Amber JEST selectable kad je Lantern playable; gate child CenterSlot; sivi Unlock bez 220c/12 T3; s resursima primary + grant; Ember i dalje test-lock; Coral bez coin gatea; Lantern gate i dalje radi kad Lantern nije unlocked.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati u A: naslov gore vs sredina, roster širina/boja, band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, seed_type_ids, 48 stubova.

Relevantno: docs/03-content/ideje-home-cardfit-gate.md, ideje-home-cardfit-pitanja.md P103–P106 P110–P111, game_state.gd, season_unlock_gate.gd, season_stage.gd _refresh_unlock_gate, season_browser.gd, shop_screen.gd, season_home_smoke.gd, season_unlock_smoke.gd.

Acceptance: save Bloom+Frost+Lantern playable → swipe na Amber ne bounce; Amber centar pokazuje Coins n/220 + Seeds n/12 + Unlock sivo u njenom prozoru; s 220c/12 T3 gumb ispunjen i klikabilan; tap grant-a Amber; Ember locked; Coral bez coin Unlock.
```

---

## Prompt — CARDFIT-B (Naslov sredina + roster kontrast + širina)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-09 CARDFIT-B — ime na sredini, per-season roster/gate frame, širi roster.

CARDFIT-B (samo chrome; TEST_LOCK/Amber logika je A, ne dirati):

1) Naslov: CenterTitle i PaidCenterTitle full-rect Fill, horizontal_alignment CENTER, vertical_alignment CENTER. Maknuti P100 top-only (offset_bottom 72, vertical TOP). Override P107. L/R side naslove ne dirati. mouse_filter IGNORE.

2) Roster kontrast: apply_season mora ponovo StyleBox — danas _apply_frame samo u _ready pa je sve 1A1A14. Paleta iz season_stage _mood_color. Svijetle kartice (Bloom, Frost, Lantern, Amber, Coral) → frame darkened ~0.5–0.6 + cream tekst. Tamne (Moonlit, Starfall) → frame lightened + tamni tekst. Ember: darken + cream. Gate _apply_frame isti jezik za hero_id. Ne treća paleta. PaidRoster isti algoritam.

3) Širina: FreeRoster/PaidRoster min ~320px, ~0.42–0.50 širine CenterFill (danas 260 / offset_right 268). Sidro donji lijevo ostaje. clip_contents ostaje. Gate donji desni, z_index iznad rostera. Ikona 52 / font 22 / zvijezde 18 / red 56 ostaju. Ellipsis samo fallback.

Smokes: CenterTitle vertical_alignment CENTER i anchors pune visine; Bloom roster bg_color != Moonlit bg_color; FreeRoster.size.x > 260 na hero Bloom; Harvest Pumpkin / Golden Oak Bloom / Reef Crown vidljivi.

Headless OpenGL. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne watcher. Ne dirati TEST_LOCK, band 20/80, L/R in-place, seed_type_ids, Shop Select, AdMob, SAVE_VERSION.

Relevantno: docs/03-content/ideje-home-cardfit-naslov.md, ideje-home-cardfit-roster.md, P107–P109 P113, season_stage.tscn CenterTitle/FreeRoster/PaidRoster/UnlockGate, season_roster_panel.gd, season_unlock_gate.gd, season_stage.gd _mood_color.

Acceptance: selektovana sezona ima ime NA SREDINI kartice; Bloom vs Moonlit vs Amber vs Coral — različita roster pozadina s kontrastom; duga imena stanu na hero Fillu; gate na Amber (ako A gotov) nije Bloom-crn na jantar kartici.
```

---

## Redoslijed i ovisnosti

- **P0** prije A/B (docs). Već urađeno 2026-08-25.
- **A** urađen 2026-08-25. **B** sljedeći — B boji gate frame po `hero_id`; A je Amber pustila u centar.
- Ne spajati A i B u jedan prompt.

## Povezano

- [[plan-prompts-home-incard|HOME-08]] · [[plan-prompts-home-unlock|HOME-07]] · [[plan-prompts-home-focus|HOME-06]]
