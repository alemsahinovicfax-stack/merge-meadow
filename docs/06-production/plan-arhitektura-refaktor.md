---
type: produkcija
status: aktivan
milestone: —
tags: [produkcija, arhitektura, refaktor, gamestate, testing]
povezano:
  - CHECKPOINT
  - scope-i-granice
ai_sažetak: "Kod arhitektura refaktor — nakon CAMP-06. GameState pun split po domenama, GUT testing, season/home naming, sitni cleanup. Napisano, ne izvršeno."
---

# Plan — kod arhitektura refaktor (poslije CAMP-06)

> **Status:** napisano kao roadmap 2026-09-07, **nije izvršeno**. Pokreni tek kad je CAMP-06 gotov i committan — ne miješaj sa aktivnim feature radom.

## Kontekst

Tri Explore agenta su 2026-09-07 mapirala `game/` arhitekturu za potrebe šireg docs+kod reorga. Nalazi:

- **`game/scripts/autoload/game_state.gd` je 2,987-linijski god object** — pokriva save/load+migraciju, wallet, seed bag, garden/greenhouse ekonomiju, magnet/multiplier upgrade, crystal stash, bloom inbox, cosmetics, boosters, companions, tutorial state, daily chest, arena-daily-task, arena combo coins, merge-arena chip pour/merge/leftover, seed-unlock chain + almanac, i **cijeli** season/home navigacijski model (unlock, strip cycling, paid grants, home-band, IAP-lock). Barem 6-8 odvojenih domena u jednoj klasi.
- **Naming sprawl oko "koji sezonski sadržaj je prikazan/odabran"**: `season` (podaci/`SeasonDef`/`SeasonCatalog`), `meadow` (`season_meadow_smoke.gd`, `_apply_meadow_tint()`), `field` (`season_field.gd`, `home_season_field_id`), `home`/`strip`/`band` (`strip_focus_id`, `home_band`, `cycle_free_strip`). Dva fajla imaju header komentare "IGNORE; not an arena chip" / "IGNORE; FSM lives on SeasonField" — dokaz da je autor morao ostaviti disambiguation napomene za sebe.
- **Nema pravog test frameworka** — samo 44 ručna `extends SceneTree` smoke skripta u `scripts/dev/` (7,572 linija), svaki reimplementira `_fail`/`quit`/manual `await process_frame` petlje, poziva `GameState` preko stringly-typed `.get()/.set()/.call()`.
- **Duplicirani UI pattern**: `seed_bag_chip.gd`/`seed_bag_icon.gd` (garden trade) i `crystal_stash_chip.gd`/`crystal_stash_icon.gd` (crystal exchange) su strukturno paralelni "chip + icon" parovi.
- `scripts/progression/` ima samo 1 fajl (49 linija, `seed_unlock_config.gd`) — cijeli folder za jedan mali config.
- `run_level_library.gd` je autoload, `season_catalog.gd` (identičan lazy-JSON-catalog pattern) nije — nekonzistentan tretman.
- `game/tools/` i `scripts/dev/` su dvije odvojene dev-tooling lokacije bez jasnog pravila kad koristiti koju.
- Debug-only funkcije (`debug_unlock_all_seasons()`, `debug_grant_unlock_test_funds()`, itd.) su trajno kompajlirane u `GameState` — nisu izolovane u zaseban dev modul.

Korisnik je odlučio (2026-09-07): **pun domain split** GameState-a (ne lagani touch), i **adopcija GUT-a** (Godot Unit Testing) umjesto konsolidacije smoke skripti.

## Scope refaktora

### 1. GameState pun domain split

Razdvoji `game_state.gd` u zasebne klase koje `GameState` (autoload) sastavlja kao fasada:

- `Economy` — wallet (coins/diamonds), seed bag, garden/greenhouse ekonomija
- `Seasons` — unlock/select/strip navigacija, home-band, paid-grant, IAP-lock (trenutno najveći dio god objecta)
- `Arena` — merge-arena chip pour/merge/leftover, combo coins, daily task
- `Cosmetics` / `Boosters` — cosmetics catalog, booster consumables, companions
- `Tutorial` — tutorial flags, onboarding state
- `SaveManager` — serialize/deserialize/migracija (`SAVE_VERSION` logika mora ostati **identična** ponašajno — ovo je najrizičniji dio, testiraj migraciju sa starim save fajlom prije/poslije)

**Sigurnosna mreža prije refaktora:** prvo portuj smoke testove koji pokrivaju domenu koja se dijeli (vidi #3) na GUT, pa tek onda dijeli tu domenu — ne obrnuto.

### 2. Season/home naming konsolidacija

Preko `scripts/ui/season_*`, `camp/season_link_card.gd`, i season-related smoke testova — odaberi kanonske termine (npr. `Season` = sadržaj/identitet paketa, `Home` = ekran koji ga prikazuje) i preimenuj sistematski. Ukloni ili jasno omeđi ad-hoc žargon ("meadow"/"field"/"strip"/"band"). Ovo dotiče ~14 fajlova u `scripts/ui/` (najveći koncentrisani sprawl u projektu).

### 3. Adopcija GUT-a

1. Instaliraj GUT addon (`addons/gut`)
2. Portuj smoke testove koji pokrivaju domene iz #1 prve (safety net za refaktor)
3. Migriraj ostale opurtunistički
4. Prestani pisati nove bare `extends SceneTree` smoke skripte nakon ovoga

### 4. Sitniji cleanup (isti prolaz)

- Zajednička chip/icon base klasa za `seed_bag_chip/icon` + `crystal_stash_chip/icon`
- Spoji `scripts/progression/` (1 fajl) u `scripts/seasons/`
- Uskladi `run_level_library.gd` vs `season_catalog.gd` autoload-vs-static konvenciju
- Uskladi `game/tools/` vs `scripts/dev/` (dvije dev-tooling lokacije)
- Izmjesti `debug_*` funkcije iz shipped `GameState` klase (izolovati iza `OS.is_debug_build()` konzistentno ili u zaseban dev-only fajl)

## Redoslijed izvršenja

1. CAMP-06 gotov + committan (preduvjet — ne miješati sa aktivnim feature radom)
2. GUT instalacija + prvi testovi za domene koje se dijele
3. GameState split, domena po domena, sa GUT regresijom nakon svake
4. Season/home naming pass
5. Sitniji cleanup (#4)

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[scope-i-granice|scope-i-granice]]
