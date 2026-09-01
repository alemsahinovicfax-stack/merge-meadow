---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, nav, scratch]
povezano:
  - ideje-home-meadow-chrome
  - ideje-home-meadow-chrome-pitanja
  - ideje-home-meadow-shell
  - plan-prompts-home-meadow-chrome
ai_sažetak: "HOME-13 E — natrag name chip (display name); system Back; SeasonsButton UniqueName hidden."
---

# IDEJE — HOME-13 nav (natrag na karusel)

> [[ideje-home-meadow-chrome|hub]] · freeze P172–P174.  
> **Kod:** **CHROME-E ✅** 2026-09-01. Hook ostaje `close_season_field`.

## Zašto ne Seasons gumb

`%SeasonsButton` je `UiClickButton` top-center na cvijeću — izgleda kao CTA usred svijeta, ne kao „natrag / promijeni sezonu“.

## Freeze: name chip

- Mali control gore (npr. `%SeasonNameChip`), **ne** puni secondary panel.
- Tekst = display name `home_season_field_id` (Country Bloom, Frost Orchard, …).
- Tap → `close_season_field` (isti sync kao danas: flag off, BandColumn show, flowers dismiss).
- Daily ostaje gore-lijevo; Settings gore-desno — chip **ne** prekriva Daily.

## System back

Android / Godot `go_back` / `_unhandled_input` KEY_ESCAPE: ako je polje open → close, **ne** izlaz iz hub stranice. Swipe L/R i dalje nije Back (P148).

## `%SeasonsButton`

UniqueName ostaje (postojeći meadow smoke traži node). `visible = false`; label prazan. Ne povezivati `clicked` na close (chip + Back rade posao). CAMP2-A analogija.

## Alternativa (samo ako korisnik kaže)

Chevron pored Settings, isti hook. Ne dokumentirati kao default.

## Što E **ne** radi

- Home tab ≠ Back. Nema swipe-down close u v1 ovog tracka. Nema Browser gumba u meadowu.

## Smoke

Open → SeasonsButton not visible (node postoji); name chip visible s imenom sezone; tap chip **ili** close API → karusel. Frost open → chip tekst ≠ Bloom.
