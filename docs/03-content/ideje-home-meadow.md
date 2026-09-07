---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, pip, scratch]
povezano:
  - ideje-home-meadow-pitanja
  - ideje-home-meadow-shell
  - ideje-home-meadow-field
  - ideje-home-meadow-pip
  - ideje-home-meadow-grupe
  - plan-prompts-seed-meadow
  - ideje-home-meadow-chrome
  - ideje-home-meadow-life
  - ideje-seed-pool
  - ideje-home-barfit
  - ideje-sezone
  - CHECKPOINT
ai_sažetak: "HOME-12 hub — jedno SeasonField za svaku playable sezonu (apply_season); tap/Play → polje; Play na polju → run; Seasons natrag. Ne 8 scena."
---

# IDEJE — Home meadow (HOME-12 hub)

> **ID:** **HOME-12** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **MEADOW-A ✅ B ✅ C ✅**. Prompti: [[../06-production/plan-prompts-seed-meadow|plan-prompts-seed-meadow]] **1–6 ✅**. Grupe: [[ideje-home-meadow-grupe|grupe]].  
> **Sljedeće:** [[ideje-home-meadow-dock|HOME-15]] dock. HOME-14 life ✅. HOME-13 chrome ✅.  
> **Sjeme:** unique T1–T3 po sezoni = [[ideje-seed-pool|SEED-01]] (**prije MEADOW-B**).  
> **Prethodnik:** [[ideje-home-barfit|HOME-11]] BARFIT-A ✅ — dual-band karusel ostaje kad meadow **nije** otvoren.  
> **Override 2026-09-01:** P141/P142/P151 Bloom-only **povučen**. Jedan shell, sve **playable** sezone.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — polje je **tema**, ne snaga; nema IAP na ulaz.

## Pitch

Igrač na Homeu **bira** sezonu (dual-band). Kad je **playable** sezona u hero-centru i tapne **prozor** ili **Play**, ne ide odmah u run — **uđe u tu sezonu**. I dalje je Home: header, Daily gift, Basket, Play, Play Endless, footer ostaju. Zona `SeasonStage` postaje **jedno polje** (isti Control) s tintom, cvijećem i Pipom te sezone.

To **nije** igra. Pip i cvijeće `IGNORE`. Play na polju = campaign run. **Seasons** vraća karusel. Ulaz u **drugu** playable sezonu restylira **isti** `SeasonField` (`apply_season`) — nema 8 tscn-ova.

## Zašto jedan shell

Osam gotovih polja se razilaze (zaboravljeni tint, drugi Seasons gumb, smoke samo za Bloom). Novi season pack mora raditi bez nove scene. Jedan path = manje bagova pri izmjeni sezone.

## Dijagnoza

[`main_menu.gd`](../../game/scripts/ui/main_menu.gd) `_on_play_pressed`: odmah run. [`season_stage.gd`](../../game/scripts/ui/season_stage.gd) free hero center: `open_browser()`. Dual-band je biranje, ne mjesto.

Roster id-evi (`frost_snowdrop`) **nisu** `seed_type_ids` — to popravlja [[ideje-seed-pool|SEED-01]], ne overlay scena.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Play → odmah run | Play s karusela (playable) → **polje**; Play na polju → run |
| Tap playable centar → Browser | Tap središnji prozor → **polje** |
| Dual-band uvijek | Na polju bandovi hide; jedno polje |
| Nema natrag | Gumb **Seasons** |
| Frost run spawna clover | SEED-01: pool te sezone; polje čita `seed_type_ids` |

## Što HOME-12 **jest**

- Jedan `SeasonField`; `apply_season(season_id)` za tint (A) i kasnije cvijeće (B).
- Session: `home_season_field_open` + `home_season_field_id` — **nije** u saveu.
- Ulaz: `is_season_playable(home_hero_center_id())` + (tap hero center **ili** Play). Free unlocked **i** paid owned.
- Locked / unowned: UnlockGate / stari tap; **nema** polja.
- Izlaz: **Seasons**.
- A: prazan tint + routing. B: cvijeće iz `seed_type_ids` tog id-a. C: Pip wander.
- Endless **uvijek** run.

## Što HOME-12 **nije**

- Osam `SeasonField` scena. Merge/drag na polju. `merge_arena_controller`.
- Novi Browser gumb u meadowu. Swipe L/R = Back.
- SeedCatalog / JSON pool rewrite (to je SEED-01).
- Unlock JSON 500/20, Shop IAP, AdMob, CAMP-01 spend, CAMP-02, SAVE_VERSION.
- Launch blocker.

## Agent

- „Uđi u sezonu“, „polje“, „Pip šeta“, „Seasons“, Frost/paid **isto polje** → **HOME-12**.  
- Basket u polju, Endless samo u sezoni, full-bleed, Pip van, name-chip natrag → **HOME-13**.
- Play snap, jednaki gumbi, više cvijeća, Pip hod/njuh/spavanje → **HOME-14**.
- Unique sjeme / journal / arena draw → **SEED-01**, ne MEADOW-A.
- Ne spajati A/B/C. Ne spajati s CAMP-02 ili SEED kodom u istom chatu.
- Ne praviti `frost_field.tscn`.

## Povezano

- [[ideje-home-meadow-pitanja|P137+ / P153+]] · [[ideje-home-meadow-grupe|grupe]]
- [[ideje-seed-pool|SEED-01]] · [[../06-production/plan-prompts-seed-meadow|prompti]]
- [[ideje-home-meadow-chrome|HOME-13 chrome]] · [[../06-production/plan-prompts-home-meadow-chrome|HOME-13 prompti]]
- [[ideje-home-meadow-life|HOME-14 life]] · [[../06-production/plan-prompts-home-meadow-life|HOME-14 prompti]]
- [[ideje-home-meadow-dock|HOME-15 dock]] · [[../06-production/plan-prompts-home-meadow-dock|HOME-15 prompti]]
- [[ideje-home-barfit|HOME-11]] · [[ideje-sezone|SEZ-01]]
