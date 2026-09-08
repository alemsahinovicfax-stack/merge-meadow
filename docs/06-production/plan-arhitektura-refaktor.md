---
type: produkcija
status: zatvoreno
milestone: —
tags: [produkcija, arhitektura, refaktor, gamestate, testing]
povezano:
  - CHECKPOINT
  - scope-i-granice
ai_sažetak: "Kod arhitektura refaktor — ZAVRŠEN (2026-09-08). GameState pun split po domenama u 8 etapa, GUT testing, SaveManager thin-out, season/home naming, dev-only izolacija. game_state.gd 2987→1898 linija."
---

# Plan — kod arhitektura refaktor

> **Status: REFAKTOR ZAVRŠEN** (2026-09-08) — svih 8 etapa gotovo, `ba89cc5` je zadnji commit. CAMP-06 je bio preduvjet, gotov i committan (`7b010d7`). Prva verzija ovog doca (2026-09-07) je pretpostavljala "pun domain split u jednom prolazu"; nakon detaljnog remapiranja `game_state.gd` (2026-09-07, drugi prolaz) ispalo je da je to previše rizično bez testova (430 poziva iz 38 fajlova, nula signala, jedna 150-linijska `_apply_save_dict` koja dira ~35 varijabli). Ovaj doc opisuje **8 malih, samostalno-shippable etapa** koje su vodile do istog odobrenog cilja — sve su isporučene.
>
> **Napredak:** Stage 0 ✅ (`abd9743`) · Stage 1 ✅ (`c25a191`) · Stage 2 ✅ (`79f4523`) · Stage 3 ✅ (`83d2abd`, Cosmetics+Boosters ekstraktovani) · Stage 4.1 ✅ (`134c034`, Companions) · Stage 4.2 ✅ (`77ec067`, Tutorial) · Stage 4.3 ✅ (`39589eb`, Seed bag) · Stage 4.4 ✅ (`4822da0` + `af1f57b`, Garden beds — vidi napomenu ispod) · Stage 4.5 ✅ (`f79d8f0`, Crystal stash) · Stage 4.6 ✅ (`c2f3641` dead-code prep + `dc0fff4` extrakcija, Bloom inbox) · Stage 4.7 ✅ (`9687d8e`, Arena — 152 poziva) · Stage 4.8 ✅ (`901fb7e`, Seasons — najveći blast radius, 71 poziva) · **Stage 4 gotov (svih 8 domena)** · Stage 5 ✅ (`6652aae`, SaveManager thin-out) · Stage 6 ✅ (`5d01945`, naming konsolidacija) · **Stage 7 ✅ (`ba89cc5`, dev-only izolacija) — SVE ETAPE GOTOVE.** Usput nađen i **prijavljen (ne popravljen)** pre-postojeći bug: `shop_nav_smoke.gd` puca sa "Identifier not found: SceneRouter" — potvrđeno da postoji i prije refaktora, nije regresija.
>
> `game_state.gd`: **2987 → 1898 linija** (-36%) nakon Stage 4.1-7 (Stage 6 je čist rename, bez promjene linija). 8 domenskih klasa ekstraktovano u `game/scripts/economy/` (cosmetics, boosters, companions, tutorial, seed_bag_domain, crystal_stash, bloom_inbox, arena, seasons — 9 fajlova, Boosters+Cosmetics su Stage 3) plus `game/scripts/autoload/save_migrations.gd` (Stage 5) i `game/scripts/autoload/game_state_debug.gd` (Stage 7).
>
> **Stage 7 napomena (2026-09-08, zadnja etapa):** Svi `debug_*`/`DEBUG_*` fixture-i i konstante → `game/scripts/autoload/game_state_debug.gd` (`GameStateDebug`), dosljedno iza `OS.is_debug_build()`/`DEBUG_DEV_RESOURCES`. `apply_debug_leftover_test_bag()`/`_try_apply_debug_leftover_test_bag()` facade-i ostaju jer ih zove produkcijski kod (`merge_arena_controller.gd`-ov ARENA-02 leftover playtest) i nekoliko dev smoke skripti preko `gs.call(...)` po imenu. `_remap_seed_bag_to_season()` je otišao s njima — jedini pozivalac je `debug_fixture_s1_star3_playtest`. Dva propusta uhvaćena smoke-testom prije nego što su stigla do commita: (1) `grant_unlock_test_funds()` je koristio `:=` na tri vrijednosti pročitane kroz netipizirani `_owner: Variant` — GDScript ne može inferisati tip iz Variant poziva, cijeli fajl nije parsirao; popravljeno eksplicitnim tipovima. (2) `arena_leftover_d_smoke.gd` i `game/tools/grant_test_seeds.gd` resetuju one-shot apply flag po imenu (`gs.set("_debug_leftover_bag_applied", false)`) — pošto je flag preselio u `GameStateDebug`, taj dynamic set je tiho postajao no-op (`Object.set()` na nepostojeće ime ne baca grešku), pa "first apply" test nije prošao na drugom pokretanju istog procesa; popravljeno property shim-om (isti pattern kao svako drugo ekstraktovano polje). GUT 33/33 + svih 17 arena/merge_arena smoke skripti + 7 season/strip/home-basket smoke skripti + `camp_donate_smoke`/`save_persistence_smoke` zeleno prije i poslije, uključujući ponovnu verifikaciju `arena_leftover_d_smoke` nakon flag-shim fixa.
>
> **Stage 5 napomena (2026-09-08):** `_apply_save_dict()`/`save_player_save()` su sad čisti per-domain dispatcheri — svaka od 5 preostalih ekstraktovanih domena (seed_bag, crystal_stash, bloom_inbox, arena, seasons) dobila je svoj `apply_from_save()`/`to_save_dict()` preko `SaveDictUtils` (cosmetics/boosters/companions/tutorial su to već imali od Stage 3/4). Dvije strukturne migracije (`_drop_retired_seed_keys`, `_migrate_legacy_beds_to_inbox`) preselile u `game/scripts/autoload/save_migrations.gd` (`SaveMigrations`) — čist code-motion, isti pozivi na istim mjestima. `SAVE_VERSION` ostaje na `GameState`. Verifikovano protiv `test_game_state_save_migration.gd` — 7 karakterizacionih testova napisanih baš da dokažu da ova etapa ništa ne mijenja — svih 7 zeleno, plus GUT 33/33 + 9 save/load-osjetljivih smoke skripti.
>
> **Stage 4.8 napomena (2026-09-08):** Seasons je najveći preostali domen (season_stage.gd samo 71 poziva). Free/paid unlock state, star3-flower unlock cost, i home/strip navigacija → `game/scripts/economy/seasons.gd` (`SeasonsDomain`). `debug_unlock_all_seasons`/`debug_grant_unlock_test_funds`/`debug_playtest_two_free`/`debug_relock_playtest_free`/`debug_fixture_s1_star3_playtest`/`_remap_seed_bag_to_season` namjerno ostaju na `GameState` — Stage 7 teritorija (fizički file-move), rade nepromijenjeno preko istih property/facade imena. `get_unlocked_loadout_types_for_season`/`get_active_season_spawn_types`/`is_loadout_in_active_season_pool` takođe ostaju — seed-unlock/spawn-pool utility, ne season-progression state. GUT 33/33 + svih 7 season/strip/home-basket smoke skripti + `save_persistence_smoke`/`camp_donate_smoke` zeleno prije i poslije.
>
> **Stage 4.7 napomena (2026-09-08):** Arena je bila najviše cross-domain-spregnuta domena dosad (Economy preko `_add_coins`, seed_bag preko `take_seed_from_bag`/`add_seeds_to_bag`, crystal_stash preko `stash_garden_crystal`, tutorial preko `notify_merge_completed`). `ARENA_MAX_CHIPS`/`ARENA_SNAP_DISTANCE`/`ARENA_MAGNET_RADIUS`/`ARENA_PEST_*` ostaju na `GameState` (čitaju se direktno kao `GameState.ARENA_*` iz `merge_arena_controller.gd`/`arena_pest.gd`) — nisu ekstraktovani, isti princip kao Garden beds' migration landing-pad. `_compare_seed_pour_priority`/`get_bag_types_by_pour_priority` ostaju takođe — dijeljena sortirajuća utility i za `crystal_stash.gd`, nije Arena-ekskluzivna. GUT 33/33 + svih 17 arena/merge_arena smoke skripti + `save_persistence_smoke`/`camp_donate_smoke` zeleno prije i poslije.
>
> **Stage 4.4 napomena (2026-09-07):** Garden beds nije ekstraktovan kao domena — pokazalo se da je cijeli `garden_beds`/`greenhouse_beds` bed-merge API (~20 funkcija, ~180 linija: `plant_seed_in_bed`, `try_merge_beds`, `keep_bloom_from_bed`, `bed_is_empty`, `get_bed_type/tier`, `count_flowers_tier`, `empty_garden_beds`, `resolve_plant_type`, itd.) **mrtav kod** — prežitak pred-Arena prototipa, bez ijednog pozivaoca iz `merge_arena_controller.gd` ili bilo kojeg drugog ekrana. Obrisano umjesto ekstraktovano. `garden_beds`/`greenhouse_beds` nizovi + `_bed_array`/`_serialize_beds`/`_deserialize_beds`/`_migrate_legacy_beds_to_inbox` ostaju — i dalje služe kao landing pad za migraciju starih save-ova (`SAVE_VERSION` < 12). GUT 33/33 + `save_persistence_smoke`/`camp_donate_smoke` zeleno prije i poslije.
>
> **2026-09-07, van etapa:** `apply_debug_leftover_test_bag()`/`ensure_dev_unlocked_seeds()` guard popravljen (`DEBUG_DEV_RESOURCES` konstanta → `OS.is_debug_build()`) — bio je flipnut na `false` u `7b010d7` (CAMP-06 commit), pa su `arena_leftover_d_smoke` i `arena_leftover_b_smoke` (potonji: stara pretpostavka o alfabetskom sortu, ne guard) popravljeni izolovano od Stage 7. Stage 7 sad je samo fizički file-move.

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
1. ✅ Companions — čita magnet/multiplier, ne piše tuđe stanje (`134c034`)
2. ✅ Tutorial — run lifecycle (`77ec067`)
3. ✅ Seed bag — razbacano bilo ~1262, 1527, 1911, 2251 (`39589eb`)
4. ✅ Garden beds — ispalo mrtav kod, obrisan umjesto ekstraktovan (vidi napomenu gore, 2026-09-07)
5. ✅ Crystal stash → `game/scripts/economy/crystal_stash.gd` (`f79d8f0`)
6. ✅ Bloom inbox → `game/scripts/economy/bloom_inbox.gd` (`dc0fff4`) — potvrđeno: per-item donate/keep/basket dizajn (`donate_bloom_inbox`, `basket_bloom_inbox`, `BloomInboxItem`) bio mrtav kod, zamijenjen CAMP-01 B redizajnom (`flush_bloom_inbox_to_album()` auto-keep). Obrisano u `c2f3641` prije ekstrakcije.
7. ✅ Arena → `game/scripts/economy/arena.gd` (`9687d8e`) — 152 poziva iz camp/
8. ✅ Seasons → `game/scripts/economy/seasons.gd` (`901fb7e`) — najveći, 71 poziva

