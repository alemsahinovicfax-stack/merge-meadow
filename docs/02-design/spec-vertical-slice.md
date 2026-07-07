---
type: dizajn
status: aktivan
milestone: M7
tags: [dizajn, spec, vertical-slice, source-of-truth]
povezano:
  - gdd-overview
  - core-loop
  - ekonomija-brojevi
  - mehanike/_index
  - CHECKPOINT
ai_sažetak: "Source of truth za M7 slice — tačno ponašanje svakog ekrana/mehanike + kriterij 'gotovo'. Kod prati OVAJ dokument, ne obrnuto."
---

# Spec — Vertical slice (M7)

## Sažetak

Ovo je **jedan izvor istine** za ono što gradimo u M7. Za razliku od [[gdd-overview|GDD-a]] (vizija) i [[core-loop|core-loop]] (koncept petlje), ovdje piše **tačno šta svaki ekran radi, koja stanja ima i kad je "gotovo"**.

> **Pravilo rada:** prije kodiranja mehanike otvori ovaj spec. Kod **prati spec**. Ako igra treba raditi drugačije → prvo promijeni spec (+ [[../06-production/otvorena-pitanja|otvorena-pitanja]]), pa kod. Konkretne brojke → [[ekonomija-brojevi|ekonomija-brojevi]].

## Screen flow

```
Main Menu ──Play──► Run ──(finish/fail)──► Loot ──┬─ Double (×2, 1×)
   ▲                 ▲                            ├─ Revive → NASTAVI Run (1×)
   │                 │                            ├─ Retry → svjež Run
   └──────── Play ── Camp ◄──── To Camp ──────────┘
                     (merge + magnet upgrade)
```

Prijelazi idu kroz `GameState.go_to_scene()`. Stanje između scena čuva **`GameState`** autoload (jedini "mozak" izvan scena).

---

## 1. Main Menu

**Scena:** `scenes/main_menu.tscn` · **skripta:** `scripts/ui/main_menu.gd`

| Element | Ponašanje |
|---------|-----------|
| Play | → Run scena. Ako `tutorial_seen == false`, prvo `mark_tutorial_seen()`. |
| Tutorial hint | Vidljiv **samo** dok `tutorial_seen == false`. |

**Gotovo kad:** Play pokreće svjež run; hint nestaje nakon prvog Play.

---

## 2. Run (lane run)

**Scena:** `scenes/run/run_scene.tscn` · **skripta:** `scripts/run/run_controller.gd`, `player.gd`, `orb.gd`, `obstacle.gd`

### Stanja (`_state`)
- `0` = RUNNING (obrada teče)
- `1` = ENDED (guard — `_end_run` i `_process` ne rade ništa nakon kraja)

### Pokretanje — dva ulaza
| Ulaz | Kad | Ponašanje |
|------|-----|-----------|
| **Fresh run** | iz Menu / Camp / Retry (`resume_pending == false`) | `begin_fresh_run()` (reset revive), `elapsed = 0`, `orb_count = 0` |
| **Resume (revive)** | `resume_pending == true` | nastavi: `elapsed = carry_elapsed`, `orb_count = carry_orbs`, prepreke očišćene, igrač na centar lane |

### Pravila runa
- **Trajanje:** `RUN_DURATION` (vidi [[ekonomija-brojevi|brojevi]]) → istekne = **finish** (uspjeh).
- **Auto-scroll:** entiteti padaju prema dolje; brzina raste u koracima (ramp).
- **3 fiksna lanea** (25% / 50% / 75% širine). Swipe L/R = ±1 lane, s tween 0.12 s (ne teleport). Odluka: [[mehanike/lane-run|lane-run]].
- **Spawn:** na interval, uz šansu; svaki spawn je ili **orb** ili **prepreka**.
- **Orb pickup:** dodirom igrača **ili** magnet poljem. Orb ima `_collected` guard → skuplja se **tačno jednom**.
- **Magnet:** `MagnetField` (Area2D oko igrača) auto-skuplja orbove u dometu; **ne reagira na prepreke**. Domet = `get_magnet_radius()`, raste s `magnet_level` (kupljeno u kampu).
- **Fail:** sudar s preprekom → `_end_run(true)`.
- **HUD:** brojač orbova + preostalo vrijeme (sekunde).

### Kraj runa → `finish_run(orb_count, failed, elapsed)`
Sprema `carry_orbs`/`carry_elapsed` (za mogući revive) i računa `last_loot`:
- **finish (uspjeh):** `last_loot = orb_count` (100%)
- **fail:** `last_loot = round(orb_count × 0.5)` (50%, zaokruženo — 5 → 3)

**Gotovo kad:** timer i brojač rade; prepreka završava run; magnet skuplja u dometu i raste s levelom; fail = 50%, finish = 100%.

