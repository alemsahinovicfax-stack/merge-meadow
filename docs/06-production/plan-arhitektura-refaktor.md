---
type: produkcija
status: aktivan
milestone: —
tags: [produkcija, arhitektura, refaktor, gamestate, testing]
povezano:
  - CHECKPOINT
  - scope-i-granice
ai_sažetak: "Kod arhitektura refaktor — u toku. GameState pun split po domenama u 8 sigurnih etapa, GUT testing, season/home naming, sitni cleanup. Stage 0/1 aktivni."
---

# Plan — kod arhitektura refaktor

> **Status:** CAMP-06 je gotov i committan (`7b010d7`) — preduvjet ispunjen, refaktor je **u toku**. Prva verzija ovog doca (2026-09-07) je pretpostavljala "pun domain split u jednom prolazu"; nakon detaljnog remapiranja `game_state.gd` (2026-09-07, drugi prolaz) ispalo je da je to previše rizično bez testova (430 poziva iz 38 fajlova, nula signala, jedna 150-linijska `_apply_save_dict` koja dira ~35 varijabli). Ovaj doc sad opisuje **8 malih, samostalno-shippable etapa** koje vode do istog odobrenog cilja.
>
> **Napredak:** Stage 0 ✅ (`abd9743`) · Stage 1 ✅ (`c25a191`) · Stage 2 ✅ (`79f4523`) · Stage 3 ✅ (`83d2abd`, Cosmetics+Boosters ekstraktovani) · Stage 4-7 preostaju. Usput nađen i **prijavljen (ne popravljen)** pre-postojeći bug: `shop_nav_smoke.gd` puca sa "Identifier not found: SceneRouter" — potvrđeno da postoji i prije refaktora, nije regresija.

## Trenutno stanje `game_state.gd` (izmjereno 2026-09-07, post-CAMP-06)

- **2,987 linija** (poraslo +148 od CAMP-06/HOME-15…18/star-3-hub serije; prije toga 2,839).
- **430 `GameState.` poziva u 38 fajlova.** Najveći "blast radius": `ui/season_stage.gd` (71), `camp/camp_controller.gd` (59), `camp/merge_arena_controller.gd` (59).
- **Nula signala** — sve je poll-based (caller čita getter poslije mutatora). Pojednostavljuje split (nema pub/sub shim-a), ali ništa ne prisiljava čitanje kroz accessor.
- **Nema domenskih granica danas** — crystal-stash funkcije žive na liniji 1571 I 2724-2799; garden-bed funkcije razbacane 1962-2317; seed-bag funkcije na ~1262, 1527, 1911, 2251. Ekstrakcija mora skupljati po identifikatoru, ne po kontinuiranom range-u.
- **Cross-domain coupling je svuda i bez indirekcije**: `wallet_coins` i `garden_crystal_stash` se direktno mijenjaju (`+=`/dict write) iz Arena, Seasons-debug, Garden-bed, Bloom-inbox i Seed-bag koda — nigdje ne postoji `Economy.add_coins()`/`try_spend_coins()`. Isto za `magnet_level`/`multiplier_level`/`*_donations` iz Garden-bed i Bloom-inbox donate flowova.
- **`_apply_save_dict()` (linija 836)** je jedna ~150-linijska funkcija koja popunjava ~35 varijabli iz svih domena — nema odvojenih `_migrate_v1_to_v2()` koraka, samo inline `.get(key, default)` fallback-ovi + dvije strukturne migracije (`_migrate_legacy_beds_to_inbox()`, `_drop_retired_seed_keys()`) koje dirinu 3-4 domene odjednom. `SAVE_VERSION = 12`.
- Season-naming sprawl potvrđen konkretno: `game_state.gd` sam koristi 4 različita korijena riječi za "koji paket je fokusiran" — `season` (`active_season_id`), `strip` (`strip_focus_id`, `cycle_free_strip`), `band` (`home_band`), `home_season_field` (open-overlay flag). `season_stage.gd` dodatno koristi "field" za DRUGU stvar (open overlay) nego `season_field.gd`-ov "field"/"meadow" (dekorativna cvjetna scena) — pravi sukob istog imena za različit koncept, plus `camp_controller.gd`-ov `top_strip` (nevezani layout chrome) koji se sudara sa carousel "strip" terminom.

## 8 etapa (izvršavaj redom, jedan commit po etapi)

### Stage 0 — GUT setup + karakterizacioni testovi
Korisnik instalira GUT preko Godot AssetLib (detaljni koraci dati direktno korisniku u chatu 2026-09-07). Agent scaffold-a `game/test/unit/`, `game/.gutconfig.json`, `scripts/gut-run.ps1`, i piše karakterizacione testove za najrizičnije GameState ponašanje (save/load round-trip, wallet add/spend, seed-bag add/take/capacity, `_migrate_legacy_beds_to_inbox`) PRIJE bilo kakve izmjene produkcijskog koda. Fallback bez GUT-a: koristi postojeće `scripts/dev/*_smoke.gd` kao mrežu.