### Stage 5 — SaveManager thin-out
`_apply_save_dict` postaje dispatcher (`economy.apply_from_save(data)`, `seasons.apply_from_save(data)`, …). Dvije strukturne migracije sele u `game/scripts/autoload/save_migrations.gd`, pokreću se prije dispatch-a domenama. `SAVE_VERSION` ostaje na `GameState`.

### Stage 6 — Season/home naming konsolidacija ✅ (`5d01945`)
Nakon što je Seasons svoja klasa: kanon = **"Season"** kao jedini content-noun (najmanje disruptivno, `SeasonDef`/`SeasonCatalog`/`SeasonTheme`/`SeasonCardContrast` već konzistentni). `strip_focus_id` → `focus_season_id` ✅ (save-dict ključ ostaje `"strip_focus_id"` — save kompatibilnost; `paid_strip_focus_id` namjerno netaknut, doc imenuje samo ovo polje). "Field" sudar (`SeasonField`'s meadow vs. `season_stage`'s overlay) riješen ✅ preimenovanjem dekorativnog widgeta na `meadow_ground`/`_meadow_bounds()` (+ scene node `FieldGround` → `MeadowGround`). `camp_controller.gd`'s `top_strip` → **`header_panel`** ✅ (ne `top_bar` kako je doc doslovno predložio — `camp_scene.tscn` već ima nevezan child node legitimno nazvan "TopBar" (dugme-red ugniježđen unutar ovog kontejnera), pa bi ponovna upotreba tog imena za vanjski kontejner zamijenila jedan sudar imena gorim (roditelj i dijete dijele ime); `header_panel` zadržava stvarnu namjeru — prestati koristiti "strip" za nevezani layout chrome).

### Stage 7 — Dev-only izolacija ✅ (`ba89cc5`)
`debug_*`/`DEBUG_*` → `game/scripts/autoload/game_state_debug.gd` (`GameStateDebug`), konzistentno iza `OS.is_debug_build()`. Guard fix (`apply_debug_leftover_test_bag()` i `ensure_dev_unlocked_seeds()` gate) urađen prije samog Stage 7-a, 2026-09-07 — vidi napomenu gore. Vidi Stage 7 napomenu iznad za dva propusta uhvaćena i popravljena prije commita.

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
