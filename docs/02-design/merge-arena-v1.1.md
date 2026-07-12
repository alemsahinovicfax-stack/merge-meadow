---
type: dizajn
status: aktivan
milestone: v1.1
tags: [dizajn, mehanika, merge, kamp, retention]
povezano:
  - mehanike/merge-kamp
  - ekonomija-brojevi
  - core-loop
  - verzije-nakon-launcha
  - ideje-gameplay-ekonomija
ai_sažetak: "Odobren v1.1 redesign — gredice zamijenjene Merge Arenom (magnet drag, bloom traka); daily goals kao prošireni chest."
---

# Merge Arena + Daily Goals (v1.1)

> **Status:** implementirano u kodu **2026-07-12** (MA-01 faza 1–3). Gredice uklonjene; kamp = hub + **Merge Arena** scena.

## Problem (zašto)

| Bol | Uzrok |
|-----|--------|
| Prenatrpanost slotova | Fiksni grid (9–12 gredica) vs rastući broj tipova sjemena |
| Spor / nejasan merge | Slotovi + auto-plant + nasumična sadnja (djelomično riješeno pair-first patchom) |
| T2/T3 „zaglavljuju“ | Donate maxed → jedini izlaz Keep, ali grid i dalje pun |
| Loša preglednost | Torba = agregat „seeds“ bez jasnog flowa |

## Odluke (potvrđeno)

| # | Tema | Odluka |
|---|------|--------|
| 1 | Gredice vs arena | **Zamjena** — sav merge u novom prozoru; kamp = hub |
| 2 | Input | **Magnet drag + snap** — povučeš sjeme, privlači najbliže istog tipa, snap → merge |
| 3 | Output mergea | **Hibrid + tap spend** — T1 ostaje u areni; T2/T3 u donju traku |
| 4 | Donate / Keep / upgradei | **Donja traka (Bloom inbox)** — tap: Donate · Keep → Album · Basket |
| 5 | Ulaz u arenu | **Oboje** — nakon runa predložak „Merge your loot!“ (skip OK); stalni gumb u kampu |
| 6 | Daily goals | **Prošireni daily chest** — 3 mini-zadatka + bonus; **v1.1**, ne launch |

---

## Core loop (cilj)

```
Run (lane) → Loot → [Merge Arena] → Kamp hub → Play / Shop
                      ↑ rasuta T1
                      ↓ T2/T3 → Bloom traka → Donate | Keep | Basket
```

Kamp hub zadržava: **Play**, **Shop**, **upgrade kartice** (Sprinkler, Loot Boost), **daily chest**, **wallet**, **Album/Almanac** — **bez merge grida**.

---

## Merge Arena — UX spec

### Layout (portrait)

```
┌─────────────────────────────┐
│ ← Kamp    Wallet   Settings │
├─────────────────────────────┤
│                             │
│   ○  ○      ○               │  ← T1 rasuta (physics-lite)
│      ○  ○        ○          │     max N objekata na ekranu
│                             │
├─────────────────────────────┤
│ Bloom inbox: [T2 Daisy] [T3 Clover] … │  ← horizontal scroll
├─────────────────────────────┤
│  Done · Sort by type (opt)  │
└─────────────────────────────┘
```

### Magnet drag + snap

1. **Tap seed bag** (donji centar) — izbaci sjeme u arenu (do **40** na polju); ponovni tap dopunjava praznine.
2. Vrećica **otvorena + wiggle** kad ima **≥2** sjemena u torbi; prazna/zatvorena kad je torba prazna.
3. **Touch down** na chip → drag; **magnet** privlači isti tip+tier u radiusu `ARENA_MAGNET_RADIUS`.
4. **Release** unutar snap distance → merge; **T1+T1 → T2** ostaje u areni; **T2+T2 → T3** u Bloom inbox.

**Feel:** brže od grid tap-a, zabavnije od čistog menija; mobile-first (jedan prst).

