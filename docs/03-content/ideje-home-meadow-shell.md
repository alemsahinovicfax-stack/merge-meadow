---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, scratch]
povezano:
  - ideje-home-meadow
  - ideje-home-meadow-pitanja
  - ideje-home-meadow-field
  - ideje-seed-pool
ai_sažetak: "HOME-12 A — jedan SeasonField, apply_season, Play/tap za svaku playable sezonu, gumb Seasons; bez Pipa i cvijeća."
---

# IDEJE — HOME-12 shell (ulaz/izlaz, prazno polje)

> [[ideje-home-meadow|hub]] · freeze P137–P140, P143–P148, P150, P152–P156, P158.  
> **Kod:** **MEADOW-A ✅**. **Ne** cvijeće (B), **ne** Pip (C). **Ne** SeedCatalog JSON (SEED-A).  
> **HOME-13** override: Endless/Basket/Seasons gumb / full-bleed → [[ideje-home-meadow-chrome|chrome]].

## Layout

Jedan overlay, **nije** po sezoni:

```
SeasonStage
  BandColumn          ← hide kad meadow open
  SeasonField         ← show kad open; full rect; JEDAN node
    FieldGround       ← apply_season tint
    SeasonsButton     ← "Seasons"
    (B: flowers)
    (C: Pip)
  SeasonBrowser
  SeasonUnlockSheet
```

`apply_season(season_id)`: ground modulate iz `SeasonTheme.bg_modulate(id)` (ako WHITE, lokalni pastel na **samo** FieldGround). Ne instancirati drugi Field.

Kad open: BandColumn + roster + UnlockGate **hidden**. Field root `STOP`; djeca `IGNORE` osim Seasons.

## Routing — Play

[`main_menu.gd`](../../game/scripts/ui/main_menu.gd) `_on_play_pressed`:

1. Meadow već open → run kao danas.
2. Else ako `can_open_home_season_field()` → open (`home_season_field_id = home_hero_center_id()`), `apply_season`, **ne** run.
3. Else → run (locked / unowned).

Endless **ne** dirati.

## Routing — tap

Hero **center** (free **ili** paid, tad kad je taj band hero): ako playable → `open_season_field`, **ne** `open_browser`. L/R ciklus ostaje na karuselu. Locked center: Unlock / bounce kao danas.

Meadow open: gui_input ne ciklusira skrivene bandove.

## Seasons

Close: flag false, `home_season_field_id` clear, bandovi show, `refresh()`. Ne mijenja `active_season_id` obavezno (open smije `set_active_season` na field id da run koristi tu temu — preporuka: open **postavi** active na field id).

## GameState

```
var home_season_field_open: bool = false
var home_season_field_id: String = ""
```

Nije u save/load.

- `can_open_home_season_field() -> bool` = playable hero center.
- `open_home_season_field() -> bool`
- `close_home_season_field()`
- Stage: `apply_season(id)`

## Smoke (A)

[`season_meadow_smoke.gd`](../../game/scripts/dev/season_meadow_smoke.gd):

- Default off; BandColumn visible.
- Open Bloom (playable) → flag true, field_id `country_bloom`, BandColumn hidden, SeasonField visible, Seasons exists, **jedan** SeasonField u stablu.
- Close → karusel.
- Ako je Frost **playable** u fixtureu: `can_open` true; open → `home_season_field_id == frost_orchard`, ground tint ≠ Bloom (ili apply_season zvan).
- Ako je sezona **locked** (npr. lantern uz debug skip): `can_open` false.
- `season_home_smoke`: playable center više **nije** Browser assert; locked UnlockGate ostaje.

## Acceptance A

- Playable u centru: tap ili Play → polje, još Home.
- Play na polju → run.
- Seasons → karusel.
- Druga playable sezona → **isti** SeasonField, drugi tint/id.
- Locked: nema polja.
- Endless uvijek endless.
- Nema Pipa ni cvijeća. Nema `frost_field.tscn`.
