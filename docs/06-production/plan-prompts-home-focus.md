---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, gesta, sezone, plan, prompt]
povezano:
  - ideje-home-focus
  - ideje-home-focus-gesta
  - ideje-home-focus-browser
  - ideje-home-focus-chrome
  - ideje-home-focus-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-06 — FOCUS-P0 → A gesta → B Browser+badge → C outline+lock."
---

# Plan promptovi — HOME-06 Focus korekcija

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **FOCUS-P0 → A → B → C**  
> **Ideje:** [[../03-content/ideje-home-focus|hub]] · [[../03-content/ideje-home-focus-gesta|gesta]] · [[../03-content/ideje-home-focus-browser|browser]] · [[../03-content/ideje-home-focus-chrome|chrome]] · [[../03-content/ideje-home-focus-pitanja|pitanja]]

**FOCUS-P0** urađen 2026-08-20 (docs). **FOCUS-A–C** urađeni 2026-08-20. **FOCUS-D** urađen 2026-08-20 (L/R in-place pretapanje).

## Freeze

| # | Odluka |
|---|--------|
| P1–P59 | Ostaju (HIT-A, dual-band, P55 preview H, Shop bez Select, …) |
| P60 | Override P69: **nema** row-slide; in-place pretapanje `BAND_TWEEN_SEC` |
| P61 / **P75** | Outline = playable `active_season_id` |
| P62 | Override smjer: **P70** dolje = paid, gore = free |
| P63–P65, P66–P68 | Ostaju (preview H statičan; V ne bira karticu; katalog) |
| **P69** | L/R in-place pretapanje (kao band visine); nema HBox pomaka |
| **P70** | Invert vertikalnog swipea |
| **P71 / P79** | Outline visoki kontrast |
| **P72** | Browser → `home_band` + centar |
| **P73 / P76–P80** | Test-lock amber + ember; const default true |
| **P74** | Nema `PlayThemeBadge` teksta |

Ne dirati: unique S2 seed ID-evi, Play Console, AdMob, wrap, hub pager stranice, Shop Select, SAVE_VERSION, band 20/80 visine.

---

## Prompt — FOCUS-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow, HOME-06 korekcija Home fokusa i glajda — docs freeze.

Dokumentiraj: HOME-05 L/R je krivo shvaćen; referenca je samo band-swap visina 20↔80; L/R ostaje 3-slot pomak ali bez refresh cuta (P69); invert V swipe (P70); Browser mora centrirati sezonu i band (P72); jači outline (P79); TEST_LOCK_LAST_SEASONS amber_canopy + ember_fen (P73); ugašen PlayThemeBadge (P74); P69–P80.

Relevantno: ideje-home-focus*.md, ideje-home-glide.md, season_stage.gd, season_browser.gd, main_menu.gd, plan-prompts-home-focus.md.

Nema game/ u P0.
```

---

## Prompt — FOCUS-A (Gesta: invert + L/R bez cuta)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-06 gesta.

FOCUS-A:
U season_stage.gd _on_vertical_swipe invertirati dy: dy > 0 (prst dolje) → swap_home_band paid; dy < 0 → free; bounce ako si već na tom bandu. Tap preview ostaje.

L/R: zadrži _play_slide / _play_paid_slide offset tween (center.width + 8, BAND_TWEEN_SEC). U istom tweenu stretch_ratio 1.35↔1.0: odlazeći centar se skuplja, dolazeći susjed raste. _finish_slide cycle+refresh+reset offset tek kad vizual već sjedi — nema identity/size snap. Nova rubna kartica smije fade-in. Klik L/R i swipe L/R isti path. Preview H ne cyclea (P55). Bounce na rubu ostaje. Band visine ne dirati.

Relevantno: season_stage.gd, ideje-home-focus-gesta.md, P69 P70.

U planu:
- Točan predznak dy
- Paralelni tween stretch + offset
- season_home_smoke: cycle radi; await ~0.3s
- Headless OpenGL; ne pali GUI Godot u A
- Ne Browser (B), ne outline/lock (C)

Acceptance: Bloom→Frost odklizi bez cuta; swipe dolje na free = paid visinski glajd.
```

---

## Prompt — FOCUS-B (Browser fokus + ugašen badge)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-06 Browser + Play chrome.

FOCUS-B:
_on_browser_selected(season_id): playable → home_band = kind; ta sezona hero centar 3-slota; ako band treba promjenu, swap_home_band(band, id) (visinski glajd); ako je band već točan, setter fokusa + refresh bez lažnog tweena. Browser set_active ostaje; Stage mora centrirati, ne samo outline. Locked/unowned u Browseru: postojeći sheet/IAP (test-lock no-op dolazi u C).

PlayThemeBadge: uvijek hidden / _refresh_play_theme_badge no-op. Između Play i Play Endless nema teksta. Play interno i dalje home_hero_center_id / P50.

Relevantno: season_stage.gd, season_browser.gd, main_menu.gd, main_menu.tscn, P72 P74.

U planu:
- Handler s band check
- Badge visible false
- Ne invert swipe (A), ne TEST_LOCK (C)
- Headless ako postoji browser smoke; inače ne rušiti season_home_smoke

Acceptance: Browser Moonlit sa free-heroa → paid-hero + Moonlit centar + overlay zatvoren. Nema Theme: labele.
```

---

## Prompt — FOCUS-C (Outline + test-lock)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-06 outline i test-lock.

FOCUS-C:
_apply_card_color: visoki kontrast outline (5px FFF6D6 + shadow 2px 1A1A14, ili 4–5px 1A1A14). Ne 3px E8D5A3. Outline samo playable active_season_id.

TEST_LOCK_LAST_SEASONS := true na GameState. amber_canopy i ember_fen nisu playable; debug_unlock_all ih preskače; unlock/IAP/grant no-op; Shop/Browser ember tap no-op; amber tap bounce ne sheet. Home lock vizual kao P11. Nema SAVE_VERSION bump.

Relevantno: season_stage.gd, game_state.gd, season_browser.gd, shop_screen.gd, IAP grant, season_home_smoke, shop_open_smoke, P73 P75–P80.

U planu:
- Const + is_season_playable / grant / debug
- Shop 4 kartice ostaju
- Smokes; headless OpenGL; na kraju sesije jednom godot-run.ps1
- Ne dirati A/B osim ako lock lomi cycle

Acceptance: Outline čitljiv na Bloom; debug unlock ne otvara Amber/Ember; Shop 4. pack ne grant-a.
```

---

## Prompt — FOCUS-D (L/R in-place pretapanje) — urađeno

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow, HOME-06 L/R = ista glatkoća kao free↔paid.

FOCUS-D:
Ukloniti HBox offset tween iz _play_slide / _play_paid_slide. Slotovi ostaju. Pretapanje modulate.a 1→0, cycle+fill, 0→1 kroz BAND_TWEEN_SEC (sine out). Stretch 1.35 ostaje na miru. Preview H ne cyclea. Invert V, Browser, outline, test-lock ne dirati.

Acceptance: Bloom→Frost pretapa na mjestu, bez pomaka reda i bez snap-a.
```

---

## Povezano

- [[../03-content/ideje-home-focus|HOME-06 hub]]
- [[plan-prompts-home-glide|HOME-05 prompti]] (zatvoren; korekcija je ovaj fajl)
- [[plan-prompts-home-paid|HOME-04 prompti]]
