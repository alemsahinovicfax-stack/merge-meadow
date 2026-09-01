---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, layout, scratch]
povezano:
  - ideje-home-meadow-chrome
  - ideje-home-meadow-chrome-pitanja
  - ideje-home-meadow-shell
  - plan-prompts-home-meadow-chrome
  - ideje-home-meadow-life-layout
ai_sažetak: "HOME-13 B — full-bleed SeasonTheme iza Daily/Settings/Play; donji red Basket/Play/Endless samo u polju. HOME-14: PlayRow + safe rect."
---

# IDEJE — HOME-13 layout (full-bleed + control row)

> [[ideje-home-meadow-chrome|hub]] · freeze P161–P165, P169, P175.  
> **Kod:** **CHROME-B ✅** (tint) · **CHROME-C ✅** (Basket) · **CHROME-D ✅** (Endless) · **CHROME-E ✅** (name chip). Ne Pip (A).  
> **HOME-14:** jednaki PlayRow + cvijeće safe rect — [[ideje-home-meadow-life-layout|life layout]].

## Full-bleed (B)

Danas `FieldGround` živi u `SeasonField` unutar `SeasonStage` (~416px). Play, Daily, Settings, `PipPortrait` sjede **izvan** tinta.

Kad je `home_season_field_open`:

- Tint (`SeasonTheme.bg_modulate(id)`; Bloom WHITE → isti lokalni pastel kao MEADOW-A) pokriva **cijeli MainMenu** iza chromea.
- Implementacija: sibling backdrop na `MainMenu` full-rect **ili** proširiti `SeasonField`/`FieldGround` iza `HomeColumn` + `HomeTopStack`. Chrome (Daily, Settings, Play, Basket, Endless) **iznad** tinta (`z_index`).
- Cvijeće ostaje u field sloju (MEADOW-B slotovi **ne** dirati).
- Hub `TopBar` / page indicator / NavPanel **ne** tintati (P162).
- Karusel zatvoren: današnji tamni `MainMenu/Background` (P163). `DecorMound*` smije hide na open da tint čita čisto.

`apply_season(season_id)` i dalje **jedan** id — isti hook, širi rect.

## Donji red (C + D, nakon B)

Na otvorenom polju, u `HomeColumn` (ili field overlay row) ispod/na dnu:

```
[ BasketCard ] [ Play ] [ Endless ]
```

- Basket lijevo od Play (P165).
- Endless desno / ispod Play kao P24, ali **samo visible u polju**.
- Karusel: Play ostaje (P175 ulaz u polje). Basket i Endless **hidden**.

## Što layout **ne** radi

- Ne premješta Daily ni Settings (ostaju gore).
- Ne dira hub pager.
- Ne mijenja flower count/slotove.

## Smoke (B)

`season_meadow_smoke`: nakon Bloom open, tint nije stisnut u stari Stage rect — npr. točka iza Daily ili Play nije `MainMenu/Background` tamnozelena. Close → stari bg. Jedan `SeasonField`. Frost tint ≠ Bloom.
