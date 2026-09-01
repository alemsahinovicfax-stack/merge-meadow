---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, leftover, grant, debug, playtest, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-field
  - ideje-arena-leftover-math
  - ideje-arena-leftover-pitanja
  - ideje-arena-leftover-grupe
  - plan-prompts-arena-leftover
  - ideje-arena-sort
ai_sažetak: "ARENA-02 debug grant — svaki debug play jednom prepisuje torbu na freeze 100 T1 (19/22/13/28/18); ne na Arena tab return; soft cap 40 ostaje."
---

# IDEJE — ARENA-02 debug grant (100 T1, 5 tipova)

> [[ideje-arena-leftover|hub]]. **LEFTOVER-D ✅.** Nije produkcijski loot. Nije D0 blocker.  
> Freeze: [[ideje-arena-leftover-pitanja|L26–L30]]. Overlay dismiss je [[ideje-arena-leftover-popup|C]], ne ovaj fajl.  
> **ARENA-03 nije 100 grant.** D freeze ostaje. Pour/vacuum: [[ideje-arena-sort|ARENA-03]].  
> **E nije 100 grant.** Field leftover T1 (Muncher vs ÷4): [[ideje-arena-leftover-field|field]] — E kod **ne**. Playtest sada vidi **100** (19/22/13/28/18). Ne spajati D i E.  
> Kod: [`apply_debug_leftover_test_bag`](../../game/scripts/autoload/game_state.gd); Arena `_deferred_boot` remen apply (nema min-10); [`grant_test_seeds.gd`](../../game/tools/grant_test_seeds.gd) ista mapa.

## Zašto ovaj grant postoji

Leftover overlay i ÷4 pour se **ne mogu** igrati očima ako torba ima 10 po tipu (sve ×2 ostatak 2, ali `ensure_dev` stalno diže ispod 10) ili 20/20/20/20/20 (sve ×4, overlay se pojavi tek kad igrač **potroši** do remaindera — sporo za C/D playtest).

Treba:

1. **100 T1** — dovoljno za više valova do cap 40, bez podizanja `SEED_BAG_SOFT_CAP`.
2. **5 tipova** — clover, daisy, buttercup, tulip, sunflower (isti unlock lanac kao današnji grant; `seed_unlock_index = 4`).
3. **Različiti brojevi** — ne 20/20/20/20/20. Mix **višekratnika 4** (da se može mergeati) i **remaindera 1–3** (da leftover overlay ima smisla nakon što se ×4 istrese).
4. **Isti svaki put** — F5 / `godot-run.ps1` / headless grant skripta daju **istu** torbu. Nije `randi()` na boot. Brojevi su „randomizirani jednom“ u docs freezeu, zatim konstanta.

Chat 2026-08-28: **svaki debug play prepisuje torbu**. Ne samo kad ručno pokreneš `grant_test_seeds.gd`.

## Što danas kvari leftover test

### `ensure_dev_unlocked_seeds(10)`

Arena [`_deferred_boot`](../../game/scripts/camp/merge_arena_controller.gd) zove ovo svaki put kad se Arena **instancira**. Funkcija **ne** overwritea. Za svaki otključani tip: ako `bag[type] < 10`, stavi 10.

Posljedice:

- Remainder clover 3 → **10** na sljedećem Arena bootu (nova instanca). Leftover overlay nestaje.
- Igrač namjerno spusti torbu da vidi `3/4` — debug ga „popravi“.
- Hub **obično** drži istu instancu, pa se ovo ne pali na tab return — ali F5 / standalone arena / reinstance **da**.

D **zamjenjuje** taj top-up: jednom po **processu** stavi freeze 100, i **prestane** min-10 dopunu na Arena boot.

### `grant_test_seeds.gd` = 5×20

Zbroj 100, ali svi tipovi `n % 4 == 0`. Nakon punog poura (do slota) remainder je 0. Overlay se vidi samo ako igrač **ne** istrese sve, ili ako pest/partial session ostavi bag. Loše za „otvori igru, odmah leftover“. Freeze tablica namjerno ima remainder po većini tipova.

### `_apply_debug_resources_if_new_game`

Samo kad **nema** `player_save.json`. Playtest već ima save — zato Arena boot zove `ensure_dev`. D i dalje treba **overwrite postojećeg save baga** na debug play, ne samo new-game.

## Freeze tablica (L28) — randomizirano jednom

Pet T1, zbroj **100**. Izabrano 2026-08-28 da leftover i pour budu vidljivi u **istom** bagu. Nije `RandomNumberGenerator` u runtimeu. Agenti **ne** re-rollaju.

| `type_id` | Count | Pour `floor(n/4)*4` | Remainder `n%4` | Zašto |
|-----------|------:|--------------------:|----------------:|-------|
| clover | **19** | 16 | 3 | Najveći leftover — overlay red `3/4` |
| daisy | **22** | 20 | 2 | `2/4` |
| buttercup | **13** | 12 | 1 | `1/4` — jedan do T3 |
| tulip | **28** | 28 | 0 | Čist ×4; nestaje iz stuck liste kad se sve istrese |
| sunflower | **18** | 16 | 2 | `2/4` |
| **Zbroj** | **100** | 92 | 8 | 92 ide na polje kroz valove (cap 40); 8 ostaje za overlay |

