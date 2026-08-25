---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, roster, unlock, sezone, scratch]
povezano:
  - ideje-home-incard
  - plan-prompts-home-incard
  - ideje-home-unlock-pitanja
  - ideje-home-cardfit-pitanja
ai_sažetak: "HOME-08 pitanja P92–P102 — roster/gate u hero-centar prozoru; veličina; Lantern lock vizual."
---

# IDEJE — HOME-08 pitanja (P92–P102)

> [[ideje-home-incard|hub]]. P1–P91 ostaju osim HOME-07 layouta (Stage overlay). Freeze 2026-08-20.  
> **Chrome korekcija:** [[ideje-home-cardfit-pitanja|P103–P114 HOME-09]] — P100 naslov gore overridean (sredina); P84 Amber TEST_LOCK overridean; P90 frame po sezoni.

P81–P91 (select, bounce, next-lock, lantern debug skip, T3 progres, 48 stubova, paid bez coin Unlock, run seed_type_ids) **ne dirati**. Ovdje samo **gdje** i **koliko veliko**.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P92** | Gdje roster? | Child **hero-centar** slota (`CenterSlot` free-hero, `PaidCenterSlot` paid-hero). Donji **lijevi** kut **tog** panela. `clip_contents`. **Ne** Stage overlay. |
| **P93** | L/R i preview? | Side kartice i 20% preview **bez** rostera/gatea. Kad sezona dođe u hero-centar, njen roster se pojavi u tom prozoru. |
| **P94** | Koliko veliko? | Ikona **~52px**, ime font **~22**, zvijezde **~18**, red **~56px**. Tamni okvir ostaje. Cijeli roster `IGNORE`. |
| **P95** | Paid? | Isti roster u paid hero-centru. **Nema** coin Unlock (P54/P89). |
| **P96** | Gdje gate? | Child **istog** free hero-centar panela, donji **desni** kut (ne prekriva roster). Samo `next_locked_free_id()` i nije TEST_LOCK. |
| **P97** | Unlock gumb? | Dok `not can_unlock_free`: sivo/subtle, `disabled`, `IGNORE`. Kad može: primary (ispunjeno), `STOP`, tap `unlock_free`. |
| **P98** | „Sjemena“? | UI label **Seeds** = `t3_flower_count()` / `t3_flowers_required`. Nije seed bag (P86). |
| **P99** | Lantern locked? | P84 ostaje (debug skip; `can_unlock_free` da; Amber/Ember TEST_LOCK). Na Lantern **prozoru**: 🔒 + roster + gate. |
| **P100** | Naslov sezone? | Gore na kartici, centriran. Roster/gate ne prekrivaju ime. |
| **P101** | L/R pretapanje? | HOME-06 in-place ostaje. Roster/gate su djeca slota pa se pretapaju s karticom. |
| **P102** | Run spawn? | `seed_type_ids` **ne dirati**. 48 roster id-eva ostaju Home katalog. |

## Nije otvoreno (namjerno)

- Follow-finger, wrap, band 20/80, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager.
- Coin Unlock na paid.
- Roster na uskim L/R karticama (premalo; P93).
- Mijenjanje 48 imena / rarity rasporeda (HOME-07 tablica).

## Povezano

- [[ideje-home-unlock-pitanja|P81–P91]]
- [[ideje-home-cardfit-pitanja|P103–P114]]
- [[../06-production/plan-prompts-home-incard|prompti]]
