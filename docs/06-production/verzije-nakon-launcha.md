---
status: draft
tags: [produkcija, verzije, post-launch]
---

# Verzije nakon launcha

## Sažetak

**Parking lot** za buduće verzije — **ne detaljno planirati** prije M7 playtesta. Dovoljno znati što postoji da ne scope creepamo u v1.

## Verzije u projektu (definicije)

| Termin | Značenje | Milestone |
|--------|----------|-----------|
| **Greybox** | Prvi kod, lane run only | M6 |
| **Vertical slice** | Cijeli loop, polish, playtest | M7 |
| **v1 launch** | Store objava, 100 runova, shop | M8 |
| **v1.1+** | Mali updatei nakon launcha | Post-M8 |
| **Alpha / beta** | Test s javnošću prije production | Između M7 i M8 (opcionalno) |

RADIONICA-razvoj pokriva do **vertical slice (Faza 7)**. **Alpha, beta, puni launch** su u [[roadmap|roadmap]] i CHECKPOINT **Sekcija D**.

## Je li prerano planirati dalje verzije?

| Što | Prerano? | Kada planirati |
|-----|----------|----------------|
| v2, live ops, sezone | **Da** | Nakon launch metrika (D30 retention) |
| v1.1 popis ideja | OK kao lista | Nakon M7 playtesta |
| Mjesec 2 level generator | OK kao jedna rečenica | Već u [[scope-i-granice|scope]] |
| Alpha/beta proces | OK outline | Prije M8 (vidi [[testiranje|testiranje]]) |
| Sigurnost duboka | **Da** | v1 minimum u M8; ostalo post-launch |

## v1.1 — kandidati (ne obećavati u v1)

Iz OUT / “kasnije” liste — **samo ako launch uspije**:

### Prioritet A — odobreno 2026-07-11

| ID | Ideja | Effort | Doc |
|----|--------|--------|-----|
| **MA-01** | **Merge Arena** — zamjena gredica; magnet drag T1; Bloom inbox (Donate/Keep/Basket) | **L** | [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] |
| **MA-01b** | **Arena Muncher** — pest jede T1/T2, freeze 2 s na T3 | **M** | [[../02-design/merge-arena-pest\|merge-arena-pest]] |
| **UX-04** | **Hub carousel** — Shop · Main (centar) · Camp · Arena · Collection | **L** | [[../06-production/ideje-kad-predloziti\|ideje-kad-predloziti]] § UX-04 |
| **DG-01** | **Daily Goals** — 3 dnevna zadatka + bonus (prošireni daily chest) | **M** | isti doc § Daily Goals |

Redoslijed: **v1.1.0 paket (MA-01 + MA-01b + UX-04)** → **DG-01 (v1.1.1)**.

- Level generator (procedural) — već planirano “mjesec 2”
- Treći ljubimac (Bramble)
- `speed_merge_24h` IAP ([[../02-design/monetizacija|monetizacija]])
- Interstitial A/B na loot ekranu
- Daily push notifikacije (opt-in)
- Lokalizacija (HR, DE…)
- Više ljubimaca / cosmetic shop

### Run / lane polish (rezervisano 2026-07-07 — nakon v1 launch)

| ID | Ideja | Effort | Napomena |
|----|--------|--------|----------|
| R-P1 | Parallax pozadina (scroll s laneom ili ~80% brzine) | M | Dubina + kozmetika sa strane |
| R-P2 | Krtica — telegraph 1 s, peek animacija, statična kolizija | M–L | Blaga prepreka, safe fantasy |
| R-P3 | „New seed!“ toast gore (ikona + tekst) | S | `discovered_blooms` hook |
| R-P4 | Tematske staze (proljeće, holiday…) | L | v1 = Meadow; sezone v1.1+ |
| R-P5 | Unlock teme nakon završetka prethodne | M | Uz R-P4 |

**Ne kodirati** dok M8 Sekcija D nije ✅.

## v2+ — samo naslovi (bez rada)

- Battle pass
- Online leaderboard
- Cloud save + account
- Više kamp zona
- Collab / eventi

**Pravilo:** nova v1.1+ ideja → dodaj ovdje, **ne kodiraj** dok M8 nije ✅.

## Povezano

- [[scope-i-granice|scope-i-granice]]
- [[milestone-i|milestone-i]]
- [[CHECKPOINT|CHECKPOINT]]
- [[../05-technical/sigurnost|sigurnost]]
