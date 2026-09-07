---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, layout, scratch]
povezano:
  - ideje-home-meadow-dock
  - ideje-home-meadow-dock-pitanja
  - ideje-home-meadow-life-layout
  - ideje-home-meadow-chrome-layout
  - plan-prompts-home-meadow-dock
ai_sažetak: "HOME-15 C ✅ — Basket 336×104 ispod Daily; Seasons 320×96 u PlayRow; chip ne zatvara polje; safe_rect + Basket."
---

# IDEJE — HOME-15 layout (Basket / Seasons / chip)

> [[ideje-home-meadow-dock|hub]] · freeze P197–P200, P205, P211–P213.  
> **Kod:** **DOCK-C ✅**. Ne picker overlay (A). Ne T3 plant_tier (B). Ne Daily streak (D).

## Danas (nakon C)

[`main_menu.tscn`](../../game/scenes/main_menu.tscn): `%BasketCard` u `HomeTopStack` ispod Daily, **336×104**. PlayRow: `%SeasonsRowButton` | Play | Endless (320×96). `%SeasonNameChip` `mouse_filter` IGNORE — ne close. `%SeasonsButton` na SeasonField UniqueName hidden. `HomeColumn` `offset_top = 380`.

`meadow_safe_rect` chrome: Daily, **BasketCard**, Settings, chip, PlayRow.

## C — layout ✅

1. Premjesti `%BasketCard` u `HomeTopStack` **ispod** Daily. `custom_minimum_size` **336×104** (kao Daily). Visible samo `home_season_field_open`. Karusel hidden (P164).
2. PlayRow: novo `%SeasonsRowButton` (label **Seasons**, 320×96, isti flags kao Play/Endless) **lijevo od Play**. Endless ostaje desno. Tap Seasons → `close_season_field`. Karusel: Seasons hidden.
3. Stari `%SeasonsButton` na SeasonField ostaje UniqueName **hidden**.
4. `%SeasonNameChip`: ime ostaje; **ne** close (`mouse_filter` IGNORE ili disconnect `clicked`). P174 Back/Escape ostaje.
5. `HomeColumn` `offset_top` podići da Daily + Basket + razmak ne preklope polje.
6. `meadow_safe_rect`: dodaj `%BasketCard` u chrome listu (P205). Pip FSM ne dirati.

Ne duplicirati Basket. Ne mijenjati Endless Hard/tema.

## Smoke (P211–P213) ✅

[`season_meadow_smoke.gd`](../../game/scripts/dev/season_meadow_smoke.gd) (+ home smoke karusel):

- Field open: Basket global y ispod Daily; size ~336×104; Basket **nije** dijete PlayRow.
- `%SeasonsRowButton` visible; emit clicked → field close. Chip clicked **ne** close. Karusel: Seasons hidden. SeasonField `%SeasonsButton` hidden.
- `_assert_play_row_equal`: Seasons / Play / Endless ista min size — **ne** BasketCard.

## Acceptance

- Basket izgleda kao drugi Daily, ispod njega, gore lijevo.
- Donji red: Seasons | Play | Endless, jednaki.
- Ime sezone se vidi, ali ne vraća na karusel; to radi Seasons.
