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
Meta Hub (main) — swipe/tabs: Shop · Journal · Home · Camp · Arena
    Home ──Play──► Run ──(finish/fail)──► Loot ──┬─ Double (×2, 1×)
    ▲                 ▲                            ├─ Revive → NASTAVI Run (1×)
    │                 │                            ├─ Retry → svjež Run
    └──────── Play ── Camp ◄──── To Camp ──────────┘
                     (upgrades + footer Merge/Play)
                         │
                         └──► Merge Arena (T1→T3, pest, bloom inbox)
```

Prijelazi idu kroz `GameState.go_to_*` / `SceneRouter`. Stanje između scena čuva **`GameState`** autoload.

---

## 0. Meta Hub

**Scena:** `scenes/meta/meta_hub.tscn` · **skripta:** `scripts/meta/meta_hub_controller.gd`

| Stranica | Indeks | Ugrađena scena |
|----------|--------|----------------|
| Shop | 0 | `shop_screen.tscn` |
| Journal | 1 | `collection_journal.tscn` |
| Home | 2 | `main_menu.tscn` |
| Camp | 3 | `camp_scene.tscn` |
| Arena | 4 | `merge_arena.tscn` |

- Swipe lijevo/desno ili tabovi; shared top bar prikazuje coin/seed ikone (`pickups/coin.png`, `pickups/seed.png`) + brojeve (bez riječi). Page ResourceBar skriven kad je stranica ugrađena u hub.
- Page dots (○/●) uklonjeni — navigacija preko tabova + caption.
- Ugrađene stranice imaju `meta_hub_embedded = true`; Back/Home gumbi skriveni gdje dupliciraju hub navigaciju.
- **Settings** gumb na hubu: placeholder poruka (puni ekran → D0-P).

**Gotovo kad:** sve 5 stranica učitava bez crasha; navigacija ne gubi stanje; Play iz Home/Camp pokreće run.

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

## 4. Camp (upgrades + seed bag)

**Scena:** `scenes/camp/camp_scene.tscn` · **skripta:** `scripts/camp/camp_controller.gd`

### Seed bag (ne grid slotovi)
- Run loot → `seed_bag` (Dictionary tip→count), soft cap **40**.
- **Garden kartica:** sažetak `Seeds: N/40` + **vizualni bag grid** (ikona + ime + broj po tipu s count > 0).
- **To Camp** na loot ekranu: `deposit_loot_to_camp()` → ako ima sjemena, **Merge Arena**, inače **Camp**.

### Kamp UI
- **Layout (D0-P / Bug-008 / Bug-012):** zone Daily → Garden (bag + seed trade) → Crystal stash → Upgrades → Run prep → Footer Merge/Play. Merge i dalje u Areni, ne na gridu.
- **Sprinkler (magnet):** donate T2 bloomovi → `magnet_level` (0–4), veći domet u runu.
- **Loot Boost:** donate T3 → `multiplier_level` (0–4), ×1.0–×2.0 u runu.
- **Exchange:** 3× isti tip iz baga → coins (Garden kartica, select tipa); crystal exchange: zasebna Crystal stash kartica (select tipa, 1→coins); seed trade ostaje u Garden kartici.
- **Daily chest**, **loadout basket** (1 slot, +5% spawn šanse).
- Footer: **Merge** → arena; **Play** → svjež run.

### Merge (Arena — §4b)
Merge T1→T2→T3 radi u **Merge Arena**, ne na gridu u kampu. Max tier = `MAX_MERGE_TIER` (3).

| Play | → svjež Run |
|------|-------------|

**Gotovo kad:** bag prima loot; upgrade donate radi; Merge/Play navigacija ispravna; status toast + Garden cliff vode igrača.

---

## 4b. Merge Arena

**Scena:** `scenes/camp/merge_arena.tscn` · **skripta:** `scripts/camp/merge_arena_controller.gd`

- Drag-and-drop chipovi iz **seed bag**; merge isti tip + tier → tier+1.
- **Pest** jede T1/T2; T3 freeze.
- **Bloom inbox:** Keep (album) / Donate (sprinkler/multiplier progress).
- Povratak → Camp hub stranica.

**Gotovo kad:** T1→T3 lanac radi; Keep/Donate ažuriraju album i donate brojače.

---

## 5. GameState (perzistentno stanje)

**Skripta:** `scripts/autoload/game_state.gd` (autoload `GameState`)

| Grupa | Varijable | Svrha |
|-------|-----------|-------|
| Loot | `last_loot`, `last_raw_orbs`, `last_failed`, `loot_doubled` | rezultat zadnjeg runa + double flag |
| Revive/resume | `revive_used_this_run`, `resume_pending`, `carry_orbs`, `carry_elapsed` | nastavak runa |
| Kamp | `seed_bag`, `magnet_level`, `multiplier_level`, `garden_crystals` | meta progres (bag + upgrades) |
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
