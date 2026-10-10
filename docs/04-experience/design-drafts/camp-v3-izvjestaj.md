---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, camp, arena, nadogradnje, claude-design, izvjestaj]
povezano:
  - camp-v3-cd-brief
  - camp-v2-izvjestaj
  - CHECKPOINT
  - changelog
ai_sažetak: "Provjera paketa design_handoff_camp_v3 u igri (2026-10-09): svih 16 odluka i 9 koraka prenosa je u kodu; dopunjeno zatvaranje modala vrata tapom van / Back, prelaz pilule N / 50 u mint (0,18 s) i njena tvrda sjena, razmak 10 i jedan spojen red u camp_trade_bar.gd."
---

# Camp v3 — izvještaj o provjeri paketa

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[camp-v3-cd-brief]] · paket: `design_handoff_camp_v3/` · datum: 2026-10-09

## Ukratko

Paket `design_handoff_camp_v3/` (Design.zip) je provjeren stavku po stavku. Kopija u repou je ista kao zip (razlika je samo u krajevima linija).

- **Svih 16 odluka iz README § Odlučeno i 9 koraka iz `godot/README.md` je u igri.** Popravke iz playtesta 2026-10-08 su na mjestu.
- **Dopunjeno 2026-10-09:**
  1. Modal „Not enough seeds” na vratima Arene se sada zatvara i tapom van i dugmetom Back. Paket traži „tap scrim / dugme / back”; do sada se zatvarao samo dugmetom.
  2. Pilula `N / 50` na 50 prelazi krem → mint za 0,18 s. Do sada je boja skakala odmah.
  3. Pilula `N / 50` sada ima tvrdu sjenu 0 8 0 iz paketa. Ranije je imala `shadow_size 0`, a to Godot uopšte ne crta.
  4. Razmak u pilulici je 10 umjesto 12.
  5. U `camp_trade_bar.gd` se nastavak reda spojio u jednu liniju. Radilo je, ali je bilo nečitko.
- Stari „need seeds” overlay (iz Popups paketa) i dalje se zatvara samo dugmetom. `arena_leftover_b_smoke` sada provjerava novo v3 pravilo.

## Stavke paketa

| # | Stavka | Stanje |
|---|---|---|
| 1 | Pozadina Campa `#4E3F5A`, sjene plum | ✅ `UiCamp.PAGE_BG` / `PAGE_SHADOW` |
| 2 | Sekcija 1289 (1585 bez kartice) | ✅ budžet u `UiCamp` |
| 3 | MergeableMark 64 × 42, mint, dva kruga, samo Seeds, stog ≥ 4 | ✅ `PipsRow` u `camp_stash_chip.gd`, ulaz 0,14 s |
| 4 | Oznaka desno u redu pipsa | ✅ |
| 5 | MergeableWarning ispod TradeRow, 48 px, bez panela | ✅ bar 152 ↔ 212 za 0,16 s |
| 6 | Tekst „Arena takes all N” / „… · sell 1 and none go” + amber disk na 4 | ✅ tekst se mijenja za 0,08 s |
| 7 | Prodaja ne staje na 4 | ✅ |
| 8 | Vrata Arene: pilula `N / 50` iznad korpe, polje vidljivo | ✅ broj pop 0,09 s; **mint prelaz 0,18 s i sjena dodani 2026-10-09** |
| 9 | Ispod 50 tap na korpu → modal (N / 50, sitni tipovi s 4 tačke, Back to Camp / Play a run) | ✅ **zatvaranje tapom van / Back dodano 2026-10-09** |
| 10 | Na 50 pilula mint, oznaka se upali | ✅ |
| 11 | Naslov sheeta = ime sezone u tint pilulici | ✅ centrirano (popravka 2026-10-08) |
| 12 | UpgradeButton 340 × 132 s obje cijene, pink za ono što fali, 5 stanja | ✅ `UiCamp.upgrade_state()` |
| 13 | Coini 10 / 20 / 40 / 60; cvijet samo iznad Kept granice | ✅ |
| 14 | Nadogradnje po sezoni (nova sezona 0, povratak čita stari zapis) | ✅ + migracija starog savea |
| 15 | Twin Seeds: p = 8 % × nivo, „+2” pop, cap 40 isti | ✅ `run_controller.gd` |
| 16 | Korpa: samo sjeme skupljeno u runu; prazno = „Seeds you catch in a run show up here” | ✅ |
| — | Testovi `camp_mergeable_smoke`, `arena_gate_sum_smoke`, `upgrades_per_season_smoke`, `twin_seeds_smoke` | ✅ postoje i prolaze |

## Otvorene odluke iz paketa

- **Kartica sezone 276 (v2) prema Season Kit 318 u igri.** v3 ne dira karticu; igra ostaje na Season Kitu. Ništa se ne čeka.
- **Od čega se broji `N`.** Igra broji cijelu vreću iz Camp Seeds taba (`GameState.mergeable_seed_count()`): svi tipovi, svih sezona, stog se računa samo od 4. Ako želiš da se broji samo sjeme aktivne sezone, reci.

## Performanse

Camp v3 animacije su kratki pojedinačni tweenovi na jednom čvoru (0,08–0,4 s). Nema petlji ni crtanja svaki frejm, pa ih nisam posebno mjerio.