### Tier pravila

| Tier | U areni | Nakon mergea |
|------|---------|--------------|
| T1 | Da, rasuto | 2× T1 → 1× T2 u areni **ili** odmah u Bloom traku (vidi balans) |
| T2 | Kratko u areni OK | **Preporuka:** odmah u Bloom traku (ne zauzima prostor) |
| T3 | Ne u areni | Samo Bloom traka |

**Preporuka za implementaciju:** T2+ **nikad ne ostaje** na playfieldu — čim nastane T2/T3, fly animacija u inbox. Arena = isključivo T1 merge playground.

### Bloom inbox (tap spend)

| Akcija | Efekt |
|--------|--------|
| **Donate** | T2 → Sprinkler progress; T3 → Loot Boost progress (isto kao danas) |
| **Keep → Album** | Kolekcija + almanac tier; ukloni iz trake |
| **Basket** | Postavi loadout tip za sljedeći run (+5% spawn) |
| **Long-press** | Preview tip + tier (accessibility) |

Kad su upgradei maxed, Donate disabled — ista poruka kao danas: „use Keep“.

### Ulaz u scenu

| Trigger | Ponašanje |
|---------|-----------|
| Nakon runa (To Camp) | Ako `sum_seed_bag > 0`: overlay „Merge your loot!“ → Arena; **Skip** → Kamp hub |
| Kamp gumb **Merge** | Uvijek; učitava trenutni `seed_bag` u arenu |
| Daily chest / shop seeds | Dodaju u bag; ne otvaraju arenu automatski |

### Staklenik / ★★★ (mythic)

**Preporuka (do playtesta):** ista Arena, **vizualni filter** — mythic T1 imaju zlatni outline; merge samo mythic↔mythic istog tipa. Nema zasebnog grid-a.

---

## Kamp hub (nakon zamjene)

Ukloni: `camp_bed` grid, auto-plant na gredice, seed chips za sadnju.

Zadrži / premjesti:

| Element | Gdje |
|---------|------|
| Play | Sticky footer |
| Merge | Primary CTA pored Play ili iznad |
| Shop, Settings, Home | Header |
| Sprinkler / Loot Boost | Upgrade kartice |
| Daily chest | Header ili kartica |
| Album | Shop ili zaseban gumb (postojeći almanac) |
| Basket loadout | Post-merge u Bloom traci **ili** mali widget u hubu |

---

## Daily Goals (DG-01) — prošireni chest

**Ne blokira run** (Pillar 2). **Jedan claim** dnevno za bonus paket.

### Struktura

- **3 zadatka** generirana u ponoć (local day, isti key kao `last_daily_chest_day`).
- Svaki zadatak: **tip + target + progress** (persist u save v5+).
- **Bonus reward** kad su sva 3 ✅: coins + mali seed paket (unlocked tipovi only).

### Primjeri generatora (skalirano na unlock)

| Faza | Zadatak A | Zadatak B | Zadatak C |
|------|-----------|-----------|-----------|
| Rano | Collect 10 coins (run) | Pick up 5 seeds (run) | Merge 1× T2 (arena) |
| Mid | Collect 20 coins | Collect 3× [random unlocked type] | Donate 1 bloom |
| Kasno | Reach 1× T3 (arena) | Complete 2 runs | Keep 1 bloom to Album |

### UI

- Ista kartica kao daily chest → proširi u **3 reda + progress bar + „Claim bonus“**.
- Ne duplicirati poseban ekran (MVP).

### Reward (draft brojke — balans u playtestu)

| | Vrijednost |
|---|------------|
| Per-task micro | +2 coins (instant, opcionalno) |
| Bonus (3/3) | +8 coins + 3 seeds (random unlocked) — usklađeno s `DAILY_CHEST_*` |

---

## Tehnički plan (Godot)

### Nove scene / skripte