### Stage 1 — Economy indirekcija (bez file split-a)
Dodaj `_add_coins()`/`_try_spend_coins()` unutar `game_state.gd`, migriraj sve direktne `wallet_coins +=/-=` pozive (`try_grant_arena_combo_coins` ~1990, `claim_daily_chest` ~2003, `exchange_seeds_from_bag` ~2289, `exchange_garden_crystal` ~2768, `resolve_arena_leftover_bloom` ~2848, `debug_grant_unlock_test_funds` ~702) da idu kroz njih. Nula eksternih call-site promjena.

### Stage 2 — Upgrades indirekcija (magnet/multiplier donations)
Isti pattern za `donate_bloom_from_bed` (~2302), `donate_crystal_from_bed` (~2398), `donate_bloom` (~2545) — dodaj `_donate_toward_magnet()`/`_donate_toward_multiplier()`.

### Stage 3 — Ekstraktuj Cosmetics + Boosters (najmanji blast radius)
`owned_cosmetics`/`equipped_cosmetics` (2868-2918) → `game/scripts/economy/cosmetics.gd` kao `GameState.cosmetics`. `booster_inventory`/`merge_hint_booster_active` (2920-2987) → `game/scripts/economy/boosters.gd` kao `GameState.boosters`. Facade-forward sa istim imenima funkcija na `GameState` (ne breaking rename još). Svaka nova klasa dobija svoj `apply_from_save()`/`to_save_dict()`.

### Stage 4 — Ostale domene, po redoslijedu rizika (isti pattern kao Stage 3)
1. Companions (2437-2495) — čita magnet/multiplier, ne piše tuđe stanje
2. Tutorial (1048-1054 + run lifecycle ~1701-1909)
3. Seed bag (razbacano ~1262, 1527, 1911, 2251 — skupi prvo)
4. Garden beds (2100-2317, 1962-1997)
5. Crystal stash (2724-2799 + ~1571)
6. Bloom inbox (2521-2637)
7. Arena (1984-1997, 2640-2865) — 152 poziva iz camp/
8. Seasons (278-789) — najveći, najviše poziva (season_stage.gd = 71), radi zadnje

### Stage 5 — SaveManager thin-out
`_apply_save_dict` postaje dispatcher (`economy.apply_from_save(data)`, `seasons.apply_from_save(data)`, …). Dvije strukturne migracije sele u `game/scripts/autoload/save_migrations.gd`, pokreću se prije dispatch-a domenama. `SAVE_VERSION` ostaje na `GameState`.

### Stage 6 — Season/home naming konsolidacija
Nakon što je Seasons svoja klasa: kanon = **"Season"** kao jedini content-noun (najmanje disruptivno, `SeasonDef`/`SeasonCatalog`/`SeasonTheme`/`SeasonCardContrast` već konzistentni). `strip_focus_id` → `focus_season_id`, riješi "field" sudar (`SeasonField`'s meadow vs. `season_stage`'s overlay) preimenovanjem dekorativnog widgeta na `meadow_ground`/`_meadow_bounds()`. `camp_controller.gd`'s `top_strip` → `top_bar`.

### Stage 7 — Dev-only izolacija
`debug_*`/`DEBUG_*` (674-789, 1001-1046, konstante 79-114) → `game/scripts/autoload/game_state_debug.gd`, konzistentno iza `OS.is_debug_build()` (fix: `apply_debug_leftover_test_bag()` i `ensure_dev_unlocked_seeds()` trenutno nemaju runtime guard, samo `DEBUG_DEV_RESOURCES == false` konstantu).

## Sitniji cleanup (usput, ne zaseban stage)

- Zajednička chip/icon base klasa za `seed_bag_chip/icon` + `crystal_stash_chip/icon`
- Spoji `scripts/progression/` (1 fajl) u `scripts/seasons/`
- Uskladi `run_level_library.gd` vs `season_catalog.gd` autoload-vs-static konvenciju
- Uskladi `game/tools/` vs `scripts/dev/` (dvije dev-tooling lokacije)

## Verifikacija (poslije svake etape)

- GUT suite (ili postojeći smoke skripti ako je GUT odgođen) — zeleno prije i poslije
- 5-min ručni playtest poslije Stage 1/2 posebno (dodiruju money-granting kod puteve)
- `git status`/`git diff` pregled prije commita — jedan commit po etapi

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[scope-i-granice|scope-i-granice]]
