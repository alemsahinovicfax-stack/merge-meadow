---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, sezone, meadow, chrome, scratch]
povezano:
  - ideje-home-meadow-chrome
  - ideje-home-meadow-pitanja
  - plan-prompts-home-meadow-chrome
  - CHECKPOINT
ai_sažetak: "HOME-13 pitanja P159–P178 — Basket/Endless u polju; full-bleed; Pip van; name-chip natrag. Override P139/P140/P144/P149."
---

# IDEJE — HOME-13 pitanja (P159–P178)

> [[ideje-home-meadow-chrome|hub]]. Freeze **2026-09-01**.  
> P1–P158 ostaju osim override tablice ispod. Dual-band / UnlockGate / roster kad meadow **nije** otvoren — HOME-12.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P159** | Pip na biranju sezona? | **Off.** `%PipPortrait` hidden na karuselu (i dok je polje otvoreno). Kartice/roster i sad nemaju Pip — ne dodavati. |
| **P160** | Pip u polju (MEADOW-C)? | **Off.** `%MeadowPip` UniqueName **ostaje**; `visible = false`; wander stop. Ne `pip_visual` / ArenaPip / `player.gd`. |
| **P161** | Koliko velik tint? | Kad je polje otvoreno: **full-bleed MainMenu** iza Daily, Settings, Play. Ne samo `SeasonStage` rect. |
| **P162** | Hub TopBar / nav tabovi? | **Ne** u ovom tracku. Tint = `main_menu` page. |
| **P163** | Pozadina karusela? | Današnja tamna. Tint samo dok je `home_season_field_open`. |
| **P164** | Basket na karuselu? | **Ne.** `%BasketCard` nije vidljiv u `HomeTopStack` dok meadow nije open. Daily ostaje. |
| **P165** | Gdje je Basket u polju? | Donji red: **Basket \| Play \| Endless**. Basket **lijevo** od Play. |
| **P166** | Koja sjemena u pickeru? | `SeedCatalog.types_for_season(home_season_field_id)` ∩ unlocked; bez mythic. |
| **P167** | Ikona izabranog? | `CampPlantDraw` **tier 3** u basket visualu. Ne pickup T1. Prazno = outline korpe. |
| **P168** | Loadout pri promjeni sezone? | Ako `loadout_type_id` nije u novom poolu → `clear_loadout`. API `set_loadout` ostaje. |
| **P169** | Endless na karuselu? | **Ne.** Visible samo `home_season_field_open` **i** `tutorial_complete` (P44 ostaje). |
| **P170** | Endless teškoća? | I dalje **Hard** (P38 / P139 sadržaj runa). Nema Easy/Normal UI. |
| **P171** | Endless tema / spawn? | `home_season_field_id` (open već `set_active_season`). Smoke: Frost field → Frost `seed_type_ids`, ne Bloom clover. |
| **P172** | Natrag na karusel? | Mali **season-name chip** gore; tekst = display name; tap = `close_season_field`. Nije debeli gumb na cvijeću. |
| **P173** | Hardware Back? | **Da** — Android system back zatvara polje (isti close). Ne swipe L/R (P148). |
| **P174** | `%SeasonsButton`? | UniqueName **ostaje** (smoke). Default hidden / prazan label. CAMP2-A pattern. |
| **P175** | Play s karusela? | **P138 ostaje:** playable centar ili Play → **otvori polje**. Na polju Play = campaign run. |
| **P176** | Milestone? | **v1.1+**. Nije D0 / launch blocker. |
| **P177** | Save? | **Ne** `SAVE_VERSION`. Session flagovi P146 ostaju. |
| **P178** | Što ne dirati? | Shop IAP, AdMob, Unlock JSON 500/20, CAMP-01/02, leftover/vacuum pravila, hub pager, flower slotovi/count, run Pip, `merge_arena_controller`. |

## Override mapa (HOME-12 / HOME-03)

| Staro | HOME-13 |
|-------|---------|
| P139 Endless **uvijek** gumb na Homeu | Gumb **samo u polju**; run i dalje Hard |
| P140 gumb **Seasons** | P172 name chip + P174 node hide |
| P144 chrome: Daily, Basket, Play, Endless, samo Stage zona | Basket+Endless u polju; tint full-bleed; Daily/Settings ostaju |
| P149 / MEADOW-C Pip wander | P160 off |
| P36 PipPortrait na Homeu | P159 off na ovom ekranu |
| P37 dva gumba na HomeColumn | Dva gumba **u polju**; karusel samo Play (ulaz) |
| P38 Hard, P39 `active_season_id` | Ostaju; P171 veže na field id |

## Ostaje iz HOME-12

P137 ulaz, P138 Play dual, P143 locked nema polja, P145 IGNORE cvijeće, P146 session, P147 playable ≠ Browser, P148 swipe ≠ Back, P153 jedan Field, P154 `can_open` playable, P155 field_id, P156 paid owned, P157 cvijeće iz poola.

## Nije otvoreno

- Chevron pored Settings umjesto name chipa — jedini dozvoljeni swap u E, isti `close_season_field`.
- Osam tscn. Merge na polju. IAP na ulaz.

## Povezano

- [[ideje-home-meadow-pitanja|P137–P158]] · [[ideje-home-chrome-pitanja|HOME-03 P]]
- [[ideje-home-meadow-life-pitanja|HOME-14 P179+]]
- [[ideje-home-meadow-dock-pitanja|HOME-15 P197+]]
- [[../06-production/plan-prompts-home-meadow-chrome|prompti]]