Nakon što igrač istrese sve ×4 (više valova, merge, Done između ili auto-refill 12): stuck bag ≈ clover 3, daisy 2, buttercup 1, sunflower 2. Tulip 0 se **ne** crta (L5). Overlay ima 4 reda + naslov **You need more seeds!**.

Mythic (pumpkin / watermelon) **nisu** u ovoj tablici. Unlock index ostaje 4. L3 pour pravilo za mythic ostaje u A, ne treba ih grantati za ovaj playtest.

## Kad se grant pali (L26)

```
DEBUG_DEV_RESOURCES == true
  → jednom po OS procesu, NAKON load savea
  → seed_bag = freeze mapa (overwrite, ne max())
  → seed_unlock_index = 4
  → tutorial_complete = true, tutorial_step = FREE
  → discovered_blooms za tih 5 tipova = true (kao grant_test_seeds)
  → save_player_save()
```

**Da:**

- Svaki F5 / `.\scripts\godot-run.ps1` / novi Godot play.
- Headless `grant_test_seeds.gd` — **ista** mapa, da CI i ručni grant ne divergiraju.

**Ne:**

- `set_arena_page_active(true)` — povratak Arena taba u **istom** playu.
- Svaki `_deferred_boot` ako je Arena re-instancirana u istom procesu **nakon** što je flag već true — drugi call **ne** smije vratiti 100 ako je igrač već mergeao (npr. otišao u kamp, skupio run loot, vratio se). Flag `_debug_leftover_bag_applied` (process-lifetime, nije save key).

Zašto ne na tab return: igrač overlay → Camp → run → loot T1 → Arena. Ako overwrite, loot nestane i leftover loop laže. Chat je rekao „svaki debug play“, ne „svaki ulazak u arenu“.

Produkcija: `DEBUG_DEV_RESOURCES == false` — nijedan overwrite, nijedan min-10. Store build mora imati flag **false** prije shipa (već postojeće pravilo; D ga ne mijenja osim što debug path postaje 100 umjesto 10).

## Soft cap 40 (L7 / L27)

`SEED_BAG_SOFT_CAP := 40` ostaje. `add_seeds_to_bag` i dalje soft-capa. Debug overwrite **smije** staviti 100 direktno u dict (kao današnji `grant_test_seeds`). Pour gleda **slotove polja** (40) + ÷4, ne cap torbe. UI vreće pokazuje zbroj 100. To je namjerno playtest.

Ne dizati cap na 100 „da grant bude legalan“ — to mijenja kamp ekonomiju.

## Što grant **nije**

- Nije wallet grant (combo coins, shop). Wallet ostaje što save kaže (osim postojećeg new-game `DEBUG_WALLET_COINS`).
- Nije Home 500c / 20 T3 (BARFIT).
- Nije `SAVE_VERSION` bump. Nema novog save polja za „debug bag applied“ — samo in-memory flag.
- Nije kanon `merge-arena-v1.1.md`.
- Nije zamjena za run loot u produkciji.
- Nije IAP pack „100 seeds“.

## Kod mapa (D ✅)

| Mjesto | D |
|--------|---|
| `game_state.gd` | `DEBUG_LEFTOVER_TEST_BAG`; `apply_debug_leftover_test_bag()` overwrite jednom po procesu (nakon load + new-game) |
| `merge_arena_controller.gd` `_deferred_boot` | Remen apply; **nema** `ensure_dev_unlocked_seeds(10)` |
| `grant_test_seeds.gd` | Ista freeze mapa |
| Produkcija | `DEBUG_DEV_RESOURCES` false = no-op |

`ensure_dev_unlocked_seeds` ostaje u GameState, Arena ga ne zove. Soft cap 40. Nema `SAVE_VERSION`.

## Smokes (LEFTOVER-D) ✅

`arena_leftover_d_smoke` + leftover_a/b/c + `grant_test_seeds` headless.

## Igračev debug loop (cilj)

```
F5 / godot-run
  → torba 100 (19/22/13/28/18)
  → Arena: pour ×4 valovi, merge do T3
  → remainder u torbi; tap vreće
  → You need more seeds! + n/4
  → tap → Camp (overlay se gasi — C)
  → run / chest; loot ostaje u ovoj sesiji
  → Arena tab: čist ekran, torba = remainder + loot (nije opet 100)
  → novi F5: opet 100 freeze
```

## Povezano

- [[ideje-arena-leftover-pitanja|L7 L26–L30]] · [[ideje-arena-leftover-popup|C hide]]  
- [[ideje-arena-leftover-field|field]] — E **nije** 100 grant  
- [[../06-production/plan-prompts-arena-leftover|LEFTOVER-D prompt]]