| Asset | Svrha |
|-------|--------|
| `scenes/camp/merge_arena.tscn` | Root arena |
| `scripts/camp/merge_arena_controller.gd` | Spawn, drag, magnet, merge resolve |
| `scripts/camp/arena_seed_chip.gd` | Jedno sjeme (type, tier, touch) |
| `scripts/camp/bloom_inbox_row.gd` | Donja traka T2/T3 |
| `scripts/camp/bloom_inbox_item.gd` | Tap Donate/Keep/Basket |

### `GameState` promjene (v1.1)

- `spawn_arena_from_bag()` — bag → lista `{type_id, tier}` chipova
- `commit_arena_to_bag()` — preostali T1 natrag u bag (cap `CAMP_BAG_SOFT_CAP`)
- `push_bloom_to_inbox(type_id, tier)` — traka umjesto bed state
- **Deprecate:** `garden_beds`, `greenhouse_beds`, `auto_plant_from_bag`, `plant_seed_in_bed` (migracija save v4→v5)
- **Zadrži:** `seed_bag`, donate counters, `collection_kept_tiers`, loadout, almanac

### Save migracija v4 → v5

1. T1 u bag ostaje bag.
2. T2/T3 na gredicama → konvert u **inbox queue** ili auto-Keep (jednokratno, friendly).
3. Prazne gredice → drop.

---

## Faze implementacije

| Faza | Scope | Effort | Gate |
|------|--------|--------|------|
| **0** | Ovaj doc + v1 launch s trenutnim kampom | — | ✅ |
| **1** | Arena MVP: T1 only, magnet merge, bag sync | **L** | v1.1.0 |
| **2** | Bloom inbox + Donate/Keep/Basket | **M** | v1.1.0 |
| **3** | Post-run prompt + hub CTA; ukloni stari grid | **M** | v1.1.0 |
| **4** | Daily Goals (3 task + bonus) | **M** | v1.1.1 |
| **5** | Mythic vizual + polish VFX/SFX | **S–M** | v1.1.x |

**Launch blocker:** ništa od gore — v1 shipa s pair-first kampom.

---

## Balans konstante (draft — `ekonomija-brojevi.md` kad implement)

| Konstanta | Draft | Napomena |
|-----------|-------|----------|
| `ARENA_MAX_CHIPS` | 24 | T1 na ekranu; višak ostaje u bag |
| `ARENA_MAGNET_RADIUS` | 120 px | @ 1080×1920 ref |
| `ARENA_SNAP_DISTANCE` | 48 px | |
| `BLOOM_INBOX_MAX` | 12 | soft cap; toast „inbox full — Keep or Donate“ |

---

## Test plan (DoD v1.1)

- [ ] 20× T1 različitih tipova — merge bez FPS dropa
- [ ] Merge lanac T1→T2→T3 bez grid overflow buga
- [ ] Donate/Keep iz inboxa ažurira upgrade + album
- [ ] Skip nakon runa → kamp OK, bag netaknut
- [ ] Save v4 migracija na postojećem saveu
- [ ] Daily 3/3 bonus jednom dnevno
- [ ] Tutorial update (CAMP koraci → Arena, ne gredice)

---

## Otvoreno (sljedeći playtest)

- [ ] T2 odmah u inbox vs kratko u areni — koji feel bolji?
- [ ] „Sort by type“ gumb — potreban ili sufliranje dovoljno?
- [ ] Interstitial na izlazu iz Arene (monetizacija) — **ne** na launch v1.1 bez A/B

---

## Povezano

- [[mehanike/merge-kamp|merge-kamp]] — **trenutni** kanon (v1)
- [[ekonomija-brojevi|ekonomija-brojevi]]
- [[../06-production/verzije-nakon-launcha|verzije-nakon-launcha]]
- [[../03-content/ideje-gameplay-ekonomija|ideje-gameplay-ekonomija]] — MA-01, DG-01
