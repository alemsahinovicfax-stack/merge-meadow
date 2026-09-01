---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, chrome, basket, endless, scratch]
povezano:
  - ideje-home-meadow-chrome-pitanja
  - ideje-home-meadow-chrome-layout
  - ideje-home-meadow-chrome-basket
  - ideje-home-meadow-chrome-nav
  - ideje-home-meadow-chrome-grupe
  - ideje-home-meadow
  - ideje-home-meadow-life
  - ideje-home-chrome
  - ideje-seed-pool
  - plan-prompts-home-meadow-chrome
  - CHECKPOINT
ai_sažetak: "HOME-13 hub — Basket i Endless samo u polju; full-bleed tint; Pip van s Homea i meadowa; natrag ime-chip. Ne 8 scena."
---

# IDEJE — Home meadow chrome (HOME-13 hub)

> **ID:** **HOME-13** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **CHROME-P0 ✅ A ✅ B ✅ C ✅ D ✅ E ✅**. Playlist zatvoren ([[../06-production/plan-prompts-home-meadow-chrome|prompti]]). Grupe: [[ideje-home-meadow-chrome-grupe|grupe]].  
> **Sljedeće:** [[ideje-home-meadow-life|HOME-14]] meadow life.  
> **Prethodnik:** [[ideje-home-meadow|HOME-12]] MEADOW-A ✅ B ✅ C ✅ — jedan `SeasonField` + `apply_season` ostaje.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — paid/sezona = **tema**, ne snaga; basket filter ne daje jači run.

## Pitch

Karusel bira sezonu. **U polju** igrač vidi svijet te sezone na cijelom Homeu (iza Daily, Settings, Play), bira sjeme u Basketu **te** sezone, i pali Play ili Endless. Na karuselu nema Basketa, Endlessa ni Pipa. Natrag = tap na **ime sezone** gore, ne debeli gumb na cvijeću.

## Zašto sada

HOME-12 je otvorio polje, ali chrome je ostao **karusel-Home**: Basket i Endless visé dok biraš sezonu; tint je samo srednji pravokutnik; PipPortrait + MeadowPip šum; **Seasons** sjedi na sredini polja.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Basket u `HomeTopStack` na karuselu | Basket **samo u polju**, lijevo od Play / Endless |
| Picker = globalni unlock chain | Picker = `SeedCatalog.types_for_season(field_id)` ∩ unlocked |
| Basket ikona = pickup T1 | Izabrano sjeme = **T3** `CampPlantDraw` |
| Endless na karuselu (može Bloom spawn uz Frost fokus) | Endless **samo u polju**; tema = `home_season_field_id` |
| PipPortrait na biranju + MeadowPip u polju | Oba **off** (run Pip ostaje) |
| Tint samo `SeasonStage` rect | Full-bleed iza Daily / Settings / Play |
| Gumb **Seasons** top-center | Mali **name chip** gore; UniqueName SeasonsButton hidden |

## Što HOME-13 **jest**

- Chrome/layout na **istom** `SeasonField` shellu (P153 ostaje).
- Override P139 (vidljivost Endless), P140 (natrag), P144 (što ostaje na karuselu), P149/MEADOW-C (Pip wander off).
- Play dual P138 ostaje: karusel Play / playable centar → polje; Play na polju → campaign run.

## Što HOME-13 **nije**

- Osam tscn polja. Shop IAP, AdMob, Unlock JSON 500/20, CAMP-01/02, leftover/vacuum, hub pager, `SAVE_VERSION`.
- Run companion / `pip_visual.gd` / ArenaPip / `player.gd`.
- Easy/Normal Endless picker (P38 ostaje Hard).
- SeedCatalog rewrite (SEED-01 ✅). Flower slotovi / count (MEADOW-B ostaje).

## Agent

- Basket u polju, Endless samo u sezoni, full-bleed, makni Pip, natrag bez Seasons gumba → **HOME-13**.
- Jedan Field / `apply_season` / Play dual → baza **HOME-12** (ne reimplementirati).
- Frost clover / journal → **SEED-01**.
- Ne spajati A–E. Ne spajati s CAMP-02 ili SEED kodom.

## Paket

| Doc | Što |
|-----|-----|
| ovaj hub | pitch + override |
| [[ideje-home-meadow-chrome-layout\|layout]] | full-bleed + donji red |
| [[ideje-home-meadow-chrome-basket\|basket]] | filter + T3 |
| [[ideje-home-meadow-chrome-nav\|nav]] | name chip + Back |
| [[ideje-home-meadow-chrome-pitanja\|pitanja]] | P159–P178 |
| [[ideje-home-meadow-chrome-grupe\|grupe]] | A–E mapa |
| [[../06-production/plan-prompts-home-meadow-chrome\|prompti]] | copy-paste |

## Povezano

- [[ideje-home-meadow|HOME-12]] · [[ideje-home-meadow-life|HOME-14]] · [[ideje-home-chrome|HOME-03]] · [[ideje-seed-pool|SEED-01]]
- [[../06-production/plan-prompts-home-meadow-chrome|prompti]] · [[CHECKPOINT|CHECKPOINT]]
