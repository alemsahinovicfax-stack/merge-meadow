---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, play, scratch]
povezano:
  - ideje-home-meadow-life
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-shell
  - plan-prompts-home-meadow-life
ai_sažetak: "HOME-14 A — Play 3-koraka: snap na active ako hero nije playable; playable otvara polje; polje Play = run. Nikad run s karusela."
---

# IDEJE — HOME-14 play (3-koraka)

> [[ideje-home-meadow-life|hub]] · freeze P179–P183, P193.  
> **Kod:** **LIFE-A ✅** 2026-09-01. Ne PlayRow (B). Ne cvijeće (C). Ne Pip (D).

## Bug

Prije A: [`main_menu.gd`](../../game/scripts/ui/main_menu.gd) `_on_play_pressed` je na locked/unowned zvao `begin_campaign_run`.

Sada: `home_play_action()` → `run` / `open_field` / `snap`. `can_open` ostaje za `open_home_season_field`. Karusel **nikad** ne pada na run.

## Freeze

1. `home_season_field_open` → `begin_campaign_run` + `SceneRouter` run (P182).
2. Inače ako je hero **playable** → `open_season_field` (P181). To uključuje drugi playable u centru (npr. Frost) — otvara **to** polje, ne snap na stari Bloom.
3. Inače (locked free, unowned paid) → `snap_carousel_to_active()` (P180): `home_band` + free/paid strip focus na `active_season_id`, `refresh()`. Flag ostaje closed. **Ne** run.

Selektirana sezona = `active_season_id` (P183).

Tap na playable hero-centar i dalje otvara polje (HOME-12 P137). Endless, UnlockGate, Shop, swipe L/R netaknuti.

## Hook

`season_stage.gd`: npr. `snap_carousel_to_active() -> bool`. Ako je `active_season_id` prazan, fallback `SeasonCatalog.DEFAULT_SEASON_ID` / `country_bloom`. Band swap ako je active paid a gledaš free (ili obrnuto).

## Što A **ne** radi

- Ne mijenja visinu PlayRow. Ne cvijeće. Ne MeadowPip. Ne `begin_endless_run`. Ne `SAVE_VERSION`.

## Smoke (P193)

[`season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd) + [`season_meadow_smoke.gd`](../../game/scripts/dev/season_meadow_smoke.gd):

- Fixture: locked free ili unowned paid u hero-centru; `active_season_id` = Bloom (ili zadnji playable). Simuliraj Play (`_on_play_pressed` ili ekvivalent) → `home_season_field_open == false`; hero center = `active_season_id`; **nije** `SCENE_RUN`.
- Bloom playable u centru + Play → field open, `home_season_field_id == country_bloom`.
- Field već open: Play path ostaje run (spy/flag; ne obavezno puna run scena).

## Acceptance A

- Pregled paid/locked + Play = povratak na selektiranu sezonu, još karusel.
- Na selektiranoj playable + Play = polje.
- U polju + Play = run.
- Nikad run dok biraš sezonu.
