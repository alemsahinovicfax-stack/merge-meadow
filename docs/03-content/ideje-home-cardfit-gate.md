---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-cardfit
  - ideje-home-cardfit-pitanja
  - ideje-home-incard-gate
  - ideje-home-unlock-gate
ai_sažetak: "HOME-09 gate — Amber skinut s TEST_LOCK; coins+Seeds+Unlock na svakoj next-lock free (Frost/Lantern/Amber); Ember paid ostaje lock; sequential can_unlock_free."
---

# IDEJE — HOME-09 Unlock gate na svakoj next-lock free sezoni

> [[ideje-home-cardfit|hub]]. Widget, parent, sivo→primary i Seeds = T3 **ostaju** iz [[ideje-home-incard-gate|HOME-08 gate]]. **Kod CARDFIT-A ✅** — Amber više nije TEST_LOCK.

## Što je krivo (nije clip, nije „nije implementirano“)

INCARD-B je premjestio gate u `CenterSlot/CenterFill`. Playtest: „prva zaključana free sezona treba progres bar na svom prozoru i Unlock koji nije clickable dok se ne skupi, pa ispunjen i clickable.“ To **jest** ponašanje `season_unlock_gate.gd` — **ako** sezona smije biti u hero-centru.

U saveu gdje su Country Bloom, Frost Orchard i Lantern Meadow **playable**, `next_locked_free_id()` vraća `amber_canopy`. Amber je `TEST_LOCK_FREE_ID`:

| Poziv | Amber danas | Posljedica |
|-------|-------------|------------|
| `is_test_locked_season` | `true` | — |
| `is_season_playable` | `false` (TEST_LOCK prije `unlocked_seasons`) | Ne možeš Play na Amber |
| `is_free_selectable` | `false` (TEST_LOCK prije next-lock) | Swipe bounce, nikad u centru |
| `can_unlock_free` | `false` (TEST_LOCK prva linija) | Gumb nikad primary |
| `refresh_gate` | `is_free_selectable` fail | `visible = false` |

Zato izgleda kao da agent „nije napravio“ INCARD-B. Gate je na Lanternu. Lantern je već otključan. Amber je sljedeća, a Amber je ugašena.

P84 je to namjerno uradio: zadnja free (Amber) i zadnja paid (Ember) ostaju locked za test bounce/IAP. Playtest sada kaže: **napravi Unlock UI za svaku trenutno zaključanu sezonu, npr. Amber Canopy.** To je P104.

## Tko vidi gate (P103)

Isti parent kao HOME-08: child `%CenterSlot` / `CenterFill`, donji **desni** kut, `z_index` iznad rostera (P110).

**Vidi se kad su svi:**

1. `home_band != "paid"` (free je hero), **i**
2. hero-centar = `next_locked_free_id()`, **i**
3. `is_free_selectable(hero_id)` — sada **uključuje Amber** kad je ona next, **i**
4. `not is_season_playable(hero_id)`.

Nije vezano za hardkodirani `lantern_meadow`. Koja sezona nosi gate ovisi o saveu:

| Save | Next-lock free | Gate na |
|------|----------------|---------|
| Novi igrač (samo Bloom) | `frost_orchard` (80c / 5 T3) | Frost prozor kad je Frost u centru |
| Debug skip Lantern, Frost playable | `lantern_meadow` (150c / 8 T3) | Lantern prozor |
| Bloom+Frost+Lantern playable (ovaj playtest) | `amber_canopy` (220c / 12 T3) | **Amber prozor** |
| Sve free playable | `""` | Gate hidden |

**Ne vidi se:** playable centar (Bloom dok je Bloom odabran); paid-hero; preview 20%; L/R side kartice; sezona koja **nije** next-lock (further — npr. Amber dok Lantern još locked: bounce, nema gatea na Amber). Sequential ostaje (P106).

## Amber više nije TEST_LOCK (P104)

U [`game_state.gd`](../../game/scripts/autoload/game_state.gd):

- `TEST_LOCK_FREE_ID := "amber_canopy"` prestaje ulaziti u `is_test_locked_season`.
- `is_test_locked_season` ostaje **samo** `ember_fen` (P105), ili ekvivalent: `season_id == TEST_LOCK_PAID_ID`.
- `is_free_selectable(amber)` = true kad je Amber `next_locked_free_id()` (Lantern playable).
- `can_unlock_free(amber)` = true kad je prethodna free (`lantern_meadow`) u `unlocked_seasons` **i** `wallet_coins >= 220` **i** `t3_flower_count() >= 12`.
- `unlock_free(amber)` troši 220c, append, `active` + strip na Amber, gate nestaje.

Troškovi ostaju iz [`seasons.json`](../../game/data/seasons/seasons.json) — ne hardkodirati 220/12 u UI; čitati `def.coins_cost` / `def.t3_flowers_required` kao sad.

Swipe L/R na Amber: **ne** bounce ako je next-lock. Further (npr. ako ikad bude 5. free) i dalje bounce.

## Ember ostaje paid TEST_LOCK (P105)

