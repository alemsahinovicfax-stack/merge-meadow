---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, sezone, meadow, play, pip, scratch]
povezano:
  - ideje-home-meadow-life
  - ideje-home-meadow-chrome-pitanja
  - ideje-home-meadow-pitanja
  - plan-prompts-home-meadow-life
  - CHECKPOINT
ai_sažetak: "HOME-14 pitanja P179–P196 — Play 3-koraka; jednaki PlayRow; 12–14 cvjetova u safe zoni; MeadowPip FSM. Override P138/P175/P157/P160."
---

# IDEJE — HOME-14 pitanja (P179–P196)

> [[ideje-home-meadow-life|hub]]. Freeze **2026-09-01**.  
> P1–P178 ostaju osim override tablice ispod. Dual-band / UnlockGate / roster kad meadow **nije** otvoren — HOME-12. Chrome Basket/Endless/tint/chip — HOME-13.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P179** | Play s karusela = run? | **Nikad.** `begin_campaign_run` samo dok je `home_season_field_open`. |
| **P180** | Play na locked free / unowned paid? | **Snap** karusel na `active_season_id` (`home_band` + strip focus + `refresh`). Ne run. Ne otvaraj polje. |
| **P181** | Play na playable hero? | Otvori **polje tog id-a** (P137 ostaje), `set_active_season`. Drugi playable u centru ≠ snap natrag na stari active — otvara to polje. |
| **P182** | Play na otvorenom polju? | Campaign **run** (isti `begin_campaign_run` kao danas). |
| **P183** | Što je „selektirana“ sezona? | `active_season_id`. |
| **P184** | PlayRow proporcije? | Basket, Play, Endless: **ista** `custom_minimum_size` i jednaki `size_flags_horizontal` (npr. 320×96, expand fill). Karusel: samo Play, ista visina, centriran. |
| **P185** | Koliko cvijeća? | **12–14** iz `seed_type_ids` field id-a; T1/T2 mix; IGNORE; `apply_season` rebuild. |
| **P186** | Gdje smiju sjeme i Pip? | Chrome-**safe** rect: ne sijeku Daily, Settings, `%SeasonNameChip`, `%PlayRow` (global rect + ~8–16px margin). Clip `SeasonField`; meadow `z_index` ispod chromea. |
| **P187** | MeadowPip u polju? | **On** kad je field open. UniqueName ostaje. Close → hide + stop FSM. |
| **P188** | Kakvo ponašanje? | Hod (sporo, ease, random točka u safe rectu ili prema cvijetu), njuh (kratko, ne isti cvijet zaredom), spavanje (duži idle). Weighted random **bez odmah istog** stanja. Nije stari flower-index tween. |
| **P189** | PipPortrait? | **Off** (P159 ostaje). Ne vraćati na karusel. |
| **P190** | Milestone? | **v1.1+**. Nije D0 / launch blocker. |
| **P191** | Save? | **Ne** `SAVE_VERSION`. Session flagovi P146 ostaju. |
| **P192** | Što ne dirati? | Shop IAP, AdMob, Unlock JSON 500/20, CAMP-01/02, leftover/vacuum, hub pager, SeedCatalog JSON, run Pip, Endless Hard/tema (CHROME-D), name chip close (CHROME-E), Basket picker/T3 (CHROME-C). |
| **P193** | Smoke A (Play)? | Locked/unowned Play: `home_season_field_open == false`, scena nije run, hero = `active_season_id`. Playable Bloom center Play → field. |
| **P194** | Smoke B (PlayRow)? | Field open: tri djece PlayRow ista `custom_minimum_size`. Karusel Play visina ista. |
| **P195** | Smoke C (cvijeće)? | Open: 12–14 IGNORE; nijedan cvijet ne siječe Daily/Settings/chip/PlayRow (margin). Frost pool ≠ Bloom ako treba. |
| **P196** | Smoke D (Pip)? | Bloom/Frost open: Pip **visible**, UniqueName 1, isti instance_id; close hidden. `is_pip_alive` / wander-or-FSM. **Ne** assertirati sniff frame. |

## Override mapa (HOME-12 / HOME-13)

| Staro | HOME-14 |
|-------|---------|
| P138 / P175 non-playable Play → **run** | P179–P180 snap na active |
| P154 `can_open` = playable hero | Ostaje za **open field**; Play routing koristi P179–P182 |
| P157 6–10 cvjetova | P185 12–14 |
| P160 MeadowPip **off** | P187–P188 on u polju |
| P178 flower slotovi van chrome tracka | P186 safe rect **u** ovom tracku |
| P159 PipPortrait off | P189 ostaje off |

## Ostaje iz HOME-12 / HOME-13

P137 tap playable → polje. P143 locked **nema** polja. P145 IGNORE. P146 session. P147 playable ≠ Browser. P148 swipe ≠ Back. P153 jedan Field. P156 paid owned playable. P161–P174 chrome (tint, Basket, Endless, chip). P189 portrait.

## Nije otvoreno

- Chevron. Easy Endless. Merge na polju. IAP na ulaz. 8 tscn.

## Povezano

- [[ideje-home-meadow-pitanja|P137–P158]] · [[ideje-home-meadow-chrome-pitanja|P159–P178]]
- [[ideje-home-meadow-dock-pitanja|HOME-15 P197+]]
- [[../06-production/plan-prompts-home-meadow-life|prompti]]
