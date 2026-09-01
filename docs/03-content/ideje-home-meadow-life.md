---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, pip, play, cvijece, scratch]
povezano:
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-life-play
  - ideje-home-meadow-life-layout
  - ideje-home-meadow-life-pip
  - ideje-home-meadow-life-grupe
  - ideje-home-meadow
  - ideje-home-meadow-chrome
  - plan-prompts-home-meadow-life
  - CHECKPOINT
ai_sažetak: "HOME-14 hub — Play 3-koraka (nikad run s karusela); jednaki PlayRow; više cvijeća u chrome-safe zoni; MeadowPip hod/njuh/spavanje."
---

# IDEJE — Home meadow life (HOME-14 hub)

> **ID:** **HOME-14** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **LIFE-P0 ✅ LIFE-A ✅ LIFE-B ✅ LIFE-C ✅ LIFE-D ✅**. Playlist gotova. Grupe: [[ideje-home-meadow-life-grupe|grupe]].  
> **Prethodnik:** [[ideje-home-meadow-chrome|HOME-13]] CHROME-P0 ✅ A–E ✅ — Basket/Endless u polju, full-bleed, name chip; PipPortrait ostaje off.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — polje/Pip = **tema**, ne snaga.

## Pitch

Na karuselu Play **nikad** ne pali run. Pregled locked free ili unowned paid + Play vraća pogled na **selektiranu** sezonu (`active_season_id`). Play na toj sezoni otvara polje. Play **u polju** = campaign run.

U polju: donji red Basket | Play | Endless **jednakih** proporcija; više dekorativnog cvijeća u zoni koja **ne** prekriva Daily, Settings, name chip, PlayRow. Pip opet šeta — sporo, njuši, spava — bez vidljive petlje.

## Zašto sada

HOME-13 je skinuo MeadowPip (šum na chromeu). **LIFE-A–D ✅** — Play 3-koraka, jednaki PlayRow, 13 cvjetova u `meadow_safe_rect`, Pip hod/njuh/spavanje.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Play na locked/unowned → **run** | Snap karusel na `active_season_id`; ostani Home |
| Play na playable centru → polje | Ostaje (P137 / P181) |
| Play na polju → run | Ostaje (P182) |
| Basket 336×104, Play 360, Endless 260 | Tri **ista** min size (npr. 320×96) |
| 8 cvjetova, slot 0.82 kod Play | **12–14** u chrome-safe rectu — **LIFE-C ✅** |
| MeadowPip hidden (CHROME-A) | U polju **on**: hod / njuh / spavanje — **LIFE-D ✅** |
| PipPortrait hidden | **Ostaje off** (P189) |

## Što HOME-14 **jest**

- Override P138/P175 za **non-playable** Play (nije run). Playable hero i dalje otvara **to** polje.
- Override P160: MeadowPip u polju ponovo živ. P159 portrait **ne** vraćati.
- Override P157 count + P178 slotovi: više cvijeća, safe rect.
- Isti `SeasonField` + `apply_season`. Name chip, Endless Hard, Basket filter ostaju iz HOME-13.

## Što HOME-14 **nije**

- Osam tscn polja. Shop IAP, AdMob, Unlock JSON 500/20, CAMP-01/02, leftover/vacuum, hub pager, `SAVE_VERSION`.
- Run companion / `pip_visual.gd` / ArenaPip / `player.gd`.
- SeedCatalog JSON rewrite. Easy/Normal Endless. Chevron umjesto name chipa.

## Agent

- Play na paid/locked baca u run, snap na selektiranu, jednaki gumbi, više sjemena, Pip šeta/njuši/spava → **HOME-14**.
- Basket/Endless/full-bleed/name chip → baza **HOME-13** (ne reimplementirati).
- Jedan Field / `apply_season` → **HOME-12**.
- Ne spajati A+D ni C+D. Ne spajati s CAMP-02 ili SEED kodom.

## Paket

| Doc | Što |
|-----|-----|
| ovaj hub | pitch + override |
| [[ideje-home-meadow-life-play\|play]] | 3-koraka Play |
| [[ideje-home-meadow-life-layout\|layout]] | PlayRow + cvijeće + safe rect |
| [[ideje-home-meadow-life-pip\|pip]] | hod / njuh / spavanje |
| [[ideje-home-meadow-life-pitanja\|pitanja]] | P179–P196 |
| [[ideje-home-meadow-life-grupe\|grupe]] | A–D mapa |
| [[../06-production/plan-prompts-home-meadow-life\|prompti]] | copy-paste |

## Povezano

- [[ideje-home-meadow-chrome|HOME-13]] · [[ideje-home-meadow|HOME-12]] · [[ideje-home-meadow-pip|HOME-12 Pip]]
- [[../06-production/plan-prompts-home-meadow-life|prompti]] · [[CHECKPOINT|CHECKPOINT]]