`ember_fen` — paid, `coins_cost` 0, IAP. `is_test_locked_season` da. `grant_paid_season` no-op. Shop/Browser IAP. Roster u paid-hero prozoru **da** (HOME-08). Coin Unlock **ne**. Fair F2P: ne prodavati Ember za coins.

Moonlit / Coral / Starfall unowned: roster da, gate ne (P113). IAP ostaje Shop.

## Sequential (P106)

`can_unlock_free` već ima:

```
prev_id := SeasonCatalog.previous_free_id(def)
if not prev_id.is_empty() and not unlocked_seasons.has(prev_id):
    return false
```

To ostaje. Ne skačeš Amber prije Lanterna. Gate na Amber postoji **samo** kad je Amber next-lock (Lantern već playable). „Svaka trenutno zaključana“ u **ovom** saveu = Amber. U saveu gdje je samo Bloom playable = Frost. Nije „sve locked kartice odjednom imaju klikabilan Unlock“.

## Stanja gumba (ostaje P97)

| Resursi | Izgled | Input |
|---------|--------|--------|
| `not can_unlock_free` | `disabled`, `button_variant = "subtle"` (sivo, prazno) | `MOUSE_FILTER_IGNORE` — swipe prolazi |
| `can_unlock_free` | `disabled = false`, `button_variant = "primary"` (ispunjeno bojom) | `MOUSE_FILTER_STOP` — tap `unlock_free` |

Trake: **Coins** `wallet_coins / def.coins_cost`; **Seeds** `t3_flower_count() / t3_flowers_required` (P98). Na Amber: 220 / 12.

`_ignore_hits(strip_motion)` rekurzivno IGNORE-a djecu. `refresh_gate` **mora** vratiti STOP na gumb **nakon** svakog refresh/morph kad `can` — inače INCARD-B gumb ostane mrtav. To nije novi feature; to je uvjet da P97 stvarno radi.

## Debug skip (P111)

`debug_unlock_all_seasons` i dalje **ne** dodaje:

- `lantern_meadow` (`DEBUG_SKIP_FREE_ID`)
- `amber_canopy` (eksplicitni skip, više ne preko TEST_LOCK)
- `ember_fen` (TEST_LOCK paid)

Editor playtest: Bloom+Frost playable, Lantern next-lock, gate na Lanternu. Korisnikov postojeći save s Lanternom playable: Amber next-lock, gate na Amberu. Oba puta postoji locked free kartica s trakama.

Ne grantati Amber kroz debug. Ne grantati Ember.

## Layout gatea (P110)

Ostaje donji desni kut `CenterFill`. `z_index` iznad `FreeRoster` (roster je širi u B — smiju se vizualno dodirivati, gate crta na vrhu). `clip_contents` na `CenterSlot` ostaje. Gate panel `MOUSE_FILTER_IGNORE` osim gumba.

Kontrast okvira gatea prati roster (P108) — CARDFIT-B, ne A. U A samo logika + vidljivost; tamni okvir smije ostati dok B ne oboji.

## Što ne dirati u CARDFIT-A

- Naslov gore vs sredina (B / P107)
- Roster širina i per-season boja (B)
- Band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, `seed_type_ids`
- 48 stubova, HIT-A IGNORE na rosteru
- `season_unlock_sheet` fallback; Stage i dalje ne otvara sheet za next-lock (P85)

## Tehnički (za CARDFIT-A, ne P0 kod)

- [`game_state.gd`](../../game/scripts/autoload/game_state.gd): `is_test_locked_season` bez Amber; `debug_unlock_all` skipa Amber po id-u.
- [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd): uvjeti ostaju next-lock + selectable + not playable — Amber sad prolazi. Brojevi iz `SeasonDef`.
- [`season_browser.gd`](../../game/scripts/ui/season_browser.gd) / shop: Amber više nije test-lock no-op; next-lock → Home fokus (P85). Ember i dalje test-lock.
- Smokes [`season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd), [`season_unlock_smoke.gd`](../../game/scripts/dev/season_unlock_smoke.gd): **obrnuto** od HOME-07 — Amber **jest** selectable kad je Lantern playable; `can_unlock_free(amber)` da s 220c/12 T3; Ember i dalje locked; Coral bez coin gatea; gate i dalje dijete `CenterSlot`.
- Headless OpenGL. `godot-run.ps1` jednom na kraju A, ne watcher.

## Acceptance

- Save Bloom+Frost+Lantern playable: swipe na Amber **ne** bounce; Amber u centru; **u narančastom/jantar prozoru** Coins `n / 220`, Seeds `n / 12`, Unlock sivo ako nema resursa.
- Bez 220c/12 T3: Unlock nije clickable; swipe L/R radi.
- S resursima: gumb ispunjen bojom; tap grant-a Amber; gate nestaje; `active_season_id` Amber.
- Debug skip (nema Lanterna u unlocked): cycle na Lantern i dalje pokazuje 150/8 + Unlock — nije hardkodirano samo Amber.
- Paid Coral: roster da, **nema** Unlock.
- Ember: i dalje TEST_LOCK; nema coin Unlock; debug ga ne grant-a.
