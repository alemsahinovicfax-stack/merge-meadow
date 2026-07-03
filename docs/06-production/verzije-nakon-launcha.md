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

- Level generator (procedural) — već planirano “mjesec 2”
- Treći ljubimac (Bramble)
- `speed_merge_24h` IAP ([[../02-design/monetizacija|monetizacija]])
- Interstitial A/B na loot ekranu
- Daily push notifikacije (opt-in)
- Lokalizacija (HR, DE…)
- Više ljubimaca / cosmetic shop

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
