---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, layout, chrome, scratch]
povezano:
  - ideje-home-chrome
  - ideje-home-chrome-pitanja
  - ideje-home-polish-layout
  - main_menu
ai_sažetak: "HOME-03 layout — HomeColumn: Pip, traka, Play, Play Endless; bez wordmarka, Endless labela i DifficultyRow."
---

# IDEJE — HOME-03 layout (chrome)

> [[ideje-home-chrome|HOME-03 hub]]. Scena: [`game/scenes/main_menu.tscn`](../../game/scenes/main_menu.tscn).

## Ciljni stupac (HomeColumn)

Odozgo prema dolje (chest/basket ostaju u `HomeTopStack`, **izvan** ovog stupca):

1. **PipPortrait** — ostaje, centriran, ~64px. Identitet umjesto wordmarka.
2. (nema `HomeTitle`)
3. Tagline i dalje **hidden** (već HOME-A).
4. TutorialHint — samo dok tutorial nije complete (postojeće).
5. **SeasonStage** — 3-slot, HIT-A hit-through, `size_flags_vertical` stretch.
6. **PlayButton** — label `"Play"`, uži min width ~540 (HOME-B).
7. **PlayThemeBadge** — samo mismatch paid ≠ strip (P43).
8. **EndlessPlayButton** — label `"Play Endless"`. Nema parent VBox s naslovom. Nema DifficultyRow.
9. Safe area bottom na koloni — postojeće.

## Što ukloniti / sakriti

| Node danas | CHROME-A |
|------------|----------|
| `%HomeTitle` "Merge Meadow" | `visible = false` **ili** brisanje nodea + null-safe u `main_menu.gd` (`_setup_typography`) |
| `%EndlessSection` VBox + `EndlessTitle` | Flatten: `EndlessPlayButton` direktno child `HomeColumn` (kao Play) **ili** ostaviti VBox bez title/row |
| `DifficultyRow` Easy/Normal/Hard | Obrisati nodeove + disconnect u gd |
| `%EasyButton` / `%NormalButton` / `%HardButton` | Nestaju |

Preferencija implementacije: **obrisati** dead nodeove (ne ostavljati hidden Easy) da smoke ne nađe lažni picker. `home_title` u skripti: `get_node_or_null` / `if home_title`.

## Dva gumba — vizual

- Isti stil: `UiClickButton`, primary, Play ikona na campaign, Endless smije isti ili `play` ikona.
- Ista širina kao Play (`custom_minimum_size.x` 540, `size_flags_horizontal` shrink center).
- Vertikalni razmak `HomeColumn` separation 12 — bez ekstra "Endless" caption.

Copy EN: **Play** / **Play Endless**. Ne "Endless mode". Ne "Hard" na gumbu (teškoća je implicitna; HUD u runu smije reći Hard — vidi endless doc).

## Tutorial (P44)

`endless_section.visible = hub` danas. Nakon flatten: `endless_play_button.visible = GameState.tutorial_complete`. Campaign **Play** ostaje vidljiv (postojeće tutorial ponašanje — ne dirati F6 flow osim ako gumb path pukne).

## Što ne pomicati

- Settings (gore desno).
- Daily chest / basket (`HomeTopStack`).
- Season strip veličine P22.
- Hub `SwipePager` stranice.
- `HomeColumn.mouse_filter = IGNORE` (HOME-A); `block_hub_swipe` samo Stage.

## Vertikalni zrak

Brisanje title + difficulty **oslobađa** visinu — traka smije rasti (`size_flags_vertical = 3` već). Ne smanjivati Play da popuni rupu; ne gurati Play iznad trake.

## Smokes / alati

Grep `EasyButton`, `EndlessTitle`, `DifficultyRow`, `_on_easy_pressed`. Ažurirati:

- `main_menu.gd` handleri i `_refresh_difficulty_selection` — ukloniti ili no-op.
- Bilo koji screenshot tool koji bira Normal — postaviti HARD ili ignorirati.

`season_home_smoke` ne mora assertati Easy; smije assertati da DifficultyRow **nema**.

## Povezano

- [[ideje-home-polish-layout|HOME-01 layout]] — P18 default je bio Pip+title; HOME-03 to siječe.
- [[ideje-home-chrome-endless|endless]]
