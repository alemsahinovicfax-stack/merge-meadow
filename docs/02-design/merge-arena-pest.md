---
type: dizajn
status: aktivan
milestone: v1.1
tags: [dizajn, mehanika, merge, arena, pest]
povezano:
  - merge-arena-v1.1
  - ideje-kad-predloziti
  - verzije-nakon-launcha
ai_sažetak: "MA-01b — Muncher pest u Merge Areni: spava, budi se na pour, jede T1/T2, freeze na T3."
---

# Merge Arena — Muncher pest (MA-01b)

> **Status:** implementirano u kodu v1.1 paket (2026-07-29). Dio UX-04 + MA-01 bundlea.

## Sažetak

Mali **Muncher** (štetočina livade) dodaje pritisak u Merge Areni: spava u sredini playfielda (od 2026-10-16; ranije na vrhu), probudi se kad igrač izbaci sjemena iz vrećice, jede T1/T2 s polja, i zamrzne se 2 s kad igrač napravi T3 merge.

## Pravila

| # | Pravilo |
|---|---------|
| 1 | Spava na **nestu** (sredina playfielda, od 2026-10-16) dok nema chipova na polju |
| 2 | **Pour** s barem 1 chipom → wake delay → hunting |
| 3 | Jede **T1 i T2** na playfieldu (ne bag, ne inbox, ne T3). Uvijek ide na sjemenku koja mu je **sada najbliža**: cilj se bira svakih 0,25 s, a mijenja se kad je druga bliža bar 24 px (od 2026-10-16; ranije je zaključao prvu metu). Sjemenku koju igrač drži ne lovi |
| 4 | Polje prazno → spava **gdje je stao / pojeo zadnje sjeme** |
| 5 | Sljedeći pour → budi se s sleep spot-a |
| 6 | **T3 merge** → freeze 2 s |
| 7 | Exit arena → reset na nest |

## Konstante

Vidi `GameState.ARENA_PEST_*` i [`ekonomija-brojevi.md`](ekonomija-brojevi.md).

## Kod

| Asset | Svrha |
|-------|--------|
| `game/scripts/camp/arena_pest.gd` | State machine + draw |
| `game/scripts/camp/merge_arena_controller.gd` | Hookovi pour/merge/eat |

## Povezano

- [[merge-arena-v1.1|merge-arena-v1.1]] — MA-01 arena
- [[../06-production/ideje-kad-predloziti#ux-04--hub-carousel-clash-royale-meta--ideja-2026-07-05|UX-04 hub carousel]]
