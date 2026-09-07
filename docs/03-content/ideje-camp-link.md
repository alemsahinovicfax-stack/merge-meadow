---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, flowers, sezone, scratch]
povezano:
  - ideje-camp-link-pitanja
  - ideje-camp-link-grupe
  - ideje-camp-link-chrome
  - ideje-camp-link-flowers
  - ideje-camp-link-season
  - ideje-camp
  - ideje-camp-cliff
  - ideje-home-meadow-field
  - plan-prompts-home-camp-field
  - CHECKPOINT
ai_sažetak: "CAMP-03 hub — A–C ✅; override 2026-09-03: scroll 280; kartica nav, Unlock delay spend."
---

# IDEJE — Kamp link (CAMP-03 hub)

> **ID:** **CAMP-03** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **CAMP3-A ✅** **CAMP3-B ✅** **CAMP3-C ✅**. Docs **CAMP3-P0 ✅**. Prompti: [[../06-production/plan-prompts-home-camp-field|plan-prompts-home-camp-field]] **CAMP3-P0 ✅ → A ✅ → B ✅ → C ✅**. Grupe: [[ideje-camp-link-grupe|grupe]].  
> **Prethodnik:** [[ideje-camp|CAMP-01]] A ✅ B ✅; [[ideje-camp-cliff|CAMP-02]] P0 ✅ — **CAMP2-A superseded** (C21 upija CAMP3-A).  
> **Ovisi o:** [[ideje-home-meadow-field|HOME-16]] **FIELD-D** (kamp UpgradeCards već hidden).  
> **Nasljednik:** [[ideje-camp-read|CAMP-04]] — scroll 280 / uski Unlock / chip 68 **superseded**.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — coins + ★3 cvijeće, ne IAP. Kartica = Home locked poster. Unlock gumb (kad može) = Home + delay + `unlock_free`.

## Pitch

Kamp je **Seeds + Flowers + svijest o sljedećoj free sezoni**. Naslovi su samo **Seeds** / **Flowers** — nema cliff poruke, nema `Seeds: 0/40`, nema `Flowers: n`. Flowers se ponaša kao Seeds (rarity boje, auto-select za Exchange). Scrollovi **280**. Treća kartica iste visine pokazuje **zaključanu free sezonu** (barovi + Unlock) u bojama te sezone. Tap na karticu vodi na Home locked poster. Unlock gumb (kad `can_unlock_free`) ide na Home, pa nakon ~0.4 s zove `unlock_free`.

## Zašto sada

CAMP-02-A nije urađen: GardenCliff i dalje gurа „Bag seeds are…“. BagLabel i CrystalTotalLabel ponavljaju naslov. Flowers chipovi su bijeli, bez auto-selecta poslije deplete. Igrač u kampu ne vidi dokle je do sljedeće sezone.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| GardenCliff + `Seeds: n/40` | Samo naslov **Seeds** pa grid |
| `Flowers: n` + bijeli chipovi | Samo **Flowers**; rarity bg; auto-select kao Seeds |
| Scroll 220 px | **280** px oba jednako |
| Nema sezonskog progresa u kampu | Kartica = nav na locked poster; Unlock gumb = delay + spend |

## Što CAMP-03 **jest**

- Override C7/C21: GardenCliff hidden + prazan **i** BagLabel / CrystalTotalLabel hidden.
- Flowers parity sa Seeds (vizual + select FSM).
- Scroll visina **280**.
- Nova kartica next-lock; kartica = nav; Unlock gumb = Home delay spend.

## Što CAMP-03 **nije**

- Shop IAP, AdMob, leftover/vacuum, `SAVE_VERSION`, Unlock JSON rewrite.
- Magnet/Loot UI (FIELD-D). Ne vraćati `%UpgradeCards`.
- Paid sezone na ovoj kartici.
- HOME-16 Daily/picker/swipe kod.

## Agent

- Seeds/Flowers chrome +10% → **CAMP3-A ✅**.
- Flowers = Seeds → **CAMP3-B ✅**.
- Next-lock kartica → **CAMP3-C ✅**.
- Ne spajati A s FIELD-D. Ne spajati s CAMP-01 kod promptima.

## Paket

| Doc | Što |
|-----|-----|
| ovaj hub | pitch + override |
| [[ideje-camp-link-chrome\|chrome]] | naslovi, hide counts, +10% (A) |
| [[ideje-camp-link-flowers\|flowers]] | rarity + auto-select (B) |
| [[ideje-camp-link-season\|season]] | next-lock kartica (C) |
| [[ideje-camp-link-pitanja\|pitanja]] | C22–C34 |
| [[ideje-camp-link-grupe\|grupe]] | A–C mapa |
| [[../06-production/plan-prompts-home-camp-field\|prompti]] | copy-paste |

## Povezano

- [[ideje-camp|CAMP-01]] · [[ideje-camp-cliff|CAMP-02]] · [[ideje-home-meadow-field|HOME-16]]
- [[../06-production/plan-prompts-home-camp-field|prompti]] · [[CHECKPOINT|CHECKPOINT]]