---

## 3. Loot ekran

**Scena:** `scenes/ui/loot_screen.tscn` · **skripta:** `scripts/ui/loot_screen.gd`

Prikaz: naslov (Failed/Complete), boja trake, `+N Coins/Seeds`, status s **X → Y** na failu.

| Dugme | Ponašanje | Uvjet |
|-------|-----------|-------|
| **Double** | `last_loot ×= 2`, jednom po ekranu (rewarded placeholder) | skriveno/disabled ako `loot_doubled` ili `last_loot ≤ 0` |
| **Revive** | **NASTAVI run** tamo gdje si stao (`request_revive()` → Run resume). Ne dira loot broj. | vidljivo **samo** ako `last_failed` **i** revive još nekorišten u ovom runu; max **1× po runu** |
| **Retry** | svjež run (`SCENE_RUN`, fresh) | uvijek |
| **To Camp** | deponuj loot u kamp → Camp scena | ako je kamp pun i ima loota: poruka "Camp full", ostani |

> **Revive semantika (bitno):** revive **nije** loot bonus. Vraća te u igru s istim orbovima i preostalim vremenom. Definirano i u [[core-loop|core-loop]] (fail state tablica).

**Gotovo kad:** Double udvostruči jednom; Revive vraća u run bez diranja broja i nestane nakon korištenja; Double+Revive se **ne miješaju** (nema skakanja broja); To Camp ispravno deponuje / javlja pun kamp.

---

## 4. Camp (merge + magnet)

**Scena:** `scenes/camp/camp_scene.tscn` · **skripta:** `scripts/camp/camp_controller.gd`

### Slotovi
- `CAMP_SLOT_COUNT` slotova (mreža). Deponovani loot puni prazne slotove kao **T1**, po jedan orb = jedan slot.
- Ako nema praznih slotova → loot ostaje na loot ekranu (poruka "Camp full").

### Merge
- Tap orb → selektiraj; tap drugi **isti tier** → merge: `T + T = T+1`, jedan slot se prazni.
- Max tier = `MAX_MERGE_TIER` (T2 u slice-u). T2+T2 se **ne** mergea (nema T3 u slice).
- Različiti tierovi ili prazan slot → nema merge (poruka).

### Magnet upgrade
- Trošak: `MAGNET_COST_T2` × T2 orbova → `magnet_level += 1`.
- Max level `MAGNET_MAX_LEVEL`. Efekt: veći pickup domet u sljedećem runu (`get_magnet_radius()`).
- Ekonomija mora biti **ostvariva** (dovoljno slotova da se skupi potreban T2) — vidi [[ekonomija-brojevi|brojevi]].

| Play | → svjež Run |
|------|-------------|

**Gotovo kad:** merge T1+T1=T2 radi i vizualno je jasan; magnet upgrade je dostižan i mijenja domet u runu; instrukcije u `info_label` vode igrača korak-po-korak.

---

## 5. GameState (perzistentno stanje)

**Skripta:** `scripts/autoload/game_state.gd` (autoload `GameState`)

| Grupa | Varijable | Svrha |
|-------|-----------|-------|
| Loot | `last_loot`, `last_raw_orbs`, `last_failed`, `loot_doubled` | rezultat zadnjeg runa + double flag |
| Revive/resume | `revive_used_this_run`, `resume_pending`, `carry_orbs`, `carry_elapsed` | nastavak runa |
| Kamp | `camp_slots[]`, `magnet_level` | meta progres |
| Ostalo | `tutorial_*`, `loadout_type_id` | onboarding + basket |

**Save (C1½ odluka 2026-07-05):** minimalni JSON `user://player_save.json` v1 — wallet, bag, kreveti, sprinkler, kolekcija, loadout, tutorial. **Ne** sprema run-in-progress (`last_*`, `carry_*`). Migracija iz `tutorial_flags.json`. Pun cloud/M8 save → F8.7.

> Debug `DEBUG_DEV_RESOURCES` samo kad **nema** save datoteke (prvi boot).

---

## Otvorene odluke (drže smjer jasnim)

- [x] Save na disk (JSON) u slice-u — **minimalni `player_save.json` v1** (M7); puni save F8.7
- [ ] Fluid swerve vs 3 lanea (playtest) → [[mehanike/lane-run|lane-run]]
- [x] % loota na fail (50%) — ostaje
- [x] Balans pass 1 — RUN 60 s post-tutorial; spawn/magnet bez promjene

## Povezano

- [[gdd-overview|gdd-overview]] — executive index
- [[core-loop|core-loop]] — petlja (koncept)
- [[ekonomija-brojevi|ekonomija-brojevi]] — sve konstante
- [[mehanike/_index|mehanike]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] — build order
