---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, sjeme, pitanja, scratch]
povezano:
  - ideje-seed-pool
  - plan-prompts-seed-pool
  - ideje-home-meadow-pitanja
ai_sažetak: "SEED-01 pitanja S1–S16 — jedan type_id; Bloom CHAIN ostaje; journal katalog; fallback T1–T3; pour katalog; nema SAVE_VERSION."
---

# IDEJE — SEED-01 pitanja (S1–S16)

> [[ideje-seed-pool|hub]]. Freeze **2026-09-01**.

| # | Pitanje | Odluka |
|---|---------|--------|
| **S1** | Dva namespacea (roster vs seed_type_ids)? | **Jedan.** `seed_type_ids` = merge tipovi. Roster id = isti string. |
| **S2** | Country Bloom 7? | **Ostaju** clover…watermelon. CHAIN + `seed_unlock_index` samo za njih. |
| **S3** | Ostale sezone? | `seed_type_ids` = postojeći `roster[].id` (6). Frost = frost_snowdrop…crystal_peony, itd. |
| **S4** | Spawn u runu? | `get_active_season_spawn_types()` = pool **aktivne** sezone. Sezona playable ⇒ tipovi smiju spawnati (ne čekaju Bloom CHAIN). |
| **S5** | Paid sjeme jače? | **Ne.** Fair F2P: tema, isti magnet/loot. Rarity za exchange vizual, ne pay-to-win. |
| **S6** | SeedCatalog? | Da. `all_type_ids()` stabilni red; `season_id_for`; display_name; rarity. `SEED_DISPLAY_NAMES` čita katalog. |
| **S7** | Journal? | `get_collection_journal_entries` iterira **katalog**, ne samo CHAIN. Stanja locked/seen/album T2/T3 ostaju. |
| **S8** | T1 T2 T3 art? | `draw_plant(type, tier)` za **svaki** id. Explicit paleta gdje postoji; inače **fallback** hash+rarity. Nikad clover default za frost id. |
| **S9** | Arena chip? | Isti draw. Ne fork `ArenaSeedChip` po sezoni. |
| **S10** | Camp prodaja? | Bag/exchange po `type_id`. Labele iz kataloga. Ne novi IAP. |
| **S11** | SORT pour? | Red = `SeedCatalog.all_type_ids()` ∩ bag. Ne samo CHAIN 7. Ne dirati leftover/vacuum. |
| **S12** | SAVE_VERSION? | **Ne.** CHAIN se ne briše. |
| **S13** | Meadow? | HOME-12 B čita `seed_type_ids`. SEED ne crta SeasonField. |
| **S14** | 48 roster stubova? | Home roster **prikazuje** season `seed_type_ids` (6 ili 7), iste id-eve. Ne drugi katalog od 48 lažnih id-eva za merge. (Ako 48 stubova ostaju kao kozmetika bez mergea — **ne** u A; A = JSON + catalog alignment.) |
| **S15** | Milestone? | **v1.1+**. |
| **S16** | Što ne dirati? | Shop IAP, AdMob, Unlock 500/20, CAMP-01 spend, SAVE_VERSION, leftover/vacuum brojke, hub pager, 8 field scena. |

## Zašto

Roster je već imao karakteristična imena; run ih nije koristio. Ujedinjenje id-eva je jedini način da polje, arena i journal ne lažu.

CHAIN grind na 50+ tipova bi slomio Bloom progresiju i save clamp — zato CHAIN ostaje 7.

Fallback draw: inače svaki novi id zahtijeva match granu ili izgleda kao clover (bug).

## Otvoreno (preporuka)

1. Ime helpera: `SeedCatalog` u `game/scripts/seasons/` ili `progression/`.  
2. Rarity za roster JSON već postoji na roster retku — kopirati u catalog lookup.  
3. Journal UI grupa po `season_id` — opcionalno u B, nije blocker.  
4. S14: A **ne** briše 48 stubova ako su odvojeni od spawn; A **mora** da `seed_type_ids` = roster merge id. Ako roster ostane 48 a spawn 6, to je opet dva namespacea — **odbijeno**. A: roster liste u JSON za non-Bloom postaju identične spawn listi (već 6+6). Bloom roster 6 vs spawn 7: spawn 7 ostaje kanon; roster smije ostati 6 display stubova **samo ako** su subset spawn id-eva (meadow_clover ≠ clover = problem). **A freeze:** Bloom roster id-evi se **mapiraju ili preimenuje** na clover… ili roster dobije clover…watermelon. Preporuka: Bloom `roster[].id` postaju clover, daisy, … (display_name ostaje „Meadow Clover“ ako želiš copy). Jedan id.

## Nije otvoreno

- Dva id-a za isti cvijet. Paid snaga. SAVE_VERSION. CHAIN od 56. N field scena.

## Povezano

- [[ideje-seed-pool|hub]] · [[../06-production/plan-prompts-seed-pool|prompti]]
